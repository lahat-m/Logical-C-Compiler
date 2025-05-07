#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "parser.h"  /* Use parser.h instead of tokens.h */

/* Print indentation for AST visualization */
static void print_indent(int indent) {
    for (int i = 0; i < indent; i++) {
        printf("  ");
    }
}

/* Get operator or quantifier name as string */
static const char* get_op_name(int op_type) {
    switch (op_type) {
        case OP_AND:        return "AND";
        case OP_OR:         return "OR";
        case OP_IMPLIES:    return "IMPLIES";
        case OP_IFF:        return "IFF";
        case OP_XOR:        return "XOR";
        case OP_NOT:        return "NOT";
        default:            return "UNKNOWN";
    }
}

static const char* get_quantifier_name(int quant_type) {
    switch (quant_type) {
        case QUANT_FORALL:  return "FORALL";
        case QUANT_EXISTS:  return "EXISTS";
        default:            return "UNKNOWN";
    }
}

/* Convert token values to operator types */
BinaryOpType token_to_binary_op(int token) {
    switch (token) {
        case AND:     return OP_AND;
        case OR:      return OP_OR;
        case IMPLIES: return OP_IMPLIES;
        case IFF:     return OP_IFF;
        case XOR:     return OP_XOR;
        default:      return OP_AND; /* Default, shouldn't happen */
    }
}

UnaryOpType token_to_unary_op(int token) {
    if (token == NOT) return OP_NOT;
    return OP_NOT; /* Default, shouldn't happen */
}

QuantifierType token_to_quantifier(int token) {
    if (token == FORALL) return QUANT_FORALL;
    if (token == EXISTS) return QUANT_EXISTS;
    return QUANT_FORALL; /* Default, shouldn't happen */
}

/* Print AST node recursively */
void print_ast(ASTNode* node, int indent) {
    if (node == NULL) {
        print_indent(indent);
        printf("NULL\n");
        return;
    }
    
    switch (node->type) {
        case NODE_BINARY_OP:
            print_indent(indent);
            printf("BinaryOp: %s\n", get_op_name(node->data.binary.operator));
            print_indent(indent);
            printf("Left:\n");
            print_ast(node->data.binary.left, indent + 1);
            print_indent(indent);
            printf("Right:\n");
            print_ast(node->data.binary.right, indent + 1);
            break;
            
        case NODE_UNARY_OP:
            print_indent(indent);
            printf("UnaryOp: %s\n", get_op_name(node->data.unary.operator));
            print_indent(indent);
            printf("Operand:\n");
            print_ast(node->data.unary.operand, indent + 1);
            break;
            
        case NODE_QUANTIFIER:
            print_indent(indent);
            printf("Quantifier: %s\n", get_quantifier_name(node->data.quantifier.quantifier));
            print_indent(indent);
            printf("Variable: %s\n", node->data.quantifier.variable);
            print_indent(indent);
            printf("Domain: [");
            for (int i = 0; i < node->data.quantifier.domain_size; i++) {
                printf("%s", node->data.quantifier.domain[i]);
                if (i < node->data.quantifier.domain_size - 1) {
                    printf(", ");
                }
            }
            printf("]\n");
            print_indent(indent);
            printf("Expression:\n");
            print_ast(node->data.quantifier.expr, indent + 1);
            break;
            
        case NODE_LITERAL:
            print_indent(indent);
            printf("Literal: %s\n", node->data.literal.value ? "TRUE" : "FALSE");
            break;
            
        case NODE_VARIABLE:
            print_indent(indent);
            printf("Variable: %s\n", node->data.variable.name);
            break;
            
        case NODE_PREDICATE:
            print_indent(indent);
            printf("Predicate: %s\n", node->data.predicate.name);
            print_indent(indent);
            printf("Arguments: [");
            for (int i = 0; i < node->data.predicate.arg_count; i++) {
                printf("%s", node->data.predicate.args[i]);
                if (i < node->data.predicate.arg_count - 1) {
                    printf(", ");
                }
            }
            printf("]\n");
            break;
    }
}

/* Free memory allocated for AST */
void free_ast(ASTNode* node) {
    if (node == NULL) {
        return;
    }
    
    switch (node->type) {
        case NODE_BINARY_OP:
            free_ast(node->data.binary.left);
            free_ast(node->data.binary.right);
            break;
            
        case NODE_UNARY_OP:
            free_ast(node->data.unary.operand);
            break;
            
        case NODE_QUANTIFIER:
            free(node->data.quantifier.variable);
            for (int i = 0; i < node->data.quantifier.domain_size; i++) {
                free(node->data.quantifier.domain[i]);
            }
            free(node->data.quantifier.domain);
            free_ast(node->data.quantifier.expr);
            break;
            
        case NODE_VARIABLE:
            free(node->data.variable.name);
            break;
            
        case NODE_PREDICATE:
            free(node->data.predicate.name);
            for (int i = 0; i < node->data.predicate.arg_count; i++) {
                free(node->data.predicate.args[i]);
            }
            free(node->data.predicate.args);
            break;
            
        case NODE_LITERAL:
            /* Nothing to free for literals */
            break;
    }
    
    free(node);
}