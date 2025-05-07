#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "codegen.h"
#include "ast.h"

/* Global variables */
int label_counter = 0;
FILE* asm_file = NULL;
bool registers_in_use[6] = {false, false, false, false, false, false};

/* Forward declaration for recursion */
void generate_code_for_node(ASTNode* node, CodeGenMode mode);

/* Register allocation */
Register allocate_register() {
    for (int i = 0; i < 6; i++) {
        if (!registers_in_use[i]) {
            registers_in_use[i] = true;
            return (Register)i;
        }
    }
    fprintf(stderr, "Error: No free registers available\n");
    exit(1);
}

void free_register(Register reg) {
    if (reg >= 0 && reg < 6) {
        registers_in_use[reg] = false;
    }
}

const char* register_name(Register reg) {
    switch (reg) {
        case REG_EAX: return "%eax";
        case REG_EBX: return "%ebx";
        case REG_ECX: return "%ecx";
        case REG_EDX: return "%edx";
        case REG_ESI: return "%esi";
        case REG_EDI: return "%edi";
        default: return "unknown_register";
    }
}

/* Label generation */
char* new_label(const char* prefix) {
    char* label = (char*)malloc(64);
    if (!label) {
        fprintf(stderr, "Memory allocation error\n");
        exit(1);
    }
    sprintf(label, ".%s_%d", prefix, label_counter++);
    return label;
}

/* Assembly code emission */
void emit_instruction(const char* format, ...) {
    va_list args;
    va_start(args, format);
    fprintf(asm_file, "    ");
    vfprintf(asm_file, format, args);
    fprintf(asm_file, "\n");
    va_end(args);
}

void emit_label(const char* label) {
    fprintf(asm_file, "%s:\n", label);
}

void emit_comment(const char* format, ...) {
    va_list args;
    va_start(args, format);
    fprintf(asm_file, "    # ");
    vfprintf(asm_file, format, args);
    fprintf(asm_file, "\n");
    va_end(args);
}

void emit_prologue() {
    fprintf(asm_file, "    .text\n");
    fprintf(asm_file, "    .globl main\n");
    fprintf(asm_file, "main:\n");
    emit_instruction("pushl %%ebp");
    emit_instruction("movl %%esp, %%ebp");
    emit_instruction("pushl %%ebx");
    emit_instruction("pushl %%esi");
    emit_instruction("pushl %%edi");
    emit_comment("Begin logic expression evaluation");
}

void emit_epilogue() {
    emit_comment("End logic expression evaluation");
    emit_comment("Result is in %%eax (0=FALSE, 1=TRUE)");
    emit_instruction("popl %%edi");
    emit_instruction("popl %%esi");
    emit_instruction("popl %%ebx");
    emit_instruction("movl %%ebp, %%esp");
    emit_instruction("popl %%ebp");
    emit_instruction("ret");
}

