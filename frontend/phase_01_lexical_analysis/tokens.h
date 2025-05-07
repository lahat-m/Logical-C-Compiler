#ifndef TOKENS_H
#define TOKENS_H

/* Token definitions */
enum {
    /* Operators */
    AND = 256,      /* /\ */
    OR,             /* \/ */
    NOT,            /* ~ */
    IMPLIES,        /* -> */
    IFF,            /* <-> */
    XOR,            /* ^ */
    
    /* Quantifiers */
    FORALL,         /* forall */
    EXISTS,         /* exists */
    
    /* Literals */
    TRUE_VAL,       /* TRUE */
    FALSE_VAL,      /* FALSE */
    
    /* Grouping */
    LPAREN,         /* ( */
    RPAREN,         /* ) */
    LBRACKET,       /* [ */
    RBRACKET,       /* ] */
    
    /* Identifiers */
    VARIABLE,       /* Starts with lowercase letter */
    PREDICATE       /* Starts with uppercase letter */
};

/* Yylval union for storing token attributes */
typedef union {
    char *string_val;
} YYSTYPE;

/* Define yylval here to avoid undefined reference errors */
YYSTYPE yylval;

#endif /* TOKENS_H */