#include <avr/io.h>
#define byte uint8_t

int main(void){
	DDRA = 0x00; //PORTA is the input
	PORTA = 0xFF; //enable pull-up resistance
	DDRC = 0xFF; //PORTC is the output
	
	while(1){
		byte temp = PINA;
		byte ans = 0; //initialize answer with 0
		
		if(temp > 99) { 
			ans = 255; // if input >= 100, output is 0b11111111
			PORTC = ans;
			continue;
		}
		
		while(temp >= 10){ 
			temp -= 10;
			ans +=1; //subtract all the times temp is greater than 9 and count them
		}
		
		ans <<= 4; //move them to the 4 MSB
		ans += temp; //add the remainder to the 4 LSB
		PORTC = ans;
	}	
}