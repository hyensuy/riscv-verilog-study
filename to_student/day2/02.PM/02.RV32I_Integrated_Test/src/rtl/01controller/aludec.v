`define OP_R		7'b011_0011	//*don't use ; when declare `define 
`define OP_I_ARITH 	7'b001_0011
`define OP_I_LOAD	7'b000_0011
`define OP_I_JALR	7'b110_0111
`define OP_S		7'b010_0011
`define OP_B		7'b110_0011
`define OP_U_LUI	7'b011_0111
`define OP_U_AUIPC	7'b001_0111
`define OP_J_JAL	7'b110_1111

module aludec(	//input Btaken,
		input [6:0] opcode,
		input [6:0] funct7,
		input [2:0] funct3,
		output reg[4:0] ALUControl
);


	always @(*)
	begin
 		case(opcode)
  	`OP_R:
        case({funct7,funct3})
        10'b0000000_000: ALUControl = 5'b0_0000;        //add
        10'b0100000_000: ALUControl = 5'b1_0000;        //sub
        10'b0000000_001: ALUControl = 5'b0_0100;        //sll
        10'b0000000_010: ALUControl = 5'b1_0111;        //slt
        10'b0000000_011: ALUControl = 5'b1_1000;        //sltu
        10'b0000000_100: ALUControl = 5'b0_0011;        //xor
        10'b0000000_101: ALUControl = 5'b0_0101;        //srl
        10'b0100000_101: ALUControl = 5'b0_0110;        //sra
        10'b0000000_110: ALUControl = 5'b0_0001;        //or
        10'b0000000_111: ALUControl = 5'b0_0010;        //and
        default:         ALUControl = 5'bx_xxxx;
        endcase
  `OP_I_ARITH:
				casez({funct7,funct3}) //casez : for ?(=z) -> don't care
				10'b???????_000: ALUControl = 5'b0_0000;        //addi
        10'b0000000_001: ALUControl = 5'b0_0100;        //slli
        10'b???????_010: ALUControl = 5'b1_0111;        //slti
        10'b???????_011: ALUControl = 5'b1_1000;        //sltui
        10'b???????_100: ALUControl = 5'b0_0011;        //xori
        10'b0000000_101: ALUControl = 5'b0_0101;        //srli
        10'b0100000_101: ALUControl = 5'b0_0110;        //srai
        10'b???????_110: ALUControl = 5'b0_0001;        //or
        10'b???????_111: ALUControl = 5'b0_0010;        //and    
				default:         ALUControl = 5'bx_xxxx;
				endcase
  `OP_I_LOAD,
  `OP_S,
  `OP_U_LUI,
  `OP_U_AUIPC:
												 ALUControl = 5'b0_0000;        //add
  `OP_B:
												 ALUControl = 5'b1_0000;        //sub
 				default: 
				ALUControl = 5'b0_0000;        
 				endcase
	end
          
endmodule
