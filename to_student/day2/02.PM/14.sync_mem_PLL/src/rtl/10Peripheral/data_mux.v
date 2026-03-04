`timescale 1ns/1ns

module data_mux (
	//MEM
	input [31:0]	read_data_mem,

	//GPIO
	input cs_gpio_n,
	input [31:0] read_data_gpio,

	//Timer
	input cs_timer_n,
	input [31:0] read_data_timer,

	//UART
	input cs_uart_n,
	input [31:0] read_data_uart,


	//Output
  output reg [31:0] read_data 
);
  
  always @(*)
	begin
		if 			(~cs_gpio_n) 	read_data = read_data_gpio;
		else if (~cs_timer_n) read_data = read_data_timer;
		else if (~cs_uart_n) 	read_data = read_data_uart;
 	  else            			read_data = read_data_mem;
 	end
 
endmodule  
