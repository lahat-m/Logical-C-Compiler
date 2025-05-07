# Logic Compiler - Phase 2: Syntax Analysis & AST Construction

This is the implementation of Phase 2 of the Logic Compiler project. This phase performs syntax analysis of tokenized input and constructs an Abstract Syntax Tree (AST) representation.

## Components

1. **ast.h** - Header file defining the AST structure and operations
2. **ast.c** - Implementation of AST node creation and manipulation functions
3. **parser.y** - Bison grammar specification for the parser
4. **tokens.h** - Updated token definitions for parser integration
5. **lexer.l** - Modified lexical analyzer to work with the parser
6. **Makefile** - Updated build system configuration
7. **test_parser.sh** - Script to run parser tests

## Grammar Implementation

The parser implements the context-free grammar as defined in the project specification:

```
program         → expression
expression      → quantified_expr | binary_expr
quantified_expr → quantifier IDENTIFIER domain expression
domain          → LBRACKET value_list RBRACKET
value_list      → value | value "," value_list
binary_expr     → unary_expr binary_op binary_expr | unary_expr
unary_expr      → NOT unary_expr | atomic_expr
atomic_expr     → LPAREN expression RPAREN | predicate | literal
predicate       → IDENTIFIER LPAREN arg_list RPAREN
arg_list        → IDENTIFIER | IDENTIFIER "," arg_list
literal         → TRUE | FALSE | IDENTIFIER
binary_op       → AND | OR | IMPLIES | IFF | XOR
quantifier      → FORALL | EXISTS
```

## Operator Precedence

The parser implements the following precedence rules (highest to lowest):

1. NOT (right associative)
2. AND (left associative)
3. OR (left associative)
4. XOR (left associative)
5. IMPLIES (right associative)
6. IFF (left associative)

## AST Structure

The Abstract Syntax Tree consists of nodes representing:
- Binary operations (AND, OR, IMPLIES, IFF, XOR)
- Unary operations (NOT)
- Quantifiers (FORALL, EXISTS)
- Literals (TRUE, FALSE)
- Variables and Predicates

Each node includes:
- Type information
- Operation-specific data
- Source location for error reporting

## Error Handling

The parser provides error detection and reporting for:
- Syntax errors
- Mismatched parentheses
- Missing operands
- Incomplete expressions
- Invalid grammatical constructs

## Building and Testing

### To build the compiler:
```
make
```

### To run parser tests:
```
./test_parser.sh
```

### To clean build artifacts:
```
make clean
```

## Usage

```
./logic_compiler input_file.logic
```

chmod +x test_parser2.sh
./test_parser.sh

This will process the input file, construct an AST, and print the AST structure for verification.