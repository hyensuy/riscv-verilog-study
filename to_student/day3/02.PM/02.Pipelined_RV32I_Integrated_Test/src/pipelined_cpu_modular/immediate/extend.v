// RV32I immediate generator.
module extend(input [31:0] instr,input [2:0] ImmSrc,output reg [31:0] ImmExt);
  always @(*) begin
    case (ImmSrc)
      3'b000: ImmExt = {{20{instr[31]}},instr[31:20]};
      3'b001: ImmExt = {{20{instr[31]}},instr[31:25],instr[11:7]};
      3'b010: ImmExt = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
      3'b011: ImmExt = {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
      3'b100: ImmExt = {instr[31:12],12'b0};
      default: ImmExt = 32'd0;
    endcase
  end
endmodule
