module register_file (
	input clk,	
	input rst_n,
	input we3, 
	input [4:0] a1,a2,a3, //a1, a2  //a3: wb
  input	[31:0] 	wd3,		//write data
  output [31:0] rd1,rd2
);
	
	reg [31:0] rf[0:31];

	//write back
	always @(posedge clk, negedge rst_n)
	begin 
		if (~rst_n) begin
   		rf[a3] <= 32'h0;  
    end
  	else begin
    	if (we3 == 1'b1)
        rf[a3] <= wd3;
    end
	end

	assign rd1 = (a1 != 5'h0) ? rf[a1] : 32'h0;
	assign rd2 = (a2 != 5'h0) ? rf[a2] : 32'h0;

////////////////

`ifdef SIM
  initial
  begin
		rf[5] = 32'd50;
		rf[10] = 32'd100;
		rf[15] = 32'd150;
		rf[20] = 32'd200;
  end

	//to check verctor signal when simulation
		wire [31:0] rf5;
		assign rf5 = rf[5];
		wire [31:0] rf10;
		assign rf10 = rf[10];
		wire [31:0] rf15;
		assign rf15 = rf[15];
		wire [31:0] rf20;
		assign rf20 = rf[20];	
`endif

endmodule

