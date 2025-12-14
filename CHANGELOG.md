# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **PowerShell support**: Created `runnable.ps1` for Windows/cross-platform compatibility
- **Security features**:
  - Dry-run mode (`DRY_RUN=true`) to preview commands without executing
  - Interactive mode (`INTERACTIVE=true`) to confirm each command before execution
  - Dangerous command detection for patterns like `rm -rf`, `mkfs`, `dd`, etc.
  - Security warnings before command execution
- **Environment variable configuration**:
  - `DEBUG`: Enable debug logging (default: false)
  - `DRY_RUN`: Preview mode (default: false)
  - `INTERACTIVE`: Confirmation mode (default: false)
- **Comprehensive documentation**:
  - Security considerations section in README
  - PowerShell usage examples
  - Best practices guide
  - Cross-platform installation instructions
- **GitHub Actions CI/CD**:
  - Automated testing for both Bash and PowerShell scripts
  - Multi-OS testing (Ubuntu, macOS, Windows)
  - ShellCheck linting for Bash script
  - Code quality checks
- **Example files**:
  - `example.md` with sample runnable commands
  - Updated test examples

### Fixed
- Fixed bug in `runnable.sh:64` where `$N` was used instead of `$2`
- Fixed hardcoded `DEBUG=true` to respect environment variable
- Improved error handling throughout the script
- Better input validation

### Changed
- Updated README with comprehensive cross-platform documentation
- Enhanced usage information with security examples
- Improved help messages in both scripts

### Security
- Added protection against accidental execution of dangerous commands
- Implemented command validation before execution
- Added security warnings and best practices documentation

## [1.0.0] - Initial Release

### Added
- Basic markdown command extraction
- Command execution by ID
- Test script generation
- Debug logging
- Support for file and folder inputs
