#include "memory_map.h"
#include "uart.h"
#include "string.h"

#define RISCV_GPIO_BASE   0x80002000
#define RISCV_UART_BASE   0x80000000
#define RISCV_TIMER_BASE  0x80001000

int8_t* read_n(int8_t*b, uint32_t n) {
    for (uint32_t i = 0; i < n;  i++) {
        b[i] =  uread_int8();
    }
    b[n] = '\0';
    return b;
}

int8_t* read_token(int8_t* b, uint32_t n, int8_t* ds) {
    for (uint32_t i = 0; i < n; i++) {
        int8_t ch = uread_int8();
        for (uint32_t j = 0; ds[j] != '\0'; j++) {
            if (ch == ds[j]) {
                b[i] = '\0';
                return b;
            }
        }
        b[i] = ch;
    }
    b[n - 1] = '\0';
    return b;
}

void delay(unsigned int time)
{
  while (time--);
}

#define BUFFER_LEN 16
int main(void) {
  //uwrite_int8s("\r\nhello World");
  while(1)
	{
   uwrite_int8s("\r\nhell World 1: Love IDEC");
   delay(0xffffffff);
   uwrite_int8s("\r\nhell World 2: Love RISC-V");
   delay(0xffffffff);
  } 
	//delay(0xfffff);
}
  
