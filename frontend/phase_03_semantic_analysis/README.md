# Logic Compiler - Phase 3: Semantic Analysis

## Overview

Phase 3 implements semantic analysis for the logic compiler. This phase validates the semantic correctness of logical expressions after they've been tokenized (Phase 1) and parsed into an Abstract Syntax Tree (Phase 2).

## Features

### Semantic Rules Implemented

- **Variable Binding**: All variables must be bound by a quantifier before use
- **Scope Rules**: Variables are only visible within the scope of their quantifier
- **Predicate Arity**: Predicates must be used with a consistent number of arguments
- **Variable Shadowing**: Redefining variables in nested scopes generates warnings

### Components

- **Symbol Table**: Tracks variables and predicates with their properties
- **Scope Management**: Handles nested scopes with proper variable visibility
- **Error Detection**: Reports semantic errors with line and column information
- **Warning Generation**: Identifies potential issues like variable shadowing

## Files

- **symbol_table.h/c**: Symbol table implementation for tracking variables and predicates
- **semantic.h/c**: Core semantic analysis functionality
- **semantic_main.c**: Main entry point for running semantic analysis
- **semantic_tests/**: Directory containing test files for semantic analysis

## Building

```bash
# Build the semantic analyzer
make semantic_analyzer
```

## Running Semantic Analysis

```bash
# Analyze a single file
./semantic_analyzer input_file.logic

# Run the test suite
./run_semantic_tests.sh
```

## Test Suite

The semantic test suite includes 22 test files organized into logical groups:

### Group 1: Valid Expressions (should pass)
- 01_valid_simple.logic - Simple valid expression
- 02_valid_complex.logic - Complex expression with multiple operators
- 03_valid_nested.logic - Nested quantifiers
- 04_valid_multi.logic - Multiple expressions in one file
- 05_valid_constants.logic - Expressions with TRUE/FALSE constants

### Group 2: Variable Binding Errors (should fail)
- 06_unbound_simple.logic - Simple unbound variable
- 07_unbound_complex.logic - Unbound variable in complex expression
- 08_unbound_scope.logic - Variable used outside its scope

### Group 3: Predicate Arity Errors (should fail)
- 09_arity_simple.logic - Simple predicate arity error
- 10_arity_mixed.logic - Mixed predicate arities
- 11_arity_complex.logic - Arity error in complex expression

### Group 4: Variable Shadowing (should produce warnings)
- 12_shadow_simple.logic - Simple variable shadowing
- 13_shadow_multi.logic - Multiple variable shadowing
- 14_shadow_separate.logic - Shadowing in separate expressions

### Group 5: All Logical Operators (should pass)
- 15_operators_and.logic - AND operator
- 16_operators_or.logic - OR operator
- 17_operators_not.logic - NOT operator
- 18_operators_implies.logic - IMPLIES operator
- 19_operators_iff.logic - IFF operator
- 20_operators_xor.logic - XOR operator
- 21_operators_precedence.logic - Operator precedence

### Group 6: Mixed Errors (should fail)
- 22_mixed_errors.logic - Multiple different errors in one file

## Example

Sample logic expression with semantic error (unbound variable):
```
// z is not bound by any quantifier
P(z)
```

Output from semantic analyzer:
```
Abstract Syntax Tree:
Predicate: P
Arguments: [z]

Performing semantic analysis...

Semantic Errors (1):
  Error: Unbound variable 'z' at line 2, column 3

Semantic analysis failed. See errors above.
```

## Handling Multiple Expressions

The semantic analyzer supports multiple logical expressions in a single file, treating them as if they're implicitly combined with logical AND operators. This allows for more complex logic programs and better tests of semantic rules.