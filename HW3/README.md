# Homework3: SoftCPU
###### tags: `計算機結構`

## Setup Environment
- Download srv32
  > git clone https://github.com/sysprog21/srv32.git

- Download [riscv-none-embed-gcc-xpack](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/)

- Install RISC-V toolchains
  
  1. > sudo apt install autoconf automake autotools-dev curl gawk git \
                 		build-essential bison flex texinfo gperf libtool patchutils bc git \
                 		libmpc-dev libmpfr-dev libgmp-dev gawk zlib1g-dev libexpat1-dev  
  2. > git clone --recursive https://github.com/riscv/riscv-gnu-toolchain    
  3. > cd riscv-gnu-toolchain  
  4. > mkdir -p build && cd build 	 
  5. > ../configure --prefix=/opt/riscv --enable-multilib     
  6. > sudo make -j$(nproc)

- Install the dependent packages
  1. > sudo apt-get update -y
  2. > sudo apt-get install -y lcov
  3. > sudo apt install build-essential ccache

## Requirement 1
I choose my [Homework1](https://hackmd.io/qcy4ey6CTh2ffP4t3TQfbA) to analyze by srv32
:::spoiler C code
```c=
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
:::

::: spoiler Handwriting Assembly code
```assembly=
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
:::

1. Create Folder **quicksort** in Folder **sw**, and put my C code and makefile (reference from folder hello) into it
2. Go to folder **sim**, compiler the C code, and execute it
   > make quicksort.run
3. Result
   ```shell=
    $ Before sorting: 10	9	8	7	6	5	4	3	21	
	$ After sorting: 1	2	3	4	5	6	7	8	910	

	$ Excuting 15048 instructions, 19238 cycles, 1.278 CPI
	$ Program terminate
	$ - ../rtl/../testbench/testbench.v:418: Verilog $finish

	$ Simulation statistics
	$ =====================
	$ Simulation time  : 0.009 s
	$ Simulation cycles: 19249
	$ Simulation speed : 2.13878 MHz
   ```

## Requirement 2
### Step
- step1. Download the GTKwave
   > sudo apt install gtkwave

- step2. Generate the VCD/FST file
   > ./sim +dump

- step3. srv32 architecture
   ![](https://i.imgur.com/YaCisKG.png)
   From srv32 architecture, I choose the following singnal in GTKwave
   ![](https://i.imgur.com/Op0gLGN.png)

### GTKwave analyze
- From GTKwave analyze, I find some interest phenomenon 

- Data Hazard
 
  I find a data hazard in my disassembly file
  
  ```assembly=
  54:	00060913          	mv	s2,a2
  58:	00050493          	mv	s1,a0
  5c:	00259513          	slli	a0,a1,0x2
  60:	00a48533          	add	a0,s1,a0
  64:	00052883          	lw	a7,0(a0)
  68:	00090413          	mv	s0,s2
  ...
  ```
  From [Lab3: srv32 - RISCV RV32IM Soft CPU](https://hackmd.io/@sysprog/S1Udn1Xtt#Analyze-srv32-RV32-core), the implementation of register forwarding is as follow:
  
  ```Verilog=
  // register reading @ execution stage and register forwarding
  // When the execution result accesses the same register,
  // the execution result is directly forwarded from the previous
  // instruction (at write back stage)
  assign reg_rdata1[31: 0]    = (ex_src1_sel == 5'h0) ? 32'h0 :
                                (!wb_flush && wb_alu2reg &&
                                (wb_dst_sel == ex_src1_sel)) ? // register forwarding
                                (wb_mem2reg ? wb_rdata : wb_result) :
                                regs[ex_src1_sel];
  assign reg_rdata2[31: 0]    = (ex_src2_sel == 5'h0) ? 32'h0 :
                                (!wb_flush && wb_alu2reg &&
                                (wb_dst_sel == ex_src2_sel)) ? // register forwarding
                                (wb_mem2reg ? wb_rdata : wb_result) :
                                regs[ex_src2_sel];
  ```
  
  The instrution **slli	a0,a1,0x2** and **add a0,s1,a0** have RAW data hazard in a0, and I watch the GTKwave signal
  
  ![](https://i.imgur.com/V2l4TOE.png)

  In the picture, we can see that **wb_dst_sel == ex_src1_sel (0A), wb_flush == false, wb_alu2reg == true, and wb_mem2reg == false**
  &rarr; wb_rdata is forward to a0 register in EX stage
  
  
- Branch Penalty
  1. case 1: SB-Format Instruction
	 ![](https://i.imgur.com/J2wIxcr.png)
        
	 To find what instruction the CPU executes, I look it up in the disassembly file !
	 ```assembly
	 00000020 <_bss_clear>:
  	 20:	0002a023          	sw	zero,0(t0)
     24:	00428293          	addi	t0,t0,4
     28:	fe62ece3          	bltu	t0,t1,20 <_bss_clear>
	 2c:	00040117          	auipc	sp,0x40
     30:	fd410113          	addi	sp,sp,-44 # 40000 <_stack>
     34:	160000ef          	jal	ra,194 <main>
     38:	3391406f          	j	14b70 <exit>

	 0000003c <quick_sort>:
     3c:	12c5d063          	bge	a1,a2,15c <quick_sort+0x120>
     40:	ff010113          	addi	sp,sp,-16
	 ...
	 ```
		
	 We can find that the EX stage is executing **bltu	t0,t1,20 <_bss_clear>**, and CPU have known that the next instruction isn't **auipc	sp,0x40** 
	 &rarr; ex_fush & wb_flush is set and the pipeline will **stall** two cycles !		
     
  2. case 2: UJ-Format Instruction
	 ![](https://i.imgur.com/FdAo169.png)

	 It's same like case1, I look it up in the disassembly file !
 	 ```Assembly=
	 304:	00112e23          	sw	ra,28(sp)
     308:	00d12623          	sw	a3,12(sp)
     30c:	170000ef          	jal	ra,47c <_vfprintf_r>
     310:	01c12083          	lw	ra,28(sp)
     314:	04010113          	addi	sp,sp,64
     318:	00008067          	ret

 	 0000031c <_putchar_r>:
     31c:	00852603          	lw	a2,8(a0)
     320:	01c0006f          	j	33c <_putc_r>
	 ...
	 ```
		
	 We can find that the EX stage is executing **jal	ra,47c <_vfprintf_r>**, and CPU have known that the next instruction isn’t **lw	ra,28(sp)**
	 → ex_fush & wb_flush is set and the pipeline will stall two cycles !

## Requirement 3
- Goal: fewer instructions, shorter cycle counts, eliminate unnecessary stalls.
  
  :::spoiler Original result
  ```shell=
    $ Before sorting: 10	9	8	7	6	5	4	3	2   1	
    $ After sorting: 1	2	3	4	5	6	7	8	9   10	

    $ Excuting 15048 instructions, 19238 cycles, 1.278 CPI
    $ Program terminate
    $ - ../rtl/../testbench/testbench.v:418: Verilog $finish

    $ Simulation statistics
    $ =====================
    $ Simulation time  : 0.009 s
    $ Simulation cycles: 19249
    $ Simulation speed : 2.13878 MHz
  ```
  :::
  
- step1. Rewrite my C code: Delete unnecessary function
   
  I delete some instruction and redundant variables
   
  :::spoiler New C code
  ```c=
    #include <stdio.h>
    #define numsize 10

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

    int main(void){

        int arr[numsize] = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
        printf("Before sorting: ");
        for(int i = 0; i < numsize; i++)
            printf("%d\t", *(arr + i));
    
        quick_sort(arr, 0, numsize);
    
        printf("\nAfter sorting: ");
        for(int i = 0; i < numsize; i++)
            printf("%d\t", *(arr + i));
        printf("\n");

        return 0;
    }
  ```
   
  :::
   
  ::: spoiler New result
  ```shell=
    $ Before sorting: 10	9	8	7	6	5	4	3	2   1	  
    $ After sorting: 0	1	2	3	4	5	6	7	8   9	

    $ Excuting 14880 instructions, 19030 cycles, 1.278 CPI
    $ Program terminate
    $ - ../rtl/../testbench/testbench.v:418: Verilog $finish

    $ Simulation statistics
    $ =====================
    $ Simulation time  : 0.102 s
    $ Simulation cycles: 19041
    $ Simulation speed : 0.186676 MHz
  ```
  :::
  
- step2. Rewrite my C code: Using loop unrooling and macro function
  :::spoiler New C code
  ```c=
    #include <stdio.h>
    #define numsize       10
    #define swap(x, y)    do{x ^= y; y ^= x; x ^= y;}while(0)
    #define printArr()    do{ for(int i = 0; i < numsize; i+=5) \
                                 printf("%d\t%d\t%d\t%d\t%d\t", *(arr + i), *(arr + i + 1), *(arr + i + 2), *(arr + i + 3), *(arr + i + 4)); \
                            }while(0)

    void quick_sort(int* number, int lb, int rb){ 

        if(lb >= rb) return ;
        int pivot = number[lb], l = lb, r = rb;
        while(l != r) {
            while( *(number + r) > pivot  && l < r) r--; 
            while( pivot >= *(number + l) && l < r) l++; 
            if(l < r) swap(*(number + l), *(number + r));
        }
        *(number + lb) = *(number + l);
        *(number + l) = pivot;
        quick_sort(number, lb, l - 1);
        quick_sort(number, l + 1, rb);
    }

    int main(void){

        int arr[numsize] = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
        printf("Before sorting: ");
        printArr();
        quick_sort(arr, 0, numsize);
        printf("\nAfter sorting: ");
        printArr();
        printf("\n");
        return 0;
    }
  ```
  :::
  
  :::spoiler New result
  ```shell=
    $ Before sorting: 10	9	8	7	6	5	4	3	2   1 	
    $ After sorting: 0	1	2	3	4	5	6	7	8   9	

    $ Excuting 11279 instructions, 14737 cycles, 1.306 CPI
    $ Program terminate
    $ - ../rtl/../testbench/testbench.v:418: Verilog $finish

    $ Simulation statistics
    $ =====================
    $ Simulation time  : 0.083 s
    $ Simulation cycles: 14748
    $ Simulation speed : 0.177687 MHz

  ```
  
|                        | Origin Code | Step 1 | Step 2 |
| ---------------------- | ----------- | ------ | ------ |
| Executing instructions |    15048    | 14880  | 11279  | 
| Cycles                 |    19238    | 19030  | 14737  |

Executing instructions: 15048 &rarr; 14880 (reduce 168 instructions) &rarr; 11279 (reduce 3601 instructions)
Cycles: 19238 &rarr; 19030 (reduce 208 cycles) &rarr; 14737 (reduce 4293 cycles)

## Reference
- [Lab3 Practice](https://hackmd.io/PSNo9Y4HR-OjC3wmmyC6Kg)
- [Assignment3: SoftCPU](https://hackmd.io/BavcCOkUQZ2oE24wStsrnQ)

