#!/bin/bash
# Make the script executable
chmod +x "$0"

echo "Checking for required source files..."

required_files=(
  "lexer.l"
  "parser.y"
  "ast.h"
  "ast.c"
  "symbol_table.h"
  "symbol_table.c"
  "semantic.h"
  "semantic.c"
  "semantic_main.c"
)

missing_files=()
for file in "${required_files[@]}"; do
  if [ ! -f "$file" ]; then
    missing_files+=("$file")
    echo "MISSING: $file"
  else
    echo "FOUND: $file"
  fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
  echo -e "\nERROR: ${#missing_files[@]} required files are missing."
  exit 1
else
  echo -e "\nAll required source files found."
fi