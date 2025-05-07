#!/bin/bash
# Make the script executable
chmod +x "$0"

echo "Building Semantic Analyzer directly..."

# First, build the parser to generate parser.h
echo "Building parser..."
bison -d -o parser.c parser.y

# Build the lexer
echo "Building lexer..."
flex -o lexer.c lexer.l

# Compile the semantic analyzer directly
echo "Compiling semantic analyzer..."
gcc -Wall -g -o semantic_analyzer lexer.c parser.c ast.c symbol_table.c semantic.c semantic_main.c

# Check if the executable was created
if [ -f "semantic_analyzer" ]; then
    echo "Build successful! You can now run: ./semantic_analyzer [input_file]"
else
    echo "Build failed. Checking for errors..."
    
    # Try to compile each file separately to identify issues
    echo "Testing individual compilation..."
    
    echo "Compiling ast.c..."
    gcc -Wall -g -c ast.c
    
    echo "Compiling symbol_table.c..."
    gcc -Wall -g -c symbol_table.c
    
    echo "Compiling semantic.c..."
    gcc -Wall -g -c semantic.c
    
    echo "Compiling semantic_main.c..."
    gcc -Wall -g -c semantic_main.c
    
    echo "Individual compilations completed. Check for errors above."
fi