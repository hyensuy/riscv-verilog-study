//
//  Author: Prof. Yongwoo Kim
//          System Semiconductor Engineering
//          Sangmyung University
//  Date: July 19, 2022
//        Updated on July 09, 2022 
//  Description: RV32I Single-cycle CPU
//  This code references RVbook in Korea Univ. and EECS151 in UCB. Univ.
//

//`timescale 1ns/1ns
`define simdelay 1

module rv32i_cpu (
	input         clk, clkb, reset,
  output [31:0] pc,		  		// program counter for instruction fetch
  input  [31:0] inst, 			// incoming instruction
  output        MemWrite, 	// 'memory write' control signal
  output [31:0] MemAddr,  	// memory address 
  output [31:0] MemWData, 	// data to write to memory
  output [3:0]  ByteEnable,  // byte enable
  input  [31:0] MemRData
);
	 	
  parameter   RESET_PC = 32'h1000_0000;

	wire RegWrite;
	wire [2:0] ImmSrc;
	wire [1:0] ALUSrcA;
	wire ALUSrcB;
	wire [4:0] ALUControl;
	wire [1:0] ResultSrc;
	wire Branch;
	wire [1:0] PCSrc;
	wire Btaken;
	//wire Csr;


  // Instantiate Controller
  controller i_controller(
    .opcode		(inst[6:0]), 
    .funct7		(inst[31:25]), 
    .funct3		(inst[14:12]), 
    .RegWrite		(RegWrite),
    .ImmSrc		(ImmSrc),
    .ALUSrcA		(ALUSrcA),
    .ALUSrcB		(ALUSrcB),
    .ALUControl		(ALUControl),
    .MemWrite		(MemWrite),
    .ResultSrc		(ResultSrc),
    .Branch		(Branch),
    .PCSrc		(PCSrc),
    .Btaken		(Btaken)
    //.Csr      (Csr)
  );


  // Instantiate Datapath
  datapath #(
      .RESET_PC(RESET_PC)
  ) i_datapath(
  	.clk				(clk),
		.clkb				(clkb),
    .reset			(reset),
		.instr			(inst),

		.RegWrite		(RegWrite),
		.ImmSrc			(ImmSrc),
		.ALUSrcA		(ALUSrcA),
		.ALUSrcB		(ALUSrcB),
		.ALUControl	(ALUControl),
		.ResultSrc	(ResultSrc),
		.Branch			(Branch),
		.PCSrc			(PCSrc),
  //.Csr        (Csr),

		.pc			(pc),

		.ALUResult	(MemAddr),
		.BE_WD			(MemWData),
		.ByteEnable	(ByteEnable),
		.MemRData		(MemRData),
		.Btaken			(Btaken)
  );



endmodule

