#!/bin/bash
# Make the script executable
chmod +x "$0"

# Create a simpler test file
cat > test_domain.logic << EOF
// Test with simpler domain
forall x [simple] P(x)
EOF

# Modify the lexer to make sure domains are handled properly
cat > lexer.l << EOF
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "parser.h"  /* Include only parser.h, not tokens.h */

int line_num = 1;
int col_num = 1;
void update_position();
void handle_error();

/* Suppress yyunput unused function warning */
#define YY_NO_UNPUT
%}

%option noyywrap

/* Regular expression shorthand */
WHITESPACE      [ \t]+
NEWLINE         \n|\r\n|\r
DIGIT           [0-9]
ALPHA           [a-zA-Z]
ALPHANUMERIC    [a-zA-Z0-9_]

%%

{WHITESPACE}    { col_num += yyleng; }
{NEWLINE}       { line_num++; col_num = 1; }

"/\\"           { update_position(); return AND; }
"\\/"           { update_position(); return OR; }
"~"             { update_position(); return NOT; }
"->"            { update_position(); return IMPLIES; }
"<->"           { update_position(); return IFF; }
"^"             { update_position(); return XOR; }

[fF][oO][rR][aA][lL][lL] { update_position(); return FORALL; }
[eE][xX][iI][sS][tT][sS] { update_position(); return EXISTS; }
[tT][rR][uU][eE]         { update_position(); yylval.bool_val = true; return TRUE_VAL; }
[fF][aA][lL][sS][eE]     { update_position(); yylval.bool_val = false; return FALSE_VAL; }

"("             { update_position(); return LPAREN; }
")"             { update_position(); return RPAREN; }
"["             { update_position(); return LBRACKET; }
"]"             { update_position(); return RBRACKET; }
","             { update_position(); return ','; }

[a-z]{ALPHANUMERIC}*  { 
                        if (yyleng > 64) {
                            fprintf(stderr, "Error at line %d, column %d: Identifier '%s' exceeds maximum length of 64 characters\n", 
                                    line_num, col_num, yytext);
                        }
                        update_position(); 
                        yylval.string_val = strdup(yytext);
                        return VARIABLE; 
                      }

[A-Z]{ALPHANUMERIC}*  { 
                        if (yyleng > 64) {
                            fprintf(stderr, "Error at line %d, column %d: Identifier '%s' exceeds maximum length of 64 characters\n", 
                                    line_num, col_num, yytext);
                        }
                        update_position(); 
                        yylval.string_val = strdup(yytext);
                        return PREDICATE; 
                      }

"//".*          { /* Single line comment - ignore */ }

"/*"            { /* Begin multi-line comment */
                  int start_line = line_num;
                  int start_col = col_num;
                  char c, prev = 0;
                  update_position();
                  
                  while (1) {
                    c = input();
                    if (c == 0) {
                      fprintf(stderr, "Error: Unterminated comment starting at line %d, column %d\n", 
                              start_line, start_col);
                      break;
                    }
                    if (c == '/' && prev == '*')
                      break;
                    if (c == '\n') {
                      line_num++;
                      col_num = 1;
                    } else {
                      col_num++;
                    }
                    prev = c;
                  }
                }

.               { handle_error(); }

%%

void update_position() {
    col_num += yyleng;
}

void handle_error() {
    fprintf(stderr, "Error at line %d, column %d: Unrecognized character '%s'\n", 
            line_num, col_num, yytext);
    col_num++;
}

/* Main function for lexer testing (if needed) */
#ifdef TEST_LEXER
int main(int argc, char *argv[]) {
    /* Lexer testing code here if needed */
    return 0;
}
#endif
EOF

# Clean and rebuild
make clean
make

# Test the modified compiler with our simpler test file
echo "===== Testing Domain Handling ====="
./compiler test_domain.logic