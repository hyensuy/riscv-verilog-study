`timescale 1ns/1ps

module testbench();
    reg  [31:0] a_in;
    reg  [31:0] b_in;
    wire [31:0] sum_out;

    sub_32bit dut (
      .a     (a_in),
      .b     (b_in),
      .y     (sum_out)
    );
/*
    initial
    begin
      rst_n = 1'b1;
      #3 
      rst_n = 1'b0;
      @(negedge clk);
      rst_n = 1'b1;
    end

    initial
    begin
      clk <= 1'b0;
      forever begin
        //#0.7 clk <= ~clk;
        #5 clk <= ~clk;
      end
    end
*/
    initial
    begin
        		a_in = 32'd0; 			 b_in = 32'd0; 				//expected result : 32'd0
        #10 a_in = 32'd1; 			 b_in = 32'd1; 				//32'h0
        #10 a_in = 32'd2; 			 b_in = 32'd5;		 	  //32'b101				(-3)
        #10 a_in = 32'd25; 			 b_in = 32'd30; 			//32'b1011			(-5)
        #10 a_in = 32'd100; 		 b_in = 32'd200; 			//32'b1001_1100 (-100)
        #10 a_in = 32'd15520; 	 b_in = 32'd35000; 		//32'hFFFF_B3E8 (-19,480)
        #10 a_in = 32'd60000; 	 b_in = 32'd60000; 		//32'd0					(0)
    end


    initial
    begin
        #5 $display("               Time  ns:   a   -  b   / Result");
        #10 $display("%t ns: %d - %d / result: %d", $time, a_in, b_in, $signed(sum_out));
        #10 $display("%t ns: %d - %d / result: %d", $time, a_in, b_in, $signed(sum_out));
        #10 $display("%t ns: %d - %d / result: %d", $time, a_in, b_in, $signed(sum_out));
        #10 $display("%t ns: %d - %d / result: %d", $time, a_in, b_in, $signed(sum_out));
	      #10 $display("%t ns: %d - %d / result: %d", $time, a_in, b_in, $signed(sum_out));
	      #10 $display("%t ns: %d - %d / result: %d", $time, a_in, b_in, $signed(sum_out));
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
