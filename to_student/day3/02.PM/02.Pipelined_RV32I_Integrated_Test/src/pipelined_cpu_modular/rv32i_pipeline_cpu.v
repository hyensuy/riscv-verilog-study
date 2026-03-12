// CPU wrapper: datapath + external memory interface.
// rv32i_pipeline_cpu: functional wrapper.
// rv32i_cpu: compatibility alias wrapper for existing top/testbench instantiation.
module rv32i_pipeline_cpu #(parameter RESET_PC=32'h1000_0000)(
  input clk,input reset,
  output [31:0] pc,
  input  [31:0] inst,
  output MemWrite,
  output [31:0] MemAddr,
  output [31:0] MemWData,
  output [3:0]  ByteEnable,
  input  [31:0] MemRData
);
  datapath #(.RESET_PC(RESET_PC)) i_datapath(
    .clk(clk),.reset(reset),.instrF(inst),.MemRData(MemRData),
    .pcF(pc),.MemWriteM(MemWrite),.MemAddrM(MemAddr),.MemWDataM(MemWData),.ByteEnableM(ByteEnable),
    .if_id_inst(),.id_ex_rd(),.ex_mem_rd(),.mem_wb_rd(),
    .stallF(),.stallD(),.flushD(),.flushE(),.ForwardAE(),.ForwardBE(),
    .pcD(),.pcE(),.resultW_dbg(),.pcSrcE_act_dbg(),
    .tohost_csr()
  );
endmodule

module rv32i_cpu #(parameter RESET_PC=32'h1000_0000)(
  input clk,input reset,
  output [31:0] pc,
  input  [31:0] inst,
  output MemWrite,
  output [31:0] MemAddr,
  output [31:0] MemWData,
  output [3:0]  ByteEnable,
  input  [31:0] MemRData
);
  rv32i_pipeline_cpu #(.RESET_PC(RESET_PC)) u_cpu(
    .clk(clk),.reset(reset),.pc(pc),.inst(inst),.MemWrite(MemWrite),.MemAddr(MemAddr),.MemWData(MemWData),.ByteEnable(ByteEnable),.MemRData(MemRData)
  );
endmodule
