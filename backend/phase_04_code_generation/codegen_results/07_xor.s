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
    # Literal value
    movl $0, %eax
    movl %eax, %ecx
    popl %eax
    # XOR operation
    xorl %ecx, %eax
    # End logic expression evaluation
    # Result is in %eax (0=FALSE, 1=TRUE)
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret
