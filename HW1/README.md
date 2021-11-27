# Homework1: RISC-V Assembly and Instruction Pipeline
###### tags: `計算機結構`

[Assignment1: RISC-V Assembly and Instruction Pipeline](https://hackmd.io/@sysprog/2021-arch-homework1)
[Lab1: RV32I Simulator](https://hackmd.io/@sysprog/H1TpVYMdB)

## Introduction
I choose the problem [Leetcode912](https://leetcode.com/problems/sort-an-array/).
Example: 
- Input: nums = [5,2,3,1]
- Output: [1,2,3,5]

## QuickSort
To solve this problem, I use the **Quick Sort**, which is O(nlogn) sort algorithm in average case.
[Reference Website](https://alrightchiu.github.io/SecondRound/comparison-sort-quick-sortkuai-su-pai-xu-fa.html)
- Quick Sort
  - Quick Sort is based on **Divide & Conquer**
  - Quick Sort Step
    1. Choose a number in array as a **pivot**, and we need to make all the numbers on the left of the pivot are smaller than the pivot, all the numbers on the right of the pivot are bigger than the pivot.
    2. Next, look upon all numbers on the left of the pivot as **new array**, and do the same in numbers on the right side.
    3. Repeat the step 1 and 2, until you can't divide more small array.

    ![](https://i.imgur.com/UMB3lUS.png)

## C code (quicksort.c)
The following is the code of quick sort which I implement in C.
I choose the arr[lb] as a pivot, **lb** means **left bound**

```C=
#include <stdio.h>
#define numsize 10
void quick_sort(int* number, int lb, int rb);
int* sortArray(int* nums, int numsSize, int* returnSize);
int main(void){

    int arr[numsize] = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
    printf("Before sorting: ");
    for(int i = 0; i < numsize; i++)
        printf("%d\t", *(arr + i));
    
    int returnSize;
    int* res = sortArray(arr, numsize, &returnSize);
    printf("\nAfter sorting: ");
    for(int i = 0; i < numsize; i++)
        printf("%d\t", *(res + i));
    printf("\n");
    return 0;
}

int* sortArray(int* nums, int numsSize, int* returnSize){
    *returnSize = numsSize;
    quick_sort(nums, 0, *returnSize - 1);
    return nums;
}

void quick_sort(int* number, int lb, int rb){
    if(lb >= rb) return ;
    int pivot = number[lb], l = lb, r = rb;
    while(l != r){
        while( pivot < *(number + r) && l < r)  r--; 
        while( pivot >= *(number + l) && l < r) l++; 
        if(l < r){
            *(number + l) ^= *(number + r);
            *(number + r) ^= *(number + l);
            *(number + l) ^= *(number + r);
        }
    }
    *(number + lb) = *(number + l);
    *(number + l) = pivot;
    quick_sort(number, lb, l - 1);
    quick_sort(number, l + 1, rb);
}

```

## Assembly Code (quicksort.s)
The following is the code of quick sort which I implement in assembly.
- How to use
  &rarr; Just modify **number** and **numbersize** in .data

```clike=
.data
numsize:  .word 13
number:   .word 5, 6, 8, 4, 2, -1, 20, 1531, 5132132, -5, 2147483647, 325, -521
bfstr:    .string "Before sorting "
afstr:    .string "After sorting "
space:    .string " "
nextline: .string "\n"

.text
main:
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
    la   a0, afstr    # Load address of bfstr
    addi a7, x0, 4    # a7 = 4 print_str
    ecall
    
    # print arr
    la   a0, number
    la   a1, numsize
    jal  ra, PrintArr
    li  a7, 10        #call system to end the program 
    ecall
    
QuickSort:
    # sp     : ra
    # sp + 4 : s0 = &arr 
    # sp + 8 : s1 = lb
    # sp + 12: s2 = rb
    # sp + 16: s3 = pivot
    # sp + 20: s4 = l
    # sp + 24: s5 = r
    # Store saved register
    addi sp, sp, -28
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
    mv   a0, s0
    mv   a1, s1
    addi a2, s4, -1
    jal  ra, QuickSort
    
Recursion2:
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

```

## Result
- Example1:
  - Input: [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
  - Output: 
    Using C:
    ![](https://i.imgur.com/X4LBo5M.png)
    Using Assembly:
    ![](https://i.imgur.com/QQSi3Ez.png)

- Example2:
  - Input: [-1, -2, -3, -4, -5, -6, -7, -8, -9, -10]
  - Output: 
    Using C:
    ![](https://i.imgur.com/clqCKMJ.png)
    Using Assembly:
    ![](https://i.imgur.com/AZW746J.png)

- Example3:
  - Input: [5, 6, 8, 4, 2, -1, 20, 1531, 5132132, -5, 2147483647, 325, -521]
  - Output:
    Using C:
    ![](https://i.imgur.com/jMPmPed.png)
    Using Assembly:
    ![](https://i.imgur.com/4YaK8rx.png)

## Analysis
### Five Stage Pipeline CPU
**Ripes** is a 5-stages pipeline CPU
![](https://i.imgur.com/DqNlCAE.png)

The following is 5 phase of instruction executed
- IF (Instruction Fetch)
  - PC holds the address of current instruction
  - PC input the address to **Instr. Memory**, and instruction memory output the current instruction bits
- ID (Instruction Decode)
  - The instruction bits are decoded
  - Based on operation, the CPU will choose use **the value of Reg1 and Reg2** or **the value of Reg1 and immediate**
- EX (Execution)
  - ALU and Branch operations are performed
- MEM(Memory)
  - Based on instruction, CPU will choose read from/write to memory
- WB (Write Back)
  - Write the result of the instruction to the destination register

### R-Type Instruction Example
In this case, I use **add x6, x5, x6** as a example, which is located at 0x000000d4 in my pseudo instruction
```clike=
	c8:		000a0393		addi x7 x20 0
	cc:		00231313		slli x6 x6 2
	d0:		00239393		slli x7 x7 2
	d4:		00628333		add x6 x5 x6
	d8:		00032303		lw x6 0 x6
	dc:		007283b3		add x7 x5 x7
	e0:		0003a383		lw x7 0 x7
```

- IF Stage(Instruction Fetch)
  ![](https://i.imgur.com/jwCtfNi.png)

- ID Stage(Instruction Decode)
  ![](https://i.imgur.com/VKeaLjR.png)

- EX Stage(Execution)
  - Because the instruction **slli x6, x6, 2** complete and the **Forwarding**, so the value of x6 become 0x00000030 from 0x0000000c
  ![](https://i.imgur.com/y6nBLNC.png)

- MEM Stage(Memory)
  ![](https://i.imgur.com/KBLLD6R.png)

- WB Stage(Write Back)
  ![](https://i.imgur.com/yWWH8Dk.png)

## Pipeline Hazard
### Structural Hazard
- Problem: Two or more instructions in the pipeline compete for access to a single physical resource
  
- Register File Structural Hazard
  ![](https://i.imgur.com/MrXC0oD.png)
      
  - Solution in RISC-V: Using **Double Pumping**
  - Double Pumping: split Regfile into two situation (complete in one cycle)
    1. Write during 1st half of cycle
    2. Read during 2nd half of cycle
         
- Memory Structural Hazard
  ![](https://i.imgur.com/LxTBMEa.png)
    
- Solution in RISC-V
  &rarr; Without separate memory units, instruction fetch would have to **stall** for that cycle
  &rarr; Means all operations in pipeline would have to wait
      
### Data Hazard
- Problem: Instruction depends on result from previous instruction
  ![](https://i.imgur.com/eZZoLFX.png)
  
- Solution in RISC-V: Forwarding
  1. Forwarding result as soon as it available, even through it's not stored in RegFile yet
  2. Grab operand from pipeline stage, rather than register
  3. Example:
     ![](https://i.imgur.com/Pz4yAAy.png) 
  
- Detect Need for Forwarding
  - Compare destination of old instruction in pipline with sources of new instruction in decode stage 
  - Example:
    ![](https://i.imgur.com/7ubqR8X.png)
  
- Forwarding Fail
  - Forwarding can't solve all cases. For example:
    > lw t0, 0(t1)
    > sub t3, t0, t2
      
    ![](https://i.imgur.com/ADCdB28.png)
    
  - In these cases, must stall instructions, then forward is done
  
  - Example:
    ![](https://i.imgur.com/wGv8SNB.png)
  
- Conclusion
  - Most cases of data hazard, uses **Forwarding** to solve it
  - Some Special cases like **load**, hardware will stall **one cycle**
      
### Control Hazard
- Problem: Because of **branch instruction**, pipeline can't always fetch correct instruction (until the end of execution)

- Solution in RISC-V: **Branch Prediction**
  1. Guess an outcome instead of waiting directly
  2. If the processor guess wrong, the hardware will stall two cycles

- Example1:
  - In this case, I use **beq x20 x21 156 < EndSortLoop >** as a example which is located at 0x000000bc in my pseudo instruction
  ```clike=
    b4:		006282b3		add x5 x5 x6
	b8:		0002a983		lw x19 0 x5

  000000bc <WhileLoop>:
	bc:		095a0e63		beq x20 x21 156 <EndSortLoop>
	c0:		00040293		addi x5 x8 0
	c4:		000a8313		addi x6 x21 0
  ```

  - EX Stage(Execute)
    ![](https://i.imgur.com/BJD2e7Z.png)
    ![](https://i.imgur.com/5EZTpcJ.png)

  - MEM Stage(Execue)
    - The CPU guess the instruction successfully, so the pipeline is continuous 
    
    ![](https://i.imgur.com/ItTsUYL.png)

- Example2:
  - In this case, I use **bne x6 x0 -36 < PrintLoop >** as a example which is located at 0x000001f0 in my pseudo instruction
  ```clike=
    1e4:		00000073		ecall
	1e8:		00428293		addi x5 x5 4
	1ec:		fff30313		addi x6 x6 -1
	1f0:		fc031ee3		bne x6 x0 -36 <PrintLoop>
	1f4:		10000517		auipc x10 0x10000
	1f8:		e6550513		addi x10 x10 -411
	1fc:		00400893		addi x17 x0 4
	200:		00000073		ecall
  ```
  - EX Stage(Execute)
    ![](https://i.imgur.com/P7qU0uB.png)
    ![](https://i.imgur.com/iEroNA4.png)
    
  - MEM Stage(Execue)
    - The CPU guess the instruction failed, so the pipeline flush, and stall two cycles(NOP)
    
    ![](https://i.imgur.com/2IaPx3X.png)
  
## Appendix: Execute Instruction
```clike=

00000000 <main>:
	0:		10000517		auipc x10 0x10000
	4:		03850513		addi x10 x10 56
	8:		00400893		addi x17 x0 4
	c:		00000073		ecall
	10:		10000517		auipc x10 0x10000
	14:		ff450513		addi x10 x10 -12
	18:		10000597		auipc x11 0x10000
	1c:		fe858593		addi x11 x11 -24
	20:		1a4000ef		jal x1 420 <PrintArr>
	24:		10000517		auipc x10 0x10000
	28:		fe050513		addi x10 x10 -32
	2c:		00000593		addi x11 x0 0
	30:		10000617		auipc x12 0x10000
	34:		fd060613		addi x12 x12 -48
	38:		00062603		lw x12 0 x12
	3c:		fff60613		addi x12 x12 -1
	40:		030000ef		jal x1 48 <QuickSort>
	44:		10000517		auipc x10 0x10000
	48:		00450513		addi x10 x10 4
	4c:		00400893		addi x17 x0 4
	50:		00000073		ecall
	54:		10000517		auipc x10 0x10000
	58:		fb050513		addi x10 x10 -80
	5c:		10000597		auipc x11 0x10000
	60:		fa458593		addi x11 x11 -92
	64:		160000ef		jal x1 352 <PrintArr>
	68:		00a00893		addi x17 x0 10
	6c:		00000073		ecall

00000070 <QuickSort>:
	70:		fe410113		addi x2 x2 -28
	74:		00112023		sw x1 0 x2
	78:		00812223		sw x8 4 x2
	7c:		00912423		sw x9 8 x2
	80:		01212623		sw x18 12 x2
	84:		01312823		sw x19 16 x2
	88:		01412a23		sw x20 20 x2
	8c:		01512c23		sw x21 24 x2
	90:		00050413		addi x8 x10 0
	94:		00058493		addi x9 x11 0
	98:		00060913		addi x18 x12 0
	9c:		00058a13		addi x20 x11 0
	a0:		00060a93		addi x21 x12 0
	a4:		0f24de63		bge x9 x18 252 <EndQuickSort>
	a8:		00040293		addi x5 x8 0
	ac:		00048313		addi x6 x9 0
	b0:		00231313		slli x6 x6 2
	b4:		006282b3		add x5 x5 x6
	b8:		0002a983		lw x19 0 x5

000000bc <WhileLoop>:
	bc:		095a0e63		beq x20 x21 156 <EndSortLoop>
	c0:		00040293		addi x5 x8 0
	c4:		000a8313		addi x6 x21 0
	c8:		000a0393		addi x7 x20 0
	cc:		00231313		slli x6 x6 2
	d0:		00239393		slli x7 x7 2
	d4:		00628333		add x6 x5 x6
	d8:		00032303		lw x6 0 x6
	dc:		007283b3		add x7 x5 x7
	e0:		0003a383		lw x7 0 x7

000000e4 <rLoop>:
	e4:		0269d063		bge x19 x6 32 <lLoop>
	e8:		015a5e63		bge x20 x21 28 <lLoop>
	ec:		fffa8a93		addi x21 x21 -1
	f0:		000a8313		addi x6 x21 0
	f4:		00231313		slli x6 x6 2
	f8:		00628333		add x6 x5 x6
	fc:		00032303		lw x6 0 x6
	100:		fe5ff06f		jal x0 -28 <rLoop>

00000104 <lLoop>:
	104:		0279c063		blt x19 x7 32 <SwapLR>
	108:		015a5e63		bge x20 x21 28 <SwapLR>
	10c:		001a0a13		addi x20 x20 1
	110:		000a0393		addi x7 x20 0
	114:		00239393		slli x7 x7 2
	118:		007283b3		add x7 x5 x7
	11c:		0003a383		lw x7 0 x7
	120:		fe5ff06f		jal x0 -28 <lLoop>

00000124 <SwapLR>:
	124:		f95a5ce3		bge x20 x21 -104 <WhileLoop>
	128:		00040293		addi x5 x8 0
	12c:		000a8313		addi x6 x21 0
	130:		000a0393		addi x7 x20 0
	134:		00231313		slli x6 x6 2
	138:		00239393		slli x7 x7 2
	13c:		00628333		add x6 x5 x6
	140:		00032e03		lw x28 0 x6
	144:		007283b3		add x7 x5 x7
	148:		0003a283		lw x5 0 x7
	14c:		01c3a023		sw x28 0 x7
	150:		00532023		sw x5 0 x6
	154:		f69ff06f		jal x0 -152 <WhileLoop>

00000158 <EndSortLoop>:
	158:		00040293		addi x5 x8 0
	15c:		00048313		addi x6 x9 0
	160:		000a0393		addi x7 x20 0
	164:		00231313		slli x6 x6 2
	168:		00239393		slli x7 x7 2
	16c:		00628333		add x6 x5 x6
	170:		007283b3		add x7 x5 x7
	174:		0003ae03		lw x28 0 x7
	178:		01c32023		sw x28 0 x6
	17c:		0133a023		sw x19 0 x7

00000180 <Recursion1>:
	180:		00040513		addi x10 x8 0
	184:		00048593		addi x11 x9 0
	188:		fffa0613		addi x12 x20 -1
	18c:		ee5ff0ef		jal x1 -284 <QuickSort>

00000190 <Recursion2>:
	190:		00040513		addi x10 x8 0
	194:		001a0593		addi x11 x20 1
	198:		00090613		addi x12 x18 0
	19c:		ed5ff0ef		jal x1 -300 <QuickSort>

000001a0 <EndQuickSort>:
	1a0:		00012083		lw x1 0 x2
	1a4:		00412403		lw x8 4 x2
	1a8:		00812483		lw x9 8 x2
	1ac:		00c12903		lw x18 12 x2
	1b0:		01012983		lw x19 16 x2
	1b4:		01412a03		lw x20 20 x2
	1b8:		01812a83		lw x21 24 x2
	1bc:		01c10113		addi x2 x2 28
	1c0:		00008067		jalr x0 x1 0

000001c4 <PrintArr>:
	1c4:		00050293		addi x5 x10 0
	1c8:		0005a303		lw x6 0 x11

000001cc <PrintLoop>:
	1cc:		0002a503		lw x10 0 x5
	1d0:		00100893		addi x17 x0 1
	1d4:		00000073		ecall
	1d8:		10000517		auipc x10 0x10000
	1dc:		e7f50513		addi x10 x10 -385
	1e0:		00400893		addi x17 x0 4
	1e4:		00000073		ecall
	1e8:		00428293		addi x5 x5 4
	1ec:		fff30313		addi x6 x6 -1
	1f0:		fc031ee3		bne x6 x0 -36 <PrintLoop>
	1f4:		10000517		auipc x10 0x10000
	1f8:		e6550513		addi x10 x10 -411
	1fc:		00400893		addi x17 x0 4
	200:		00000073		ecall
	204:		00008067		jalr x0 x1 0

```
