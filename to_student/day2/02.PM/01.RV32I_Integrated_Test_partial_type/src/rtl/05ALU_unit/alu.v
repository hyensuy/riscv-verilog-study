module alu( 
	input [1:0] ALUSrcA,
	input  	ALUSrcB,
	input [4:0] ALUControl, //control signal 
	input [31:0] RD1,
	input [31:0] RD2,
	input [31:0] pc,
	input  [31:0] ImmExt,
	output N,Z,C,V,
	output reg [31:0] ALUResult
);

	reg [31:0] SrcA;
	wire [31:0] SrcB;


	//SrcA mux
	always @(*) 
	begin
 		case(ALUSrcA[1:0])
			2'b00: SrcA = RD1;
			2'b01: SrcA = pc;	
			2'b10: SrcA = 2'b00;	
			2'b11: SrcA = 2'b00;	
 		endcase
	end
	
	//SrcB mux
	assign SrcB = (ALUSrcB == 1'b1) ? ImmExt : RD2;
	
	//ALU

	wire [31:0] b2, sum;
	wire slt, sltu;

	assign b2 = ALUControl[4] ? ~SrcB : SrcB;

	adder_32bit u_adder_32bit(
		.a(SrcA), 
		.b(b2), 
		.cin(ALUControl[4]), 
		.sum(sum),
	 	.N(N), 
		.Z(Z), 
		.C(C), 
		.V(V)
	); 

	//signed less than condition
	assign slt = N^V;

	//unsigned lower (C clear) condition
	assign sltu = ~C;

	//ALU mux
	always@(*)
	begin 
 		case(ALUControl[3:0])
			4'b0000: ALUResult = sum;			//both add,sub 
			4'b0001: ALUResult = SrcA | SrcB;		//or
			4'b0010: ALUResult = SrcA & SrcB;		//and
			4'b0011: ALUResult = SrcA ^ SrcB;		//xor
			4'b0100: ALUResult = SrcA << SrcB[4:0];	//sll
			4'b0101: ALUResult = SrcA >> SrcB[4:0];	//srl
			4'b0110: ALUResult = $signed(SrcA) >>> SrcB[4:0];	//sra
			4'b0111: ALUResult = {31'b0, slt};		//slt, slti
			4'b1000: ALUResult = {31'b0, sltu};		//sltu, sltui
			default: ALUResult = 32'b0;
 		endcase
	end
endmodule
