#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Runnable - scans .md files for runnable commands and executes them

.DESCRIPTION
    A PowerShell script to scan .md files for runnable commands and execute them.
    Supports extracting commands, generating test scripts, and direct execution.

.PARAMETER Target
    The file or folder to scan for commands

.PARAMETER CommandId
    The ID of the command to execute, or "00" to generate test script

.PARAMETER Run
    Switch to execute the generated test script

.EXAMPLE
    .\runnable.ps1 .\tests
    List runnable commands in .\tests\README.md

.EXAMPLE
    .\runnable.ps1 .\tests\example.md 2
    Execute command with ID 2

.EXAMPLE
    $env:DRY_RUN = "true"; .\runnable.ps1 .\example.md 2
    Preview command 2 without executing
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Target,

    [Parameter(Position = 1)]
    [string]$CommandId,

    [Parameter(Position = 2)]
    [switch]$Run
)

# Configuration from environment variables
$Script:DEBUG = [System.Environment]::GetEnvironmentVariable("DEBUG") -eq "true"
$Script:DRY_RUN = [System.Environment]::GetEnvironmentVariable("DRY_RUN") -eq "true"
$Script:INTERACTIVE = [System.Environment]::GetEnvironmentVariable("INTERACTIVE") -eq "true"

# Debug log function
function Write-DebugLog {
    param([string]$Message)
    if ($Script:DEBUG) {
        Write-Host "[DEBUG] $Message" -ForegroundColor Cyan
    }
}

# Security warning function
function Show-SecurityWarning {
    Write-Host "⚠️  WARNING: This will execute commands from the markdown file." -ForegroundColor Yellow
    Write-Host "   Only run this on trusted markdown files from trusted sources." -ForegroundColor Yellow
    Write-Host "   Review the commands before executing." -ForegroundColor Yellow
    Write-Host ""
}

# Validate command for potentially dangerous operations
function Test-CommandSafety {
    param([string]$Command)

    $dangerousPatterns = @(
        'Remove-Item.*-Recurse.*-Force',
        'rm\s+-rf',
        'Format-Volume',
        'mkfs',
        'dd\s+if=',
        '>\s*/dev/',
        'curl.*\|.*powershell',
        'curl.*\|.*pwsh',
        'wget.*\|.*powershell',
        'Invoke-Expression.*\(.*WebClient',
        'iex.*\(.*WebClient'
    )

    foreach ($pattern in $dangerousPatterns) {
        if ($Command -match $pattern) {
            Write-Host "⚠️  DANGER: Command contains potentially destructive pattern: $pattern" -ForegroundColor Red
            Write-Host "   Command: $Command" -ForegroundColor Red
            $confirm = Read-Host "   Are you ABSOLUTELY sure you want to run this? (type 'yes' to continue)"
            if ($confirm -ne "yes") {
                Write-Host "   Command execution cancelled." -ForegroundColor Yellow
                return $false
            }
        }
    }
    return $true
}

# Ask for confirmation if interactive mode is enabled
function Confirm-Execution {
    param([string]$Command)

    if ($Script:INTERACTIVE) {
        Write-Host "Command: $Command"
        $confirm = Read-Host "Execute this command? (y/N)"
        if ($confirm -notmatch '^[Yy]$') {
            Write-Host "Skipped." -ForegroundColor Yellow
            return $false
        }
    }
    return $true
}

