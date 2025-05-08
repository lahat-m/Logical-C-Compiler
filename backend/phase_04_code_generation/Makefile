CC = gcc
CFLAGS = -Wall -g
LEX = flex
LEXFLAGS = -o lexer.c
YACC = bison
YACCFLAGS = -d -o parser.c

# Directory structure
FRONTEND_DIR = ../../frontend
PHASE1_DIR = $(FRONTEND_DIR)/phase_01_lexical_analysis
PHASE2_DIR = $(FRONTEND_DIR)/phase_02_syntax_analysis
PHASE3_DIR = $(FRONTEND_DIR)/phase_03_semantic_analysis
PHASE4_DIR = .
BUILD_DIR = build

# Source files from previous phases
PHASE1_LEXER = $(PHASE1_DIR)/lexer.l
PHASE2_PARSER = $(PHASE2_DIR)/parser.y
PHASE3_AST_C = $(PHASE3_DIR)/ast.c
PHASE3_AST_H = $(PHASE3_DIR)/ast.h
PHASE3_SYMBOL_TABLE_C = $(PHASE3_DIR)/symbol_table.c
PHASE3_SYMBOL_TABLE_H = $(PHASE3_DIR)/symbol_table.h

# Default target - build the code generator
all: code_generator

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Option 1: Build with local files (original behavior)
code_generator: lexer.c parser.c ast.c ast.h codegen.c codegen.h codegen_main.c
	$(CC) $(CFLAGS) -o code_generator lexer.c parser.c ast.c codegen.c codegen_main.c

# Option 2: Build with files from previous phases
code_generator_with_paths: phase1_lexer phase2_parser phase3_ast phase3_symbol_table codegen.c codegen.h codegen_main.c
	$(CC) $(CFLAGS) -o code_generator lexer.c parser.c ast.c symbol_table.c codegen.c codegen_main.c

# Generate lexer from local flex specification
lexer.c: lexer.l parser.h
	$(LEX) $(LEXFLAGS) lexer.l

# Generate lexer from phase 1 flex specification
phase1_lexer: $(PHASE1_LEXER) parser.h
	$(LEX) $(LEXFLAGS) $(PHASE1_LEXER)

# Generate parser from local bison specification
parser.c parser.h: parser.y
	$(YACC) $(YACCFLAGS) parser.y

# Generate parser from phase 2 bison specification
phase2_parser: $(PHASE2_PARSER)
	$(YACC) $(YACCFLAGS) $(PHASE2_PARSER)

# Use AST from phase 3
phase3_ast: $(PHASE3_AST_C) $(PHASE3_AST_H)
	cp $(PHASE3_AST_C) ast.c
	cp $(PHASE3_AST_H) ast.h

# Use Symbol Table from phase 3
phase3_symbol_table: $(PHASE3_SYMBOL_TABLE_C) $(PHASE3_SYMBOL_TABLE_H)
	cp $(PHASE3_SYMBOL_TABLE_C) symbol_table.c
	cp $(PHASE3_SYMBOL_TABLE_H) symbol_table.h

# Copy necessary files from previous phases if needed
copy_previous_phases:
	cp $(PHASE1_LEXER) lexer.l
	cp $(PHASE2_PARSER) parser.y
	cp $(PHASE3_AST_C) ast.c
	cp $(PHASE3_AST_H) ast.h
	cp $(PHASE3_SYMBOL_TABLE_C) symbol_table.c
	cp $(PHASE3_SYMBOL_TABLE_H) symbol_table.h

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
	rm -rf codegen_tests codegen_results $(BUILD_DIR)

.PHONY: all test_codegen clean distclean test_dirs copy_previous_phases