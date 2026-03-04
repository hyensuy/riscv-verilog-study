`timescale 1ns/1ns
`include "mem_path.vh"

module testbench();
		parameter DWIDTH = 32;
		parameter AWIDTH = 12;
		localparam TIMEOUT_CYCLE = 100_000;

		reg clk;
		reg [11:0] fetch_addr;
		reg [11:0] data_addr;

		reg [3:0]  byte_enable;
		reg [31:0] write_data;
		reg data_we;
		wire [31:0] imem_inst;
		wire [31:0] read_imem_data_mem;

    ASYNC_RAM_DP_WBE #(
      .DWIDTH (DWIDTH),
      .AWIDTH (AWIDTH),
      .MIF_HEX ("")
  	) mem (
    	.clk      (clk),
    	.addr0    (fetch_addr),
    	.addr1    (data_addr),
    	.wbe0     (4'd0),
    	.wbe1     (byte_enable),
    	.d0       (32'd0),
    	.d1       (write_data),
    	.wen0     (1'b0),
    	.wen1     (data_we),
    	.q0       (imem_inst),
    	.q1       (read_imem_data_mem)
  	);

    initial begin
      #1;
			$readmemh("code.hex", `MEM_PATH.mem, 0, 16384-1);
		end

		initial clk = 0;
		always #(10) clk = ~clk;
			reg [255:0] MIF_FILE;

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
        @(negedge clk) fetch_addr = 12'd5; 					
        @(negedge clk) fetch_addr = 12'd10; 			 		
        @(negedge clk) fetch_addr = 12'd20; 			 		
        @(negedge clk) fetch_addr = 12'd30; 			 		
				//DM
				@(negedge clk) data_addr = 12'd40; byte_enable = 4'b1111; write_data = 32'hFFFFFFFF; data_we = 1'b0;
				@(negedge clk) data_addr = 12'd40; byte_enable = 4'b1111; write_data = 32'hFFFFFFFF; data_we = 1'b1;

			  @(negedge clk)  data_addr = 12'd20; byte_enable = 4'b0111; write_data = 32'hFFFFFFFF; data_we = 1'b0;
			  @(negedge clk)  data_addr = 12'd20; byte_enable = 4'b0111; write_data = 32'hFFFFFFFF; data_we = 1'b1;

        repeat (2) begin
          @(negedge clk);
        end

        $finish;
    end

		initial begin
    	repeat (TIMEOUT_CYCLE) @(posedge clk);
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
