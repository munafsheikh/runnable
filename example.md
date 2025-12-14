# Example Runnable Commands

This file demonstrates runnable commands that can be extracted and executed by the Runnable script.

## Basic Commands

### 1. Show Current Directory
Display the current working directory:
```shell
$ pwd
```

### 2. List Files
List all files in the current directory:
```shell
$ ls -la
```

### 3. Print a Message
Echo a simple message:
```shell
$ echo "Hello, Runnable!"
```

### 4. Show Date and Time
Display the current date and time:
```shell
$ date
```

### 5. Check Disk Usage
Show disk usage information:
```shell
$ df -h
```

### 6. Display Environment Variables
Show a specific environment variable:
```shell
$ echo $PATH
```

### 7. Create and Remove Test File
Create a temporary file and remove it:
```shell
$ touch /tmp/runnable-test.txt && ls -l /tmp/runnable-test.txt && rm /tmp/runnable-test.txt
```

## Cross-Platform Commands

These commands work on both Linux/macOS (Bash) and Windows (PowerShell):

### 8. Show Hostname
```shell
$ hostname
```

### 9. Check Network Connectivity
```shell
$ ping -c 1 google.com || ping -n 1 google.com
```

## Usage Examples

### List all commands in this file:
**Bash:**
```bash
./runnable.sh ./example.md
```

**PowerShell:**
```powershell
.\runnable.ps1 .\example.md
```

### Execute command #3:
**Bash:**
```bash
./runnable.sh ./example.md 3
```

**PowerShell:**
```powershell
.\runnable.ps1 .\example.md 3
```

### Generate and run all tests:
**Bash:**
```bash
./runnable.sh ./example.md 00 -r
```

**PowerShell:**
```powershell
.\runnable.ps1 .\example.md 00 -Run
```

## Safety Example

### Preview command without executing:
**Bash:**
```bash
DRY_RUN=true ./runnable.sh ./example.md 3
```

**PowerShell:**
```powershell
$env:DRY_RUN = "true"; .\runnable.ps1 .\example.md 3
```
