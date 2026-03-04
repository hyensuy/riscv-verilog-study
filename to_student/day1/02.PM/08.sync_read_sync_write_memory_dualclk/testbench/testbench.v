`timescale 1ns/1ns
`include "mem_path.vh"

module testbench();
		parameter DWIDTH = 32;
		parameter AWIDTH = 12;
		localparam TIMEOUT_CYCLE = 100_000;

		reg clk_read;
		reg clk_write;

		reg [11:0] fetch_addr;
		reg [11:0] data_addr;

		reg [3:0]  byte_enable;
		reg [31:0] write_data;
		reg data_we;
		wire [31:0] imem_inst;
		wire [31:0] read_imem_data_mem;

    dualport_mem_synch_rw_dualclk #(
      .DATA_WIDTH (DWIDTH),
      .ADDRESS_WIDTH (AWIDTH),
      .MIF_HEX ("")
  	) mem (
    	.clk1      (clk_read),
    	.clk2      (clk_write),
    	.addr1    (fetch_addr),
    	.addr2    (data_addr),
    	.be1      (4'd0),
    	.be2      (byte_enable),
    	.data_in1 (32'd0),
    	.data_in2 (write_data),
    	.we1      (1'b0),
    	.we2    	(data_we),
    	.data_out1(imem_inst),
    	.data_out2(read_imem_data_mem)
  	);

    initial begin
      #1;
			$readmemh("code.hex", `MEM_PATH.mem, 0, 16384-1);
		end

		initial begin
			clk_read = 0;
			clk_write = 0;
		end

    always #(7)  clk_read = ~clk_read;

    always #(12) clk_write = ~clk_write;

    initial
    begin
				//IM
        fetch_addr = 12'd0; 					
				//DM
				data_addr = 12'd0; 					

				write_data = 32'd0; 					
				byte_enable = 4'd0; 					
				data_we = 1'd0; 					
    end

    initial
    begin
				//IM
        @(negedge clk_read) fetch_addr = 12'd5; 					
        @(negedge clk_read) fetch_addr = 12'd10; 			 		
        @(negedge clk_read) fetch_addr = 12'd20; 			 		
        @(negedge clk_read) fetch_addr = 12'd30; 			 		
				//DM
				@(negedge clk_write) data_addr = 12'd40; byte_enable = 4'b1111; write_data = 32'hFFFFFFFF; data_we = 1'b0;
				@(negedge clk_write) data_addr = 12'd40; byte_enable = 4'b1111; write_data = 32'hFFFFFFFF; data_we = 1'b1;
				@(negedge clk_write) data_addr = 12'd40; byte_enable = 4'b1111; write_data = 32'hFFFFFFFF; data_we = 1'b1;

				@(negedge clk_write) data_addr = 12'd20; byte_enable = 4'b0111; write_data = 32'hFFFFFFFF; data_we = 1'b0;
				@(negedge clk_write) data_addr = 12'd20; byte_enable = 4'b0111; write_data = 32'hFFFFFFFF; data_we = 1'b1;
				@(negedge clk_write) data_addr = 12'd20; byte_enable = 4'b0111; write_data = 32'hFFFFFFFF; data_we = 1'b1;
    end


    initial
    begin
        #5 $display("////test start////");
				#250
       $finish;
    end

		initial begin
    	repeat (TIMEOUT_CYCLE) @(posedge clk_read);
    	$display("Timeout!");
    	$finish();
  	end


	`ifdef FSDB
  	initial
    begin
      $fsdbDumpfile("wave.fsdb");
      $fsdbDumpvars(0);
    end
	`endif

endmodule
