`timescale 1ns/1ps

module testbench();
		reg clk;
		reg rst_n;
		reg we3;
		reg [4:0] a1,a2,a3;
    reg [31:0] wd3;
    wire [31:0] rd1,rd2;
	
    register_file dut (
      .clk   (clk),
      .rst_n (rst_n),
      .we3 	 	 (we3),
      .a1   	 (a1),
      .a2   	 (a2),
      .a3   	 (a3),
      .wd3   	 (wd3),
      .rd1   	 (rd1),
      .rd2   	 (rd2)
    );

		initial begin
			a1 = 5'h0; 
			a2 = 5'h0; 
			a3 = 5'h0; 
			we3 = 1'h0; 
			wd3 = 31'h0; 
		end

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
				#5
				wait(rst_n == 1'b1);
       	@(posedge clk) a1 = 5'd5; 		a2 = 5'd10; //rd1 = 50			
        @(posedge clk) a1 = 5'd10; 	a2 = 5'd15; //rd2	= 100	 		
        @(posedge clk) a1 = 5'd15; 	a2 = 5'd20; //rd2	= 100	 		

        @(negedge clk) we3 = 1'b0; a3 = 32'd5; 	wd3 = 32'h12345678;			
        @(negedge clk) we3 = 1'b1; a3 = 32'd5; wd3 = 32'h12345678;						
 
        @(negedge clk) we3 = 1'b0; a3 = 32'd10; 	wd3 = 32'hFFFFFFFF;	
        @(negedge clk) we3 = 1'b1; a3 = 32'd10; 	wd3 = 32'hFFFFFFFF;				
                	
    end


    initial
    begin
        #5;
        #10 $display("%t ns: %d %d", $time, a1, a2);
        #10 $display("%t ns: %d %d", $time, a1, a2);
        #10 $display("%t ns: %d %d", $time, a1, a2);
        #10 $display("%t ns: %d %d", $time, a1, a2);
        #10 $display("%t ns: %d %d", $time, a1, a2);
	      #10 $display("%t ns: %d %d", $time, a1, a2);
        #10 $display("%t ns: %d %d", $time, a1, a2);
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
