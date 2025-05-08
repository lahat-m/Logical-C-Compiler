#!/bin/bash
# Make this script executable
chmod +x "$0"

# Define paths and directories
TEST_PATH="codegen_tests"
RESULTS_DIR="codegen_results"
BUILD_DIR="build"

# Ensure the code generator is built
if [ ! -f "code_generator" ]; then
    echo "Code generator not found. Building..."
    make code_generator
fi

# Create directories if they don't exist
mkdir -p "$TEST_PATH"
mkdir -p "$RESULTS_DIR"

# Function to create a test file
create_test() {
    local test_file="${TEST_PATH}/$1"
    local description="$2"
    
    echo "// $description" > "$test_file"
    
    # Add the test content line by line
    shift 2
    for line in "$@"; do
        echo "$line" >> "$test_file"
    done
    
    echo "Created: $test_file"
}

# Function to run a test
run_test() {
    local test_file="${TEST_PATH}/$1"
    local output_file="${RESULTS_DIR}/${1%.logic}.s"
    local options="$2"
    
    echo "=========================================="
    echo "TESTING: $1 $options"
    echo "INPUT:"
    cat "$test_file"
    echo "------------------------------------------"
    
    # Run the code generator
    ./code_generator "$test_file" $options > "$output_file" 2>&1
    
    echo "OUTPUT ASSEMBLY:"
    echo "------------------------------------------"
    cat "$output_file"
    echo "=========================================="
    echo
}

# Create test files if they don't exist
if [ ! -f "${TEST_PATH}/01_literal.logic" ]; then
    echo "Creating code generation test files..."
    
    # Group 1: Basic operations
    create_test "01_literal.logic" "Simple literal" \
        "TRUE"
    
    create_test "02_not.logic" "NOT operation" \
        "~TRUE"
    
    create_test "03_and.logic" "AND operation" \
        "TRUE /\\ FALSE"
    
    create_test "04_or.logic" "OR operation" \
        "TRUE \\/ FALSE"
    
    create_test "05_implies.logic" "IMPLIES operation" \
        "TRUE -> FALSE"
    
    create_test "06_iff.logic" "IFF operation" \
        "TRUE <-> FALSE"
    
    create_test "07_xor.logic" "XOR operation" \
        "TRUE ^ FALSE"
    
    # Group 2: Complex expressions
    create_test "08_complex.logic" "Complex expression" \
        "(TRUE /\\ FALSE) \\/ (~TRUE -> FALSE)"
    
    create_test "09_precedence.logic" "Operator precedence" \
        "TRUE /\\ FALSE \\/ TRUE -> FALSE <-> TRUE ^ FALSE"
    
    # Group 3: Quantifiers
    create_test "10_forall.logic" "Universal quantifier" \
        "forall x [Domain] P(x)"
    
    create_test "11_exists.logic" "Existential quantifier" \
        "exists x [Domain] P(x)"
    
    create_test "12_nested_quantifiers.logic" "Nested quantifiers" \
        "forall x [Domain] exists y [Range] P(x) /\\ Q(y)"
    
    # Group 4: Variables and predicates
    create_test "13_variable.logic" "Variable" \
        "p"
    
    create_test "14_predicate.logic" "Predicate" \
        "P(x)"
    
    create_test "15_pred_args.logic" "Predicate with multiple args" \
        "P(x, y, z)"
fi

# Run the tests
echo "Running code generation tests..."

# Test basic operations
echo "===== Group 1: Basic Operations ====="
run_test "01_literal.logic"
run_test "02_not.logic"
run_test "03_and.logic"
run_test "04_or.logic"
run_test "05_implies.logic"
run_test "06_iff.logic"
run_test "07_xor.logic"

# Test complex expressions
echo "===== Group 2: Complex Expressions ====="
run_test "08_complex.logic"
run_test "09_precedence.logic"

# Test quantifiers
echo "===== Group 3: Quantifiers ====="
run_test "10_forall.logic"
run_test "11_exists.logic"
run_test "12_nested_quantifiers.logic"

# Test variables and predicates
echo "===== Group 4: Variables and Predicates ====="
run_test "13_variable.logic"
run_test "14_predicate.logic"
run_test "15_pred_args.logic"

# Test with short-circuit evaluation enabled
echo "===== Testing Short-Circuit Evaluation ====="
run_test "03_and.logic" "-s"
run_test "04_or.logic" "-s"
run_test "08_complex.logic" "-s"

echo "All code generation tests completed."
echo "Assembly output files are in the $RESULTS_DIR directory."