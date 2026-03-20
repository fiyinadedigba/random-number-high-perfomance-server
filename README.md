# Random Number Shuffle Scripts (1–10)

![Bash](https://img.shields.io/badge/language-Bash-blue)
![GitHub](https://img.shields.io/badge/status-Complete-brightgreen)

Design a script that writes the numbers from 1 - 10 in random order, with a test script.

---

## Table of Contents

1. [Project Description](#project-description)  
1. [Build instructions](#build-instructions)  
2. [Usage](#usage)
3. [Known limitations / bugs](#known-limitations--bugs)
4. [Sample Output Screenshot](#sample-output-screenshot)

---

## Description

This repository contains a **pure Bash script** to shuffle numbers within a specified range using a **scalable design**.

### Features

- Uses Bash’s `$RANDOM` to generate pseudo-random numbers  
- Fully scalable: supports any integer range, not just 1–10  
- Supports optional deterministic seeding to reproduce the same shuffled sequence  
- Suitable for games, demos, and learning purposes  

### Testing

Includes a test script (`test_random_1_to_10.sh`) that validates:

- Correct number of lines  
- All numbers are within the specified range  
- No duplicate values  
- All numbers in the range are present  

### Design Choice: Pure Bash

This solution uses a pure Bash approach because:

- Simple and lightweight (no external dependencies)  
- Cross-platform compatibility (Linux/macOS)  
- No need for GNU `shuf` or `openssl rand`  
- Cryptographic security is not required (`$RANDOM` is pseudo-random)  

### Algorithm

The script implements the **Fisher–Yates shuffle algorithm**, which generates a random permutation of a finite sequence.

- Each possible ordering is equally likely  
- Ensures no duplicates or missing values  
- Default behavior shuffles numbers from **1 to 10**, but supports any range
  

## Build instructions

1. Clone or download this repository (or create a local folder):

```bash
git clone https://github.com/fiyinadedigba/random-number-order-1-10.git
cd random-number-order-1-10

```

2. Make all scripts executable:

```bash
chmod +x *.sh
```


## Usage

### Run Script

Run default shuffle (1–10):

```bash
./random_1_10.sh
```

Sample output:

```
2
4
7
1
5
10
9
6
3
8
```
Run with custom range (example):

```
./random_1_10.sh 5 15
```
Sample output:

```
10
15
12
13
8
11
6
7
9
5
14
```
Run with custom seed (deterministic shuffle)

```
./random_1_10.sh 1 10 7
```
Sample output:

```
8
7
4
3
1
9
2
10
6
5
```

> **Note:** Using the same seed will always produce the same shuffled sequence.
> Useful for testing, demonstrations, or reproducibility.

### Run Tests

Run the test script to verify correctness:

```bash
./test_random_1_to_10.sh ./random_1_10.sh
```
Output

```
TEST PASSED:  Correct number of lines (10)
TEST PASSED:  All numbers within range 1-10
TEST PASSED:  No duplicates
TEST PASSED:  All numbers 1-10 present
All tests passed!
```
Test random range

```
./test_random_1_to_10.sh ./random_1_10.sh 5 15 7
```

Output

```
TEST PASSED:  Correct number of lines (11)
TEST PASSED:  All numbers within range 5-15
TEST PASSED:  No duplicates
TEST PASSED:  All numbers 5-15 present
All tests passed!
```


## Known limitations / bugs

| Limitation                      | Notes                                                                                           |
| ------------------------------- | ----------------------------------------------------------------------------------------------- |
| Not cryptographically secure    | `$RANDOM` is pseudo-random. Do **not** use for SSL/TLS, encryption, or security-critical tasks. |
| Very large ranges may be slower | For extremely large ranges (e.g., millions), Bash performance may degrade.                      |
| Fixed integer ranges only       | Only supports numeric ranges; floating point or negative ranges are not supported.              |
| Deterministic seeding           | Useful for testing, but sequences are predictable if seed is known.                             |

**For large-scale secure applications, use compiled languages or libraries (e.g., Python `secrets`, C/C++ OpenSSL, Go `crypto/rand`).**



## Sample Output Screenshot

<img width="1440" height="900" alt="Screenshot 2026-03-20 at 13 08 33" src="https://github.com/user-attachments/assets/f0d30351-ffbb-40a5-aa46-c3296e0ab686" />



> **Extra Notes:**  
> ✅ Ideal for games, demos, learning, and reproducible tests.  
