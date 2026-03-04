module datapath(
	input clk,
	input clkb,
	input reset,
	input [31:0] instr,
	
	input RegWrite,
	input [2:0] ImmSrc,
	input [1:0] ALUSrcA,
	input ALUSrcB,
	input [4:0] ALUControl,
	//input MemWrite,
	input [1:0] ResultSrc,
	input Branch,
	input [1:0] PCSrc,
  //input Csr,	
  //input  [31:0] MemRData,

	output [31:0] pc,
  output [31:0] ALUResult,  	// memory address 
  output [31:0] BE_WD, 				// data to write to memory
  output [3:0]  ByteEnable,  	// byte enable
  input  [31:0] MemRData,
	output Btaken
);

	parameter   RESET_PC = 32'h1000_0000;

	wire [31:0] WD_path;
	wire [31:0] RD1_path;
	wire [31:0] RD2_path;

	wire [31:0] ImmExt_path;

	wire N_path; 
	wire Z_path; 
	wire C_path;
	wire V_path;

	wire [31:0] BE_RD_path;

	wire [31:0] PCPlus4_path;



	next_pc_logic u_next_pc_logic(
		.clk(clk),
    .reset(reset),
		.ImmExt(ImmExt_path),
		.ALUResult(ALUResult),
		.PCSrc(PCSrc),	//control_signal	
		.PCPlus4(PCPlus4_path),
		.pc(pc)
	);

	reg_file_async rf(
		.clk(clk),
    .clkb(clkb),
    .we(RegWrite),
    .ra1(instr[19:15]), 
    .ra2(instr[24:20]),
    .wa(instr[11:7]),
    .wd(WD_path),
    .rd1(RD1_path), 
    .rd2(RD2_path)
	);



	extend u_extend( 	
		.instr(instr[31:7]),
	//	.Csr(Csr),
  	.ImmSrc(ImmSrc),
		.ImmExt(ImmExt_path)
	);

	alu u_alu( 
		.ALUSrcA(ALUSrcA),	 //control signal 
		.ALUSrcB(ALUSrcB),	 //control signal 
		.ALUControl(ALUControl), //control signal 
		.RD1(RD1_path),
		.RD2(RD2_path),
		.pc(pc),
		.ImmExt(ImmExt_path),
		.N(N_path),
		.Z(Z_path),
		.C(C_path),
		.V(V_path),
		.ALUResult(ALUResult)
	);



	branch_logic u_branch_logic( 
		.Branch(Branch),	//control signal
		.funct3(instr[14:12]),
		.N(N_path),
		.Z(Z_path),
		.C(C_path),
		.V(V_path),
		.Btaken(Btaken)
	);

	BE_logic u_BE_logic( 
		.funct3(instr[14:12]),
		.Addr_Last2(ALUResult[1:0]),
		.WD(RD2_path),
		.RD(MemRData),
		.BE_WD(BE_WD),
		.BE_RD(BE_RD_path),
		.Byte_Enable(ByteEnable)
	);

	register_write_data_logic u_register_write_data_logic(
		.ResultSrc(ResultSrc), 	//control signal 
		.ALUResult(ALUResult),
		.BE_RD(BE_RD_path),
		.PCPlus4(PCPlus4_path),
		.WD(WD_path)
	);

/*
//Csr
reg [31:0] tohost_csr;

always @(*)
begin
    if (Csr==1'b1)
    	begin
        case (instr[14:12])
            3'b001: tohost_csr = RD1_path;
            3'b101: tohost_csr = ImmExt_path;
            default : tohost_csr = 32'h0;
        endcase
		end
    else
        tohost_csr = 32'h0;
end
*/
endmodule
