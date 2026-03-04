`timescale 1ns/1ps

module testbench();
		reg clk;
		reg rst_n;
    reg [31:0] a_in;
    wire [31:0] b_out;
	
    register_32bit dut (
      .clk   (clk),
      .rst_n (rst_n),
      .d 	 	 (a_in),
      .q   	 (b_out)
    );

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

    initial
    begin
				wait(rst_n ==1'b1);
				#1
        @(negedge clk)  a_in = 32'd1; 					
        @(negedge clk)  a_in = 32'd2; 			 		
        @(negedge clk)	a_in = 32'd5; 					
        @(negedge clk)	a_in = 32'd25; 					
        @(negedge clk)	a_in = 32'd100; 		 		
        @(negedge clk)	a_in = 32'd15520; 	 		
        @(negedge clk)	a_in = 32'd60000; 	 		
       // #10 a_in = 32'hFFFFFFFF;	 	
    end
/*

    initial
    begin
				wait(rst_n ==1'b1);
        @(negedge clk)		a_in = 32'd1; 					
        #10 a_in = 32'd2; 			 		
        #10 a_in = 32'd5; 					
        #10 a_in = 32'd25; 					
        #10 a_in = 32'd100; 		 		
        #10 a_in = 32'd15520; 	 		
        #10 a_in = 32'd60000; 	 		
       // #10 a_in = 32'hFFFFFFFF;	 	
    end
*/

    initial
    begin
        #5;
        #10 $display("%t ns: %d", $time, a_in, b_out);
        #10 $display("%t ns: %d", $time, a_in, b_out);
        #10 $display("%t ns: %d", $time, a_in, b_out);
        #10 $display("%t ns: %d", $time, a_in, b_out);
	      #10 $display("%t ns: %d", $time, a_in, b_out);
        #10 $display("%t ns: %d", $time, a_in, b_out);
        #10
        #10
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
