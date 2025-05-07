#!/bin/bash
# Make the script executable
chmod +x "$0"

# Directory for test files
TEST_DIR="tests"
RESULTS_FILE="test_results.txt"

# Clear results file
> $RESULTS_FILE

# Function to run a test
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .logic)
    
    echo "Running test: $test_name"
    echo "===== TEST: $test_name =====" >> $RESULTS_FILE
    ./lexer "$test_file" >> $RESULTS_FILE 2>&1
    echo -e "\n\n" >> $RESULTS_FILE
}

# Create test files if they don't exist
if [ ! -d "$TEST_DIR" ]; then
    mkdir -p "$TEST_DIR"
fi

if [ ! -f "$TEST_DIR/test_operators.logic" ]; then
    echo "Creating test files..."
    
    # Test file for operators
    cat > "$TEST_DIR/test_operators.logic" << EOF
// Test file for logical operators
p /\ q  // AND
p \/ q  // OR
~p      // NOT
p -> q  // IMPLIES
p <-> q // IFF
p ^ q   // XOR
EOF

    # Test file for quantifiers and literals
    cat > "$TEST_DIR/test_quantifiers.logic" << EOF
/* Test file for 
   quantifiers and literals */
forall x [Domain] P(x)
exists y [Domain] Q(y)
TRUE
FALSE
EOF

    # Test file for identifiers
    cat > "$TEST_DIR/test_identifiers.logic" << EOF
// Variables (lowercase)
x
variable_1
myVar
a123

// Predicates (uppercase)
Predicate
IsTrue
P
Test_Predicate
EOF

    # Test file for errors
    cat > "$TEST_DIR/test_errors.logic" << EOF
// Invalid characters
$invalid
@symbol

// Unterminated comment
/*
  This comment doesn't end

// Identifier too long (more than 64 characters)
abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrst
EOF

    # Complex test file
    cat > "$TEST_DIR/test_complex.logic" << EOF
// Complex logical expression
forall x [Domain] (
    (P(x) /\ Q(x)) -> 
    (exists y [Range] (
        R(x, y) \/ ~S(y)
    ))
) <-> TRUE
EOF
fi

# Run all tests
for test_file in "$TEST_DIR"/*.logic; do
    run_test "$test_file"
done

echo "All tests completed. Results in $RESULTS_FILE"