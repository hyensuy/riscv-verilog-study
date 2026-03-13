// EX/MEM register.
// Priority policy: reset -> bubble/zero outputs, else normal update.
module ex_mem_reg(input clk,input reset,input RegWriteE,input MemWriteE,input [1:0] ResultSrcE,input [31:0] pcPlus4E,input [31:0] ALUResultE,input [31:0] WriteDataE,input [4:0] rdE,input [2:0] funct3E,
  output reg RegWriteM,output reg MemWriteM,output reg [1:0] ResultSrcM,output reg [31:0] pcPlus4M,output reg [31:0] ALUResultM,output reg [31:0] WriteDataM,output reg [4:0] rdM,output reg [2:0] funct3M);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      RegWriteM<=0;MemWriteM<=0;ResultSrcM<=0;pcPlus4M<=0;ALUResultM<=0;WriteDataM<=0;rdM<=0;funct3M<=0;
    end else begin
      RegWriteM<=RegWriteE;MemWriteM<=MemWriteE;ResultSrcM<=ResultSrcE;pcPlus4M<=pcPlus4E;ALUResultM<=ALUResultE;WriteDataM<=WriteDataE;rdM<=rdE;funct3M<=funct3E;
    end
  end
endmodule
