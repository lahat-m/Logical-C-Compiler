# Logic Compiler - Phase 4: Code Generation

## Overview

Phase 4 implements code generation for the logic compiler. This phase transforms the Abstract Syntax Tree (AST) into executable x86 assembly code. The generated code evaluates logical expressions and returns the result (TRUE/FALSE) as the exit code.

## Features

### Implemented Functionality

- **Logical Operators**: Maps all logical operators to x86 assembly instructions
  - AND: `andl` instruction
  - OR: `orl` instruction
  - NOT: `xorl $1, %eax` (flip 0/1)
  - XOR: `xorl` instruction
  - IMPLIES: Implemented as `NOT left OR right`
  - IFF: Implemented as `NOT (left XOR right)`

- **Register Allocation**: Strategic use of x86 registers
  - %eax: Return value and intermediate results
  - %ebx: Temporary storage for left operands
  - %ecx: Temporary storage for right operands
  - %edx: Domain iteration for quantifiers

- **Quantifier Unrolling**: Converts quantifiers to loops
  - FORALL: Implemented as a series of AND operations
  - EXISTS: Implemented as a series of OR operations
  - Default domain: {0, 1} for boolean logic

- **Optimization**:
  - Short-circuit evaluation for AND and OR
  - Proper function prologue and epilogue
  - Register usage optimization

## Files

- **codegen.h/c**: Main code generation functionality
- **codegen_main.c**: Main entry point for running code generation

## Building

```bash
# Build the code generator
make code_generator
```

## Running Code Generation

```bash
# Basic usage
./code_generator codegen_test/01_literal.logic [output_file.s] [-s] [-o]

# Options:
#   -s: Enable short-circuit evaluation
#   -o: Enable additional optimizations
```

If no output file is specified, the output will be saved as `codegen_test/01_literal.s`

## Example Output

For the expression `p /\ q`:

```assembly
    .text
    .globl main
main:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    # Begin logic expression evaluation
    # Binary operation
    # Evaluate left operand
    # Variable reference: p (assumed TRUE)
    movl $1, %eax
    pushl %eax
    # Evaluate right operand
    # Variable reference: q (assumed TRUE)
    movl $1, %eax
    movl %eax, %ecx
    popl %eax
    # AND operation
    andl %ecx, %eax
    # End logic expression evaluation
    # Result is in %eax (0=FALSE, 1=TRUE)
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret
```

## Test Suite

The code generation test suite includes test files organized into the following groups:

### Group 1: Basic Operations
- 01_literal.logic - Simple literals (TRUE/FALSE)
- 02_not.logic - NOT operation
- 03_and.logic - AND operation
- 04_or.logic - OR operation
- 05_implies.logic - IMPLIES operation
- 06_iff.logic - IFF operation
- 07_xor.logic - XOR operation

### Group 2: Complex Expressions
- 08_complex.logic - Complex expressions with multiple operators
- 09_precedence.logic - Operator precedence

### Group 3: Quantifiers
- 10_forall.logic - Universal quantifier
- 11_exists.logic - Existential quantifier
- 12_nested_quantifiers.logic - Nested quantifiers

### Group 4: Variables and Predicates
- 13_variable.logic - Variable references
- 14_predicate.logic - Predicate calls
- 15_pred_args.logic - Predicates with multiple arguments

## Running the Tests

```bash
bash test_codegen.sh
```

This will generate assembly code for each test file and show the resulting output.

## Limitations and Simplifications

- Variables and predicates are assumed to be TRUE in this implementation
- Domain for quantifiers is fixed to {0, 1}
- No memory allocation for variables
- No runtime error checking

## Extensions

Possible extensions to the code generator include:
- User-defined domains for quantifiers
- Memory allocation for variables
- Advanced optimizations
- Runtime error checking and reporting