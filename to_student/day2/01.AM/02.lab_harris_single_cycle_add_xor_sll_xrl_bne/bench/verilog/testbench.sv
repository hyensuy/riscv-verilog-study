module testbench();
  logic clk;
  logic reset;
  logic [31:0] WriteData, DataAdr;
  logic MemWrite;

  // instantiate device to be tested
  top dut(clk, reset, WriteData, DataAdr, MemWrite);

  // initialize test
  initial
  begin
    reset <= 1;
    #22;
    reset <= 0;
  end

  // generate clock to sequence tests
  always
  begin
    #5 clk <= 1;
    #5 clk <= 0;
  end

  // check results
  always @(negedge clk)
  begin
    if(MemWrite) begin
      //if(DataAdr === 100 & WriteData === 25) begin
      if(DataAdr === 216 & WriteData === 4140) begin
        $display("Simulation succeeded !!!!!!!!!");
        $finish;
      end
    end
  end

`ifdef SIM
  initial
  begin
    #100_000;
    $display("Simulation failed !!!!!!!!!!!");
    $finish;
  end

  initial
    begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0);
  end

`endif

endmodule
