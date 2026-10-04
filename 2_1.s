.syntax unified
.thumb
.text
.global my_asm_code
.type my_asm_code, %function
.align 2

my_asm_code:
MOVS R0, #10 // R0 = 10
MOVS R1, #3 // R1 = 3
LSLS R2, R0, #2 // R2 = 40
ADDS R2, R2, R1 // R2 = 43
MOVS R1, #5 // R1 = 5
SUBS R2, R2, R1 // R2 = 38
LDR R3, [PC, #4] // R3 => [PC + 4] (.word  0x10000000)
STR R2, [R3] // [R3] = 38
loop:
	B loop

.align 4 // align memory by word (4 Bytes)
.word 0x10000000 // 4 Bytes of data (1 word)
