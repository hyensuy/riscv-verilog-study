module branch_logic( 
	input  Branch,	//control signal
	input [2:0] funct3,
	input  N,Z,C,V,
	output reg Btaken
);

	always @(*)
	begin
 		case(Branch)
 			1'b1:
				case(funct3[2:0])
					3'b000:	Btaken = (Z==1) ?  1'b1 : 1'b0;	//beq
					3'b001:	Btaken = (Z==0) ?  1'b1 : 1'b0;	//bne
					3'b100:	Btaken = (N!=V) ?  1'b1 : 1'b0;	//blt 
					3'b101:	Btaken = (N==V) ?  1'b1 : 1'b0;	//bge
					3'b110:	Btaken = (C==0) ?  1'b1 : 1'b0;	//bltu
					3'b111:	Btaken = (C==1) ?  1'b1 : 1'b0;	//bgeu
					default: Btaken = 1'b0;
				endcase
 			default: //Branch == 1'b0
 			Btaken = 1'b0;
 		endcase
	end


endmodule
