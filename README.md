# Logical C Compiler

A compiler for propositional and predicate logic that transforms logical expressions into executable x86 assembly code.

## Project Overview

This project implements a full compiler for formal logic expressions. It processes logical expressions with operators, quantifiers, variables, and predicates, compiling them through four distinct phases into executable x86 assembly code.

## Features

### Supported Syntax

- **Operators**: AND (`/\`), OR (`\/`), NOT (`~`), IMPLIES (`->`), IFF (`<->`), XOR (`^`)
- **Quantifiers**: FORALL (`forall`), EXISTS (`exists`)
- **Literals**: TRUE, FALSE
- **Variables**: Begin with lowercase letter (e.g., `x`, `variable1`)
- **Predicates**: Begin with uppercase letter (e.g., `P`, `Predicate`)
- **Grouping**: Parentheses for expressions, brackets for quantifier domains
- **Comments**: Single-line (`//`) and multi-line (`/* */`)

### Semantic Rules

- Variables must be bound by a quantifier before use
- Variables are scoped to their quantifier
- Predicates must be used with consistent arity
- Variable shadowing generates warnings

### Code Generation

- Efficient mapping of logical operations to x86 assembly instructions
- Short-circuit evaluation for AND and OR operations
- Proper function prologue and epilogue
- Register allocation optimization

## Compiler Phases

### 1. Lexical Analysis (Phase 1)

The lexical analyzer tokenizes the input source file:

- Implemented using Flex (lex)
- Recognizes operators, quantifiers, variables, predicates, and literals
- Provides detailed error reporting with line and column numbers

Key files:
- `lexer.l`: Flex specification
- `tokens.h`: Token definitions (used in earlier versions)

### 2. Syntax Analysis & AST Construction (Phase 2)

The parser analyzes the token stream and builds an Abstract Syntax Tree (AST):

- Implemented using Bison (yacc)
- Enforces operator precedence and associativity rules
- Constructs a comprehensive AST representation

Key files:
- `parser.y`: Bison grammar specification
- `ast.h/ast.c`: AST node definitions and operations

### 3. Semantic Analysis (Phase 3)

The semantic analyzer validates the logical correctness of the program:

- Implements a symbol table for tracking variables and predicates
- Verifies variable binding (all variables must be bound by quantifiers)
- Checks predicate arity consistency
- Enforces scope rules for variables
- Detects variable shadowing

Key files:
- `symbol_table.h/symbol_table.c`: Symbol table implementation
- `semantic.h/semantic.c`: Semantic analysis functions
- `semantic_main.c`: Main driver for semantic analysis

### 4. Code Generation (Phase 4)

The code generator transforms the AST into executable x86 assembly:

- Maps logical operators to x86 instructions
- Implements quantifier unrolling for FORALL and EXISTS
- Provides short-circuit evaluation optimization
- Generates proper function prologue and epilogue

Key files:
- `codegen.h/codegen.c`: Code generation functions
- `codegen_main.c`: Main driver for code generator

## Building and Usage

### Building the Compiler

```bash
# Build all components
make

# Build individual phases
make compiler            # Phases 1 & 2 (Parser)
make semantic_analyzer   # Phase 3 (Semantic Analyzer)
make code_generator      # Phase 4 (Code Generator)
```

### Using the Compiler

Each phase can be run separately or in sequence:

```bash
# Parse and build AST
./compiler input.logic

# Perform semantic analysis
./semantic_analyzer input.logic

# Generate assembly code
./code_generator input.logic [output.s] [-s] [-o]
```

Options for code generator:
- `-s`: Enable short-circuit evaluation
- `-o`: Enable additional optimizations

### Running Tests

Comprehensive test suites are available for each phase:

```bash
# Run parser tests
bash run_parser_test.sh

# Run semantic analyzer tests
bash run_semantic_tests.sh

# Run code generator tests
bash test_codegen.sh
```

## Example

### Input (`example.logic`):
```
// Check if A implies B is equivalent to not A or B
(A -> B) <-> (~A \/ B)
```

### Generated Assembly:
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
    # Binary operation
    # Evaluate left operand
    # Variable reference: A (assumed TRUE)
    movl $1, %eax
    pushl %eax
    # Evaluate right operand
    # Variable reference: B (assumed TRUE)
    movl $1, %eax
    movl %eax, %ecx
    popl %eax
    # IMPLIES operation (NOT left OR right)
    xorl $1, %eax
    orl %ecx, %eax
    pushl %eax
    # Evaluate right operand
    # Binary operation
    # Evaluate left operand
    # Unary operation
    # Variable reference: A (assumed TRUE)
    movl $1, %eax
    # NOT operation
    xorl $1, %eax
    pushl %eax
    # Evaluate right operand
    # Variable reference: B (assumed TRUE)
    movl $1, %eax
    movl %eax, %ecx
    popl %eax
    # OR operation
    orl %ecx, %eax
    movl %eax, %ecx
    popl %eax
    # IFF operation (NOT (left XOR right))
    xorl %ecx, %eax
    xorl $1, %eax
    # End logic expression evaluation
    # Result is in %eax (0=FALSE, 1=TRUE)
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret
```

## Project Structure

```
.
├── ast.c                   # Abstract Syntax Tree implementation
├── ast.h                   # AST definitions
├── codegen.c               # Code generator implementation
├── codegen.h               # Code generator declarations
├── codegen_main.c          # Main driver for code generator
├── compiler                # Executable for parser (Phases 1 & 2)
├── code_generator          # Executable for code generator (Phase 4)
├── lexer.l                 # Flex lexical analyzer specification
├── Makefile                # Build system configuration
├── parser.y                # Bison grammar specification
├── run_parser_test.sh      # Script to test the parser
├── run_semantic_tests.sh   # Script to test the semantic analyzer
├── semantic.c              # Semantic analysis implementation
├── semantic.h              # Semantic analysis declarations
├── semantic_analyzer       # Executable for semantic analyzer (Phase 3)
├── semantic_main.c         # Main driver for semantic analyzer
├── semantic_tests/         # Directory with semantic test files
├── symbol_table.c          # Symbol table implementation
├── symbol_table.h          # Symbol table declarations
├── test_codegen.sh         # Script to test the code generator
└── codegen_tests/          # Directory with code generation test files
```

## Limitations and Future Work

- Variables and predicates are assumed to be TRUE in the current implementation
- Domain for quantifiers is fixed to {0, 1}
- No memory allocation for variables

Possible extensions:
- User-defined domains for quantifiers
- Memory allocation for variables
- Additional optimization passes
- Support for user-defined predicates

## Acknowledgments

This compiler was developed as a project for a compiler construction course SCS3305, University of Nairobi.

## Author

```
Lahat Mariel
```