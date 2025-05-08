CC = gcc
CFLAGS = -Wall -g
LEX = flex
LEXFLAGS = -o lexer.c
YACC = bison
YACCFLAGS = -d -o parser.c

# Directory structure
FRONTEND_DIR = ..
PHASE1_DIR = $(FRONTEND_DIR)/phase_01_lexical_analysis
PHASE2_DIR = $(FRONTEND_DIR)/phase_02_syntax_analysis
PHASE3_DIR = .
BUILD_DIR = build

# Phase 1 and 2 source files (can be used from their original location)
PHASE1_LEXER = $(PHASE1_DIR)/lexer.l
PHASE1_TOKENS = $(PHASE1_DIR)/tokens.h
PHASE2_PARSER = $(PHASE2_DIR)/parser.y
PHASE2_AST_C = $(PHASE2_DIR)/ast.c
PHASE2_AST_H = $(PHASE2_DIR)/ast.h

# Default target - build everything
all: compiler semantic_analyzer tests

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Option 1: Build with local files (original behavior)
# Phase 1 and 2: Lexer and Parser
compiler: lexer.c parser.c ast.c ast.h
	$(CC) $(CFLAGS) -o compiler lexer.c parser.c ast.c -DTEST_PARSER

# Option 2: Build with files from previous phases
compiler_with_paths: phase1_lexer phase2_parser phase2_ast
	$(CC) $(CFLAGS) -o compiler lexer.c parser.c ast.c -DTEST_PARSER

# Phase 3: Semantic Analyzer
semantic_analyzer: lexer.c parser.c ast.c ast.h symbol_table.c symbol_table.h semantic.c semantic.h semantic_main.c
	$(CC) $(CFLAGS) -o semantic_analyzer lexer.c parser.c ast.c symbol_table.c semantic.c semantic_main.c

# Option 2: Build semantic analyzer with files from previous phases
semantic_analyzer_with_paths: phase1_lexer phase2_parser phase2_ast symbol_table.c symbol_table.h semantic.c semantic.h semantic_main.c
	$(CC) $(CFLAGS) -o semantic_analyzer lexer.c parser.c ast.c symbol_table.c semantic.c semantic_main.c

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

# Use AST from phase 2
phase2_ast: $(PHASE2_AST_C) $(PHASE2_AST_H)
	cp $(PHASE2_AST_C) ast.c
	cp $(PHASE2_AST_H) ast.h

# Copy necessary files from previous phases if needed
copy_previous_phases:
	cp $(PHASE1_LEXER) lexer.l
	cp $(PHASE2_PARSER) parser.y
	cp $(PHASE2_AST_C) ast.c
	cp $(PHASE2_AST_H) ast.h

# Create test files and run tests
tests: compiler semantic_analyzer test_files
	@echo "Creating test files..."
	@bash create_test_files.sh 2>/dev/null || echo "Test files already exist"

# Ensure test directory exists
test_files:
	@mkdir -p tests

# Run all tests
run_tests: all
	@echo "Running all semantic analysis tests..."
	@bash run_all_tests.sh

# Phase 1 test only
test_lexer: compiler
	@echo "Running lexical analyzer tests..."
	@bash run_test.sh

# Phase 2 test only
test_parser: compiler
	@echo "Running parser tests..."
	@bash build_parser.sh

# Phase 3 test only
test_semantic: semantic_analyzer
	@echo "Running semantic analyzer tests..."
	@bash run_semantic_tests.sh

# Clean all generated files
clean:
	rm -f lexer compiler semantic_analyzer parser.c parser.h lexer.c *.o
	rm -f test_results.txt parser_test_results.txt semantic_test_results.txt semantic_analysis_results.txt

# Very clean - also removes test files
distclean: clean
	rm -rf tests $(BUILD_DIR)

# Help target
help:
	@echo "Logic Compiler Makefile"
	@echo "----------------------"
	@echo "Targets:"
	@echo "  all                        Build compiler, semantic analyzer, and create test files"
	@echo "  compiler                   Build the parser (Phase 1 & 2) with local files"
	@echo "  compiler_with_paths        Build the parser using files from previous phases"
	@echo "  semantic_analyzer          Build the semantic analyzer with local files"
	@echo "  semantic_analyzer_with_paths Build the semantic analyzer using files from previous phases"
	@echo "  copy_previous_phases       Copy files from previous phases to current directory"
	@echo "  test_lexer                 Run lexer tests only"
	@echo "  test_parser                Run parser tests only"
	@echo "  run_semantic_tests         Run semantic tests only"
	@echo "  clean                      Remove all generated files"
	@echo "  distclean                  Remove all generated files and test files"
	@echo "  help                       Display this help message"

.PHONY: all tests run_tests test_lexer build_parser run_semantic_tests clean distclean help copy_previous_phases