#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "ast.h"
#include "codegen.h"

/* External declarations from parser */
extern ASTNode* ast_root;
extern int yyparse();
extern FILE* yyin;

/* Forward declaration for generate_code_for_node function */
void generate_code_for_node(ASTNode* node, CodeGenMode mode);

/* Main function to test code generation */
int main(int argc, char* argv[]) {
    /* Check command line arguments */
    if (argc < 2 || argc > 5) {
        fprintf(stderr, "Usage: %s <input_file> [<output_file>] [-s] [-o]\n", argv[0]);
        fprintf(stderr, "  -s: Enable short-circuit evaluation\n");
        fprintf(stderr, "  -o: Enable additional optimizations\n");
        return 1;
    }
    
    /* Parse command line arguments */
    char* input_filename = argv[1];
    char* output_filename = NULL;
    CodeGenOptions options;
    options.enable_short_circuit = false;
    options.enable_optimization = false;
    
    /* Process remaining arguments */
    for (int i = 2; i < argc; i++) {
        if (strcmp(argv[i], "-s") == 0) {
            options.enable_short_circuit = true;
        } else if (strcmp(argv[i], "-o") == 0) {
            options.enable_optimization = true;
        } else if (output_filename == NULL) {
            output_filename = argv[i];
        } else {
            fprintf(stderr, "Error: Unknown argument: %s\n", argv[i]);
            return 1;
        }
    }
    
    /* Set default output filename if not provided */
    if (output_filename == NULL) {
        /* Create output filename by replacing .logic extension with .s */
        output_filename = (char*)malloc(strlen(input_filename) + 3); /* +3 for .s\0 */
        if (output_filename == NULL) {
            fprintf(stderr, "Error: Memory allocation failed\n");
            return 1;
        }
        
        strcpy(output_filename, input_filename);
        
        /* Find the last dot in the filename */
        char* dot = strrchr(output_filename, '.');
        if (dot != NULL) {
            /* Replace extension with .s */
            strcpy(dot, ".s");
        } else {
            /* No extension, append .s */
            strcat(output_filename, ".s");
        }
    }
    
    options.output_filename = output_filename;
    
    /* Open input file */
    FILE* input_file = fopen(input_filename, "r");
    if (!input_file) {
        fprintf(stderr, "Error: Cannot open file '%s'\n", input_filename);
        return 1;
    }
    
    yyin = input_file;
    
    /* Parse the input */
    printf("Parsing input file: %s\n", input_filename);
    int parse_result = yyparse();
    
    if (parse_result != 0 || ast_root == NULL) {
        fprintf(stderr, "Parsing failed. Cannot generate code.\n");
        fclose(input_file);
        return 1;
    }
    
    /* Print the AST */
    printf("Abstract Syntax Tree:\n");
    print_ast(ast_root, 0);
    printf("\n");
    
    /* Generate code */
    printf("Generating assembly code...\n");
    bool code_result = generate_code(ast_root, &options);
    
    if (!code_result) {
        fprintf(stderr, "Code generation failed.\n");
        free_ast(ast_root);
        fclose(input_file);
        return 1;
    }
    
    /* Cleanup */
    free_ast(ast_root);
    fclose(input_file);
    
    /* If we allocated the output filename, free it */
    if (output_filename != argv[2]) {
        free(output_filename);
    }
    
    return 0;
}