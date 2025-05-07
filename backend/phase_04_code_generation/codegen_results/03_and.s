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
    # Short-circuit AND
    # Literal value
    movl $1, %eax
    cmpl $0, %eax
    je .false_1
    pushl %eax
    # Literal value
    movl $0, %eax
    movl %eax, %ecx
    popl %eax
    andl %ecx, %eax
    jmp .end_0
.false_1:
    movl $0, %eax
.end_0:
    # End logic expression evaluation
    # Result is in %eax (0=FALSE, 1=TRUE)
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret
