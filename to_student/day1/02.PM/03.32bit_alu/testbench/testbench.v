`timescale 1ns/1ps

module testbench();
		reg  [2:0]  ALUControl;
    reg  [31:0] a_in;
    reg  [31:0] b_in;
    wire [31:0] result;

    alu_32bit dut (
			.ALUControl(ALUControl),
      .a(a_in),
      .b(b_in),
			.result(result),
			.N(N),
			.Z(Z),
			.C(C),
			.V(V)	
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
        		ALUControl = 3'b000; a_in = 32'd2; 	b_in = 32'd5; 				//add : 7
        #10 ALUControl = 3'b001; a_in = 32'd2; 	b_in = 32'd5; 				//sub : -3	//N
        #10 ALUControl = 3'b010; a_in = 32'd2; 	b_in = 32'd5;		 	  	//and : 0000 	//0010, 0101 
        #10 ALUControl = 3'b011; a_in = 32'd2;  b_in = 32'd5; 				//or  : 0111
        #10 ALUControl = 3'b101; a_in = 32'd2;	b_in = 32'd5; 				//SLT : 1

        #10 ALUControl = 3'b000; a_in = 32'd3;  b_in = 32'hFFFFFFFE; 					//add : 3 + (-2) = 1	//C=1	
        #10 ALUControl = 3'b000; a_in = 32'h7FFFFFFF;  b_in = 32'h7FFFFFFF; 	//add : (+) + (+) = (-) //V=1

        #10 ALUControl = 3'b001; a_in = 32'd3; 	b_in = 32'd3; 				//sub :	3 - (3) = 0		//Z=1, C=1
        #10 ALUControl = 3'b010; a_in = 32'd3; 	b_in = 32'hFFFFFFFB;	//and	: 0011(32'd3)		//0011, 1011  
        #10 ALUControl = 3'b011; a_in = 32'd3; 	b_in = 32'hFFFFFFFE; 	//or	: 1111(32'd-1)	//N=1
        #10 ALUControl = 3'b101; a_in = 32'd3; 	b_in = 32'hFFFFFFFE; 	//SLT	: 0  	   end
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
