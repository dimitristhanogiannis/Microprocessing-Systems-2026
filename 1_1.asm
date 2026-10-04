.include "m16def.inc"

.def count = r18
.def temp = r17
.def zero_low = r14
.def zero_high = r15
.def between_count = r16
.def i = r19

.org 0x0000
	rjmp start

.org 0x002A ;start the program after the dedicated memory space for interrupts

start:
	;stack pointer initialization
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	clr r26 ;xl = 00
	ldi r27, $02 ;xh = 20 => start = $0200
	ldi count, 255 ;numbers 255 -> 0

loop_a:
	st x+, count ;post-increment memory addressing
	tst count ;check for zero counter before decrement, to avoid overflow and include 0
	breq loop_b ;if zero, exit
	dec count 
	rjmp loop_a

loop_b:
	ld temp, -x ;load the memory addresses by decrementing, the opposite way
	ldi i, 8 ;intialize i with 8, used for bits in a byte
	rjmp zero_counting

inc_loop:
	inc count
	cpi count, 255 ;check for all numbers
	breq loop_c
	rjmp loop_b

zero_counting:
	lsr temp ;put the LSB to the carry bit
	brcs dec_loop ;if it is not zero, continue
	inc zero_low ;if it is zero, add to the sum
	brne dec_loop ;if there is no overflow in the low register (zero flag is 0, because 255 + 1 = 0), continue
	inc zero_high ;else increment the high register
	rjmp dec_loop

dec_loop:
	dec i
	breq inc_loop ;if all bits are checked, next Byte
	rjmp zero_counting

loop_c:
	clr between_count ;initialization of counter for numbers between 16 and 128
	clr r26 ;xl = 00
	ldi r27, $02 ;xh = 20 => start = $0200
	clr count ;so that we go from 0 to 255 and to 0 again, executing 256 iterations
	
compare_loop:
	ld temp, x+ ;load numbers
	cpi temp, $10 
	brlo skip_number ;discard if < 10
	cpi temp, $81 
	brsh skip_number ;discard if >= 81
	inc between_count ;else include number

skip_number:
	dec count ;counter was at 255 from b)
	brne compare_loop ;this includes the iteration when counter is 0

end: 
	rjmp end