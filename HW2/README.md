# Homework2: RISC-V Toolchain

###### tags: `計算機結構`

## Rewrite [Length of Last Word](https://leetcode.com/problems/length-of-last-word/)
I choose the **Length of Last Word** from [蕭珮珊](https://hackmd.io/@peishan/Hy5WwjCrK)

**Motivation**: I think the problem is interesting, and I want to practice how to send the **u32** data to emulator

```c=
#include <string.h>
void Display(const char* str){
    /* Send char to UART Tx */
    volatile char* u8tx  = (volatile char*)0x40002000;
    while(*str) 
        *u8tx = *(str++);     
}

void _start()
{
    const char* str1 = "string: ";
    const char* str2 = "ans: ";
    const char* s = "Hasdkadkald,askdsd";
    
    /* Display */
    Display(str1);
    Display(s);
    Display("\n");
    Display(str2);

    int last = strlen(s) - 1;         /* the last position of string */
    int res = 0;
    while(*(s + last) == ' ') last--; /* If the last of the string is ' ' */
    for(int i = last; i >= 0; i--) {
        if(*(s + i) == ' ') break;
        res++;
    }

    /* Send int to UART Tx */
    volatile int* u32tx = (volatile int*)0x40000008;
    *u32tx = res;
}
```

To Solve this problem, I need to send **int** variable to emulator, so I modify some of source code
I modify the function **target_write_u32** in **line 883**, and choose **0x40000008** to send data

![](https://i.imgur.com/Ej5MCYK.png)

Result
![](https://i.imgur.com/734UWeV.png)

## Compare Assembly Code
### Original Code (From [蕭珮珊](https://hackmd.io/@peishan/Hy5WwjCrK))
```clike=
.data
str1:    .string "Hello World"
str2:    .string "Length of the last word is "
space:   .string " "
a:       .string "a"

.text
# s1 = str1 address
# s2 = space
# s3 = counter
# t1 = str1[i]
main:
        #function:lengthOfLastWord(char * s)
        la          s1, str1
        lb          s2, space
        lb          s4, 5(s1)
        add         s3, x0, x0
        jal         ra, loop1
        #if the last letter is space, find the position of the last letter is not space
        lb          t0, 0(s1) 
        jal         ra, loop2
        jal         ra, loop3
        jal         ra, print
        li          a7, 10
        ecall     
loop1:
        addi        s1, s1, 1 #find the last position of the string
        lb          t0, 0(s1)
        bne         t0, x0, loop1
        ret  
loop2:
        addi        s1, s1, -1    #s--
        lb          t0, 0(s1)     #t0=char[i](s), i=length(s)-1
        beq         t0, s2, loop2 #while(char[i]==" ")
        ret
loop3:
        addi        s1, s1, -1    #s--
        lb          t0, 0(s1)     #t1=char[i](s), i=last word
        addi        s3, s3, 1     #length++
        bne         t0, s2, loop3 #while(char[i]!=" ")
        ret
print:
        la          a0, str2
        addi        a7, x0, 4
        ecall
        add         a0, s3, x0
        li          a7, 1
        ecall
        ret
```
- Observation
  - Line of Code: 49
  - Register Used: 9
    - sx register: s1 s2 s3 s4
    - tx register: t0
    - ax register: a0 a7
    - other: ra zero
  - Stack used(bytes): 0
  - lw/sw count: 0

### -O3 Optimized Assembly Code
Using the following instruciton to get disassembly code

> riscv-none-embed-objdump -d test1

```clike=
test1:     file format elf32-littleriscv

Disassembly of section .text:

00010054 <Display>:
   10054:	00054783          	lbu	 a5,0(a0)
   10058:	00078c63          	beqz a5,10070 <Display+0x1c>
   1005c:	40002737          	lui	 a4,0x40002
   10060:	00150513          	addi a0,a0,1
   10064:	00f70023          	sb	 a5,0(a4) # 40002000 <__global_pointer$+0x3fff0574>
   10068:	00054783          	lbu	 a5,0(a0)
   1006c:	fe079ae3          	bnez a5,10060 <Display+0xc>
   10070:	00008067          	ret

00010074 <_start>:
   10074:	000107b7          	lui	 a5,0x10
   10078:	07300713          	li	 a4,115
   1007c:	26878793          	addi a5,a5,616 # 10268 <_start+0x1f4>
   10080:	400026b7          	lui	 a3,0x40002
   10084:	00178793          	addi a5,a5,1
   10088:	00e68023          	sb	 a4,0(a3) # 40002000 <__global_pointer$+0x3fff0574>
   1008c:	0007c703          	lbu	 a4,0(a5)
   10090:	fe071ae3          	bnez a4,10084 <_start+0x10>
   10094:	000107b7          	lui	 a5,0x10
   10098:	27478513          	addi a0,a5,628 # 10274 <_start+0x200>
   1009c:	04800713          	li	 a4,72
   100a0:	27478793          	addi a5,a5,628
   100a4:	40002637          	lui	 a2,0x40002
   100a8:	00178793          	addi a5,a5,1
   100ac:	00e60023          	sb	 a4,0(a2) # 40002000 <__global_pointer$+0x3fff0574>
   100b0:	0007c703          	lbu	 a4,0(a5)
   100b4:	fe071ae3          	bnez a4,100a8 <_start+0x34>
   100b8:	00a00793          	li	 a5,10
   100bc:	00f60023          	sb	 a5,0(a2)
   100c0:	000107b7          	lui	 a5,0x10
   100c4:	06100713          	li	 a4,97
   100c8:	28478793          	addi a5,a5,644 # 10284 <_start+0x210>
   100cc:	40002637          	lui	 a2,0x40002
   100d0:	00178793          	addi a5,a5,1
   100d4:	00e60023          	sb	 a4,0(a2) # 40002000 <__global_pointer$+0x3fff0574>
   100d8:	0007c703          	lbu	 a4,0(a5)
   100dc:	fe071ae3          	bnez a4,100d0 <_start+0x5c>
   100e0:	00b00593          	li	 a1,11
   100e4:	00050793          	mv	 a5,a0
   100e8:	40a585b3          	sub	 a1,a1,a0
   100ec:	02000613          	li	 a2,32
   100f0:	00f586b3          	add	 a3,a1,a5
   100f4:	fff78793          	addi a5,a5,-1
   100f8:	00c7c703          	lbu	 a4,12(a5)
   100fc:	fec70ae3          	beq	 a4,a2,100f0 <_start+0x7c>
   10100:	1206c863          	bltz a3,10230 <_start+0x1bc>
   10104:	fff68793          	addi a5,a3,-1
   10108:	fff00713          	li	 a4,-1
   1010c:	10e78263          	beq	 a5,a4,10210 <_start+0x19c>
   10110:	00f507b3          	add	 a5,a0,a5
   10114:	0007c783          	lbu	 a5,0(a5)
   10118:	0ec78c63          	beq	 a5,a2,10210 <_start+0x19c>
   1011c:	ffe68793          	addi a5,a3,-2
   10120:	0ee78c63          	beq	 a5,a4,10218 <_start+0x1a4>
   10124:	00f507b3          	add	 a5,a0,a5
   10128:	0007c783          	lbu	 a5,0(a5)
   1012c:	0ec78663          	beq	 a5,a2,10218 <_start+0x1a4>
   10130:	ffd68793          	addi a5,a3,-3
   10134:	0ee78663          	beq	 a5,a4,10220 <_start+0x1ac>
   10138:	00f507b3          	add	 a5,a0,a5
   1013c:	0007c783          	lbu	 a5,0(a5)
   10140:	0ec78063          	beq	 a5,a2,10220 <_start+0x1ac>
   10144:	ffc68793          	addi a5,a3,-4
   10148:	0ee78063          	beq	 a5,a4,10228 <_start+0x1b4>
   1014c:	00f507b3          	add	 a5,a0,a5
   10150:	0007c783          	lbu	 a5,0(a5)
   10154:	0cc78a63          	beq	 a5,a2,10228 <_start+0x1b4>
   10158:	ffb68713          	addi a4,a3,-5
   1015c:	fff00793          	li	 a5,-1
   10160:	0af70463          	beq	 a4,a5,10208 <_start+0x194>
   10164:	00e50733          	add	 a4,a0,a4
   10168:	00074603          	lbu	 a2,0(a4)
   1016c:	02000713          	li	 a4,32
   10170:	08e60c63          	beq	 a2,a4,10208 <_start+0x194>
   10174:	ffa68613          	addi a2,a3,-6
   10178:	0cf60063          	beq	 a2,a5,10238 <_start+0x1c4>
   1017c:	00c50633          	add	 a2,a0,a2
   10180:	00064603          	lbu	 a2,0(a2)
   10184:	0ae60a63          	beq	 a2,a4,10238 <_start+0x1c4>
   10188:	ff968613          	addi a2,a3,-7
   1018c:	0af60a63          	beq	 a2,a5,10240 <_start+0x1cc>
   10190:	00c50633          	add	 a2,a0,a2
   10194:	00064603          	lbu	 a2,0(a2)
   10198:	0ae60463          	beq	 a2,a4,10240 <_start+0x1cc>
   1019c:	ff868613          	addi a2,a3,-8
   101a0:	0af60463          	beq	 a2,a5,10248 <_start+0x1d4>
   101a4:	00c50633          	add	 a2,a0,a2
   101a8:	00064603          	lbu	 a2,0(a2)
   101ac:	08e60e63          	beq	 a2,a4,10248 <_start+0x1d4>
   101b0:	ff768613          	addi a2,a3,-9
   101b4:	08f60e63          	beq	 a2,a5,10250 <_start+0x1dc>
   101b8:	00c50633          	add	 a2,a0,a2
   101bc:	00064783          	lbu	 a5,0(a2)
   101c0:	08e78863          	beq	 a5,a4,10250 <_start+0x1dc>
   101c4:	ff668793          	addi a5,a3,-10
   101c8:	fff00713          	li	 a4,-1
   101cc:	08e78663          	beq	 a5,a4,10258 <_start+0x1e4>
   101d0:	00f507b3          	add	 a5,a0,a5
   101d4:	0007c603          	lbu	 a2,0(a5)
   101d8:	02000793          	li	 a5,32
   101dc:	06f60e63          	beq	 a2,a5,10258 <_start+0x1e4>
   101e0:	ff568693          	addi a3,a3,-11
   101e4:	06e68e63          	beq	 a3,a4,10260 <_start+0x1ec>
   101e8:	00d506b3          	add	 a3,a0,a3
   101ec:	0006c783          	lbu	 a5,0(a3)
   101f0:	fe078793          	addi a5,a5,-32
   101f4:	00f037b3          	snez a5,a5
   101f8:	00b78793          	addi a5,a5,11
   101fc:	40000737          	lui	 a4,0x40000
   10200:	00f72423          	sw	 a5,8(a4) # 40000008 <__global_pointer$+0x3ffee57c>
   10204:	00008067          	ret
```

- Observation
  - Line of Code:  112
  - Register Used: 6
    - sx register: None
    - tx register: None
    - ax register: a0 a1 a2 a3 a4 a5
    - other: None
  - Stack used(bytes): None
  - lw/sw count: 1

### -Os Optimized Assembly Code
```clike=
test1:     file format elf32-littleriscv

Disassembly of section .text:

00010054 <Display>:
   10054:	40002737          	lui	 a4,0x40002
   10058:	00054783          	lbu	 a5,0(a0)
   1005c:	00079463          	bnez a5,10064 <Display+0x10>
   10060:	00008067          	ret
   10064:	00150513          	addi a0,a0,1
   10068:	00f70023          	sb	 a5,0(a4) # 40002000 <__global_pointer$+0x3fff06d0>
   1006c:	fedff06f          	j	 10058 <Display+0x4>

00010070 <_start>:
   10070:	00010537          	lui	 a0,0x10
   10074:	ff010113          	addi sp,sp,-16
   10078:	10850513          	addi a0,a0,264 # 10108 <_start+0x98>
   1007c:	00112623          	sw	 ra,12(sp)
   10080:	00812423          	sw	 s0,8(sp)
   10084:	fd1ff0ef          	jal	 ra,10054 <Display>
   10088:	00010437          	lui	 s0,0x10
   1008c:	11440513          	addi a0,s0,276 # 10114 <_start+0xa4>
   10090:	fc5ff0ef          	jal	 ra,10054 <Display>
   10094:	00010537          	lui	 a0,0x10
   10098:	12450513          	addi a0,a0,292 # 10124 <_start+0xb4>
   1009c:	fb9ff0ef          	jal	 ra,10054 <Display>
   100a0:	00010537          	lui	 a0,0x10
   100a4:	12850513          	addi a0,a0,296 # 10128 <_start+0xb8>
   100a8:	fadff0ef          	jal	 ra,10054 <Display>
   100ac:	11440593          	addi a1,s0,276
   100b0:	00c00793          	li	 a5,12
   100b4:	02000713          	li	 a4,32
   100b8:	11440413          	addi s0,s0,276
   100bc:	fff78793          	addi a5,a5,-1
   100c0:	00b78633          	add	 a2,a5,a1
   100c4:	00064603          	lbu	 a2,0(a2)
   100c8:	00078693          	mv	 a3,a5
   100cc:	fee608e3          	beq	 a2,a4,100bc <_start+0x4c>
   100d0:	02000613          	li	 a2,32
   100d4:	40f68733          	sub	 a4,a3,a5
   100d8:	0007c863          	bltz a5,100e8 <_start+0x78>
   100dc:	00f405b3          	add	 a1,s0,a5
   100e0:	0005c583          	lbu	 a1,0(a1)
   100e4:	00c59e63          	bne	 a1,a2,10100 <_start+0x90>
   100e8:	00c12083          	lw	 ra,12(sp)
   100ec:	00812403          	lw	 s0,8(sp)
   100f0:	400007b7          	lui	 a5,0x40000
   100f4:	00e7a423          	sw	 a4,8(a5) # 40000008 <__global_pointer$+0x3ffee6d8>
   100f8:	01010113          	addi sp,sp,16
   100fc:	00008067          	ret
```

- Observation
  - Line of Code: 46
  - Register Used: 9
    - sx register: s0
    - tx register: None
    - ax register: a0 a1 a2 a3 a4 a5
    - other: sp ra
  - Stack used(bytes): 16
  - lw/sw count: 5

## Results of emu-rv32i

|                   | Original |   -O3   |   -Os   |
| ----------------  | -------- | ------- | ------- |
| Line of Code      |    49    |   112   |    46   |
| Register Used     |     9    |     6   |     9   |
| Stack used(bytes) |  None    |  None   |    16   |
| lw/sw count       |     0    |     1   |     5   |

- insn_counter: Counting how many instructions have been executed

- jump_counter: Counting how many **jump** occurred (because execute **jal jalr and other branch instructions**)

- forward_counter: If the **jump** occur and the **next_pc** is bigger than **PC**, forward_counter will plus one
  &rarr; Means, **forward_counter** counts the number that PC jumps to the bigger address of the instruction (jal jalr and branch instructions)

- backward_counter: If the **jump** occur and the **next_pc** is smaller than **PC**, forward_counter will plus one
  &rarr; Means, **backward_counter** counts the number that PC jumps to the smaller address of the instruction (jal jalr and branch instructions)

- true_counter: When executes the branch instructions and the **jump** occur, true_counter will plus one
  &rarr; Means, **true_counter** counts the number that PC jumps to the other address of the intstruction (branch instructions)

- false_counter: When executes the branch instructions but the **jump** doesn't occur, false_counter will plus one
  &rarr; Means, **false_counter** counts the number that PC doesn't jump to the other address of the intstruction (branch instructions)

### -O3 Statistics
![](https://i.imgur.com/6UNQrV4.png)

### -Os Statistics
![](https://i.imgur.com/KKdrwtV.png)



