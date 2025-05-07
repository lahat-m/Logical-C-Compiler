#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "semantic.h"

/* Create a new semantic context */
SemanticContext* create_semantic_context() {
    SemanticContext* context = (SemanticContext*)malloc(sizeof(SemanticContext));
    context->symbols = create_symbol_table(101); /* Prime number size for better hash distribution */
    context->errors.count = 0;
    context->warnings.count = 0;
    return context;
}

/* Free memory used by semantic context */
void free_semantic_context(SemanticContext* context) {
    if (context == NULL) {
        return;
    }
    
    /* Free error messages */
    for (int i = 0; i < context->errors.count; i++) {
        free(context->errors.messages[i]);
    }
    
    /* Free warning messages */
    for (int i = 0; i < context->warnings.count; i++) {
        free(context->warnings.messages[i]);
    }
    
    /* Free symbol table */
    free_symbol_table(context->symbols);
    
    free(context);
}

/* Add an error message to the context */
void add_error(SemanticContext* context, const char* format, ...) {
    if (context->errors.count >= 256) {
        return; /* Too many errors */
    }
    
    /* Format the error message */
    char buffer[1024];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    /* Add to error list */
    context->errors.messages[context->errors.count] = strdup(buffer);
    context->errors.count++;
}

/* Add a warning message to the context */
void add_warning(SemanticContext* context, const char* format, ...) {
    if (context->warnings.count >= 256) {
        return; /* Too many warnings */
    }
    
    /* Format the warning message */
    char buffer[1024];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    
    /* Add to warning list */
    context->warnings.messages[context->warnings.count] = strdup(buffer);
    context->warnings.count++;
}

/* Print all error messages */
void print_errors(SemanticContext* context) {
    if (context == NULL || context->errors.count == 0) {
        return;
    }
    
    printf("\nSemantic Errors (%d):\n", context->errors.count);
    for (int i = 0; i < context->errors.count; i++) {
        printf("  Error: %s\n", context->errors.messages[i]);
    }
}

/* Print all warning messages */
void print_warnings(SemanticContext* context) {
    if (context == NULL || context->warnings.count == 0) {
        return;
    }
    
    printf("\nSemantic Warnings (%d):\n", context->warnings.count);
    for (int i = 0; i < context->warnings.count; i++) {
        printf("  Warning: %s\n", context->warnings.messages[i]);
    }
}

/* Main entry point for semantic analysis */
bool analyze_semantics(ASTNode* root) {
    if (root == NULL) {
        return false;
    }
    
    /* Create semantic context */
    SemanticContext* context = create_semantic_context();
    
    /* Analyze the AST recursively */
    bool result = false;
    
    switch (root->type) {
        case NODE_BINARY_OP:
            result = analyze_binary_op(root, context);
            break;
        case NODE_UNARY_OP:
            result = analyze_unary_op(root, context);
            break;
        case NODE_QUANTIFIER:
            result = analyze_quantifier(root, context);
            break;
        case NODE_PREDICATE:
            result = analyze_predicate(root, context);
            break;
        case NODE_VARIABLE:
            result = analyze_variable(root, context);
            break;
        case NODE_LITERAL:
            result = analyze_literal(root, context);
            break;
        default:
            add_error(context, "Unknown node type in AST");
            result = false;
    }
    
    /* Print any errors or warnings */
    print_warnings(context);
    print_errors(context);
    
    /* Cleanup and return result */
    bool success = (context->errors.count == 0);
    free_semantic_context(context);
    
    return success && result;
}

/* Analyze binary operation nodes */
bool analyze_binary_op(ASTNode* node, SemanticContext* context) {
    if (node == NULL || node->type != NODE_BINARY_OP) {
        return false;
    }
    
    /* Analyze left and right operands */
    bool left_ok = false;
    bool right_ok = false;
    
    switch (node->data.binary.left->type) {
        case NODE_BINARY_OP:
            left_ok = analyze_binary_op(node->data.binary.left, context);
            break;
        case NODE_UNARY_OP:
            left_ok = analyze_unary_op(node->data.binary.left, context);
            break;
        case NODE_QUANTIFIER:
            left_ok = analyze_quantifier(node->data.binary.left, context);
            break;
        case NODE_PREDICATE:
            left_ok = analyze_predicate(node->data.binary.left, context);
            break;
        case NODE_VARIABLE:
            left_ok = analyze_variable(node->data.binary.left, context);
            break;
        case NODE_LITERAL:
            left_ok = analyze_literal(node->data.binary.left, context);
            break;
        default:
            add_error(context, "Invalid left operand type in binary operation at line %d, column %d",
                      node->line, node->column);
            left_ok = false;
    }
    
    switch (node->data.binary.right->type) {
        case NODE_BINARY_OP:
            right_ok = analyze_binary_op(node->data.binary.right, context);
            break;
        case NODE_UNARY_OP:
            right_ok = analyze_unary_op(node->data.binary.right, context);
            break;
        case NODE_QUANTIFIER:
            right_ok = analyze_quantifier(node->data.binary.right, context);
            break;
        case NODE_PREDICATE:
            right_ok = analyze_predicate(node->data.binary.right, context);
            break;
        case NODE_VARIABLE:
            right_ok = analyze_variable(node->data.binary.right, context);
            break;
        case NODE_LITERAL:
            right_ok = analyze_literal(node->data.binary.right, context);
            break;
        default:
            add_error(context, "Invalid right operand type in binary operation at line %d, column %d",
                      node->line, node->column);
            right_ok = false;
    }
    
    return left_ok && right_ok;
}

/* Analyze unary operation nodes */
bool analyze_unary_op(ASTNode* node, SemanticContext* context) {
    if (node == NULL || node->type != NODE_UNARY_OP) {
        return false;
    }
    
    /* Analyze operand */
    bool operand_ok = false;
    
    switch (node->data.unary.operand->type) {
        case NODE_BINARY_OP:
            operand_ok = analyze_binary_op(node->data.unary.operand, context);
            break;
        case NODE_UNARY_OP:
            operand_ok = analyze_unary_op(node->data.unary.operand, context);
            break;
        case NODE_QUANTIFIER:
            operand_ok = analyze_quantifier(node->data.unary.operand, context);
            break;
        case NODE_PREDICATE:
            operand_ok = analyze_predicate(node->data.unary.operand, context);
            break;
        case NODE_VARIABLE:
            operand_ok = analyze_variable(node->data.unary.operand, context);
            break;
        case NODE_LITERAL:
            operand_ok = analyze_literal(node->data.unary.operand, context);
            break;
        default:
            add_error(context, "Invalid operand type in unary operation at line %d, column %d",
                      node->line, node->column);
            operand_ok = false;
    }
    
    return operand_ok;
}

/* Analyze quantifier nodes */
bool analyze_quantifier(ASTNode* node, SemanticContext* context) {
    if (node == NULL || node->type != NODE_QUANTIFIER) {
        return false;
    }
    
    /* Check if variable shadows another variable */
    SymbolEntry* existing = lookup_symbol(context->symbols, node->data.quantifier.variable);
    if (existing != NULL && existing->type == SYM_VARIABLE) {
        add_warning(context, "Variable '%s' at line %d, column %d shadows another variable defined at line %d, column %d",
                    node->data.quantifier.variable, node->line, node->column, existing->line, existing->column);
    }
    
    /* Enter a new scope for the quantifier */
    context->symbols = enter_scope(context->symbols);
    
    /* Add the quantified variable to the symbol table */
    SymbolEntry* entry = insert_variable(context->symbols, 
                                        node->data.quantifier.variable,
                                        node->data.quantifier.domain,
                                        node->data.quantifier.domain_size,
                                        node->line, 
                                        node->column);
    
    if (entry == NULL) {
        add_error(context, "Variable '%s' at line %d, column %d is already defined in this scope",
                 node->data.quantifier.variable, node->line, node->column);
        context->symbols = exit_scope(context->symbols);
        return false;
    }
    
    /* Analyze the quantifier's expression */
    bool expr_ok = false;
    
    switch (node->data.quantifier.expr->type) {
        case NODE_BINARY_OP:
            expr_ok = analyze_binary_op(node->data.quantifier.expr, context);
            break;
        case NODE_UNARY_OP:
            expr_ok = analyze_unary_op(node->data.quantifier.expr, context);
            break;
        case NODE_QUANTIFIER:
            expr_ok = analyze_quantifier(node->data.quantifier.expr, context);
            break;
        case NODE_PREDICATE:
            expr_ok = analyze_predicate(node->data.quantifier.expr, context);
            break;
        case NODE_VARIABLE:
            expr_ok = analyze_variable(node->data.quantifier.expr, context);
            break;
        case NODE_LITERAL:
            expr_ok = analyze_literal(node->data.quantifier.expr, context);
            break;
        default:
            add_error(context, "Invalid expression type in quantifier at line %d, column %d",
                      node->line, node->column);
            expr_ok = false;
    }
    
    /* Exit the quantifier's scope */
    context->symbols = exit_scope(context->symbols);
    
    return expr_ok;
}

