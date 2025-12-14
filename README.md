# Runnable

A cross-platform script to scan `.md` files for runnable commands and execute them. Available for both **Bash** (Linux/macOS) and **PowerShell** (Windows/Linux/macOS). Supports extracting commands, generating test scripts, and direct execution of commands with optional debugging.

---

## Features
- ✅ Extract and list commands prefixed with `$` from `.md` files
- ✅ Generate test scripts from extracted commands (`doctest.sh` or `doctest.ps1`)
- ✅ Execute specific commands by their ID
- ✅ Debug logging for troubleshooting, easily toggled on/off
- ✅ **Security features**: dry-run mode, interactive confirmation, dangerous command detection
- ✅ **Cross-platform**: Works on Linux, macOS, and Windows
- ✅ Command validation to prevent accidental destructive operations

---

## Installation

### Prerequisites

**For Linux/macOS (Bash):**
- **Bash**: Most Linux and macOS systems include Bash. Verify with:
  ```bash
  bash --version
  ```

**For Windows/Cross-platform (PowerShell):**
- **PowerShell 7+**: Install from [PowerShell GitHub](https://github.com/PowerShell/PowerShell)
  ```powershell
  pwsh --version
  ```

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/munafsheikh/runnable.git
   cd runnable
   ```

2. **For Bash users** (Linux/macOS), make the script executable:
   ```bash
   chmod +x runnable.sh
   ```

3. **For PowerShell users** (Windows/Linux/macOS), set execution policy if needed:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

4. (Optional) Add the folder to your PATH for global usage:

   **Bash (Linux/macOS):**
   ```bash
   export PATH=$PATH:$(pwd)
   ```

   **PowerShell (Windows):**
   ```powershell
   $env:PATH += ";$(Get-Location)"
   ```

---

## Usage

### General Syntax

**Bash (Linux/macOS):**
```bash
./runnable.sh <file|folder> [id] [-r]
```

**PowerShell (Windows/Linux/macOS):**
```powershell
.\runnable.ps1 <file|folder> [id] [-Run]
```

### Basic Examples

#### 1. List runnable commands in a file or folder

**Bash:**
```bash
./runnable.sh ./example.md
./runnable.sh ./tests
```

**PowerShell:**
```powershell
.\runnable.ps1 .\example.md
.\runnable.ps1 .\tests
```

#### 2. Generate a test script from the commands

**Bash:**
```bash
./runnable.sh ./example.md 00
```

**PowerShell:**
```powershell
.\runnable.ps1 .\example.md 00
```

#### 3. Generate and execute the test script

**Bash:**
```bash
./runnable.sh ./example.md 00 -r
```

**PowerShell:**
```powershell
.\runnable.ps1 .\example.md 00 -Run
```

#### 4. Execute a specific command by ID

**Bash:**
```bash
./runnable.sh ./example.md 2
```

**PowerShell:**
```powershell
.\runnable.ps1 .\example.md 2
```

### Environment Variables

Both scripts support the following environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `DEBUG` | Enable debug logging | `false` |
| `DRY_RUN` | Preview commands without executing | `false` |
| `INTERACTIVE` | Ask for confirmation before each command | `false` |

### Security Examples

#### Enable debug logging

**Bash:**
```bash
DEBUG=true ./runnable.sh ./example.md
```

**PowerShell:**
```powershell
$env:DEBUG = "true"; .\runnable.ps1 .\example.md
```

#### Preview commands without executing (Dry Run)

**Bash:**
```bash
DRY_RUN=true ./runnable.sh ./example.md 2
```

**PowerShell:**
```powershell
$env:DRY_RUN = "true"; .\runnable.ps1 .\example.md 2
```

#### Interactive mode (confirm before executing)

**Bash:**
```bash
INTERACTIVE=true ./runnable.sh ./example.md 2
```

**PowerShell:**
```powershell
$env:INTERACTIVE = "true"; .\runnable.ps1 .\example.md 2
```

---

## ⚠️ Security Considerations

### Important Security Warnings

🔴 **Only run Runnable on trusted markdown files from trusted sources!**

This tool executes commands directly from markdown files. Running it on untrusted files could:
- Delete files or directories
- Modify system settings
- Execute malicious code
- Compromise system security

### Built-in Security Features

Runnable includes several safety features:

1. **Dangerous Command Detection**: Automatically detects potentially dangerous patterns:
   - `rm -rf` / `Remove-Item -Recurse -Force`
   - `mkfs` / `Format-Volume`
   - `dd if=` commands
   - Pipe to shell (`curl | bash`, etc.)
   - Fork bombs and other destructive operations

2. **Dry Run Mode**: Preview commands before execution
   ```bash
   DRY_RUN=true ./runnable.sh ./example.md 2
   ```

3. **Interactive Mode**: Confirm each command before running
   ```bash
   INTERACTIVE=true ./runnable.sh ./example.md 2
   ```

4. **Security Warnings**: Displays warnings before executing commands

### Best Practices

✅ **DO:**
- Review markdown files before running Runnable on them
- Use `DRY_RUN=true` first to preview commands
- Enable `INTERACTIVE=true` for untrusted sources
- Keep Runnable updated for latest security patches

❌ **DON'T:**
- Run Runnable on markdown files from unknown sources
- Execute commands without reviewing them first
- Disable security warnings or confirmations
- Run with elevated privileges (sudo/admin) unless necessary

### Responsible Disclosure

If you discover a security vulnerability, please report it responsibly:
- Open a private security advisory on GitHub
- Email the maintainers directly
- Do not publicly disclose until a fix is available

---

## Test Cases

### Test Commands in Example File
Create a file `example.md` with the following content:
```markdown
# Example File

## Commands

1. Show current directory
   ```shell
   $ pwd
   ```

2. List files
   ```shell
   $ ls -la
   ```

3. Print a message
   ```shell
   $ echo "Hello, Runnable!"
   ```
```

### Run Tests
1. List commands:
   ```bash
   ./runnable.sh ./example.md
   ```
   Expected Output:
   ```
   pwd
   ls -la
   echo "Hello, Runnable!"
   ```

2. Generate `doctest.sh`:
   ```bash
   ./runnable.sh ./example.md 00
   ```
   Expected Output:
   ```
   Generating... [doctest.sh]
   ```

3. Execute the test script:
   ```bash
   ./runnable.sh ./example.md 00 -r
   ```
   Expected Output:
   ```
   =========================
   pwd
   ------------------------
   /path/to/current/directory

   =========================
   ls -la
   ------------------------
   <list of files>

   =========================
   echo "Hello, Runnable!"
   ------------------------
   Hello, Runnable!
   ```

4. Run a specific command by ID:
   ```bash
   ./runnable.sh ./example.md 2
   ```
   Expected Output:
   ```
   <list of files>
   ```

---

## Debugging
Enable debug logs by setting `DEBUG=true`:
```bash
DEBUG=true ./runnable.sh ./example.md
```

This will provide detailed logs at every step of execution.

---

## License
MIT License
