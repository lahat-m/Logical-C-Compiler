#ifndef AST_H
#define AST_H

#include <stdbool.h>

/* Forward declaration */
struct ASTNode;
typedef struct ASTNode ASTNode;

/* Node types in the AST */
typedef enum {
    NODE_BINARY_OP,
    NODE_UNARY_OP,
    NODE_QUANTIFIER,
    NODE_LITERAL,
    NODE_VARIABLE,
    NODE_PREDICATE
} NodeType;

/* Binary operator types */
typedef enum {
    OP_AND = 1,
    OP_OR = 2,
    OP_IMPLIES = 3,
    OP_IFF = 4,
    OP_XOR = 5
} BinaryOpType;

/* Unary operator types */
typedef enum {
    OP_NOT = 10
} UnaryOpType;

/* Quantifier types */
typedef enum {
    QUANT_FORALL = 1,
    QUANT_EXISTS = 2
} QuantifierType;

/* AST node structure */
struct ASTNode {
    NodeType type;
    union {
        struct {
            BinaryOpType operator;  /* For binary operators */
            ASTNode* left;
            ASTNode* right;
        } binary;
        struct {
            UnaryOpType operator;   /* For unary operators */
            ASTNode* operand;
        } unary;
        struct {
            QuantifierType quantifier; /* FORALL or EXISTS */
            char* variable;
            char** domain;          /* Array of domain values */
            int domain_size;
            ASTNode* expr;
        } quantifier;
        struct {
            bool value;             /* For TRUE/FALSE literals */
        } literal;
        struct {
            char* name;             /* For variables */
        } variable;
        struct {
            char* name;             /* For predicates */
            char** args;            /* Arguments */
            int arg_count;
        } predicate;
    } data;
    int line;                       /* Source line number */
    int column;                     /* Source column number */
};

/* Function to convert token values to operator types */
BinaryOpType token_to_binary_op(int token);
UnaryOpType token_to_unary_op(int token);
QuantifierType token_to_quantifier(int token);

/* Functions for AST operations */
void free_ast(ASTNode* node);
void print_ast(ASTNode* node, int indent);

#endif /* AST_H */