/* Analyze predicate nodes */
bool analyze_predicate(ASTNode* node, SemanticContext* context) {
    if (node == NULL || node->type != NODE_PREDICATE) {
        return false;
    }
    
    /* Check if the predicate is defined */
    SymbolEntry* entry = lookup_symbol(context->symbols, node->data.predicate.name);
    
    if (entry == NULL) {
        /* First use of this predicate, register it */
        entry = insert_predicate(context->symbols, 
                                node->data.predicate.name,
                                node->data.predicate.arg_count,
                                node->line, 
                                node->column);
                                
        if (entry == NULL) {
            add_error(context, "Failed to register predicate '%s' at line %d, column %d",
                     node->data.predicate.name, node->line, node->column);
            return false;
        }
    } else if (entry->type != SYM_PREDICATE) {
        add_error(context, "Symbol '%s' at line %d, column %d is not a predicate",
                 node->data.predicate.name, node->line, node->column);
        return false;
    } else if (entry->data.predicate.arity != node->data.predicate.arg_count) {
        add_error(context, "Predicate '%s' at line %d, column %d is called with %d arguments, but it was defined with %d arguments at line %d, column %d",
                 node->data.predicate.name, node->line, node->column,
                 node->data.predicate.arg_count, entry->data.predicate.arity,
                 entry->line, entry->column);
        return false;
    }
    
    /* Check that all arguments are valid variables */
    for (int i = 0; i < node->data.predicate.arg_count; i++) {
        SymbolEntry* arg_entry = lookup_symbol(context->symbols, node->data.predicate.args[i]);
        
        if (arg_entry == NULL) {
            add_error(context, "Unbound variable '%s' used as argument %d in predicate '%s' at line %d, column %d",
                     node->data.predicate.args[i], i + 1, node->data.predicate.name, 
                     node->line, node->column);
            return false;
        } else if (arg_entry->type != SYM_VARIABLE) {
            add_error(context, "Symbol '%s' used as argument %d in predicate '%s' at line %d, column %d is not a variable",
                     node->data.predicate.args[i], i + 1, node->data.predicate.name,
                     node->line, node->column);
            return false;
        }
    }
    
    return true;
}

/* Analyze variable nodes */
bool analyze_variable(ASTNode* node, SemanticContext* context) {
    if (node == NULL || node->type != NODE_VARIABLE) {
        return false;
    }
    
    /* Check if the variable is defined */
    SymbolEntry* entry = lookup_symbol(context->symbols, node->data.variable.name);
    
    if (entry == NULL) {
        add_error(context, "Unbound variable '%s' at line %d, column %d",
                 node->data.variable.name, node->line, node->column);
        return false;
    } else if (entry->type != SYM_VARIABLE) {
        add_error(context, "Symbol '%s' at line %d, column %d is not a variable",
                 node->data.variable.name, node->line, node->column);
        return false;
    }
    
    return true;
}

/* Analyze literal nodes */
bool analyze_literal(ASTNode* node, SemanticContext* context) {
    if (node == NULL || node->type != NODE_LITERAL) {
        return false;
    }
    
    /* Literals are always valid */
    return true;
}