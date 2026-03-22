# Monitoring a High-Performance SSL Offloading Server

---

## Table of Contents

1. [What Does This Server Do?](#what-does-this-server-do?)
2. [The Server](#the-server)
3. [Interesting Metrics](#interesting-metrics)
4. [How I'd Set This Up](#how-id-set-this-up)
5. [Challenges](#challenges)

---

## What Does This Server Do?

**SSL offloading** means dedicating a server to handle TLS termination for incoming HTTPS connections. This server performs the handshake, decrypts the incoming request, and forwards plain HTTP to application servers behind it. On the way back, it encrypts the response before returning it to the client. This relieves application servers of TLS tasks, allowing them to focus on content delivery. The server also acts as a **reverse proxy** between the internet and backend servers, forwarding requests and responses.

---
## The Server

| Resource | Spec |
|----------|------|
| CPU | 4 × Intel Xeon E7-4830 v4 @ 2.00 GHz — **56 physical cores** (112 with hyperthreading) |
| RAM | 64 GB |
| Storage | 2 TB HDD (a traditional spinning hard drive, not an SSD) |
| Network | 2 × 10 Gbit/s NICs (network interface cards — the physical network ports) |
| Workload | ~25,000 HTTPS requests per second |

In this scenario, **CPU** is likely the first resource to reach capacity — the TLS handshake involves heavy public-key cryptography, and at 25k req/s that adds up fast. **Network** is the second concern at this traffic volume. For a proxy, **memory** and **disk** are not likely to bottleneck, but they are still worth keeping an eye on.

---
## Interesting Metrics

The table below summarises every metric worth tracking on this server. Detailed explanations follow.

| Category | Metric | Prometheus Metric |
|----------|--------|-------------------|
| **CPU** | Per-core utilisation | `node_cpu_seconds_total` |
| | Load average | `node_load1`, `node_load5`, `node_load15` |
| | SSL handshake rate / session reuse | `nginx_ssl_handshakes`, `nginx_ssl_session_reuses` |
| **Network** | Bytes in/out per NIC | `node_network_receive_bytes_total`, `node_network_transmit_bytes_total` |
| | Packet drops and errors | `node_network_receive_drop_total`, `node_network_transmit_errs_total` |
| | TCP retransmits | `node_netstat_Tcp_RetransSegs` |
| | Conntrack table usage | `node_nf_conntrack_entries`, `node_nf_conntrack_entries_limit` |
| **Memory** | Available memory | `node_memory_MemAvailable_bytes`, `node_memory_MemTotal_bytes` |
| | Connection count | `node_netstat_Tcp_CurrEstab`, `node_sockstat_TCP_tw` |
| **Disk** | Disk utilisation | `node_disk_io_time_seconds_total` |
| | Free space | `node_filesystem_avail_bytes` |
| **SSL/TLS** | Certificate expiry | `probe_ssl_earliest_cert_expiry` |
| | Handshake errors | `nginx_ssl_handshakes_failed` |
| **Proxy** | Request rate | `nginx_http_requests_total` |
| | Error rate (5xx) | `nginx_http_requests_total{status=~"5.."}` |
| | Latency percentiles | `nginx_http_request_duration_seconds_bucket` |
| | Active connections | `nginx_connections_active` |

System-level metrics are collected by **node_exporter** (a lightweight agent on port 9100). Proxy-level metrics come from the proxy's own exporter (e.g., nginx-prometheus-exporter or HAProxy's stats socket). Certificate checks use **blackbox_exporter**, which probes the endpoint from outside.

### CPU

TLS handshakes come in two forms: a **full handshake** on first connection (expensive, involves public-key crypto) and a **resumed session** that reuses a cached key (roughly 10x cheaper). The ratio between them directly controls CPU load — even at a constant 25k req/s, a drop in session reuse from 80% to 40% effectively doubles the handshake workload.

The key challenge with CPU on this server is that **aggregate utilisation is misleading**. With 112 threads, the average might show 15% while a single core is at 100%. This happens when **RSS (Receive Side Scaling)** — the kernel feature that spreads incoming packets across cores — isn't properly configured. One core ends up handling all NIC interrupts and becomes the bottleneck. The fix is to monitor `rate(node_cpu_seconds_total[5m])` per core (using the `cpu` and `mode` labels) and alert when any individual core exceeds a threshold, not just the average.

Load average (`node_load1/5/15`) is a useful secondary signal: consistently above 112 means the server is saturated.

### Network

Two failure modes exist at this traffic volume: saturating **bandwidth** (approaching 10 Gbit/s per NIC) and exceeding the NIC's **packet-rate** limit (small responses produce more packets per gigabit). Inbound encrypted traffic is slightly larger than outbound cleartext due to TLS overhead, so the two directions won't be symmetrical. Use the `device` label on `node_network_receive_bytes_total` / `node_network_transmit_bytes_total` to monitor each NIC independently.

Packet drops (`node_network_receive_drop_total`) often appear before bandwidth is fully used — the kernel starts dropping frames when it can't process them fast enough. TCP retransmits (`node_netstat_Tcp_RetransSegs`) are the downstream effect: the client doesn't get an acknowledgement, so it resends, adding latency and wasting CPU.

The most dangerous network metric on this server is **conntrack table usage**. The Linux kernel tracks every connection in a fixed-size table (65k–260k entries by default). At 25k req/s, completed connections stay in `TIME_WAIT` for up to 60 seconds, so the table accumulates entries fast. When it fills up, the kernel **silently drops new connections** — no error in the proxy logs, no TCP reset to the client, no indication at all. The SYN packet simply vanishes. This is extremely hard to debug after the fact, which is why proactive monitoring of `node_nf_conntrack_entries` against `node_nf_conntrack_entries_limit` is essential. The mitigation is to tune `nf_conntrack_max` upward based on observed connection rates and alert at 80% capacity.

### Memory

64 GB is generous for a proxy. The main consumers — SSL session cache, per-connection buffers, and kernel socket buffers — are unlikely to exhaust it. The value of monitoring memory here is primarily as a **leak detector**: if `node_memory_MemAvailable_bytes` trends downward over days, something is wrong. (Use "available" rather than "free" — Linux uses unused memory for disk caching, so "free" looks low even when things are healthy.)

Connection count (`node_netstat_Tcp_CurrEstab` + `node_sockstat_TCP_tw`) is useful for correlation: a spike in connections often precedes spikes in CPU and memory.

### Disk

The HDD is the weakest component on this server. At 100–150 random IOPS, it's orders of magnitude slower than an SSD. The proxy shouldn't touch it in the request path, but **access logging** is the trap. If the proxy writes a log line synchronously for each of the 25,000 requests per second, the disk stalls and adds latency to every request.

The volume problem compounds this: 25,000 req/s × 200 bytes per line = ~400 GB/day uncompressed. The 2 TB disk fills in under a week. The mitigations are **buffered/asynchronous logging** (write to memory, flush periodically), writing to **tmpfs** (RAM-backed filesystem) and rotating to disk on a schedule, **sampling** (log 1 in N requests), or **streaming to a centralised log pipeline** (Elasticsearch, a cloud logging service). In practice, a combination of sampling, streaming, and relying on Prometheus metrics for real-time monitoring is the most practical approach.

Monitor `rate(node_disk_io_time_seconds_total[5m])` for utilisation (approaching 1.0 = 100% busy) and `node_filesystem_avail_bytes` for free space.

### SSL / TLS Health

Certificate expiry (`probe_ssl_earliest_cert_expiry` from blackbox_exporter) should be probed externally — from outside the server, not from the server itself. This catches cases where the cert is valid on disk but not trusted by browsers (wrong chain, wrong hostname). An alert rule like `probe_ssl_earliest_cert_expiry - time() < 86400 * 7` fires 7 days before expiry.

Handshake errors (`nginx_ssl_handshakes_failed` for Nginx; `haproxy_frontend_ssl_connections_total` with error labels for HAProxy) spike when something changes — a bad certificate deployment, a client fleet updating to an incompatible TLS version, or a misconfigured cipher suite.

### Proxy Application Metrics

These are the user-facing indicators of service health.

Request rate (`rate(nginx_http_requests_total[1m])`) establishes the baseline. A sudden drop from 25k to 15k req/s usually means something upstream broke, not that traffic naturally decreased.

Error rate — filter on `status=~"5.."` for 5xx server errors. At this scale, even a 0.1% error rate means 25 failed requests per second. HTTP 502 (Bad Gateway) or 503 (Service Unavailable) point to unhealthy or overloaded backends.

Latency percentiles from `nginx_http_request_duration_seconds_bucket` (computed via `histogram_quantile`) reveal intermittent problems that averages hide. If p50 is 2ms but p99 is 500ms, 1 in 100 users is waiting 250x longer than typical.

Active connections (`nginx_connections_active`) tracks concurrent clients. When this approaches the proxy's `worker_connections` limit, new connections are refused.

---
## How I'd Set This Up

```
  ┌─────────────────────────┐
  │   SSL Proxy Server      │
  │                         │
  │   node_exporter :9100   │──► CPU, memory, disk, network, conntrack
  │   proxy exporter        │──► req/s, latency, errors, SSL stats
  └────────────┬────────────┘
               │
               ▼
  ┌──────────────────┐     ┌──────────────────┐
  │   Prometheus      │────►│   Alertmanager    │──► Slack / PagerDuty
  │  (stores metrics  │     └──────────────────┘
  │   + evaluates     │
  │   alert rules)    │
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │   Grafana         │  visual dashboards
  └──────────────────┘

  + blackbox_exporter (runs on a DIFFERENT server)
   
```

**Prometheus** scrapes both exporters every 15 seconds — frequent enough to catch issues quickly without adding meaningful CPU overhead.

**Alertmanager** routes critical alerts to the on-call team: certificate expiration, CPU saturation, conntrack table saturation, error rate spikes, and disk full.

**Grafana** provides dashboards grouped by the resource categories above, so when something goes wrong, an operator can quickly drill from "something is slow" to "which resource is the problem."

**blackbox_exporter** runs on a separate server and verifies that the HTTPS endpoint is reachable and the certificate is valid from the outside. This catches problems that appear fine from inside, such as a firewall blocking external traffic or a certificate that's locally valid but not trusted by browsers.

---

## Challenges

### Monitoring overhead

The exporters share CPU and memory with the proxy handling 25k req/s. `node_exporter` is negligible (well under 1% CPU). The proxy exporter needs more scrutiny — if it parses access logs or computes histograms on every scrape, that cost adds up. Its CPU footprint should be tested under production-like load, and scrape intervals should stay at 15 seconds rather than being aggressively tightened.

### Observability at scale

At 25,000 requests per second, logging or tracing every single request is impractical — the disk and memory would quickly become overwhelmed. Writing each request to disk or keeping all details in memory would slow the server and could cause dropped requests.

Instead, the monitoring strategy relies on pre-aggregated metrics (counters and histograms in Prometheus) to track overall system health without storing every request. When individual request-level debugging is necessary, a sampled log stream is sent to a centralized system, providing detailed information for troubleshooting without overwhelming the server.

---

>***Note***
> Although my hands‑on experience is with Prometheus and Grafana, the core monitoring concepts apply equally to Zabbix.
