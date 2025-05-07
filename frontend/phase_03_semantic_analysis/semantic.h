#ifndef SEMANTIC_H
#define SEMANTIC_H

#include <stdbool.h>
#include "ast.h"
#include "symbol_table.h"

/* Error reporting structure */
typedef struct {
    char* messages[256];     /* Array of error messages */
    int count;               /* Number of errors */
} ErrorList;

/* Warning reporting structure */
typedef struct {
    char* messages[256];     /* Array of warning messages */
    int count;               /* Number of warnings */
} WarningList;

/* Semantic analysis context */
typedef struct {
    SymbolTable* symbols;    /* Current symbol table */
    ErrorList errors;        /* List of semantic errors */
    WarningList warnings;    /* List of semantic warnings */
} SemanticContext;

/* Function to perform semantic analysis on the AST */
bool analyze_semantics(ASTNode* root);

/* Utility functions */
SemanticContext* create_semantic_context();
void free_semantic_context(SemanticContext* context);
void add_error(SemanticContext* context, const char* format, ...);
void add_warning(SemanticContext* context, const char* format, ...);
void print_errors(SemanticContext* context);
void print_warnings(SemanticContext* context);

/* Analyze specific node types */
bool analyze_binary_op(ASTNode* node, SemanticContext* context);
bool analyze_unary_op(ASTNode* node, SemanticContext* context);
bool analyze_quantifier(ASTNode* node, SemanticContext* context);
bool analyze_predicate(ASTNode* node, SemanticContext* context);
bool analyze_variable(ASTNode* node, SemanticContext* context);
bool analyze_literal(ASTNode* node, SemanticContext* context);

#endif /* SEMANTIC_H */