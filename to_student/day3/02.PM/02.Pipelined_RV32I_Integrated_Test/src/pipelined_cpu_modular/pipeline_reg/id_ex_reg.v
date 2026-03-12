// ID/EX register.
// Priority policy: flushE > normal update (no explicit stall input).
module id_ex_reg(
  input clk,input reset,input flushE,
  input RegWriteD,input MemWriteD,input BranchD,input ALUSrcBD,input [1:0] ALUSrcAD,input [1:0] ResultSrcD,input [1:0] PCSrcD,input [4:0] ALUControlD,
  input [31:0] pcD,input [31:0] pcPlus4D,input [31:0] rd1D,input [31:0] rd2D,input [31:0] ImmExtD,input [4:0] rs1D,input [4:0] rs2D,input [4:0] rdD,input [2:0] funct3D,
  output reg RegWriteE,output reg MemWriteE,output reg BranchE,output reg ALUSrcBE,output reg [1:0] ALUSrcAE,output reg [1:0] ResultSrcE,output reg [1:0] PCSrcE,output reg [4:0] ALUControlE,
  output reg [31:0] pcE,output reg [31:0] pcPlus4E,output reg [31:0] rd1E,output reg [31:0] rd2E,output reg [31:0] ImmExtE,output reg [4:0] rs1E,output reg [4:0] rs2E,output reg [4:0] rdE,output reg [2:0] funct3E
);
  always @(posedge clk or posedge reset) begin
    if(reset || flushE) begin
      RegWriteE <= 1'b0;
      MemWriteE <= 1'b0;
      BranchE   <= 1'b0;
      ALUSrcBE  <= 1'b0;
      ALUSrcAE  <= 2'b00;
      ResultSrcE <= 2'b00;
      PCSrcE    <= 2'b00;
      ALUControlE <= 5'b00000;

      pcE      <= 32'b0;
      pcPlus4E <= 32'b0;
      rd1E     <= 32'b0;
      rd2E     <= 32'b0;
      ImmExtE  <= 32'b0;
      rs1E     <= 5'b0;
      rs2E     <= 5'b0;
      rdE      <= 5'b0;
      funct3E  <= 3'b0;
    end else begin
      RegWriteE <= RegWriteD;
      MemWriteE <= MemWriteD;
      BranchE   <= BranchD;
      ALUSrcBE  <= ALUSrcBD;
      ALUSrcAE  <= ALUSrcAD;
      ResultSrcE <= ResultSrcD;
      PCSrcE    <= PCSrcD;
      ALUControlE <= ALUControlD;

      pcE      <= pcD;
      pcPlus4E <= pcPlus4D;
      rd1E     <= rd1D;
      rd2E     <= rd2D;
      ImmExtE  <= ImmExtD;
      rs1E     <= rs1D;
      rs2E     <= rs2D;
      rdE      <= rdD;
      funct3E  <= funct3D;
    end
  end
endmodule
