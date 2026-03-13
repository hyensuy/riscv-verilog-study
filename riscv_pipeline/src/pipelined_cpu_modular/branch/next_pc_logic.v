// Next-PC selection logic (separate for easier waveform tracing).
module next_pc_logic(input [31:0] pcF,input [31:0] pcTargetE,input [31:0] jalrTargetE,input [1:0] PCSrcE,output [31:0] pcPlus4F,output reg [31:0] pcNextF);
  assign pcPlus4F = pcF + 32'd4;
  always @(*) begin
    case (PCSrcE)
      2'b01: pcNextF = pcTargetE;
      2'b10: pcNextF = {jalrTargetE[31:1],1'b0};
      default: pcNextF = pcPlus4F;
    endcase
  end
endmodule
