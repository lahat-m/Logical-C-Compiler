    .text
    .globl main
main:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    # Begin logic expression evaluation
    # Unary operation
    # Literal value
    movl $1, %eax
    # NOT operation
    xorl $1, %eax
    # End logic expression evaluation
    # Result is in %eax (0=FALSE, 1=TRUE)
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret
