module extend( 	
	input [31:7] instr,
	//input Csr,
  input [2:0] ImmSrc,
	output reg [31:0] ImmExt
);

	always@(*) 
	begin
		case (ImmSrc [2:0])
	      3'b000:	ImmExt = {{20{instr[31]}}, instr[31:20]};																	//i-type
	      3'b001:	ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};										//s-type
	      3'b010:	ImmExt = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};		//B-type
	      3'b011:	ImmExt = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};	//J-type
	      3'b100:	ImmExt = {instr[31:12], 12'b0};																						//U-type
	      default:ImmExt = 32'h0000_0000;
    endcase
	end
/*
always@(*) 
begin
    if(Csr == 1'b1)
        ImmExt = {27'h0, instr[19:15]};
    else
        case (ImmSrc [2:0])
	      3'b000:	ImmExt = {{20{instr[31]}}, instr[31:20]};					//i-type
	      3'b001:	ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};				//s-type
	      3'b010:	ImmExt = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};		//B-type
	      3'b011:	ImmExt = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};	//J-type
	      3'b100:	ImmExt = {instr[31:12], 12'b0};							//U-type
	      default:ImmExt = 32'h0000_0000;
        endcase
end
*/

endmodule
