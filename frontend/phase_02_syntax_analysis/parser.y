%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "ast.h"

/* External declarations */
extern int yylex();
extern int line_num;
extern int col_num;
extern FILE* yyin;
extern char* yytext;

/* Error handling */
void yyerror(const char* msg);
int syntax_errors = 0;

/* Root of the AST */
ASTNode* ast_root = NULL;
%}

/* Define the values that can be returned by terminals and non-terminals */
%union {
    int token;           /* For operators and keywords */
    char* string_val;    /* For identifiers */
    bool bool_val;       /* For TRUE/FALSE literals */
    struct ASTNode* node; /* For AST nodes */
    char** string_list;  /* For argument lists */
    struct {
        char** list;
        int size;
    } domain_info;       /* For domain lists with size */
}

/* Define tokens from the lexer */
%token <token> AND OR NOT IMPLIES IFF XOR
%token <token> FORALL EXISTS
%token <bool_val> TRUE_VAL FALSE_VAL
%token <token> LPAREN RPAREN LBRACKET RBRACKET
%token <string_val> VARIABLE PREDICATE

/* Define the types for non-terminals */
%type <node> program expr binary_expr unary_expr atom_expr quant_expr 
%type <node> literal variable predicate
%type <domain_info> domain domain_list
%type <string_list> arg_list
%type <token> binary_op quantifier

/* Define operator precedence (highest to lowest) and associativity */
%right NOT
%left AND
%left OR
%left XOR
%right IMPLIES
%left IFF

/* Entry point */
%start program

%%

program
    : expr
        {
            ast_root = $1;
            $$ = $1;
        }
    ;

expr
    : binary_expr
        {
            $$ = $1;
        }
    | unary_expr
        {
            $$ = $1;
        }
    | quant_expr
        {
            $$ = $1;
        }
    | atom_expr
        {
            $$ = $1;
        }
    ;

binary_expr
    : expr binary_op expr
        {
            $$ = create_binary_op_node($2, $1, $3);
        }
    ;

binary_op
    : AND      { $$ = AND; }
    | OR       { $$ = OR; }
    | IMPLIES  { $$ = IMPLIES; }
    | IFF      { $$ = IFF; }
    | XOR      { $$ = XOR; }
    ;

unary_expr
    : NOT expr
        {
            $$ = create_unary_op_node(NOT, $2);
        }
    ;

quant_expr
    : quantifier VARIABLE domain expr
        {
            $$ = create_quantifier_node($1, $2, $3.list, $3.size, $4);
        }
    ;

quantifier
    : FORALL   { $$ = FORALL; }
    | EXISTS   { $$ = EXISTS; }
    ;

domain
    : LBRACKET domain_list RBRACKET
        {
            $$ = $2;
        }
    ;

domain_list
    : VARIABLE
        {
            $$.list = create_domain_list($1);
            $$.size = 1;
        }
    | PREDICATE
        {
            $$.list = create_domain_list($1);
            $$.size = 1;
        }
    | VARIABLE ',' domain_list
        {
            $$.list = append_to_domain_list($3.list, $3.size, $1);
            $$.size = $3.size + 1;
        }
    | PREDICATE ',' domain_list
        {
            $$.list = append_to_domain_list($3.list, $3.size, $1);
            $$.size = $3.size + 1;
        }
    ;

atom_expr
    : LPAREN expr RPAREN
        {
            $$ = $2;
        }
    | predicate
        {
            $$ = $1;
        }
    | variable
        {
            $$ = $1;
        }
    | literal
        {
            $$ = $1;
        }
    ;

predicate
    : PREDICATE LPAREN arg_list RPAREN
        {
            /* Count the number of arguments */
            int count = 0;
            char** args_ptr = $3;
            while (args_ptr && *args_ptr) {
                count++;
                args_ptr++;
            }
            $$ = create_predicate_node($1, $3, count);
        }
    ;

arg_list
    : VARIABLE
        {
            $$ = create_arg_list($1);
        }
    | VARIABLE ',' arg_list
        {
            /* Count the number of existing arguments */
            int count = 0;
            char** args_ptr = $3;
            while (args_ptr && *args_ptr) {
                count++;
                args_ptr++;
            }
            $$ = append_to_arg_list($3, count, $1);
        }
    ;

variable
    : VARIABLE
        {
            $$ = create_variable_node($1);
        }
    ;

literal
    : TRUE_VAL
        {
            $$ = create_literal_node(true);
        }
    | FALSE_VAL
        {
            $$ = create_literal_node(false);
        }
    ;

%%

/* Error handler for Bison */
void yyerror(const char* msg) {
    syntax_errors++;
    fprintf(stderr, "Error at line %d, column %d: %s\n", line_num, col_num, msg);
    
    /* Add more context to the error message */
    fprintf(stderr, "Near token: '%s'\n", yytext);
}

