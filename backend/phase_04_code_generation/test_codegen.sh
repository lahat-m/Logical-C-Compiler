#!/bin/bash
# Make this script executable
chmod +x "$0"


# test path files
TEST_PATH="codegen_tests"
# Create directories if they don't exist
mkdir -p codegen_results

# Function to create a test file
run_test() {
    local test_files="${TEST_PATH}/$1"
    local description="$2"
    
    echo "// $description" > "$test_files"
    
    # Add the test content line by line
    shift 2
    for line in "$@"; do
        echo "$line" >> "$test_files"
    done
    
    echo "Created: $test_files"
}

# Function to run a test
run_test() {
    local test_file="${TEST_PATH}/$1"
    local output_file="codegen_results/${1%.logic}.s"
    local options="$2"
    
    echo "=========================================="
    echo "TESTING: $1 $options"
    echo "INPUT:"
    cat "$test_file"
    echo "------------------------------------------"
    
    # Run the code generator
    ./code_generator "$test_file" "$output_file" $options
    
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
    run_test "01_literal.logic" "Simple literal" \
        "TRUE"
    
    run_test "02_not.logic" "NOT operation" \
        "~TRUE"
    
    run_test "03_and.logic" "AND operation" \
        "TRUE /\\ FALSE"
    
    run_test "04_or.logic" "OR operation" \
        "TRUE \\/ FALSE"
    
    run_test "05_implies.logic" "IMPLIES operation" \
        "TRUE -> FALSE"
    
    run_test "06_iff.logic" "IFF operation" \
        "TRUE <-> FALSE"
    
    run_test "07_xor.logic" "XOR operation" \
        "TRUE ^ FALSE"
    
    # Group 2: Complex expressions
    run_test "08_complex.logic" "Complex expression" \
        "(TRUE /\\ FALSE) \\/ (~TRUE -> FALSE)"
    
    run_test "09_precedence.logic" "Operator precedence" \
        "TRUE /\\ FALSE \\/ TRUE -> FALSE <-> TRUE ^ FALSE"
    
    # Group 3: Quantifiers
    run_test "10_forall.logic" "Universal quantifier" \
        "forall x [Domain] P(x)"
    
    run_test "11_exists.logic" "Existential quantifier" \
        "exists x [Domain] P(x)"
    
    run_test "12_nested_quantifiers.logic" "Nested quantifiers" \
        "forall x [Domain] exists y [Range] P(x) /\\ Q(y)"
    
    # Group 4: Variables and predicates
    run_test "13_variable.logic" "Variable" \
        "p"
    
    run_test "14_predicate.logic" "Predicate" \
        "P(x)"
    
    run_test "15_pred_args.logic" "Predicate with multiple args" \
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
echo "Assembly output files are in the codegen_results directory."