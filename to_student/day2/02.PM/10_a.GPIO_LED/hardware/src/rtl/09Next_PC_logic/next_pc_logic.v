module next_pc_logic(
	input clk,
  input reset,
	input  [31:0] ImmExt,
	input  [31:0] ALUResult,
	input  [1:0]  PCSrc,	//control_signal	
	output 	[31:0] PCPlus4,
	//output 	[31:0] PCTarget,
	output 	reg [31:0] pc
);

	parameter   RESET_PC = 32'h1000_0000;
	reg [31:0] PCNext;
	wire [31:0] PCTarget;

	alu_add u_alu_add (
		.a(pc), 
		.b(32'h4), 
		.sum(PCPlus4)
	);

	alu_add u2_alu_add (
		.a(pc), 
		.b(ImmExt), 
		.sum(PCTarget)
	);

	always @(*) 
	begin
 		case(PCSrc[1:0])
			2'b00: PCNext = PCPlus4;	//remain
			2'b01: PCNext = PCTarget;	//B-type,jal
			2'b10: PCNext = ALUResult;	//jalr
			2'b11: PCNext = 32'h0;
 		endcase
	end

	always @(posedge clk, posedge reset)
	begin
 		if (reset) 
			pc <= RESET_PC; 	//RESET_PC parameter
 		else 
			pc <= PCNext;
	end

endmodule
          