/* Main function if we're testing the parser directly */
#ifdef TEST_PARSER
int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }
    
    FILE* input_file = fopen(argv[1], "r");
    if (!input_file) {
        fprintf(stderr, "Error: Cannot open file '%s'\n", argv[1]);
        return 1;
    }
    
    yyin = input_file;
    
    /* Parse the input */
    int parse_result = yyparse();
    
    /* Report results */
    if (parse_result == 0 && syntax_errors == 0) {
        printf("Parsing completed successfully.\n");
        
        /* Print the AST if parsing was successful */
        printf("Abstract Syntax Tree:\n");
        print_ast(ast_root, 0);
        
        /* Free the AST */
        free_ast(ast_root);
    } else {
        printf("Parsing failed with %d errors.\n", syntax_errors);
    }
    
    fclose(input_file);
    return parse_result;
}
#endif

/* Helper functions for AST construction */

ASTNode* create_binary_op_node(int operator, ASTNode* left, ASTNode* right) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_BINARY_OP;
    node->data.binary.operator = token_to_binary_op(operator);
    node->data.binary.left = left;
    node->data.binary.right = right;
    node->line = line_num;
    node->column = col_num;
    return node;
}

ASTNode* create_unary_op_node(int operator, ASTNode* operand) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_UNARY_OP;
    node->data.unary.operator = token_to_unary_op(operator);
    node->data.unary.operand = operand;
    node->line = line_num;
    node->column = col_num;
    return node;
}

ASTNode* create_quantifier_node(int quantifier, char* variable, char** domain, int domain_size, ASTNode* expr) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_QUANTIFIER;
    node->data.quantifier.quantifier = token_to_quantifier(quantifier);
    node->data.quantifier.variable = strdup(variable);
    node->data.quantifier.domain = (char**)malloc(sizeof(char*) * (domain_size + 1)); // +1 for NULL terminator
    
    /* Copy domain values */
    for (int i = 0; i < domain_size; i++) {
        node->data.quantifier.domain[i] = strdup(domain[i]);
    }
    node->data.quantifier.domain[domain_size] = NULL; // NULL-terminate the list
    
    node->data.quantifier.domain_size = domain_size;
    node->data.quantifier.expr = expr;
    node->line = line_num;
    node->column = col_num;
    
    /* Free the original domain list since we've duplicated it */
    for (int i = 0; i < domain_size; i++) {
        free(domain[i]);
    }
    free(domain);
    
    return node;
}

ASTNode* create_literal_node(bool value) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_LITERAL;
    node->data.literal.value = value;
    node->line = line_num;
    node->column = col_num;
    return node;
}

ASTNode* create_variable_node(char* name) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_VARIABLE;
    node->data.variable.name = strdup(name);
    node->line = line_num;
    node->column = col_num;
    return node;
}

ASTNode* create_predicate_node(char* name, char** args, int arg_count) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_PREDICATE;
    node->data.predicate.name = strdup(name);
    node->data.predicate.args = (char**)malloc(sizeof(char*) * (arg_count + 1)); // +1 for NULL terminator
    
    /* Copy argument names */
    for (int i = 0; i < arg_count; i++) {
        node->data.predicate.args[i] = strdup(args[i]);
    }
    node->data.predicate.args[arg_count] = NULL; // NULL-terminate the list
    
    node->data.predicate.arg_count = arg_count;
    node->line = line_num;
    node->column = col_num;
    
    /* Free the original arg list since we've duplicated it */
    for (int i = 0; i < arg_count; i++) {
        free(args[i]);
    }
    free(args);
    
    return node;
}

char** create_arg_list(char* arg) {
    char** list = (char**)malloc(sizeof(char*) * 2); // Space for the arg and NULL terminator
    list[0] = strdup(arg);
    list[1] = NULL;
    return list;
}

char** append_to_arg_list(char** arg_list, int curr_size, char* arg) {
    char** new_list = (char**)malloc(sizeof(char*) * (curr_size + 2)); // +1 for new arg, +1 for NULL
    
    /* Copy existing arguments */
    for (int i = 0; i < curr_size; i++) {
        new_list[i] = arg_list[i];
    }
    
    /* Add the new argument */
    new_list[curr_size] = strdup(arg);
    new_list[curr_size + 1] = NULL;
    
    /* Free the old list but not its contents */
    free(arg_list);
    
    return new_list;
}

char** create_domain_list(char* value) {
    char** list = (char**)malloc(sizeof(char*) * 2); // Space for the value and NULL terminator
    list[0] = strdup(value);
    list[1] = NULL;
    return list;
}

char** append_to_domain_list(char** domain_list, int curr_size, char* value) {
    char** new_list = (char**)malloc(sizeof(char*) * (curr_size + 2)); // +1 for new value, +1 for NULL
    
    /* Copy existing values */
    for (int i = 0; i < curr_size; i++) {
        new_list[i] = domain_list[i];
    }
    
    /* Add the new value */
    new_list[curr_size] = strdup(value);
    new_list[curr_size + 1] = NULL;
    
    /* Free the old list but not its contents */
    free(domain_list);
    
    return new_list;
}