# Display usage information
function Show-Usage {
    Write-Host "Runnable - scans .md files for runnable commands"
    Write-Host "Usage: .\runnable.ps1 <file|folder> [id] [-Run]"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\runnable.ps1 .\tests                    # List runnable commands in .\tests\README.md"
    Write-Host "  .\runnable.ps1 .\tests\example.md         # List runnable commands in example.md"
    Write-Host "  .\runnable.ps1 .\tests\example.md 00      # Generate test script from example.md"
    Write-Host "  .\runnable.ps1 .\tests\example.md 00 -Run # Run the generated test script"
    Write-Host "  .\runnable.ps1 .\tests\example.md 2       # Execute command with ID 2"
    Write-Host ""
    Write-Host "Environment Variables:"
    Write-Host "  `$env:DEBUG = `"true`"          # Enable debug logging"
    Write-Host "  `$env:DRY_RUN = `"true`"        # Preview commands without executing them"
    Write-Host "  `$env:INTERACTIVE = `"true`"    # Ask for confirmation before each command"
    Write-Host ""
    Write-Host "Security Examples:"
    Write-Host "  `$env:DRY_RUN = `"true`"; .\runnable.ps1 .\example.md 2      # Preview command 2"
    Write-Host "  `$env:INTERACTIVE = `"true`"; .\runnable.ps1 .\example.md 2  # Confirm before running"
}

# Determine target file
function Get-TargetFile {
    param([string]$Target)

    if (Test-Path $Target -PathType Leaf) {
        $mdFile = $Target
        Write-DebugLog "Target is a file: $mdFile"
    }
    elseif (Test-Path $Target -PathType Container) {
        $mdFile = Join-Path $Target "README.md"
        Write-DebugLog "Target is a directory, assuming README.md: $mdFile"
    }
    else {
        Write-Error "Error: '$Target' is neither a valid file nor directory."
        exit 1
    }

    if (-not (Test-Path $mdFile)) {
        Write-Error "Error: '$mdFile' not found."
        exit 1
    }

    return $mdFile
}

# List runnable commands
function Get-RunnableCommands {
    param([string]$MdFile)

    Write-DebugLog "Listing runnable commands in $MdFile"

    $content = Get-Content $MdFile -Raw
    $matches = [regex]::Matches($content, '\$\s+(.+)')

    foreach ($match in $matches) {
        $match.Groups[1].Value
    }
}

# Generate test script
function New-TestScript {
    param(
        [string]$MdFile,
        [bool]$RunScript
    )

    $outputScript = "doctest.ps1"
    Write-DebugLog "Generating test script: $outputScript"

    $commands = Get-RunnableCommands -MdFile $MdFile

    $scriptContent = @"
#!/usr/bin/env pwsh
# Auto-generated test script from $MdFile

"@

    foreach ($cmd in $commands) {
        $scriptContent += @"

Write-Host "=========================" -ForegroundColor Green
Write-Host "$cmd" -ForegroundColor Cyan
Write-Host "-------------------------" -ForegroundColor Green
$cmd

"@
    }

    Set-Content -Path $outputScript -Value $scriptContent

    if ($IsWindows -or $PSVersionTable.Platform -eq 'Win32NT') {
        # On Windows, we don't need to set execute permissions
        Write-DebugLog "Created $outputScript (Windows)"
    }
    else {
        # On Unix-like systems, set execute permissions
        chmod +x $outputScript 2>$null
        Write-DebugLog "Created $outputScript with execute permissions"
    }

    if ($RunScript) {
        Write-DebugLog "Executing generated test script: $outputScript"
        & ".\$outputScript"
    }
    else {
        Write-DebugLog "Generated $outputScript. Use -Run flag to execute it."
        Write-Host "Generated [$outputScript]. Use -Run flag to execute it." -ForegroundColor Green
    }
}

# Execute a specific command
function Invoke-RunnableCommand {
    param(
        [string]$MdFile,
        [int]$CommandId
    )

    Write-DebugLog "Looking for command ID=$CommandId in $MdFile"

    $commands = @(Get-RunnableCommands -MdFile $MdFile)

    if ($CommandId -lt 1 -or $CommandId -gt $commands.Count) {
        Write-Error "Error: No command found for ID '$CommandId' in '$MdFile'. Valid range: 1-$($commands.Count)"
        exit 1
    }

    $command = $commands[$CommandId - 1]

    # Show security warning before execution
    Show-SecurityWarning

    # Validate command for dangerous patterns
    if (-not (Test-CommandSafety -Command $command)) {
        exit 1
    }

    # Check for dry-run mode
    if ($Script:DRY_RUN) {
        Write-Host "[DRY RUN] Would execute: $command" -ForegroundColor Cyan
        exit 0
    }

    # Ask for confirmation if interactive mode is enabled
    if (-not (Confirm-Execution -Command $command)) {
        exit 0
    }

    Write-DebugLog "Running command: $command"

    # Execute the command
    Invoke-Expression $command
}

# Main execution
function Main {
    Write-DebugLog "Script invoked with Target=$Target, CommandId=$CommandId, Run=$Run"

    # Display usage if no arguments are provided
    if ([string]::IsNullOrEmpty($Target)) {
        Show-Usage
        exit 0
    }

    # Determine the target file
    $mdFile = Get-TargetFile -Target $Target

    # Process commands based on arguments
    if ([string]::IsNullOrEmpty($CommandId)) {
        Get-RunnableCommands -MdFile $mdFile
    }
    elseif ($CommandId -eq "00") {
        New-TestScript -MdFile $mdFile -RunScript $Run
    }
    else {
        Invoke-RunnableCommand -MdFile $mdFile -CommandId ([int]$CommandId)
    }
}

# Execute the main function
Main
