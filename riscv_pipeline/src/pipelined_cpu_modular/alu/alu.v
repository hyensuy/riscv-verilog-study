// RV32I ALU + flags used by branch unit.
// NOTE: Carry flag follows version-2 intent (C = adder carry-out) for BLTU/BGEU checks.
module alu(input [31:0] SrcA,SrcB,input [4:0] ALUControl,output reg [31:0] ALUResult,output N,Z,C,V);
  wire [32:0] sum = {1'b0,SrcA} + {1'b0,(ALUControl[4]?~SrcB:SrcB)} + ALUControl[4];
  wire slt  = (SrcA[31] ^ SrcB[31]) ? SrcA[31] : sum[31];
  wire sltu = ~sum[32];

  always @(*) begin
    case (ALUControl[3:0])
      4'b0000: ALUResult = sum[31:0];
      4'b0001: ALUResult = SrcA | SrcB;
      4'b0010: ALUResult = SrcA & SrcB;
      4'b0011: ALUResult = SrcA ^ SrcB;
      4'b0100: ALUResult = SrcA << SrcB[4:0];
      4'b0101: ALUResult = SrcA >> SrcB[4:0];
      4'b0110: ALUResult = $signed(SrcA) >>> SrcB[4:0];
      4'b0111: ALUResult = {31'd0,slt};
      4'b1000: ALUResult = {31'd0,sltu};
      default: ALUResult = 32'd0;
    endcase
  end

  assign N = ALUResult[31];
  assign Z = (ALUResult==32'd0);
  assign C = sum[32];
  assign V = (SrcA[31]^sum[31]) & ~(SrcA[31]^SrcB[31]^ALUControl[4]);
endmodule
