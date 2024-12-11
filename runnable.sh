#!/bin/bash

# Enable or disable debug logging
DEBUG=true  # Set to false to disable debug logs

# Debug log function
log_debug() {
  if [ "$DEBUG" = true ]; then
    echo "[DEBUG] $1"
  fi
}

# Display usage information
show_usage() {
  echo "Runnable - scans .md files for runnable commands"
  echo "Usage: ./runnable.sh <file|folder> [id] [-r]"
  echo "Examples:"
  echo "  ./runnable.sh ./tests                  # List runnable commands in ./tests/README.md"
  echo "  ./runnable.sh ./tests/example.md       # List runnable commands in example.md"
  echo "  ./runnable.sh ./tests/example.md 00    # Generate test script from example.md"
  echo "  ./runnable.sh ./tests/example.md 00 -r # Run the generated test script"
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
  grep "\\$ " "$MD_FILE" | awk -F '[$][ ]' '{ print $N }'
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
