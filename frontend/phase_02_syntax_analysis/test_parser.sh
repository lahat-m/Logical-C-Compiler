#!/bin/bash
# Make the script executable
chmod +x "$0"

echo -e "\n===== Testing Unary Operators ====="
./compiler test_unary.logic

echo -e "\n===== Testing Quantifiers ====="
./compiler test_quantifiers.logic

echo -e "\n===== Testing Complex Expression ====="
./compiler test_complex.logic