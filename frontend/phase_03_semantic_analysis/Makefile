CC = gcc
CFLAGS = -Wall -g
LEX = flex
LEXFLAGS = -o lexer.c
YACC = bison
YACCFLAGS = -d -o parser.c

# Default target - build everything
all: compiler semantic_analyzer tests

# Phase 1 and 2: Lexer and Parser
compiler: lexer.c parser.c ast.c ast.h
	$(CC) $(CFLAGS) -o compiler lexer.c parser.c ast.c -DTEST_PARSER

# Phase 3: Semantic Analyzer
semantic_analyzer: lexer.c parser.c ast.c ast.h symbol_table.c symbol_table.h semantic.c semantic.h semantic_main.c
	$(CC) $(CFLAGS) -o semantic_analyzer lexer.c parser.c ast.c symbol_table.c semantic.c semantic_main.c

# Generate lexer from flex specification
lexer.c: lexer.l parser.h
	$(LEX) $(LEXFLAGS) lexer.l

# Generate parser from bison specification
parser.c parser.h: parser.y
	$(YACC) $(YACCFLAGS) parser.y

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
	rm -rf tests

# Help target
help:
	@echo "Logic Compiler Makefile"
	@echo "----------------------"
	@echo "Targets:"
	@echo "  all              Build compiler, semantic analyzer, and create test files"
	@echo "  compiler         Build the parser (Phase 1 & 2)"
	@echo "  semantic_analyzer Build the semantic analyzer (Phase 3)"
	@echo "  test_lexer       Run lexer tests only"
	@echo "  test_parser      Run parser tests only"
	@echo "  run_semantic_tests    Run semantic tests only"
	@echo "  clean            Remove all generated files"
	@echo "  distclean        Remove all generated files and test files"
	@echo "  help             Display this help message"

.PHONY: all tests run_tests test_lexer build_parser run_semantic_tests clean distclean help