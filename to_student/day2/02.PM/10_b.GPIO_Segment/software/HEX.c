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
		*(unsigned int*) (RISCV_GPIO_BASE + 0x00C) = 2;	//0x0100100
    delay(0xff);
		*(unsigned int*) (RISCV_GPIO_BASE + 0x010) = 0;	//0x1000000
    delay(0xff);
		*(unsigned int*) (RISCV_GPIO_BASE + 0x014) = 2;	//0x0100100
    delay(0xff);
		*(unsigned int*) (RISCV_GPIO_BASE + 0x018) = 3;	//0x0110000
    delay(0xff);

    SIM_FINISH = 0xdeadbeef;
	}
}
