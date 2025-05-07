#ifndef CODEGEN_H
#define CODEGEN_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "ast.h"

/* Code generation modes */
typedef enum {
    MODE_NORMAL,            /* Normal code generation */
    MODE_SHORT_CIRCUIT,     /* Use short-circuit evaluation for AND/OR */
    MODE_OPTIMIZED          /* Apply additional optimizations */
} CodeGenMode;

/* Registers for x86 */
typedef enum {
    REG_EAX,
    REG_EBX,
    REG_ECX,
    REG_EDX,
    REG_ESI,
    REG_EDI
} Register;

/* Label counter for unique label generation */
extern int label_counter;

/* File pointer for assembly output */
extern FILE* asm_file;

/* Code generation options */
typedef struct {
    bool enable_short_circuit;     /* Enable short-circuit evaluation */
    bool enable_optimization;      /* Enable additional optimizations */
    char* output_filename;         /* Output filename for assembly */
} CodeGenOptions;

/* Main code generation function */
bool generate_code(ASTNode* ast, CodeGenOptions* options);

/* Function to generate code for a specific node type */
void generate_code_for_node(ASTNode* node, CodeGenMode mode);

/* Helper functions for code generation */
void generate_binary_op(ASTNode* node, CodeGenMode mode);
void generate_unary_op(ASTNode* node, CodeGenMode mode);
void generate_quantifier(ASTNode* node, CodeGenMode mode);
void generate_predicate(ASTNode* node, CodeGenMode mode);
void generate_variable(ASTNode* node, CodeGenMode mode);
void generate_literal(ASTNode* node, CodeGenMode mode);

/* Register allocation functions */
Register allocate_register();
void free_register(Register reg);
const char* register_name(Register reg);

/* Label generation */
char* new_label(const char* prefix);

/* Assembly generation helpers */
void emit_prologue();
void emit_epilogue();
void emit_instruction(const char* format, ...);
void emit_label(const char* label);
void emit_comment(const char* format, ...);

#endif /* CODEGEN_H */