`timescale 1ns/1ps

module testbench();
    reg [31:0] a_in;
    reg [31:0] b_in;
    reg carry_in;
    wire [31:0] sum_out;
    wire carry_out;

    adder_32bit dut (
      .a     (a_in),
      .b     (b_in),
      .cin 	 (carry_in),
      .sum   (sum_out),
      .cout	 (carry_out)
    );

   initial
    begin
        		a_in = 32'd0; 			 b_in = 32'd0; 				carry_in = 1'd0;	//expected sum : 32'd0
        #10 a_in = 32'd1; 			 b_in = 32'd1; 				carry_in = 1'd0;	//32'd2
        #10 a_in = 32'd2; 			 b_in = 32'd5;		 	  carry_in = 1'd1;	//32'd8
        #10 a_in = 32'd25; 			 b_in = 32'd30; 			carry_in = 1'd0;	//32'd55
        #10 a_in = 32'd100; 		 b_in = 32'd200; 			carry_in = 1'd1;	//32'd301
        #10 a_in = 32'd15520; 	 b_in = 32'd35000; 		carry_in = 1'd0;	//32'd50,520
        #10 a_in = 32'd60000; 	 b_in = 32'd60000; 		carry_in = 1'd1;	//32'd120,001
        #10 a_in = 32'hFFFFFFFF; b_in = 32'd1; 				carry_in = 1'd0;	//32'h0000_0000 , cout = 1
    end


    initial
    begin
        #5 $display("               Time  ns:   a   +  b   +c_in/ Result(Previous 2 clk)");
        #10 $display("%t ns: %d + %d + %d / sum: %d c_out: %d", $time, a_in, b_in, carry_in, sum_out, carry_out);
        #10 $display("%t ns: %d + %d + %d / sum: %d c_out: %d", $time, a_in, b_in, carry_in, sum_out, carry_out);
        #10 $display("%t ns: %d + %d + %d / sum: %d c_out: %d", $time, a_in, b_in, carry_in, sum_out, carry_out);
        #10 $display("%t ns: %d + %d + %d / sum: %d c_out: %d", $time, a_in, b_in, carry_in, sum_out, carry_out);
	      #10 $display("%t ns: %d + %d + %d / sum: %d c_out: %d", $time, a_in, b_in, carry_in, sum_out, carry_out);
        #10 $display("%t ns: %d + %d + %d / sum: %d c_out: %d", $time, a_in, b_in, carry_in, sum_out, carry_out);
        #10 $display("%t ns: %d + %d + %d / sum: %d c_out: %d", $time, a_in, b_in, carry_in, sum_out, carry_out);
        #10
        #10
        $finish;
    end

`ifdef FSDB
    initial
    begin
      $fsdbDumpfile("wave.fsdb");
      $fsdbDumpvars(0);
    end
`endif

endmodule
