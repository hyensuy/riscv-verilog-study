// Writeback data selector.
module register_write_data_logic(input [1:0] ResultSrc,input [31:0] ALUResult,input [31:0] BE_RD,input [31:0] PCPlus4,output reg [31:0] WD);
  always @(*) begin
    case (ResultSrc)
      2'b01: WD = BE_RD;
      2'b10: WD = PCPlus4;
      default: WD = ALUResult;
    endcase
  end
endmodule
