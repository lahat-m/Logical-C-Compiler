#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "semantic.h"

/* External declarations */
extern ASTNode* ast_root;
extern int yyparse();
extern FILE* yyin;

/* Main function to test semantic analysis */
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
    
    /* Parse the input file */
    int parse_result = yyparse();
    
    if (parse_result != 0 || ast_root == NULL) {
        fprintf(stderr, "Parsing failed. Cannot perform semantic analysis.\n");
        fclose(input_file);
        return 1;
    }
    
    /* Print the AST */
    printf("Abstract Syntax Tree:\n");
    print_ast(ast_root, 0);
    printf("\n");
    
    /* Perform semantic analysis */
    printf("Performing semantic analysis...\n");
    bool semantic_result = analyze_semantics(ast_root);
    
    if (semantic_result) {
        printf("\nSemantic analysis completed successfully!\n");
    } else {
        printf("\nSemantic analysis failed. See errors above.\n");
    }
    
    /* Clean up */
    free_ast(ast_root);
    fclose(input_file);
    
    return semantic_result ? 0 : 1;
}