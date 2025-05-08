# Logic Compiler - Phase 1: Lexical Analysis


This directory contains the lexical analyzer for the logic language compiler. The lexical analyzer converts source code into tokens that are used by the parser in Phase 2.

## Directory Structure

```
frontend/
└── phase_01_lexical_analysis/
├── Makefile
├── README.md
├── lexer.l          # Flex specification file
├── tokens.h         # Token definitions
├── run_test.sh      # Test script
└── tests/           # Test files directory
```

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

## Building the Lexical Analyzer

You can build the lexical analyzer using one of the following methods:

### Method 1: Local Build (Traditional)

This builds using files in the current directory:

```bash
make
```
### Method 2: Build with the Build Directory
This creates a build directory for intermediate files:
```
make lexer
```


### Running Tests
To run tests for the lexical analyzer

```
make test
```

This will:

Create test files if they don't exist
Run the lexical analyzer on each test file
Save the results to test_results.txt


## Cleaning Up
To remove generated files:
```
make clean
```
```
make distclean
```

## File Descriptions

. lexer.l: Flex specification file that defines the lexical analyzer
. tokens.h: Header file with token definitions
. un_test.sh: Test script that runs the lexical analyzer on test files
. tests/: Directory containing test input files

## Output Format

When running in test mode, the lexer outputs each token with its position (line and column) and type.

## Usage

```
./lexer example.logic
```

This will process the input file and output the recognized tokens.