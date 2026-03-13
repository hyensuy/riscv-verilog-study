// Branch condition evaluator.
module branch_logic(input Branch,input [2:0] funct3,input N,Z,C,V,output reg Btaken);
  always @(*) begin
    if (!Branch) Btaken = 1'b0;
    else case(funct3)
      3'b000: Btaken = Z;
      3'b001: Btaken = ~Z;
      3'b100: Btaken = (N!=V);
      3'b101: Btaken = (N==V);
      3'b110: Btaken = ~C;
      3'b111: Btaken = C;
      default: Btaken = 1'b0;
    endcase
  end
endmodule
