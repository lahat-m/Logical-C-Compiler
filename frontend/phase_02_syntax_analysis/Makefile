CC = gcc
CFLAGS = -Wall -g
LEX = flex
LEXFLAGS = -o lexer.c
YACC = bison
YACCFLAGS = -d -o parser.c

all: compiler

compiler: lexer.c parser.c ast.c ast.h
	$(CC) $(CFLAGS) -o compiler lexer.c parser.c ast.c -DTEST_PARSER

lexer.c: lexer.l parser.h
	$(LEX) $(LEXFLAGS) lexer.l

parser.c parser.h: parser.y
	$(YACC) $(YACCFLAGS) parser.y

lexer_only: lexer.c tokens.h
	$(CC) $(CFLAGS) -o lexer lexer.c -DTEST_LEXER

test: compiler test_files
	@echo "Running parser tests..."
	bash run_parser_test.sh

test_files:
	@mkdir -p tests

clean:
	rm -f lexer compiler parser.c parser.h lexer.c *.o
	rm -f test_results.txt parser_test_results.txt
	rm -f tokens.h

.PHONY: all test clean test_files