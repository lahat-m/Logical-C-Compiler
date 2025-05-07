#!/bin/bash
# Script to set up and build Phase 4 (Code Generation)

# Make this script executable
chmod +x "$0"

# Check if we have all required files
echo "Checking for required files..."
required_files=(
  "lexer.l"
  "parser.y"
  "ast.h"
  "ast.c"
  "codegen.h"
  "codegen.c"
  "codegen_main.c"
  "Makefile.phase4"
  "test_codegen.sh"
)

missing=0
for file in "${required_files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "MISSING: $file"
    missing=1
  else
    echo "FOUND: $file"
  fi
done

if [ $missing -eq 1 ]; then
  echo "Error: Some required files are missing. Please make sure all files are present."
  exit 1
fi

# Create test directories and files
echo "Setting up test directories..."
mkdir -p codegen_tests
mkdir -p codegen_results

# Copy or create test files
echo "Setting up test files..."

# Group 1: Basic Operations
echo "// Simple literal" > codegen_tests/01_literal.logic
echo "TRUE" >> codegen_tests/01_literal.logic

echo "// NOT operation" > codegen_tests/02_not.logic
echo "~TRUE" >> codegen_tests/02_not.logic

echo "// AND operation" > codegen_tests/03_and.logic
echo "TRUE /\ FALSE" >> codegen_tests/03_and.logic

echo "// OR operation" > codegen_tests/04_or.logic
echo "TRUE \/ FALSE" >> codegen_tests/04_or.logic

echo "// IMPLIES operation" > codegen_tests/05_implies.logic
echo "TRUE -> FALSE" >> codegen_tests/05_implies.logic

echo "// IFF operation" > codegen_tests/06_iff.logic
echo "TRUE <-> FALSE" >> codegen_tests/06_iff.logic

echo "// XOR operation" > codegen_tests/07_xor.logic
echo "TRUE ^ FALSE" >> codegen_tests/07_xor.logic

# Group 2: Complex Expressions
echo "// Complex expression" > codegen_tests/08_complex.logic
echo "(TRUE /\ FALSE) \/ (~TRUE -> FALSE)" >> codegen_tests/08_complex.logic

echo "// Operator precedence" > codegen_tests/09_precedence.logic
echo "TRUE /\ FALSE \/ TRUE -> FALSE <-> TRUE ^ FALSE" >> codegen_tests/09_precedence.logic

# Group 3: Quantifiers
echo "// Universal quantifier" > codegen_tests/10_forall.logic
echo "forall x [Domain] P(x)" >> codegen_tests/10_forall.logic

echo "// Existential quantifier" > codegen_tests/11_exists.logic
echo "exists x [Domain] P(x)" >> codegen_tests/11_exists.logic

echo "// Nested quantifiers" > codegen_tests/12_nested_quantifiers.logic
echo "forall x [Domain] exists y [Range] P(x) /\ Q(y)" >> codegen_tests/12_nested_quantifiers.logic

# Group 4: Variables and Predicates
echo "// Variable" > codegen_tests/13_variable.logic
echo "p" >> codegen_tests/13_variable.logic

echo "// Predicate" > codegen_tests/14_predicate.logic
echo "P(x)" >> codegen_tests/14_predicate.logic

echo "// Predicate with multiple args" > codegen_tests/15_pred_args.logic
echo "P(x, y, z)" >> codegen_tests/15_pred_args.logic

# Build the code generator
echo "Building code generator..."
cp Makefile.phase4 Makefile
make clean
make code_generator

if [ -f "code_generator" ]; then
  echo "Build successful! The code generator has been built."
  echo -e "\nYou can now run tests with: bash test_codegen.sh"
  echo "Or generate assembly for a specific file with: ./code_generator input.logic [output.s] [-s] [-o]"
else
  echo "Build failed. Check the error messages above."
  exit 1
fi