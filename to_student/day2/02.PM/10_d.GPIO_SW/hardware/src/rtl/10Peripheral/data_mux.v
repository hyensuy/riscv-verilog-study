
`timescale 1ns/1ns

module data_mux (
	input cs_gpio_n,
	input [31:0] read_data_gpio,
	input [31:0]	read_data_mem,
  output reg [31:0] read_data 
);
  
  always @(*)
	begin
		if (~cs_gpio_n) read_data = read_data_gpio;
 	  else            read_data = read_data_mem;
 	end
 
endmodule  
