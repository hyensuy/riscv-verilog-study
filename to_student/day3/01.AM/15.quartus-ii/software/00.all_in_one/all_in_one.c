#include "types.h"
#include "memory_map.h"
#include "ascii.h"
#include "uart.h"
#define RISCV_GPIO_BASE   0x80002000
#define RISCV_UART_BASE    0x80000000
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
  unsigned int curr_time_value;

  while(1) {
    curr_time_value = *(unsigned int*) (RISCV_TIMER_BASE+0x100);
    // Timer
    *(volatile unsigned int*) (RISCV_GPIO_BASE + 0x018) = (curr_time_value >> 12) & 0x0f;
    *(volatile unsigned int*) (RISCV_GPIO_BASE + 0x014) = (curr_time_value >> 8) & 0x0f;
    *(volatile unsigned int*) (RISCV_GPIO_BASE + 0x010) = (curr_time_value >> 4) & 0x0f;
    *(volatile unsigned int*) (RISCV_GPIO_BASE + 0x00c) = (curr_time_value) & 0x0f;

    // Segment
    *(volatile unsigned int*) (RISCV_GPIO_BASE + 0x00C) = 3;  //0x0110000 
    *(volatile unsigned int*) (RISCV_GPIO_BASE + 0x010) = 2;  //0x0100100 
    *(volatile unsigned int*) (RISCV_GPIO_BASE + 0x014) = 0;  //0x1000000
    *(volatile unsigned int*) (RISCV_GPIO_BASE + 0x018) = 2;  //0x0100100

    *(volatile unsigned int*) (RISCV_GPIO_BASE + 0x008) = 0x2AA;
    delay(0xff);
    *(volatile unsigned int*) (RISCV_GPIO_BASE + 0x008) = 0x155;
    delay(0xff);
    *(volatile unsigned int*) (RISCV_GPIO_BASE + 0x008) = 0x2AA;
    delay(0xff);
    *(volatile unsigned int*) (RISCV_GPIO_BASE + 0x008) = 0x155;
    delay(0xff);

    SIM_FINISH = 0xdeadbeef;

    delay(0xfffff);
  }
}
