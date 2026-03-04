module alu_32bit(
	input				[2:0] 	ALUControl,
	input				[31:0] 	a,b,
	output reg 	[31:0] 	result,
	output 							N,Z,C,V
);

	wire [31:0] b_bar;
	wire [31:0] sum;

	assign b_bar = (ALUControl[0] == 1'b1) ? ~b : b;

	adder_32bit u_adder_32bit(
		.a(a),
		.b(b_bar),
		.cin(ALUControl[0]),
		.sum(sum),	
		.N(N),
		.Z(Z),	
		.C(C),	
		.V(V)
	);

	//SLT
	wire slt;
	assign slt = N^V;

	//mux	
	always@(*)
	begin
		case(ALUControl[2:0])
			3'b000: result = sum;              //Add
      3'b001: result = sum;              //Sub 
      3'b010: result = a & b;            //AND 
      3'b011: result = a | b;            //OR
      3'b101: result = {31'b0,slt};      //SLT 
      default: result = 32'h0;
 		endcase
	end

endmodule
