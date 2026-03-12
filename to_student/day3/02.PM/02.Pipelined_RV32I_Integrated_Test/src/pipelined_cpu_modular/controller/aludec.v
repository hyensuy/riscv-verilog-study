// ALU decoder from opcode/funct fields.
module aludec(input [6:0] opcode,input [6:0] funct7,input [2:0] funct3,output reg [4:0] ALUControl);
  always @(*) begin
    case(opcode)
      7'b0110011: case({funct7,funct3})
        10'b0000000_000: ALUControl=5'b0_0000;
        10'b0100000_000: ALUControl=5'b1_0000;
        10'b0000000_001: ALUControl=5'b0_0100;
        10'b0000000_010: ALUControl=5'b1_0111;
        10'b0000000_011: ALUControl=5'b1_1000;
        10'b0000000_100: ALUControl=5'b0_0011;
        10'b0000000_101: ALUControl=5'b0_0101;
        10'b0100000_101: ALUControl=5'b0_0110;
        10'b0000000_110: ALUControl=5'b0_0001;
        10'b0000000_111: ALUControl=5'b0_0010;
        default:         ALUControl=5'b0_0000;
      endcase
      7'b0010011: casez({funct7,funct3})
        10'b???????_000: ALUControl=5'b0_0000;
        10'b0000000_001: ALUControl=5'b0_0100;
        10'b???????_010: ALUControl=5'b1_0111;
        10'b???????_011: ALUControl=5'b1_1000;
        10'b???????_100: ALUControl=5'b0_0011;
        10'b0000000_101: ALUControl=5'b0_0101;
        10'b0100000_101: ALUControl=5'b0_0110;
        10'b???????_110: ALUControl=5'b0_0001;
        10'b???????_111: ALUControl=5'b0_0010;
        default:         ALUControl=5'b0_0000;
      endcase
      7'b1100011: ALUControl = 5'b1_0000; // branch compare = subtract
      default:   ALUControl = 5'b0_0000;
    endcase
  end
endmodule
