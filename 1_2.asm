.include "m16def.inc"

.def temp = r16
.def prev_bit = r17
.def comp = r18
.def i = r19
.def ans = r20

.org 0x0000
	rjmp start

.org 0x002A ;start the program after the dedicated memory space for interrupts

start:
	;stack pointer initialization
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	;I/O initialization
	clr temp
	out DDRB, temp
	ser temp
	out PORTB, temp ;pull-up resstance activation
	out DDRD, temp

init:	
	in temp, PINB
	mov prev_bit, temp
	andi prev_bit, 0b00000001 ;initialize register with LSB for comparison
	clr ans ;initialize answer with 0
	ldi i, 7 ;initialize i for 7 iterations

loop:
	bst temp, 0 ;store LSB in T
	lsr temp ;shift right for next bit
	bld prev_bit, 0 ;load LSB from T
	mov comp, temp ;copy the input to compare register
	andi comp, 0b00000001 ;keep only LSB
	eor comp, prev_bit ;XOR to check for change, 1 = change, 0 = no change
	cpi comp, 0
	breq inc_loop ;if there is no change, next iteration
	sec ;set carry bit to add to the MSB
	ror ans ;if there is a change, add another one

inc_loop:
	dec i
	breq output
	rjmp loop
	
output:
	out PORTD, ans
	rjmp init