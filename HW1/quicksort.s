.data
numsize:  .word 13
number:   .word 5, 6, 8, 4, 2, -1, 20, 1531, 5132132, -5, 2147483647, 325, -521
bfstr:    .string "Before sorting "
afstr:    .string "After sorting "
space:    .string " "
nextline: .string "\n"

.text
main:
    addi sp, sp, -4
    sw   ra, 0(sp)
    
    # print bfstr
    la   a0, bfstr       # Load address of bfstr
    addi a7, x0, 4       # a7 = 4 print_str
    ecall
    
    # print arr
    la   a0, number
    la   a1, numsize
    jal  ra, PrintArr
    
    # quick sort
    la   a0, number   # a0 = &number[0]
    addi a1, x0, 0    # a1 = lb = 0
    la   a2, numsize  # a2 = &rb
    lw   a2, 0(a2)    # a2 = rb
    addi a2, a2, -1   # a2 = rb = numsize - 1
    jal  ra, QuickSort
    
    # print afstr
    la   a0, afstr       # Load address of bfstr
    addi a7, x0, 4       # a7 = 4 print_str
    ecall
    
    # print arr
    la   a0, number
    la   a1, numsize
    jal  ra, PrintArr
    
    # return
    lw   ra, 0(sp)
    addi sp, sp, 4
    jr   ra
    
QuickSort:
    # sp     : ra
    # sp + 4 : s0 = &arr 
    # sp + 8 : s1 = lb
    # sp + 12: s2 = rb
    # sp + 16: s3 = pivot
    # sp + 20: s4 = l
    # sp + 24: s5 = r
    # Store saved register
    sw   ra, 0(sp)     # store ra
    sw   s0, 4(sp)     # store s0 = &arr
    sw   s1, 8(sp)     # store s1 = lb
    sw   s2, 12(sp)    # store s2 = rb
    sw   s3, 16(sp)    # store s3 = pivot
    sw   s4, 20(sp)    # store s4 = l
    sw   s5, 24(sp)    # store s5 = r
    
    mv   s0, a0        # s0 = &number[0]
    mv   s1, a1        # s1 = lb
    mv   s2, a2        # s2 = rb
    mv   s4, a1        # l = lb
    mv   s5, a2        # r = rb
    bge  s1, s2, EndQuickSort # if lb >= rb, return number 
    mv   t0, s0        # t0 = &arr[0]
    mv   t1, s1        # t1 = lb
    slli t1, t1, 2     # t1 = t1 << 2
    add  t0, t0, t1    # addr of number[lb] = addr of number[0] + lb << 2
    lw   s3, 0(t0)     # s3 = pivot = number[lb]        
    
WhileLoop:              # while (l != r)
    beq  s4, s5, EndSortLoop  # if l == r ,goto EndSortLoop
    mv   t0, s0         # t0 = &number[0]
    mv   t1, s5         # t1 = r
    mv   t2, s4         # t2 = l
    slli t1, t1, 2      # t1 = t1 << 2
    slli t2, t2, 2      # t2 = t2 << 2
    add  t1, t0, t1     # addr of number[r] = addr of number[0] + r << 2
    lw   t1, 0(t1)      # t1 = *(number + r)
    add  t2, t0, t2     # addr of number[l] = addr of number[0] + l << 2
    lw   t2, 0(t2)      # t2 = *(number + l)

rLoop:    
    bge  s3, t1, lLoop  # if pivot >= *(number + r), break rLoop
    bge  s4, s5, lLoop  # if l >= r, break rLoop
    addi s5, s5, -1     # r--
    mv   t1, s5
    slli t1, t1, 2
    add  t1, t0, t1
    lw   t1, 0(t1)
    j rLoop

lLoop:
    blt  s3, t2, SwapLR # if pivot < *(number + l), break lLoop
    bge  s4, s5, SwapLR # if l >= r, break lLoop
    addi s4, s4, 1      # l++
    mv   t2, s4
    slli t2, t2, 2
    add  t2, t0, t2
    lw   t2, 0(t2)
    j lLoop

SwapLR:
    # swap
    bge  s4, s5, WhileLoop # if l >= r, goto CompareLR
    mv   t0, s0         # t0 = &number[0]
    mv   t1, s5         # t1 = r
    mv   t2, s4         # t2 = l
    slli t1, t1, 2      # t1 = t1 << 2
    slli t2, t2, 2      # t2 = t2 << 2
    add  t1, t0, t1     # t1 = addr of number[r] = addr of number[0] + r << 2
    lw   t3, 0(t1)      # t3 = *(number + r)
    add  t2, t0, t2     # t2 = addr of number[l] = addr of number[0] + l << 2
    lw   t0, 0(t2)      # t0 = *(number + l)
    sw   t3, 0(t2)      # *(number + r) store to addr of *(number + l)
    sw   t0, 0(t1)      # *(number + l) store to addr of *(number + r)
    j WhileLoop

EndSortLoop:
    mv   t0, s0         # t0 = &number[0]
    mv   t1, s1         # t1 = lb
    mv   t2, s4         # t2 = l
    slli t1, t1, 2      # t1 = t1 << 2
    slli t2, t2, 2      # t2 = t2 << 2
    add  t1, t0, t1     # t1 = addr of number[lb] = addr of number[0] + lb << 2
    add  t2, t0, t2     # addr of number[l] = addr of number[0] + l << 2
    lw   t3, 0(t2)      # t3 = *(number + l) 
    sw   t3, 0(t1)      # *(number + l) store to (number + lb)
    sw   s3, 0(t2)      # s3 = pivot store to (number + l)

Recursion1:
    addi sp, sp, -28   # Store volatile registers
    mv   a0, s0
    mv   a1, s1
    addi a2, s4, -1
    jal  ra, QuickSort
    
Recursion2:
    addi sp, sp, -28   # Store volatile registers
    mv   a0, s0
    addi a1, s4, 1
    mv   a2, s2
    jal  ra, QuickSort
    
EndQuickSort:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    lw   s2, 12(sp)
    lw   s3, 16(sp)
    lw   s4, 20(sp)
    lw   s5, 24(sp)
    addi sp, sp, 28
    jr   ra
    
############# print array ###############
PrintArr:
    mv t0, a0             # t0 = a0
    lw t1, 0(a1)          # t1 = *a1
PrintLoop:
    lw a0, 0(t0)
    addi a7, x0, 1        # a7 = 1 print_int
    ecall
    la a0, space
    addi a7, x0, 4        # a7 = 4 print_str
    ecall
    addi t0, t0, 4        # t0 += 4
    addi t1, t1, -1       # t1 -= 1
    bne t1, x0, PrintLoop # if t1 != 0 ,go to printLoop
#EndPrintArr
    la a0, nextline
    addi a7, x0, 4        # a7 = 4 print_str
    ecall
    jr ra    
     