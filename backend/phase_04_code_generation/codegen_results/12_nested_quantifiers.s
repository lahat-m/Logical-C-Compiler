    .text
    .globl main
main:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    # Begin logic expression evaluation
    # Quantifier: FORALL over variable x
    movl $0, %edx
    movl $1, %eax
.quant_loop_start_0:
    pushl %edx
    pushl %eax
    # Evaluating quantified expression with x = %edx
    # Quantifier: EXISTS over variable y
    movl $0, %edx
    movl $0, %eax
.quant_loop_start_3:
    pushl %edx
    pushl %eax
    # Evaluating quantified expression with y = %edx
    # Binary operation
    # Evaluate left operand
    # Predicate call: P (assumed TRUE)
    movl $1, %eax
    pushl %eax
    # Evaluate right operand
    # Predicate call: Q (assumed TRUE)
    movl $1, %eax
    movl %eax, %ecx
    popl %eax
    # AND operation
    andl %ecx, %eax
    movl %eax, %ecx
    popl %eax
    popl %edx
    # OR result (EXISTS)
    orl %ecx, %eax
    incl %edx
    cmpl $2, %edx
    jl .quant_loop_start_3
.quant_loop_end_4:
    movl %eax, %ecx
    popl %eax
    popl %edx
    # AND result (FORALL)
    andl %ecx, %eax
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
