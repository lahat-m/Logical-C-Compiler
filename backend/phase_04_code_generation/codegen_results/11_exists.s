    .text
    .globl main
main:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    # Begin logic expression evaluation
    # Quantifier: EXISTS over variable x
    movl $0, %edx
    movl $0, %eax
.quant_loop_start_0:
    pushl %edx
    pushl %eax
    # Evaluating quantified expression with x = %edx
    # Predicate call: P (assumed TRUE)
    movl $1, %eax
    movl %eax, %ecx
    popl %eax
    popl %edx
    # OR result (EXISTS)
    orl %ecx, %eax
    incl %edx
    cmpl $2, %edx
    jl .quant_loop_start_0
.quant_loop_end_1:
    # End logic expression evaluation
    # Result is in %eax (0=FALSE, 1=TRUE)
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret
