// IF/ID register.
// Priority policy: flushD > stallD hold > normal update.
module if_id_reg(input clk,input reset,input stallD,input flushD,input [31:0] pcF,input [31:0] pcPlus4F,input [31:0] instrF,output reg [31:0] pcD,output reg [31:0] pcPlus4D,output reg [31:0] instrD);
  always @(posedge clk or posedge reset) begin
    if (reset) begin pcD<=0; pcPlus4D<=0; instrD<=0; end
    else if (flushD) begin pcD<=0; pcPlus4D<=0; instrD<=0; end
    else if (!stallD) begin pcD<=pcF; pcPlus4D<=pcPlus4F; instrD<=instrF; end
  end
endmodule
