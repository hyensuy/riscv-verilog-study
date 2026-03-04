#include "types.h"
#include "memory_map.h"
#include "ascii.h"
#include "uart.h"

#define RISCV_GPIO_BASE   0x80002000
#define RISCV_UART_BASE		0x80000000
#define RISCV_TIMER_BASE  0x80001000

//////////////////////////////////////////////////////////////////
// Main Function
//////////////////////////////////////////////////////////////////

void delay(unsigned int time)
{
	while (time--);
}

int main(void)
{	
	while(1) {
		*(unsigned int*) (RISCV_GPIO_BASE + 0x000) = 0x32;	//11
		delay(0xf);

    SIM_FINISH = 0xdeadbeef;
	}
}
