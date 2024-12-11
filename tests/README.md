#!/bin/bash ./runnable.sh

# TESTING

## Overview
This document contains examples of commands to test various processes and operations. Each command is labeled with an identifier to allow quick referencing and execution.

## Tests

### 1. List Processes
Display a list of all active processes:
```shell
01. $ ps
```

### 2. Path of Working Directory
Show the current working directory:
```shell
02. $ pwd
```

### 3. Directory Listing
Display the contents of the directory, including hidden files, in a detailed format:
```shell
03. $ ls -lap
```

### 4. Example of Multiple Commands
Demonstration of running a multi-line command sequence:

#### Command:
```shell
04. $ echo "This is a"
04. $ echo "multi-line command"
```

#### Expected Output:
```
This is a
multi-line command
```

---

## Usage
1. Ensure you have the correct shell environment set up.
2. Use the `runnable.sh` script to scan this file and execute the desired commands:
   - **List All Commands:**
     ```bash
     ./runnable.sh ./tests
     ```
   - **Generate and Run Test Script:**
     ```bash
     ./runnable.sh ./tests 00 -r
     ```
3. Follow the `COMMAND_ID` format (e.g., `01`, `02`) to run specific commands.

---

## Notes
- Multi-line commands should be executed in sequence for accurate results.
- Ensure you have the required permissions and tools installed to run the commands.
- Modify the test commands as needed to suit your environment.