/* Code generation for binary operations */
void generate_binary_op(ASTNode* node, CodeGenMode mode) {
    char* end_label = NULL;
    char* false_label = NULL;
    
    if (node == NULL || node->type != NODE_BINARY_OP) {
        fprintf(stderr, "Error: Invalid binary operation node\n");
        exit(1);
    }
    
    emit_comment("Binary operation");
    
    /* Short-circuit evaluation for AND and OR */
    if (mode == MODE_SHORT_CIRCUIT) {
        switch (node->data.binary.operator) {
            case OP_AND:
                emit_comment("Short-circuit AND");
                end_label = new_label("end");
                false_label = new_label("false");
                
                /* Evaluate left operand */
                generate_code_for_node(node->data.binary.left, mode);
                
                /* If left is false, the result is false */
                emit_instruction("cmpl $0, %%eax");
                emit_instruction("je %s", false_label);
                
                /* Otherwise, evaluate right operand */
                emit_instruction("pushl %%eax");    /* Save left result */
                generate_code_for_node(node->data.binary.right, mode);
                emit_instruction("movl %%eax, %%ecx");  /* Right result in %ecx */
                emit_instruction("popl %%eax");     /* Restore left result */
                
                /* AND the results */
                emit_instruction("andl %%ecx, %%eax");
                emit_instruction("jmp %s", end_label);
                
                emit_label(false_label);
                emit_instruction("movl $0, %%eax");
                emit_label(end_label);
                
                free(end_label);
                free(false_label);
                return;
                
            case OP_OR:
                emit_comment("Short-circuit OR");
                end_label = new_label("end");
                
                /* Evaluate left operand */
                generate_code_for_node(node->data.binary.left, mode);
                
                /* If left is true, the result is true */
                emit_instruction("cmpl $0, %%eax");
                emit_instruction("jne %s", end_label);
                
                /* Otherwise, evaluate right operand */
                generate_code_for_node(node->data.binary.right, mode);
                
                emit_label(end_label);
                free(end_label);
                return;
                
            default:
                /* For other operators, continue with normal evaluation */
                break;
        }
    }
    
    /* Normal evaluation for other operators */
    emit_comment("Evaluate left operand");
    generate_code_for_node(node->data.binary.left, mode);
    
    /* Save left operand result */
    emit_instruction("pushl %%eax");
    
    emit_comment("Evaluate right operand");
    generate_code_for_node(node->data.binary.right, mode);
    
    /* Right operand result in %ecx */
    emit_instruction("movl %%eax, %%ecx");
    
    /* Restore left operand result to %eax */
    emit_instruction("popl %%eax");
    
    /* Perform operation based on operator type */
    switch (node->data.binary.operator) {
        case OP_AND:
            emit_comment("AND operation");
            emit_instruction("andl %%ecx, %%eax");
            break;
            
        case OP_OR:
            emit_comment("OR operation");
            emit_instruction("orl %%ecx, %%eax");
            break;
            
        case OP_XOR:
            emit_comment("XOR operation");
            emit_instruction("xorl %%ecx, %%eax");
            break;
            
        case OP_IMPLIES:
            emit_comment("IMPLIES operation (NOT left OR right)");
            emit_instruction("xorl $1, %%eax");  /* NOT left */
            emit_instruction("orl %%ecx, %%eax");  /* OR right */
            break;
            
        case OP_IFF:
            emit_comment("IFF operation (NOT (left XOR right))");
            emit_instruction("xorl %%ecx, %%eax");  /* left XOR right */
            emit_instruction("xorl $1, %%eax");     /* NOT result */
            break;
            
        default:
            fprintf(stderr, "Error: Unknown binary operator: %d\n", node->data.binary.operator);
            exit(1);
    }
}

/* Code generation for unary operations */
void generate_unary_op(ASTNode* node, CodeGenMode mode) {
    if (node == NULL || node->type != NODE_UNARY_OP) {
        fprintf(stderr, "Error: Invalid unary operation node\n");
        exit(1);
    }
    
    emit_comment("Unary operation");
    
    /* Generate code for operand */
    generate_code_for_node(node->data.unary.operand, mode);
    
    /* Apply operation */
    switch (node->data.unary.operator) {
        case OP_NOT:
            emit_comment("NOT operation");
            emit_instruction("xorl $1, %%eax");  /* Flip 0/1 */
            break;
            
        default:
            fprintf(stderr, "Error: Unknown unary operator: %d\n", node->data.unary.operator);
            exit(1);
    }
}

/* Code generation for literals */
void generate_literal(ASTNode* node, CodeGenMode mode) {
    if (node == NULL || node->type != NODE_LITERAL) {
        fprintf(stderr, "Error: Invalid literal node\n");
        exit(1);
    }
    
    emit_comment("Literal value");
    emit_instruction("movl $%d, %%eax", node->data.literal.value ? 1 : 0);
}

/* Code generation for variables */
void generate_variable(ASTNode* node, CodeGenMode mode) {
    if (node == NULL || node->type != NODE_VARIABLE) {
        fprintf(stderr, "Error: Invalid variable node\n");
        exit(1);
    }
    
    /* In this simple implementation, we assume variables are TRUE */
    /* In a real compiler, this would load the variable's value from memory */
    emit_comment("Variable reference: %s (assumed TRUE)", node->data.variable.name);
    emit_instruction("movl $1, %%eax");
}

/* Code generation for predicates */
void generate_predicate(ASTNode* node, CodeGenMode mode) {
    if (node == NULL || node->type != NODE_PREDICATE) {
        fprintf(stderr, "Error: Invalid predicate node\n");
        exit(1);
    }
    
    /* In this simple implementation, we assume predicates are TRUE */
    /* In a real compiler, this would evaluate the predicate with its arguments */
    emit_comment("Predicate call: %s (assumed TRUE)", node->data.predicate.name);
    emit_instruction("movl $1, %%eax");
}

