.syntax unified
.thumb
.text
.global asm_main
.type asm_main, %function
.align 2

.equ RCC_BASE,   0x40023800   // Reset and Clock Control
.equ GPIOA_BASE, 0x40020000   // GPIOA base (Output)
.equ GPIOD_BASE, 0x40020C00   // GPIOD base (Input)

.equ RCC_AHB1ENR, 0x30        // RCC AHB 1 enable
.equ MODER_OFFSET,  0x00      // Mode Register
.equ OTYPER_OFFSET, 0x04      // Output Type Register
.equ PUPDR_OFFSET,  0x0C      // Pull-Up / Pull-Down Register
.equ IDR_OFFSET,    0x10      // Input Data Register
.equ ODR_OFFSET,    0x14      // Output Data Register

asm_main:
    LDR R0, =RCC_BASE
    LDR R1, [R0, #RCC_AHB1ENR]
    ORR R1, R1, #0x09           // set bits 0 and 3 of RCC_AHB1ENR (A and D, respectively)
    STR R1, [R0, #RCC_AHB1ENR]  // we enable the clock for these ports

    LDR R0, =GPIOA_BASE

    LDR R1, =0x55555555 // set bits for all 16 pins to 01
    STR R1, [R0, #MODER_OFFSET] // so that they are used for the output

    MOV R1, #0x0000 // set bits for all 16 pins to 0
    STR R1, [R0, #OTYPER_OFFSET] // so that we have push-pull output

    LDR R0, =GPIOD_BASE

    LDR R1, [R0, #MODER_OFFSET]
    BIC R1, R1, #0xC0000000     // clear bits 31, 30 for MSB
    BIC R1, R1, #0x00000003		// and bits 1, 0 for LSB
    STR R1, [R0, #MODER_OFFSET] // leds in LSB and MSB are used for the input

    LDR R1, [R0, #PUPDR_OFFSET]
    BIC R1, R1, #0xC0000000     // clear bits 31, 30 for MSB
    BIC R1, R1, #0x00000003     // and bits 1, 0 for LSB
    LDR R2, =0x80000002 // set bits 31, 30 for MSB and bits 1, 0 for LSB to 10 (pull down)
    ORR R1, R1, R2 // so that we can safely depict 0 (GND) when the buttons (leds) are not pressed
    STR R1, [R0, #PUPDR_OFFSET]


    LDR R0, =GPIOA_BASE // R0 used for the output
    LDR R1, =GPIOD_BASE // R1 used for the input
    MOV R2, #0x0001 // R2 used for the moving led location, initialized to 1 (LSB led on)

main_loop:
    LDR R4, [R1, #IDR_OFFSET]   // read input from IDR GPIOD

    TST R4, #0x0001             // test if LSB led is on
    BEQ write_led               // if not, do not move the output led

    LDR R5, =0x8000             // if yes, check the MSB for direction
    TST R4, R5                  // if it is on
    BNE move_right              // move to the right

move_left:
    LSL R2, R2, #1              // else move to the left
    LDR R5, =0x10000            // 17-th bit used to check overflow
    CMP R2, R5                  // if bit overflow happened
    BNE write_led               // jump to led depiction if not
    MOV R2, #0x0001             // go to the LSB again
    B write_led                 // and then jump to led depiction

move_right:
    LSR R2, R2, #1              // move to the right
    CMP R2, #0                  // check for overflow
    BNE write_led               // jump to led depiction if not
    LDR R2, =0x8000             // go to the MSB again

write_led:
    STR R2, [R0, #ODR_OFFSET]   // write R2 content (led location) to the ODR

    LDR R3, =0x00FFFFFF         // use delay so that the led light changing location is visible
delay_loop:
    SUBS R3, R3, #1             // decrement (with CPSR change) the delay timer
    BNE delay_loop

    B main_loop                 // repeat when delay timer is zero
