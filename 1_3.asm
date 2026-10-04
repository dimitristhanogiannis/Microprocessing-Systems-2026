.include "m16def.inc"

.def temp = r16
.def ans = r17
.def A0 = r18
.def B0 = r19
.def A1 = r20
.def B1 = r21
.def A2 = r22
.def B2 = r23
.def A3 = r24
.def B3 = r25

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
	out DDRA, temp
	ser temp
	out PORTA, temp ;pull-up resstance activation
	out DDRB, temp

init:
	in temp, PINA
	clr ans

	;read the input appropriately
	mov B0, temp
	andi B0, 1
	lsr temp
	mov A0, temp
	andi A0, 1
	lsr temp
	mov B1, temp
	andi B1, 1
	lsr temp
	mov A1, temp
	andi A1, 1
	lsr temp
	mov B2, temp
	andi B2, 1
	lsr temp
	mov A2, temp
	andi A2, 1
	lsr temp
	mov B3, temp
	andi B3, 1
	lsr temp
	mov A3, temp
	andi A3, 1
	lsr temp

	;1st layer logical functions
	and A3, B3
	and A2, B2
	or A1, B1
	or A0, B0

	;2nd layer logical functions
	eor A3, A2
	and A1, A0

	;output the answer in the appropriate way
	or ans, A3
	lsl ans
	lsl ans
	or ans, A2
	lsl ans
	lsl ans
	or ans, A1
	lsl ans
	lsl ans
	or ans, A0
	
	out PORTB, ans
	rjmp init