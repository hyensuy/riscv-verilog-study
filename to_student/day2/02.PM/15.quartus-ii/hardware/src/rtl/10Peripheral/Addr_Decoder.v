
`timescale 1ns/1ns

module Addr_Decoder (
	input [31:0] Addr,
  output reg CS_MEM_N,
  output reg CS_TC_N,
  output reg CS_UART_N,
  output reg CS_GPIO_N
);
  
 
  always @(*)
  begin
    if       (Addr[31:16] == 16'h1000)  // Instruction & Data Memory
      begin
           CS_MEM_N   <=0;
           CS_TC_N    <=1;
           CS_UART_N  <=1;
           CS_GPIO_N  <=1;
      end
    
    else if  (Addr[31:12] == 20'h80001)  // Timer
      begin
           CS_MEM_N   <=1;
           CS_TC_N    <=0;
           CS_UART_N  <=1;
           CS_GPIO_N  <=1;
      end
     
    else if  (Addr[31:12] == 20'h80000)  // UART
      begin
           CS_MEM_N    <=1;
           CS_TC_N     <=1;
           CS_UART_N   <=0;
           CS_GPIO_N   <=1;
      end

    else if  (Addr[31:12] == 20'h80002)  // GPIO
      begin
           CS_MEM_N    <=1;
           CS_TC_N     <=1;
           CS_UART_N   <=1;
           CS_GPIO_N   <=0;
      end

		
    else 
      begin
           CS_MEM_N   <=1;	//0
           CS_TC_N    <=1;
           CS_UART_N  <=1;
           CS_GPIO_N  <=1;
      end
  end
  
endmodule  
