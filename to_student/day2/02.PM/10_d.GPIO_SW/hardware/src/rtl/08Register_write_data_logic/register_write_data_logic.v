module register_write_data_logic(
	input [1:0] ResultSrc, 	//control signal 
	input [31:0] ALUResult,
	input [31:0] BE_RD,
	input [31:0] PCPlus4,
	output reg [31:0] WD
);

	
	always@(*)
	begin 
 		case(ResultSrc[1:0])
			2'b00: WD = ALUResult;			
			2'b01: WD = BE_RD;	
			2'b10: WD = PCPlus4;	
			default: WD = 32'h0000_0000;
 		endcase
	end
endmodule
