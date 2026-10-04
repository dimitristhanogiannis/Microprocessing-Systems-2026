.syntax unified
.thumb
.text
.global asm_main_
.type asm_main_, %function
.align 2

.equ RCC_BASE,   0x40023800   // Reset and Clock Control
.equ GPIOD_BASE, 0x40020C00   // GPIOD base (Output)

.equ RCC_AHB1ENR, 0x30        // RCC AHB 1 enable
.equ MODER_OFFSET,  0x00      // Mode Register
.equ OTYPER_OFFSET, 0x04      // Output Type Register
.equ ODR_OFFSET,    0x14      // Output Data Register

asm_main_:
	LDR R0, =0x20000900 // initial address
	MOV R1, #0x000000FF // initial number (32 bits, word size)

loop_store:
	STR R1, [R0], #4 // post-index address increment by word
	SUBS R1, R1, #1
	CMP R1, #0
	BGE loop_store   // if less than zero, only then break (zero included)

	LDR R0, =0x20000900 // initial address
	MOV R2, #0          // zero counter
	MOV R4, #256		// numbers counter

loop_zero_count:
	MOV R3, #32         // bits left counter (32 bits for word)
	LDR R1, [R0], #4	// post-index address increment by word

single_number_zero_count:
	LSRS R1, R1, #1		// put LSB to C
	IT LO
	ADDLO R2, R2, #1	// if C = 0, increment zero counter
	SUBS R3, R3, #1		// decrement bits left counter
	BNE single_number_zero_count // if it is zero, we have included all bits

check_completion:
	SUBS R4, R4, #1		// decrement numbers counter
	BNE loop_zero_count	// include zero

output_1:
	LDR R0, =RCC_BASE
    LDR R1, [R0, #RCC_AHB1ENR]
    ORR R1, R1, #0x08           // set bit 3 of RCC_AHB1ENR
    STR R1, [R0, #RCC_AHB1ENR]  // we enable the clock for GPIOD

    LDR R0, =GPIOD_BASE

    LDR R1, =0x55555555 // set bits for all 16 pins to 01
    STR R1, [R0, #MODER_OFFSET] // so that they are used for the output

    MOV R1, #0x0000 // set bits for all 16 pins to 0
    STR R1, [R0, #OTYPER_OFFSET] // so that we have push-pull output

	STR R2, [R0, #ODR_OFFSET] // write R2 content (led location) to the ODR


	LDR R0, =0x20000900 // initial address
	MOV R2, #0          // numbers between counter
	MOV R4, #256		// numbers counter

loop_between_count:
	LDR R1, [R0], #4	// post-index address increment by word
	CMP R1, #0x10		// 1st comparison
	BLT check_finish	// if not satisfied, next number
	CMP R1, #0x80		// 2nd comparison
	IT LE
	ADDLE R2, R2, #1	// if both are satisfied, include this number

check_finish:
	SUBS R4, R4, #1		// decrement numbers counter
	BNE loop_between_count	// include zero

output_2:
    LDR R0, =GPIOD_BASE
	STR R2, [R0, #ODR_OFFSET] // write R2 content (led location) to the ODR

endless_loop:
	B endless_loop
