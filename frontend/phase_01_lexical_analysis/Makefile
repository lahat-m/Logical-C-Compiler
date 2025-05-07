CC = gcc
CFLAGS = -Wall -g
LEX = flex
LEXFLAGS = -o lexer.c

all: lexer

lexer: lexer.c tokens.h
	$(CC) $(CFLAGS) -o lexer lexer.c -DTEST_LEXER

lexer.c: lexer.l
	$(LEX) $(LEXFLAGS) lexer.l

test: lexer test_files
	@echo "Running lexical analyzer tests..."
	bash run_test.sh

test_files:
	@mkdir -p tests

clean:
	rm -f lexer lexer.c *.o
	rm -f test_results.txt

.PHONY: all test clean test_files