/* Code generation for quantifiers */
void generate_quantifier(ASTNode* node, CodeGenMode mode) {
    char* loop_start = NULL;
    char* loop_end = NULL;
    char* short_circuit = NULL;
    
    if (node == NULL || node->type != NODE_QUANTIFIER) {
        fprintf(stderr, "Error: Invalid quantifier node\n");
        exit(1);
    }
    
    /* We'll use a simple implementation with fixed domain {0, 1} */
    /* In a real compiler, you would use the domain from the AST */
    
    loop_start = new_label("quant_loop_start");
    loop_end = new_label("quant_loop_end");
    
    emit_comment("Quantifier: %s over variable %s", 
                 node->data.quantifier.quantifier == QUANT_FORALL ? "FORALL" : "EXISTS",
                 node->data.quantifier.variable);
    
    /* Initialize loop counter */
    emit_instruction("movl $0, %%edx");  /* Start with domain value 0 */
    
    /* Initialize result based on quantifier type */
    if (node->data.quantifier.quantifier == QUANT_FORALL) {
        /* FORALL starts with TRUE (for AND chain) */
        emit_instruction("movl $1, %%eax");
        short_circuit = new_label("forall_short_circuit");
    } else {
        /* EXISTS starts with FALSE (for OR chain) */
        emit_instruction("movl $0, %%eax");
        short_circuit = new_label("exists_short_circuit");
    }
    
    /* Loop start */
    emit_label(loop_start);
    
    /* Push loop counter and result to stack */
    emit_instruction("pushl %%edx");
    emit_instruction("pushl %%eax");
    
    /* Evaluate expression */
    emit_comment("Evaluating quantified expression with %s = %%edx", 
                 node->data.quantifier.variable);
    generate_code_for_node(node->data.quantifier.expr, mode);
    
    /* Move expression result to %ecx */
    emit_instruction("movl %%eax, %%ecx");
    
    /* Restore result and loop counter */
    emit_instruction("popl %%eax");
    emit_instruction("popl %%edx");
    
    /* Combine results based on quantifier type */
    if (node->data.quantifier.quantifier == QUANT_FORALL) {
        emit_comment("AND result (FORALL)");
        emit_instruction("andl %%ecx, %%eax");
        
        /* Short-circuit: if result is false, we're done */
        if (mode == MODE_SHORT_CIRCUIT) {
            emit_instruction("cmpl $0, %%eax");
            emit_instruction("je %s", short_circuit);
        }
    } else {
        emit_comment("OR result (EXISTS)");
        emit_instruction("orl %%ecx, %%eax");
        
        /* Short-circuit: if result is true, we're done */
        if (mode == MODE_SHORT_CIRCUIT) {
            emit_instruction("cmpl $0, %%eax");
            emit_instruction("jne %s", short_circuit);
        }
    }
    
    /* Increment loop counter */
    emit_instruction("incl %%edx");
    
    /* Check if we've processed the entire domain */
    emit_instruction("cmpl $2, %%edx");  /* Domain size is 2 (0 and 1) */
    emit_instruction("jl %s", loop_start);
    
    /* Loop end */
    if (mode == MODE_SHORT_CIRCUIT) {
        emit_label(short_circuit);
    }
    
    emit_label(loop_end);
    
    /* Free memory for labels */
    free(loop_start);
    free(loop_end);
    free(short_circuit);
}

/* Helper function to generate code for a node */
void generate_code_for_node(ASTNode* node, CodeGenMode mode) {
    if (node == NULL) {
        fprintf(stderr, "Error: NULL node in code generation\n");
        exit(1);
    }
    
    switch (node->type) {
        case NODE_BINARY_OP:
            generate_binary_op(node, mode);
            break;
            
        case NODE_UNARY_OP:
            generate_unary_op(node, mode);
            break;
            
        case NODE_QUANTIFIER:
            generate_quantifier(node, mode);
            break;
            
        case NODE_PREDICATE:
            generate_predicate(node, mode);
            break;
            
        case NODE_VARIABLE:
            generate_variable(node, mode);
            break;
            
        case NODE_LITERAL:
            generate_literal(node, mode);
            break;
            
        default:
            fprintf(stderr, "Error: Unknown node type: %d\n", node->type);
            exit(1);
    }
}

/* Main code generation function */
bool generate_code(ASTNode* ast, CodeGenOptions* options) {
    if (ast == NULL) {
        fprintf(stderr, "Error: NULL AST in code generation\n");
        return false;
    }
    
    /* Open output file */
    asm_file = fopen(options->output_filename, "w");
    if (asm_file == NULL) {
        fprintf(stderr, "Error: Could not open output file '%s'\n", options->output_filename);
        return false;
    }
    
    /* Determine code generation mode */
    CodeGenMode mode = MODE_NORMAL;
    if (options->enable_short_circuit) {
        mode = MODE_SHORT_CIRCUIT;
    }
    if (options->enable_optimization) {
        mode = MODE_OPTIMIZED;
    }
    
    /* Generate assembly code */
    emit_prologue();
    generate_code_for_node(ast, mode);
    emit_epilogue();
    
    /* Close output file */
    fclose(asm_file);
    asm_file = NULL;
    
    printf("Assembly code generated successfully: %s\n", options->output_filename);
    return true;
}