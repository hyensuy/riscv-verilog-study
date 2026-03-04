module register_32bit(
	input 						clk,	
	input 						rst_n,
  input				[31:0] 	d,
  output reg	[31:0] 	q
);
	
	always @(posedge clk, negedge rst_n)
	begin
	  if (~rst_n)
   		q <= 32'h0;  
  	else
    	q <= d;
	end

endmodule
