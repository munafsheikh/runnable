# Runnable

A script to scan `.md` files for runnable commands and execute them. Supports extracting commands, generating test scripts, and direct execution of commands with optional debugging.

---

## Features
- Extract and list commands prefixed with `$` from `.md` files.
- Generate a `doctest.sh` script from the extracted commands.
- Execute a specific command by its ID.
- Debug logging for troubleshooting, easily toggled on/off.

---

## Installation

### Prerequisites
Ensure you have the following installed:
- **Bash**: Most Linux and macOS systems include Bash. Verify with:
  ```bash
  bash --version
  ```

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/munafsheikh/runnable.git
   cd runnable
   ```

2. Make the scripts executable:
   ```bash
   chmod +x runnable.sh
   ```

3. (Optional) Add the folder to your PATH for global usage:
   ```bash
   export PATH=$PATH:$(pwd)
   ```

---

## Usage

### General Syntax
```bash
./runnable.sh <file|folder> [id] [-r]
```

### Examples
1. **List runnable commands in a file or folder**:
   ```bash
   ./runnable.sh ./example.md
   ./runnable.sh ./tests
   ```

2. **Generate a `doctest.sh` script from the commands**:
   ```bash
   ./runnable.sh ./example.md 00
   ```

3. **Generate and execute the test script**:
   ```bash
   ./runnable.sh ./example.md 00 -r
   ```

4. **Execute a specific command by ID**:
   ```bash
   ./runnable.sh ./example.md 2
   ```

5. **Enable debug logging**:
   ```bash
   DEBUG=true ./runnable.sh ./example.md
   ```

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
