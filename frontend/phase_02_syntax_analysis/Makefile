CC = gcc
CFLAGS = -Wall -g
LEX = flex
LEXFLAGS = -o lexer.c
YACC = bison
YACCFLAGS = -d -o parser.c

# Directory structure
FRONTEND_DIR = ..
PHASE1_DIR = $(FRONTEND_DIR)/phase_01_lexical_analysis
PHASE2_DIR = .
BUILD_DIR = build

# Phase 1 source files (can be used from their original location)
PHASE1_LEXER = $(PHASE1_DIR)/lexer.l
PHASE1_TOKENS = $(PHASE1_DIR)/tokens.h

all: compiler

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Option 1: Build with local files (original behavior)
compiler: lexer.c parser.c ast.c ast.h
	$(CC) $(CFLAGS) -o compiler lexer.c parser.c ast.c -DTEST_PARSER

# Option 2: Build with files from phase 1 (use this if you want to reference files from phase 1)
compiler_with_phase1: phase1_lexer parser.c ast.c ast.h
	$(CC) $(CFLAGS) -o compiler lexer.c parser.c ast.c -DTEST_PARSER

# Generate lexer from local flex specification
lexer.c: lexer.l parser.h
	$(LEX) $(LEXFLAGS) lexer.l

# Generate lexer from phase 1 flex specification (when using files from phase 1)
phase1_lexer: $(PHASE1_LEXER) parser.h
	$(LEX) $(LEXFLAGS) $(PHASE1_LEXER)

# Generate parser from bison specification
parser.c parser.h: parser.y
	$(YACC) $(YACCFLAGS) parser.y

lexer_only: lexer.c tokens.h
	$(CC) $(CFLAGS) -o lexer lexer.c -DTEST_LEXER

# Copy necessary files from phase 1 if needed
copy_phase1:
	cp $(PHASE1_LEXER) lexer.l
	cp $(PHASE1_TOKENS) tokens.h

test: compiler test_files
	@echo "Running parser tests..."
	bash run_parser_test.sh

test_files:
	@mkdir -p tests

clean:
	rm -f lexer compiler parser.c parser.h lexer.c *.o
	rm -f test_results.txt parser_test_results.txt
	rm -f tokens.h

distclean: clean
	rm -rf $(BUILD_DIR)

.PHONY: all test clean test_files copy_phase1 distclean