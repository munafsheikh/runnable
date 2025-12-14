#!/bin/bash

# Enable or disable debug logging
DEBUG="${DEBUG:-false}"  # Set DEBUG=true environment variable to enable debug logs

# Enable or disable dry-run mode (shows commands without executing)
DRY_RUN="${DRY_RUN:-false}"  # Set DRY_RUN=true to preview commands without executing

# Enable or disable interactive mode (asks for confirmation before executing)
INTERACTIVE="${INTERACTIVE:-false}"  # Set INTERACTIVE=true to confirm each command

# Debug log function
log_debug() {
  if [ "$DEBUG" = true ]; then
    echo "[DEBUG] $1"
  fi
}

# Security warning function
show_security_warning() {
  echo "⚠️  WARNING: This will execute commands from the markdown file."
  echo "   Only run this on trusted markdown files from trusted sources."
  echo "   Review the commands before executing."
  echo ""
}

# Validate command for potentially dangerous operations
validate_command() {
  local cmd=$1
  local dangerous_patterns=("rm -rf" "mkfs" "dd if=" "> /dev/" "curl.*|.*bash" "wget.*|.*sh" ":(){ :|:& };:")

  for pattern in "${dangerous_patterns[@]}"; do
    if echo "$cmd" | grep -qiE "$pattern"; then
      echo "⚠️  DANGER: Command contains potentially destructive pattern: $pattern"
      echo "   Command: $cmd"
      read -p "   Are you ABSOLUTELY sure you want to run this? (type 'yes' to continue): " confirm
      if [ "$confirm" != "yes" ]; then
        echo "   Command execution cancelled."
        return 1
      fi
    fi
  done
  return 0
}

# Ask for confirmation if interactive mode is enabled
confirm_execution() {
  local cmd=$1
  if [ "$INTERACTIVE" = true ]; then
    echo "Command: $cmd"
    read -p "Execute this command? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "Skipped."
      return 1
    fi
  fi
  return 0
}

# Display usage information
show_usage() {
  echo "Runnable - scans .md files for runnable commands"
  echo "Usage: ./runnable.sh <file|folder> [id] [-r]"
  echo ""
  echo "Examples:"
  echo "  ./runnable.sh ./tests                  # List runnable commands in ./tests/README.md"
  echo "  ./runnable.sh ./tests/example.md       # List runnable commands in example.md"
  echo "  ./runnable.sh ./tests/example.md 00    # Generate test script from example.md"
  echo "  ./runnable.sh ./tests/example.md 00 -r # Run the generated test script"
  echo "  ./runnable.sh ./tests/example.md 2     # Execute command with ID 2"
  echo ""
  echo "Environment Variables:"
  echo "  DEBUG=true          # Enable debug logging"
  echo "  DRY_RUN=true        # Preview commands without executing them"
  echo "  INTERACTIVE=true    # Ask for confirmation before each command"
  echo ""
  echo "Security Examples:"
  echo "  DRY_RUN=true ./runnable.sh ./example.md 2      # Preview command 2"
  echo "  INTERACTIVE=true ./runnable.sh ./example.md 2  # Confirm before running"
}

# Process .md file execution directly
process_direct_execution() {
  SCRIPT_DIR=$(dirname "$0")
  RUNNABLE_SCRIPT="$SCRIPT_DIR/runnable.sh"

  log_debug "Direct execution: Script directory=$SCRIPT_DIR, Runnable script=$RUNNABLE_SCRIPT"

  if [[ ! -x "$RUNNABLE_SCRIPT" ]]; then
    echo "Error: runnable.sh not found or not executable in $SCRIPT_DIR"
    exit 1
  fi

  log_debug "Invoking $RUNNABLE_SCRIPT with $0"
  "$RUNNABLE_SCRIPT" "$0"
  exit 0
}

# Determine target file
determine_target_file() {
  local target=$1
  if [ -f "$target" ]; then
    MD_FILE="$target"
    log_debug "Target is a file: $MD_FILE"
  elif [ -d "$target" ]; then
    MD_FILE="$target/README.md"
    log_debug "Target is a directory, assuming README.md: $MD_FILE"
  else
    echo "Error: '$target' is neither a valid file nor directory."
    exit 1
  fi

  if [ ! -f "$MD_FILE" ]; then
    echo "Error: '$MD_FILE' not found."
    exit 1
  fi
}

# List runnable commands
list_commands() {
  log_debug "Listing runnable commands in $MD_FILE"
  grep "\\$ " "$MD_FILE" | awk -F '[$][ ]' '{ print $2 }'
}

# Generate test script
generate_test_script() {
  OUTPUT_SCRIPT="doctest.sh"
  log_debug "Generating test script: $OUTPUT_SCRIPT"

  grep "\\$ " "$MD_FILE" | awk -F '[$][ ]' '{
    print ""
    print "echo ========================="
    print "echo " $2
    print "echo ------------------------"
    print $2
  }' > "$OUTPUT_SCRIPT"

  chmod +x "$OUTPUT_SCRIPT"

  if [ "$RUN_FLAG" = "-r" ]; then
    log_debug "Executing generated test script: $OUTPUT_SCRIPT"
    ./"$OUTPUT_SCRIPT"
  else
    log_debug "Generated $OUTPUT_SCRIPT. Use '-r' flag to execute it."
    echo "Generated [$OUTPUT_SCRIPT]. Use '-r' flag to execute it."
  fi
}

# Execute a specific command
execute_command() {
  log_debug "Looking for command ID=$COMMAND_ID in $MD_FILE"

  COMMAND=$(grep "\\$ " "$MD_FILE" | awk -F '[$][ ]' 'NR == '"$COMMAND_ID"' { print $2 }')

  if [ -z "$COMMAND" ]; then
    echo "Error: No command found for ID '$COMMAND_ID' in '$MD_FILE'."
    exit 1
  fi

  # Show security warning before execution
  show_security_warning

  # Validate command for dangerous patterns
  if ! validate_command "$COMMAND"; then
    exit 1
  fi

  # Check for dry-run mode
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would execute: $COMMAND"
    exit 0
  fi

  # Ask for confirmation if interactive mode is enabled
  if ! confirm_execution "$COMMAND"; then
    exit 0
  fi

  log_debug "Running command: $COMMAND"
  bash -c "$COMMAND"
}

# Main function
main() {
  # Check for direct execution of an .md file
  if [[ "$0" == *.md ]]; then
    log_debug "Direct execution of .md file: $0"
    process_direct_execution
    log_debug "Exiting..."
    exit 0
  fi

  # Arguments
  TARGET=$1
  COMMAND_ID=$2
  RUN_FLAG=$3

  log_debug "Script invoked directly as runnable.sh"
  log_debug "Arguments: TARGET=$TARGET, COMMAND_ID=$COMMAND_ID, RUN_FLAG=$RUN_FLAG"

  # Display usage if no arguments are provided
  if [ -z "$TARGET" ]; then
    show_usage
    exit 0
  fi

  # Determine the target file
  determine_target_file "$TARGET"

  # Process commands based on arguments
  if [ -z "$COMMAND_ID" ]; then
    list_commands
  elif [ "$COMMAND_ID" = "00" ]; then
    generate_test_script
  else
    execute_command
  fi
}

# Execute the main function
main "$@"
