# Logic Compiler - Phase 1: Lexical Analysis

This is the implementation of Phase 1 (Lexical Analysis) for the Logic Compiler project. This phase handles tokenizing input source files containing logic expressions into meaningful tokens that will be used by subsequent phases of the compiler.

## Components

1. **lexer.l** - Flex specification file for the lexical analyzer
2. **tokens.h** - Header file containing token definitions
3. **Makefile** - Build system configuration
4. **run_test.sh** - Script to run lexical analyzer tests

## Supported Tokens

The lexical analyzer recognizes the following tokens:

### Operators
- AND: `/\`
- OR: `\/`
- NOT: `~`
- IMPLIES: `->`
- IFF: `<->`
- XOR: `^`

### Quantifiers
- FORALL: `forall` (case-insensitive)
- EXISTS: `exists` (case-insensitive)

### Literals
- TRUE: `TRUE` (case-insensitive)
- FALSE: `FALSE` (case-insensitive)

### Identifiers
- Variables: Begin with lowercase letter, followed by alphanumeric characters or underscores
- Predicates: Begin with uppercase letter, followed by alphanumeric characters or underscores
- Maximum identifier length: 64 characters

### Grouping
- Parentheses: `(` and `)`
- Brackets: `[` and `]`

### Comments
- Single-line comments: `// comment`
- Multi-line comments: `/* comment */`

## Error Handling

The lexer provides error detection and reporting for:
- Unrecognized characters
- Unterminated comments
- Identifiers exceeding maximum length

## Building and Testing

### To build the lexer:
```
make
```

### To run tests:
```
make test
```

### To clean build artifacts:
```
make clean
```

## Output Format

When running in test mode, the lexer outputs each token with its position (line and column) and type.

## Usage

```
./lexer example.logic
```

This will process the input file and output the recognized tokens.