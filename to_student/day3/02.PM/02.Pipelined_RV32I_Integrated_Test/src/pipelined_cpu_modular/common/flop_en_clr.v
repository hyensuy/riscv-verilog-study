// Register primitive with enable + synchronous clear for pipeline controls.
module flop_en_clr #(parameter WIDTH=32)(
  input clk, input reset, input en, input clr,
  input [WIDTH-1:0] d, output reg [WIDTH-1:0] q
);
  always @(posedge clk or posedge reset) begin
    if (reset) q <= {WIDTH{1'b0}};
    else if (clr) q <= {WIDTH{1'b0}};
    else if (en) q <= d;
  end
endmodule
