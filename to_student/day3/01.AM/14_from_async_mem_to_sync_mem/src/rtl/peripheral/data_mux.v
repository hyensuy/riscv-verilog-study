`timescale 1ns/1ns

module data_mux (
`ifdef FPGA
  input         clk,

`endif
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
  
`ifdef FPGA
  reg r_cs_gpio_n;
  reg r_cs_timer_n;
  reg r_cs_uart_n;

  always @(posedge clk)
  begin
    r_cs_gpio_n   <= cs_gpio_n;
    r_cs_timer_n  <= cs_timer_n;
    r_cs_uart_n   <= cs_uart_n;
  end

  reg [31:0] r_read_data_gpio;
  reg [31:0] r_read_data_timer;
  reg [31:0] r_read_data_uart;

  always @(posedge clk)
  begin
    r_read_data_gpio <= read_data_gpio;
    r_read_data_timer <= read_data_timer;
    r_read_data_uart <= read_data_uart;
  end

  always @(*)
	begin
		if 			(~r_cs_gpio_n) 	read_data = r_read_data_gpio;
		else if (~r_cs_timer_n) read_data = r_read_data_timer;
		else if (~r_cs_uart_n) 	read_data = r_read_data_uart;
 	  else            			  read_data = read_data_mem;
 	end

`else

  always @(*)
	begin
		if 			(~cs_gpio_n) 	read_data = read_data_gpio;
		else if (~cs_timer_n) read_data = read_data_timer;
		else if (~cs_uart_n) 	read_data = read_data_uart;
 	  else            			read_data = read_data_mem;
 	end


`endif
 
endmodule  
