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

# Check if we have the correct number of arguments
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <input_file> <output_file>"
  exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Extract the path (line starting with 'Path:')
SEARCH_PATH=$(awk -F': *' '/^Path:/{print $2}' "$INPUT_FILE" | xargs)

# Read the 'Files:' block, then replace commas with newlines, then trim.
FILES_LIST=$(
  awk '/^Files:/{flag=1; next} flag' "$INPUT_FILE" \
    | sed 's/,/\n/g' \
    | xargs -L1
)

# 1) Truncate (clear) the output file at the start using a no-op command:
: > "$OUTPUT_FILE"

# 2) Write the initial text at the top of the output file:
{
  echo "For the context, I am posting the structure of our repo, but with up to 5 files per directory, in order not to burden you with all the data right away:"
  echo ""
} >> "$OUTPUT_FILE"

# 3) Recursively list the directory structure: subfolders + up to 5 files

# Use find with -print0 so paths with spaces are handled safely
while IFS= read -r -d '' dir; do
  echo "Directory: $dir" >> "$OUTPUT_FILE"

  # Collect subfolders one level below, storing them in an array
  # (We use 2>/dev/null to avoid 'Permission denied' warnings, etc.)
  mapfile -d '' subfolders < <(find "$dir" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null || :)

  for sub in "${subfolders[@]}"; do
    # Skip printing the directory itself
    [[ "$sub" == "$dir" ]] && continue
    echo "  Subfolder: $sub" >> "$OUTPUT_FILE"
  done

  # Collect files (up to 5) in the current directory
  mapfile -d '' files < <(find "$dir" -mindepth 1 -maxdepth 1 -type f -print0 2>/dev/null || :)
  # Print first 5 files
  for (( i = 0; i < ${#files[@]} && i < 5; i++ )); do
    echo "  File: ${files[$i]}" >> "$OUTPUT_FILE"
  done

  echo "" >> "$OUTPUT_FILE"
done < <(find "$SEARCH_PATH" -type d -print0)

# 4) Write the separator text before including important files:
{
  echo "Now, I am pasting some important files from our repo:"
  echo ""
} >> "$OUTPUT_FILE"

# 5) Append the contents of the requested files
for FILE_NAME in $FILES_LIST; do
  FILE_PATH="$SEARCH_PATH/$FILE_NAME"
  if [[ -f "$FILE_PATH" ]]; then
    {
      echo "---- $FILE_NAME ----"
      cat "$FILE_PATH"
      echo ""
    } >> "$OUTPUT_FILE"
  else
    echo "Warning: File not found => $FILE_PATH"
  fi
done

echo "Done! Collected output is in '$OUTPUT_FILE'."