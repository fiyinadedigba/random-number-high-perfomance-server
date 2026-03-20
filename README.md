# Random Number Shuffle Scripts (1–10)

![Bash](https://img.shields.io/badge/language-Bash-blue)
![GitHub](https://img.shields.io/badge/status-Complete-brightgreen)

Design a script that writes the numbers from 1 - 10 in random order, with a test script.

---

## Table of Contents

1. [Project Description](#project-description)  
1. [Build instructions](#build-instructions)  
2. [Usage](#usage)  
3. [Description](#description)  
4. [Known limitations / bugs](#known-limitations--bugs)
5. [Sample Output Screenshot](#sample-output--screenshot)

---

## Project Description

This project provides multiple Bash-based implementations for generating a **random order of numbers from 1 to 10**, ensuring:

- Each number appears **only once**  
- The order is **randomized each time**  

Three implementations are included:

1. **Pure Bash ($RANDOM)** – fully self-contained, implements **Fisher–Yates shuffle**  
2. **GNU `shuf`/`gshuf`** – relies on GNU coreutils, does not explicitly implement Fisher–Yates  
3. **Cryptographically secure (`openssl rand`)** – secure randomness, suitable for sensitive applications  

A **test script** is included to verify correctness.
---

## Build instructions

1. Clone or download the repository, or create a local folder.

2. Make all scripts executable:

```bash
chmod +x *.sh
```
3. To run the GNU shuf version (gshuf) on macOS, install GNU coreutils:
```bash
brew install coreutils
```


## Usage

Run any of the scripts:

```bash
# Pure Bash version (Fisher–Yates)
./random_1_to_10.sh

# GNU shuf / gshuf version
./random_1_to_10_shuf.sh

# Secure version (OpenSSL)
./secure_random_1_to_10.sh
```

Run the test script to verify correctness:

```bash
./test_random_1_to_10.sh ./random_1_to_10.sh
./test_random_1_to_10.sh ./random_1_to_10_shuf.sh
./test_random_1_to_10.sh ./secure_random_1_to_10.sh
```

| Test         | Description                        |
| ------------ | ---------------------------------- |
| Count        | Output contains exactly 10 numbers |
| Range        | All numbers are between 1 and 10   |
| Duplicates   | No duplicates exist                |
| Completeness | All numbers from 1–10 are present  |




## Description

This project provides three Bash-based implementations for generating numbers from 1 - 10 in random order:

| Approach                                  | Description                                               | Notes                                                                                    |
| ----------------------------------------- | --------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| Pure Bash (`$RANDOM`)                     | Fully self-contained, implements **Fisher–Yates shuffle** | Fast, portable, pseudo-random; not secure for cryptography                               |
| GNU `shuf` / `gshuf`                      | Uses GNU coreutils internal randomization                 | Simple, fast, does not explicitly implement Fisher–Yates; requires `gshuf` on macOS      |
| Secure version (`openssl rand`) | Uses `openssl rand` for secure randomness                 | Implements Fisher–Yates shuffle with rejection sampling to avoid bias; slower but secure |

### Key features of all the scripts:

1. Random order for every run
2. No duplicates
3. Complete set of numbers from 1–10



## Known limitations / bugs

1. Scripts are fixed to range 1–10; arbitrary ranges are not supported:  
  - You cannot pass a custom range as a command-line argument.
  - To use a different range, you would need to manually edit the script.
2. Pure Bash ($RANDOM) → pseudo-random, predictable; not cryptographically secure
  - Uses Bash’s built-in $RANDOM to generate numbers.
  - The numbers look random, but they can be predicted if someone knows the algorithm.
  - Not safe for secure applications like passwords, encryption, or SSL/TLS.

3. gshuf version → requires GNU coreutils on macOS; internal algorithm not Fisher–Yates
  - Uses the gshuf command from GNU coreutils to shuffle numbers.
  - On macOS, you need to install GNU coreutils first (brew install coreutils).
  - It shuffles numbers correctly, but the exact method it uses is internal; it’s not explicitly the Fisher–Yates shuffle.
    
4. openssl rand version → slower execution; Bash may not be ideal for high-performance cryptography
  - Uses openssl rand to generate truly secure random numbers.
  - It is slower than the other two methods because of extra calculations.
  - Bash scripts are not the best choice if you need very fast or heavy cryptographic operations.
**For large-scale secure applications, use compiled languages or libraries (e.g., Python `secrets`, C/C++ OpenSSL, Go `crypto/rand`).**

## Sample Output Screenshot

<img width="1440" height="900" alt="Screenshot 2026-03-20 at 10 24 11" src="https://github.com/user-attachments/assets/9b689e4e-7e45-47e1-a57d-47b81f465702" />



> **Extra Notes:**  
> Bash is widely used in companies for automation, system administration, and network monitoring tasks.  
> The limitations mentioned for cryptography **only apply when performing heavy or production-scale secure operations**.  
> For routine monitoring, log parsing, and automation, Bash scripts are fully practical and commonly used in professional environments.
