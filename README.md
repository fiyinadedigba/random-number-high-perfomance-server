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
3. **Optional (macOS only):** To run the GNU `shuf` version - `gshuf` , install coreutils:

```bash
brew install coreutils
   
```bash
chmod +x *.sh
