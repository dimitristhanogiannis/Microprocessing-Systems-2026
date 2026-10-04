#include <avr/io.h>
#define byte uint8_t 

int main(void){
	DDRA = 0x00; //PORTA is the input
	PORTA = 0xFF; //enable pull-up resistance
	DDRB = 0xFF; //PORTB is the output
	
	while(1){
		byte temp = PINA;
		byte ans = 0;
		
		//read the input appropriately
		byte B0 = temp & 1;
		temp >>= 1;
		byte A0 = temp & 1;
		temp >>= 1;
		byte B1 = temp & 1;
		temp >>= 1;
		byte A1 = temp & 1;
		temp >>= 1;
		byte B2 = temp & 1;
		temp >>= 1;
		byte A2 = temp & 1;
		temp >>= 1;
		byte B3 = temp & 1;
		temp >>= 1;
		byte A3 = temp & 1;
		temp >>= 1;
		
		//1st layer logical functions
		A3 &= B3;
		A2 &= B2;
		A1 |= B1;
		A0 |= B0;
		
		//2nd layer logical functions
		A3 ^= A2;
		A1 &= A0;
		
		//output the answer in the appropriate way
		ans |= A3;
		ans <<= 2;
		ans |= A2;
		ans <<= 2;
		ans |= A1;
		ans <<= 2;
		ans |= A0;
		
		PORTB = ans;
	}
	return 0;
}