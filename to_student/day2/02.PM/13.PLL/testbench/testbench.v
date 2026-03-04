`timescale 1ns/1ps

module testbench();
		reg clk;
		wire clk0;
		wire clk90;
		wire clk180;
		wire clk270;
		wire locked;
	
    alt_pll pll0 (
      .inclk0 (clk),
      .c0 	 	(clk0),
      .c1 	 	(clk90),
      .c2 	 	(clk180),
      .c3 	 	(clk270),
			.locked (locked)
    );

    initial
    begin
      clk <= 1'b0;
      forever begin
        #10 clk <= ~clk;
      end
    end

    initial
    begin
       	#10000
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
