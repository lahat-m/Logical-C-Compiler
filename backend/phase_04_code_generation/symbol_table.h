#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdbool.h>

/* Symbol types */
typedef enum {
    SYM_VARIABLE,
    SYM_PREDICATE
} SymbolType;

/* Symbol table entry */
typedef struct SymbolEntry {
    char* name;                  /* Name of the symbol */
    SymbolType type;             /* Type of symbol */
    int scope_level;             /* Scope level (for variables) */
    int line;                    /* Line where symbol was defined */
    int column;                  /* Column where symbol was defined */
    union {
        struct {
            char** domain;       /* Domain values for quantified variables */
            int domain_size;     /* Size of the domain */
        } variable;
        struct {
            int arity;           /* Number of arguments for predicates */
        } predicate;
    } data;
    struct SymbolEntry* next;    /* For hash table chaining */
} SymbolEntry;

/* Symbol table structure */
typedef struct SymbolTable {
    SymbolEntry** buckets;       /* Hash table buckets */
    int size;                    /* Number of buckets */
    int scope_level;             /* Current scope level */
    struct SymbolTable* parent;  /* Parent symbol table (for nested scopes) */
} SymbolTable;

/* Symbol table operations */
SymbolTable* create_symbol_table(int size);
void free_symbol_table(SymbolTable* table);
SymbolTable* enter_scope(SymbolTable* current);
SymbolTable* exit_scope(SymbolTable* current);

/* Symbol operations */
SymbolEntry* insert_variable(SymbolTable* table, char* name, char** domain, int domain_size, int line, int column);
SymbolEntry* insert_predicate(SymbolTable* table, char* name, int arity, int line, int column);
SymbolEntry* lookup_symbol(SymbolTable* table, char* name);
SymbolEntry* lookup_symbol_current_scope(SymbolTable* table, char* name);

/* Utility functions */
unsigned int hash_string(char* str, int table_size);
void print_symbol_table(SymbolTable* table);

#endif /* SYMBOL_TABLE_H */