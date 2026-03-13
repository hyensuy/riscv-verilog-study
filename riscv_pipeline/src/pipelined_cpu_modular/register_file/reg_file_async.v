// Async-read, sync-write register file (x0 hardwired to zero).
// Timing note: WB writes at posedge, ID reads are combinational. In cycle-accurate wave debug,
// observe write-after-read visibility around clock edge boundaries.
module reg_file_async(input clk,input we,input [4:0] ra1,ra2,wa,input [31:0] wd,output [31:0] rd1,rd2);
  parameter DEPTH=32;
  reg [31:0] mem [0:DEPTH-1];

  always @(posedge clk)
    if (we && (wa!=5'd0)) mem[wa] <= wd;

  assign rd1 = (ra1==0)?32'd0:mem[ra1];
  assign rd2 = (ra2==0)?32'd0:mem[ra2];
endmodule
