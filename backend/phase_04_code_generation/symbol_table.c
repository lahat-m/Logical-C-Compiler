#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

/* Hash function for symbol table */
unsigned int hash_string(char* str, int table_size) {
    unsigned int hash = 0;
    for (int i = 0; str[i] != '\0'; i++) {
        hash = hash * 31 + str[i];
    }
    return hash % table_size;
}

/* Create a new symbol table */
SymbolTable* create_symbol_table(int size) {
    SymbolTable* table = (SymbolTable*)malloc(sizeof(SymbolTable));
    table->buckets = (SymbolEntry**)calloc(size, sizeof(SymbolEntry*));
    table->size = size;
    table->scope_level = 0;
    table->parent = NULL;
    return table;
}

/* Free memory used by symbol table */
void free_symbol_table(SymbolTable* table) {
    if (table == NULL) {
        return;
    }
    
    /* Free all symbol entries */
    for (int i = 0; i < table->size; i++) {
        SymbolEntry* entry = table->buckets[i];
        while (entry != NULL) {
            SymbolEntry* next = entry->next;
            
            /* Free domain values for variables */
            if (entry->type == SYM_VARIABLE && entry->data.variable.domain != NULL) {
                for (int j = 0; j < entry->data.variable.domain_size; j++) {
                    free(entry->data.variable.domain[j]);
                }
                free(entry->data.variable.domain);
            }
            
            free(entry->name);
            free(entry);
            entry = next;
        }
    }
    
    free(table->buckets);
    
    /* Free parent tables recursively */
    if (table->parent != NULL) {
        free_symbol_table(table->parent);
    }
    
    free(table);
}

/* Enter a new scope level */
SymbolTable* enter_scope(SymbolTable* current) {
    SymbolTable* new_scope = create_symbol_table(current->size);
    new_scope->scope_level = current->scope_level + 1;
    new_scope->parent = current;
    return new_scope;
}

/* Exit current scope and return to parent scope */
SymbolTable* exit_scope(SymbolTable* current) {
    if (current == NULL || current->parent == NULL) {
        return current; /* No parent scope */
    }
    
    SymbolTable* parent = current->parent;
    
    /* Detach parent before freeing to avoid recursive free */
    current->parent = NULL;
    free_symbol_table(current);
    
    return parent;
}

/* Insert a variable into the symbol table */
SymbolEntry* insert_variable(SymbolTable* table, char* name, char** domain, int domain_size, int line, int column) {
    unsigned int hash = hash_string(name, table->size);
    
    /* Check if variable already exists in current scope */
    SymbolEntry* existing = lookup_symbol_current_scope(table, name);
    if (existing != NULL) {
        return NULL; /* Variable already defined in this scope */
    }
    
    /* Create new symbol entry */
    SymbolEntry* entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    entry->name = strdup(name);
    entry->type = SYM_VARIABLE;
    entry->scope_level = table->scope_level;
    entry->line = line;
    entry->column = column;
    
    /* Copy domain values */
    if (domain != NULL && domain_size > 0) {
        entry->data.variable.domain = (char**)malloc(sizeof(char*) * domain_size);
        entry->data.variable.domain_size = domain_size;
        
        for (int i = 0; i < domain_size; i++) {
            entry->data.variable.domain[i] = strdup(domain[i]);
        }
    } else {
        entry->data.variable.domain = NULL;
        entry->data.variable.domain_size = 0;
    }
    
    /* Insert at head of bucket chain */
    entry->next = table->buckets[hash];
    table->buckets[hash] = entry;
    
    return entry;
}

/* Insert a predicate into the symbol table */
SymbolEntry* insert_predicate(SymbolTable* table, char* name, int arity, int line, int column) {
    unsigned int hash = hash_string(name, table->size);
    
    /* Check if predicate already exists */
    SymbolEntry* existing = lookup_symbol(table, name);
    if (existing != NULL) {
        /* Only report error if arity doesn't match */
        if (existing->type == SYM_PREDICATE && existing->data.predicate.arity != arity) {
            return NULL; /* Predicate already defined with different arity */
        }
        return existing; /* Return existing entry with matching arity */
    }
    
    /* Create new symbol entry */
    SymbolEntry* entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    entry->name = strdup(name);
    entry->type = SYM_PREDICATE;
    entry->scope_level = 0; /* Predicates are global */
    entry->line = line;
    entry->column = column;
    entry->data.predicate.arity = arity;
    
    /* Insert at head of bucket chain */
    entry->next = table->buckets[hash];
    table->buckets[hash] = entry;
    
    return entry;
}

/* Look up a symbol in the current scope and parent scopes */
SymbolEntry* lookup_symbol(SymbolTable* table, char* name) {
    if (table == NULL) {
        return NULL;
    }
    
    unsigned int hash = hash_string(name, table->size);
    
    /* Search in current scope */
    SymbolEntry* entry = table->buckets[hash];
    while (entry != NULL) {
        if (strcmp(entry->name, name) == 0) {
            return entry;
        }
        entry = entry->next;
    }
    
    /* If not found, search in parent scope */
    return lookup_symbol(table->parent, name);
}

/* Look up a symbol in the current scope only */
SymbolEntry* lookup_symbol_current_scope(SymbolTable* table, char* name) {
    if (table == NULL) {
        return NULL;
    }
    
    unsigned int hash = hash_string(name, table->size);
    
    /* Search in current scope only */
    SymbolEntry* entry = table->buckets[hash];
    while (entry != NULL) {
        if (strcmp(entry->name, name) == 0) {
            return entry;
        }
        entry = entry->next;
    }
    
    return NULL;
}

/* Print the contents of the symbol table */
void print_symbol_table(SymbolTable* table) {
    if (table == NULL) {
        return;
    }
    
    printf("Symbol Table (Scope Level %d):\n", table->scope_level);
    
    for (int i = 0; i < table->size; i++) {
        SymbolEntry* entry = table->buckets[i];
        
        while (entry != NULL) {
            printf("  %s: ", entry->name);
            
            if (entry->type == SYM_VARIABLE) {
                printf("Variable (Scope %d, Line %d, Col %d)", 
                        entry->scope_level, entry->line, entry->column);
                
                if (entry->data.variable.domain != NULL) {
                    printf(", Domain: [");
                    for (int j = 0; j < entry->data.variable.domain_size; j++) {
                        printf("%s", entry->data.variable.domain[j]);
                        if (j < entry->data.variable.domain_size - 1) {
                            printf(", ");
                        }
                    }
                    printf("]");
                }
            } else if (entry->type == SYM_PREDICATE) {
                printf("Predicate (Arity %d, Line %d, Col %d)", 
                        entry->data.predicate.arity, entry->line, entry->column);
            }
            
            printf("\n");
            entry = entry->next;
        }
    }
    
    /* Recursively print parent scopes */
    if (table->parent != NULL) {
        printf("\n");
        print_symbol_table(table->parent);
    }
}