.include "m16def.inc"

.def temp = r16
.def ans = r17

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
	out DDRC, temp

init:
	in temp, PINA
	cpi temp, 100 ;check if input greater or equal to 100
	brsh error 
	clr ans ;initialize answer with 0

loop:
	cpi temp, 10 ; check if greater than 10
	brlo output ;if not, this is the output
	subi temp, 10 ;if it is, subtract 10
	inc ans ;add the times the number is greater than 10
	rjmp loop ;until it is not greater than 10

output:
	lsl ans
	lsl ans
	lsl ans
	lsl ans ;move the times it is greater than 10 to the 4 MSB
	add ans, temp ;add the remainder to the 4 LSB
	out PORTC, ans
	rjmp init

error:
	ser ans ;if it is, output is 11111111
	out PORTC, ans
	rjmp init