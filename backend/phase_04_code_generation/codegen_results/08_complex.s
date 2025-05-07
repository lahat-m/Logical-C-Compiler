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
    # Short-circuit OR
    # Binary operation
    # Short-circuit AND
    # Literal value
    movl $1, %eax
    cmpl $0, %eax
    je .false_2
    pushl %eax
    # Literal value
    movl $0, %eax
    movl %eax, %ecx
    popl %eax
    andl %ecx, %eax
    jmp .end_1
.false_2:
    movl $0, %eax
.end_1:
    cmpl $0, %eax
    jne .end_0
    # Unary operation
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
    # IMPLIES operation (NOT left OR right)
    xorl $1, %eax
    orl %ecx, %eax
    # NOT operation
    xorl $1, %eax
.end_0:
    # End logic expression evaluation
    # Result is in %eax (0=FALSE, 1=TRUE)
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret
