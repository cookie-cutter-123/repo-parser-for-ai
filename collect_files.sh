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

# 1. Extract the path (line starting with 'Path:')
SEARCH_PATH=$(awk -F': *' '/^Path:/{print $2}' "$INPUT_FILE" | xargs)

# 2. Extract the lines after 'Files:' marker and split by commas/newlines
#    - We find the section after "Files:"
#    - Then replace commas with newlines
#    - Then trim whitespace
FILES_LIST=$(awk '/^Files:/{flag=1; next} flag' "$INPUT_FILE" | sed 's/,/\n/g' | xargs -L1)

# Clear/overwrite the output file
true > "$OUTPUT_FILE"

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
    echo "Warning: File not found => $FILE_PATH"
  fi
done

echo "Done! Collected files are in '$OUTPUT_FILE'."