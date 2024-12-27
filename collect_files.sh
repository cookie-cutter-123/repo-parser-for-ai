#!/usr/bin/env bash
#
# Usage:
#   ./collect_files.sh input.txt output.txt
#
# 1) input.txt should have:
#      Path: /Users/mypath/blahblah
#      Files:
#      openapi.yaml
#      readme.md
#      or separated by commas
# 2) output.txt will be created/overwritten with the contents of those files.

# Fail immediately on errors:
set -e

# Function to print debug messages
debug() {
  echo "DEBUG: $1" >> "$OUTPUT_FILE"
}

# Check if we have the correct number of arguments
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <input_file> <output_file>"
  exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

# 1. Extract the path (line starting with 'Path:')
SEARCH_PATH=$(awk -F': *' '/^Path:/{print $2}' "$INPUT_FILE" | xargs)

# Verify that SEARCH_PATH is not empty
if [[ -z "$SEARCH_PATH" ]]; then
  echo "Error: 'Path:' not found or empty in '$INPUT_FILE'."
  exit 1
fi

echo "Searching in path: $SEARCH_PATH"

# 2. Extract the lines after 'Files:' marker and split by commas/newlines
FILES_LIST=$(
  awk '/^Files:/{flag=1; next} /^Path:/{flag=0} flag' "$INPUT_FILE" \
    | tr ',' '\n' \
    | xargs -L1
)

# Verify that FILES_LIST is not empty
if [[ -z "$FILES_LIST" ]]; then
  echo "Error: No files specified after 'Files:' in '$INPUT_FILE'."
  exit 1
fi

# Clear/overwrite the output file
: > "$OUTPUT_FILE"

# --- Add info that we are about to paste the folder structure ---
{
  echo "For the context, I am posting the folder structure of our repo (tracked by Git):"
  echo ""
} >> "$OUTPUT_FILE"

# --- Use git commands with -C to ensure correct path ---
# Check if the path is a valid directory
if [[ ! -d "$SEARCH_PATH" ]]; then
  echo "Error: The path '$SEARCH_PATH' does not exist or is not a directory." >> "$OUTPUT_FILE"
  exit 1
fi

# Check if the directory is a Git repository
if git -C "$SEARCH_PATH" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_TOPLEVEL=$(git -C "$SEARCH_PATH" rev-parse --show-toplevel)
  debug "Git top-level directory is: $REPO_TOPLEVEL"

  # Get the count of tracked files
  COUNT=$(git -C "$SEARCH_PATH" ls-files | wc -l | tr -d ' ')
  debug "Git sees $COUNT tracked file(s) here."

  echo "" >> "$OUTPUT_FILE"

  # If there are tracked files, list them
  if [[ "$COUNT" -gt 0 ]]; then
    git -C "$SEARCH_PATH" ls-files >> "$OUTPUT_FILE"
  else
    echo "No tracked files found in '$SEARCH_PATH'." >> "$OUTPUT_FILE"
  fi
else
  echo "Warning: '$SEARCH_PATH' is not a Git repository." >> "$OUTPUT_FILE"
fi

# --- Add separator before appending important files ---
{
  echo ""
  echo "Now, I am pasting some important files from our repo:"
  echo ""
} >> "$OUTPUT_FILE"

# 3. Loop through each file in FILES_LIST, check if it exists, then append to OUTPUT_FILE
for FILE_NAME in $FILES_LIST; do
  FILE_PATH="$SEARCH_PATH/$FILE_NAME"

  if [[ -f "$FILE_PATH" ]]; then
    {
      echo "---- $FILE_NAME ----"
      cat "$FILE_PATH"
      echo ""
    } >> "$OUTPUT_FILE"
  else
    echo "Warning: File not found => $FILE_PATH" >> "$OUTPUT_FILE"
  fi
done

echo "Done! Collected files are in '$OUTPUT_FILE'."