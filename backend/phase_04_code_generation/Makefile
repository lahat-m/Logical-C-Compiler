CC = gcc
CFLAGS = -Wall -g
LEX = flex
LEXFLAGS = -o lexer.c
YACC = bison
YACCFLAGS = -d -o parser.c

# Default target - build the code generator
all: code_generator

# Phase 4: Code Generator
code_generator: lexer.c parser.c ast.c ast.h codegen.c codegen.h codegen_main.c
	$(CC) $(CFLAGS) -o code_generator lexer.c parser.c ast.c codegen.c codegen_main.c

# Generate lexer from flex specification
lexer.c: lexer.l parser.h
	$(LEX) $(LEXFLAGS) lexer.l

# Generate parser from bison specification
parser.c parser.h: parser.y
	$(YACC) $(YACCFLAGS) parser.y

# Create test directories
test_dirs:
	@mkdir -p codegen_tests
	@mkdir -p codegen_results

# Run code generation tests
test_codegen: code_generator test_dirs
	@echo "Running code generation tests..."
	@bash test_codegen.sh

# Clean all generated files
clean:
	rm -f code_generator parser.c parser.h lexer.c *.o *.s
	rm -f codegen_results/*.s

# Very clean - also removes test files
distclean: clean
	rm -rf codegen_tests codegen_results

.PHONY: all test_codegen clean distclean test_dirs