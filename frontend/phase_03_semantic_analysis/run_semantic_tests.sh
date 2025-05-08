#!/bin/bash
# Make this script executable
chmod +x "$0"

# Define paths and directories
TEST_PATH="semantic_tests"
RESULTS_DIR="test_results"
BUILD_DIR="build"

# Ensure the semantic analyzer is built
if [ ! -f "semantic_analyzer" ]; then
    echo "Semantic analyzer not found. Building..."
    make semantic_analyzer
fi

# Create directories if they don't exist
mkdir -p "$RESULTS_DIR"

# Function to run a test
run_test() {
    local test_file="${TEST_PATH}/$1"
    local test_name=$(basename "$1" .logic)
    local expected_result="$2"
    local result_file="$RESULTS_DIR/${test_name}_result.txt"
    
    echo -n "Running test: ${test_name}... "
    
    # Check if the test file exists
    if [ ! -f "$test_file" ]; then
        echo "ERROR: Test file not found: $test_file"
        return
    fi
    
    # Run the semantic analyzer
    ./semantic_analyzer "$test_file" > "$result_file" 2>&1
    
    # Check the result
    if grep -q "Semantic analysis completed successfully" "$result_file"; then
        if [ "$expected_result" == "PASS" ] || [ "$expected_result" == "PASS_WITH_WARNING" ]; then
            echo "PASSED"
        else
            echo "UNEXPECTED PASS (expected failure)"
        fi
    elif grep -q "Semantic analysis failed" "$result_file"; then
        if [ "$expected_result" == "FAIL" ]; then
            echo "FAILED (as expected)"
        else
            echo "UNEXPECTED FAILURE (expected pass)"
        fi
    else
        echo "PARSING ERROR"
    fi
}

# Check if test files exist, otherwise suggest running the setup script
if [ ! -d "$TEST_PATH" ] || [ -z "$(ls -A "$TEST_PATH" 2>/dev/null)" ]; then
    echo "ERROR: No test files found in $TEST_PATH directory."
    echo "Please run the setup script first to create the test files."
    exit 1
fi

# Run all the tests
echo "===== GROUP 1: Valid Expressions (should all pass) ====="
run_test "01_valid_simple.logic" "PASS"
run_test "02_valid_complex.logic" "PASS"
run_test "03_valid_nested.logic" "PASS"
run_test "04_valid_multi.logic" "PASS"
run_test "05_valid_constants.logic" "PASS"

echo -e "\n===== GROUP 2: Variable Binding Errors (should all fail) ====="
run_test "06_unbound_simple.logic" "FAIL"
run_test "07_unbound_complex.logic" "FAIL"
run_test "08_unbound_scope.logic" "FAIL"

echo -e "\n===== GROUP 3: Predicate Arity Errors (should all fail) ====="
run_test "09_arity_simple.logic" "FAIL"
run_test "10_arity_mixed.logic" "FAIL"
run_test "11_arity_complex.logic" "FAIL"

echo -e "\n===== GROUP 4: Variable Shadowing (should have warnings but pass) ====="
run_test "12_shadow_simple.logic" "PASS_WITH_WARNING"
run_test "13_shadow_multi.logic" "PASS_WITH_WARNING"
run_test "14_shadow_separate.logic" "PASS_WITH_WARNING"

echo -e "\n===== GROUP 5: All Logical Operators (should all pass) ====="
run_test "15_operators_and.logic" "PASS"
run_test "16_operators_or.logic" "PASS"
run_test "17_operators_not.logic" "PASS"
run_test "18_operators_implies.logic" "PASS"
run_test "19_operators_iff.logic" "PASS"
run_test "20_operators_xor.logic" "PASS"
run_test "21_operators_precedence.logic" "PASS"

echo -e "\n===== GROUP 6: Mixed Errors (should fail) ====="
run_test "22_mixed_errors.logic" "FAIL"

echo -e "\nAll tests completed. Detailed results are in the $RESULTS_DIR directory."
echo "To view a specific test result: cat $RESULTS_DIR/[test_name]_result.txt"