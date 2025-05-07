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
    # Literal value
    movl $1, %eax
    pushl %eax
    # Evaluate right operand
    # Binary operation
    # Evaluate left operand
    # Literal value
    movl $0, %eax
    pushl %eax
    # Evaluate right operand
    # Binary operation
    # Evaluate left operand
    # Literal value
    movl $1, %eax
    pushl %eax
    # Evaluate right operand
    # Binary operation
    # Evaluate left operand
    # Literal value
    movl $0, %eax
    pushl %eax
    # Evaluate right operand
    # Binary operation
    # Evaluate left operand
    # Literal value
    movl $1, %eax
    pushl %eax
    # Evaluate right operand
    # Literal value
    movl $0, %eax
    movl %eax, %ecx
    popl %eax
    # XOR operation
    xorl %ecx, %eax
    movl %eax, %ecx
    popl %eax
    # IFF operation (NOT (left XOR right))
    xorl %ecx, %eax
    xorl $1, %eax
    movl %eax, %ecx
    popl %eax
    # IMPLIES operation (NOT left OR right)
    xorl $1, %eax
    orl %ecx, %eax
    movl %eax, %ecx
    popl %eax
    # OR operation
    orl %ecx, %eax
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
