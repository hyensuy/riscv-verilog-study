//
//  Author: Prof. Yongwoo Kim
//          System Semiconductor Engineering
//          Sangmyung University
//  Date: July 19, 2022
//  Description: Simple Hardware System based on RISC-V RV32I
//  This code references RVbook in Korea Univ. and EECS151 in UCB.
//
//`timescale 1ns/1ns

module SMU_RV32I_System (
  input         CLOCK_50,
  input   [2:0] BUTTON,
  input   [9:0] SW,
  output  [6:0] HEX3,
  output  [6:0] HEX2,
  output  [6:0] HEX1,
  output  [6:0] HEX0,
  output  [9:0] LEDR,

  output        UART_TXD,
  input         UART_RXD
);

  parameter RESET_PC = 32'h1000_0000;
  parameter CLOCK_FREQ = 125_000_000;
  parameter BAUD_RATE = 1_000_000;
  parameter MIF_HEX = "";
  parameter MIF_BIOS_HEX = "";
  parameter DWIDTH = 32;
  parameter AWIDTH = 12;

  wire reset;
  wire reset_poweron;
  reg  reset_ff;
  wire [31:0] fetch_addr;
  wire [31:0] imem_inst;
  wire [31:0] inst;
  wire [31:0] data_addr;
  wire [31:0] write_data;
  wire [3:0]  ByteEnable;
  wire [31:0] read_data;
  wire        cs_mem_n;
  wire        cs_timer_n;
  wire        cs_gpio_n;
  wire        cs_uart_n;
  wire        data_we;


  wire clk = CLOCK_50;
  wire clkb;
  wire data_re;
  
  assign  reset_poweron = BUTTON[0];
  assign  reset = reset_poweron;

  always @(posedge clk)
    reset_ff <= reset;

  assign clkb = ~clk;
  wire cs_bios_n;
  wire [31:0] read_imem_data_mem;
	assign data_re = ~data_we;
  assign inst = imem_inst;

	//-----------------------------------------------------------
	//PLL
	//-----------------------------------------------------------
	
	wire clk0;
	wire clk90;
	wire clk180;
	wire clk270;
	wire locked;
	
	`ifdef FPGA 
	alt_pll pll0(
		.inclk0	(CLOCK_50),
		.c0			(clk0),
		.c1			(clk90),
		.c2			(clk180),
		.c3			(clk270),
		.locked	(locked)
	);
	`endif

	//-----------------------------------------------------------
	//CPU
	//-----------------------------------------------------------		
	
	rv32i_cpu #(
      .RESET_PC(RESET_PC)
  ) icpu (
	`ifdef FPGA
		.clk			  (clk0), 
    .clkb       (clk270),		//WB
	`else
		.clk			  (clk), 
    .clkb       (clk),
	`endif
		.reset		  (~reset_ff),
		.pc			    (fetch_addr),
		.inst		  	(inst),
		.MemWrite   (data_we),  // data_we: active high
		.MemAddr		(data_addr), 
		.MemWData	  (write_data),
		.ByteEnable	(ByteEnable),
		.MemRData	  (read_data)
  );

	//-----------------------------------------------------------
	//Memory
	//-----------------------------------------------------------
	
	`ifdef FPGA
	dualport_mem_synch_rw_dualclk #(
		.DATA_WIDTH(DWIDTH),
		.ADDRESS_WIDTH(AWIDTH),
		.MIF_HEX (MIF_HEX)
	)imem (
		.clk1(clk90),
		.clk2(clk180),
	 	.addr1(fetch_addr[AWIDTH+2-1:2]),
  	.addr2(data_addr[AWIDTH+2-1:2]),
  	.be1(4'd0),
  	.be2(ByteEnable),
  	.data_in1(32'd0),
  	.data_in2(write_data),
  	.we1(1'b0),
  	.we2(data_we),
  	.data_out1(imem_inst),
  	.data_out2(read_imem_data_mem)
	);		
	
	`else
  ASYNC_RAM_DP_WBE #(
      .DWIDTH (DWIDTH),
      .AWIDTH (AWIDTH),
      .MIF_HEX (MIF_HEX)
  ) imem (
    .clk      (clk),
    .addr0    (fetch_addr[AWIDTH+2-1:2]),
    .addr1    (data_addr[AWIDTH+2-1:2]),
    .wbe0     (4'd0),
    .wbe1     (ByteEnable),
    .d0       (32'd0),
    .d1       (write_data),
    .wen0     (1'b0),
    .wen1     (data_we),//~cs_mem_n &
    .q0       (imem_inst),
    .q1       (read_imem_data_mem)
  );
	`endif

	//-----------------------------------------------------------
	//Peripheral
	//-----------------------------------------------------------

	wire [3:0] seg0;
	wire [3:0] seg1;
	wire [3:0] seg2;
	wire [3:0] seg3;

	wire [6:0] seg0_tmp;	
	wire [6:0] seg1_tmp;	
	wire [6:0] seg2_tmp;	
	wire [6:0] seg3_tmp;	
	
	wire [31:0] read_data_gpio;
	wire [31:0] read_data_timer;
	wire [31:0] read_data_uart;

	//////////////////////////////////////////
	//data_mux
	//////////////////////////////////////////
	data_mux u_data_mux(
		//MEM
		.read_data_mem(read_imem_data_mem),
		//GPIO
		.cs_gpio_n(cs_gpio_n),
		.read_data_gpio(read_data_gpio),
		//Timer
		.cs_timer_n(cs_timer_n),
		.read_data_timer(read_data_timer),
		//UART
		.cs_uart_n(cs_uart_n),
		.read_data_uart(read_data_uart),
		
		//output
		.read_data(read_data)
	);


	//////////////////////////////////////////
	//Addres Decoder
	//////////////////////////////////////////
	
	Addr_Decoder iDecoder (
  	.Addr        (data_addr),
    .CS_MEM_N    (cs_mem_n) ,
    .CS_TC_N     (cs_timer_n),
    .CS_UART_N   (cs_uart_n),
    .CS_GPIO_N   (cs_gpio_n)
	);


	//-----------------------------------------------------------
	//GPIO
	//-----------------------------------------------------------
	
 	GPIO iGPIO (
	`ifdef FPGA
			.clk			(clk180),
	`else
  		.clk      (clk),
	`endif
		.reset  		(~reset_ff),
  	.CS_N   		(cs_gpio_n),
  	.RD_N   		(~data_re),
		.WR_N   		(~data_we),
		.Addr   		(data_addr[11:0]),
  	.DataIn 		(write_data),
  	.DataOut		(read_data_gpio),
  	.Intr   		(),
  	.BUTTON 		(BUTTON[2:1]),
  	.SW     		(SW),
  	.HEX3       (seg3_tmp),
  	.HEX2       (seg2_tmp),
  	.HEX1       (seg1_tmp),
  	.HEX0       (seg0_tmp),
  	.LEDG   		(LEDR)
	);

	assign seg0 = seg0_tmp[3:0];
	assign seg1 = seg1_tmp[3:0];
	assign seg2 = seg2_tmp[3:0];
	assign seg3 = seg3_tmp[3:0];

	//Segment
	SEG7_LUT u0_SEG7_LUT(
		.idata(seg0),
		.oSEG(HEX0)
	);
        
 	SEG7_LUT u1_SEG7_LUT(
		.idata(seg1),
		.oSEG(HEX1)
	);
  
	SEG7_LUT u2_SEG7_LUT(
		.idata(seg2),
		.oSEG(HEX2)
	);
  
	SEG7_LUT u3_SEG7_LUT(
		.idata(seg3),
		.oSEG(HEX3)
	);

	//-----------------------------------------------------------
	//Timer
	//-----------------------------------------------------------
	
	TimerCounter iTimer (
	`ifdef FPGA
		.clk     (clk180),
	`else
		.clk     (clk),
	`endif
    .reset   (~reset_ff),
    .CS_N    (cs_timer_n),
    .RD_N    (~data_re),
    .WR_N    (~data_we),
    .Addr    (data_addr[11:0]),
    .DataIn  (write_data),
    .DataOut (read_data_timer),
    .Intr    ()
 	);

	//-----------------------------------------------------------
	//UART
	//-----------------------------------------------------------
	uart_wrap #(
    .CLOCK_FREQ (CLOCK_FREQ),
    .BAUD_RATE  (BAUD_RATE)
  )iuart_wrap(
	`ifdef FPGA
    .clk  	(clk180),
	`else
    .clk  	(clk),
	`endif
    .reset  (~reset_ff),
    .CS_N(cs_uart_n),
    .RD_N(~data_re),
    .WR_N(~data_we),
    .Addr(data_addr[11:0]),
    .DataIn(write_data),
    .DataOut(read_data_uart),
    .uart_rx(UART_RXD),
    .uart_tx(UART_TXD)
	);
	
	
endmodule
