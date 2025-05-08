#!/bin/bash
# Script to set up and build Phase 4 (Code Generation)

# Make this script executable
chmod +x "$0"

# Define directory structure
FRONTEND_DIR="../../frontend"
PHASE1_DIR="${FRONTEND_DIR}/phase_01_lexical_analysis"
PHASE2_DIR="${FRONTEND_DIR}/phase_02_syntax_analysis"
PHASE3_DIR="${FRONTEND_DIR}/phase_03_semantic_analysis"
PHASE4_DIR="."
BUILD_DIR="build"

# Create build directory
mkdir -p "${BUILD_DIR}"

# Function to check if a file exists in current directory or in a source directory
check_file() {
    local file="$1"
    local source_dir="$2"
    
    if [ -f "$file" ]; then
        echo "FOUND: $file (local)"
        return 0
    elif [ -f "${source_dir}/$file" ]; then
        echo "FOUND: $file (in ${source_dir})"
        return 0
    else
        echo "MISSING: $file"
        return 1
    fi
}

# Check if we have all required files
echo "Checking for required files..."
missing=0

# Check lexer.l (from Phase 1)
if ! check_file "lexer.l" "${PHASE1_DIR}"; then
    missing=1
fi

# Check parser.y (from Phase 2)
if ! check_file "parser.y" "${PHASE2_DIR}"; then
    missing=1
fi

# Check AST files (from Phase 3)
if ! check_file "ast.h" "${PHASE3_DIR}"; then
    missing=1
fi
if ! check_file "ast.c" "${PHASE3_DIR}"; then
    missing=1
fi

# Check Phase 4 specific files
if ! check_file "codegen.h" "${PHASE4_DIR}"; then
    missing=1
fi
if ! check_file "codegen.c" "${PHASE4_DIR}"; then
    missing=1
fi
if ! check_file "codegen_main.c" "${PHASE4_DIR}"; then
    missing=1
fi
if ! check_file "Makefile" "${PHASE4_DIR}"; then
    missing=1
fi
if ! check_file "test_codegen.sh" "${PHASE4_DIR}"; then
    missing=1
fi

if [ $missing -eq 1 ]; then
    echo "Error: Some required files are missing. Please make sure all files are present."
    exit 1
fi

# Copy files from previous phases if needed
echo "Setting up files from previous phases..."

# Copy lexer.l if needed
if [ ! -f "lexer.l" ] && [ -f "${PHASE1_DIR}/lexer.l" ]; then
    echo "Copying lexer.l from Phase 1"
    cp "${PHASE1_DIR}/lexer.l" .
fi

# Copy parser.y if needed
if [ ! -f "parser.y" ] && [ -f "${PHASE2_DIR}/parser.y" ]; then
    echo "Copying parser.y from Phase 2"
    cp "${PHASE2_DIR}/parser.y" .
fi

# Copy AST files if needed
if [ ! -f "ast.h" ] && [ -f "${PHASE3_DIR}/ast.h" ]; then
    echo "Copying ast.h from Phase 3"
    cp "${PHASE3_DIR}/ast.h" .
fi
if [ ! -f "ast.c" ] && [ -f "${PHASE3_DIR}/ast.c" ]; then
    echo "Copying ast.c from Phase 3"
    cp "${PHASE3_DIR}/ast.c" .
fi

# Create test directories and files
echo "Setting up test directories..."
mkdir -p codegen_tests
mkdir -p codegen_results

# Create test files (same as before)
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

# Option 1: Build with local files
echo "Building with local files..."
make clean
make code_generator

# Option 2: Build with files from previous phases
if [ ! -f "code_generator" ]; then
    echo "Trying to build with files from previous phases..."
    make code_generator_with_paths
fi

if [ -f "code_generator" ]; then
    echo "Build successful! The code generator has been built."
    echo -e "\nYou can now run tests with: bash test_codegen.sh"
    echo "Or generate assembly for a specific file with: ./code_generator input.logic [output.s] [-s] [-o]"
    echo -e "\nExamples:"
    echo "  Generate assembly for a basic test:"
    echo "    ./code_generator codegen_tests/01_literal.logic"
    echo -e "\n  Generate assembly with short-circuit evaluation enabled:"
    echo "    ./code_generator codegen_tests/03_and.logic -s"
    echo -e "\n  Generate assembly with optimization enabled:"
    echo "    ./code_generator codegen_tests/08_complex.logic -o"
    echo -e "\n  Generate assembly with custom output file:"
    echo "    ./code_generator codegen_tests/15_pred_args.logic my_output.s"
else
    echo "Build failed. Check the error messages above."
    exit 1
fi