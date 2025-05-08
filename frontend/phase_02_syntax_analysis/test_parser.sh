#!/bin/bash
# Make the script executable
chmod +x "$0"

# Directory settings
TEST_DIR="tests"
BUILD_DIR="build"

# Ensure the compiler is built
if [ ! -f "compiler" ]; then
    echo "Compiler not found. Building..."
    make compiler
fi

# Create test directory if it doesn't exist
mkdir -p "$TEST_DIR"

# Check if the test files exist, if not create them
if [ ! -f "$TEST_DIR/test_unary.logic" ]; then
    echo "Creating test files..."
    
    # Create test_unary.logic
    cat > "$TEST_DIR/test_unary.logic" << EOF
// Testing unary operators
~p
~(p /\ q)
~(~p)
~(p -> q)
~~p
EOF

    # Create test_quantifiers.logic
    cat > "$TEST_DIR/test_quantifiers.logic" << EOF
// Testing quantifiers
forall x [Domain] P(x)
exists y [Domain] Q(y)
forall x [Domain] (P(x) -> Q(x))
exists y [Range] (R(y) /\ S(y))
EOF

    # Create test_complex.logic
    cat > "$TEST_DIR/test_complex.logic" << EOF
// Complex nested expressions
forall x [Domain] (
    (P(x) /\ Q(x)) -> 
    (exists y [Range] (
        R(x, y) \/ ~S(y)
    ))
)
EOF

    # Copy files to current directory for backward compatibility
    cp "$TEST_DIR/test_unary.logic" ./test_unary.logic
    cp "$TEST_DIR/test_quantifiers.logic" ./test_quantifiers.logic
    cp "$TEST_DIR/test_complex.logic" ./test_complex.logic
fi

echo -e "\n===== Testing Unary Operators ====="
./compiler test_unary.logic

echo -e "\n===== Testing Quantifiers ====="
./compiler test_quantifiers.logic

echo -e "\n===== Testing Complex Expression ====="
./compiler test_complex.logic

# Optionally, run tests using files from the test directory
echo -e "\n===== Testing from the test directory ====="
./compiler "$TEST_DIR/test_unary.logic"
./compiler "$TEST_DIR/test_quantifiers.logic"
./compiler "$TEST_DIR/test_complex.logic"

echo -e "\nAll parser tests completed."