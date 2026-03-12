// Main decoder (decode-stage control generation).
module maindec(input [6:0] opcode,output reg RegWrite,output reg [2:0] ImmSrc,output reg [1:0] ALUSrcA,output reg ALUSrcB,output reg MemWrite,output reg [1:0] ResultSrc,output reg Branch,output reg [1:0] PCSrc);
  always @(*) begin
    RegWrite=0; ImmSrc=3'b000; ALUSrcA=2'b00; ALUSrcB=1'b0; MemWrite=0; ResultSrc=2'b00; Branch=0; PCSrc=2'b00;
    case(opcode)
      7'b0110011: begin RegWrite=1; end // R
      7'b0010011: begin RegWrite=1; ALUSrcB=1; end // I-ALU
      7'b0000011: begin RegWrite=1; ALUSrcB=1; ResultSrc=2'b01; end // LOAD
      7'b0100011: begin ALUSrcB=1; MemWrite=1; ImmSrc=3'b001; end // STORE
      7'b1100011: begin Branch=1; ImmSrc=3'b010; end // BRANCH
      7'b0110111: begin RegWrite=1; ALUSrcA=2'b10; ALUSrcB=1; ImmSrc=3'b100; end // LUI
      7'b0010111: begin RegWrite=1; ALUSrcA=2'b01; ALUSrcB=1; ImmSrc=3'b100; end // AUIPC
      7'b1101111: begin RegWrite=1; ImmSrc=3'b011; ResultSrc=2'b10; PCSrc=2'b01; end // JAL
      7'b1100111: begin RegWrite=1; ALUSrcB=1; ResultSrc=2'b10; PCSrc=2'b10; end // JALR
      default: begin end
    endcase
  end
endmodule
