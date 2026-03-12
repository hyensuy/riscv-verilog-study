// 5-stage RV32I pipelined datapath (IF/ID/EX/MEM/WB connectivity 중심).
// Function priority: preserve existing behavior, expose debug anchors for GTKWave.
module datapath #(parameter RESET_PC=32'h1000_0000)(
  input clk,input reset,input [31:0] instrF,input [31:0] MemRData,
  output [31:0] pcF,output MemWriteM,output [31:0] MemAddrM,output [31:0] MemWDataM,output [3:0] ByteEnableM,
  output [31:0] if_id_inst,output [4:0] id_ex_rd,output [4:0] ex_mem_rd,output [4:0] mem_wb_rd,
  output stallF,output stallD,output flushD,output flushE,output [1:0] ForwardAE,output [1:0] ForwardBE,
  output [31:0] pcD,output [31:0] pcE,
  output [31:0] resultW_dbg,output [1:0] pcSrcE_act_dbg,
  output reg [31:0] tohost_csr
);
  // ---------------- IF ----------------
  reg  [31:0] pcRegF;
  wire [31:0] pcPlus4F,pcNextF;
  wire [31:0] pcTargetE,jalrTargetE;
  wire [1:0]  PCSrcE_act;
  assign pcF = pcRegF;

  next_pc_logic i_nextpc(.pcF(pcRegF),.pcTargetE(pcTargetE),.jalrTargetE(jalrTargetE),.PCSrcE(PCSrcE_act),.pcPlus4F(pcPlus4F),.pcNextF(pcNextF));
  always @(posedge clk or posedge reset) begin
    if (reset) pcRegF <= RESET_PC;
    else if (!stallF) pcRegF <= pcNextF;
  end

  // ---------------- ID ----------------
  wire [31:0] pcPlus4D,instrD;
  wire [4:0] rs1D = instrD[19:15], rs2D = instrD[24:20], rdD = instrD[11:7];
  wire [2:0] funct3D = instrD[14:12];
  wire [31:0] rd1D,rd2D,ImmExtD;
  assign if_id_inst = instrD;

  if_id_reg i_ifid(.clk(clk),.reset(reset),.stallD(stallD),.flushD(flushD),.pcF(pcRegF),.pcPlus4F(pcPlus4F),.instrF(instrF),.pcD(pcD),.pcPlus4D(pcPlus4D),.instrD(instrD));

  wire RegWriteD,MemWriteD,BranchD,ALUSrcBD;
  wire [2:0] ImmSrcD;
  wire [1:0] ALUSrcAD,ResultSrcD,PCSrcD;
  wire [4:0] ALUControlD;

  controller i_controller(
    .opcode(instrD[6:0]),.funct7(instrD[31:25]),.funct3(instrD[14:12]),
    .RegWrite(RegWriteD),.ImmSrc(ImmSrcD),.ALUSrcA(ALUSrcAD),.ALUSrcB(ALUSrcBD),
    .ALUControl(ALUControlD),.MemWrite(MemWriteD),.ResultSrc(ResultSrcD),.Branch(BranchD),.PCSrc(PCSrcD)
  );

  wire RegWriteW;
  wire [4:0] rdW;
  wire [31:0] ResultW;
  reg_file_async rf(.clk(clk),.we(RegWriteW),.ra1(rs1D),.ra2(rs2D),.wa(rdW),.wd(ResultW),.rd1(rd1D),.rd2(rd2D));
  extend i_ext(.instr(instrD),.ImmSrc(ImmSrcD),.ImmExt(ImmExtD));

  // Hazard / flush controls
  wire flushE_hz,flushE_redirect;
  wire [1:0] ResultSrcE;
  wire ResultSrcE_isLoad = (ResultSrcE == 2'b01); // explicit decode for load-use condition

  hazard_detection_unit i_hdu(.rs1D(rs1D),.rs2D(rs2D),.rdE(id_ex_rd),.ResultSrcE_isLoad(ResultSrcE_isLoad),.stallF(stallF),.stallD(stallD),.flushE(flushE_hz));
  flush_control i_fctrl(.PCSrcE(PCSrcE_act),.flushD(flushD),.flushE_redirect(flushE_redirect));
  assign flushE = flushE_hz | flushE_redirect;

  // ---------------- EX ----------------
  wire RegWriteE,MemWriteE,BranchE,ALUSrcBE;
  wire [1:0] ALUSrcAE,PCSrcE;
  wire [4:0] ALUControlE;
  wire [31:0] pcPlus4E,rd1E,rd2E,ImmExtE;
  wire [4:0] rs1E,rs2E,rdE;
  wire [2:0] funct3E;
  wire [31:0] SrcA_fwd,SrcB_fwd,SrcA_E,SrcB_E;
  wire [31:0] ALUResultE;
  wire N,Z,C,V,BtakenE;

  assign id_ex_rd = rdE;
  id_ex_reg i_idex(.clk(clk),.reset(reset),.flushE(flushE),.RegWriteD(RegWriteD),.MemWriteD(MemWriteD),.BranchD(BranchD),.ALUSrcBD(ALUSrcBD),.ALUSrcAD(ALUSrcAD),.ResultSrcD(ResultSrcD),.PCSrcD(PCSrcD),.ALUControlD(ALUControlD),.pcD(pcD),.pcPlus4D(pcPlus4D),.rd1D(rd1D),.rd2D(rd2D),.ImmExtD(ImmExtD),.rs1D(rs1D),.rs2D(rs2D),.rdD(rdD),.funct3D(funct3D),
    .RegWriteE(RegWriteE),.MemWriteE(MemWriteE),.BranchE(BranchE),.ALUSrcBE(ALUSrcBE),.ALUSrcAE(ALUSrcAE),.ResultSrcE(ResultSrcE),.PCSrcE(PCSrcE),.ALUControlE(ALUControlE),.pcE(pcE),.pcPlus4E(pcPlus4E),.rd1E(rd1E),.rd2E(rd2E),.ImmExtE(ImmExtE),.rs1E(rs1E),.rs2E(rs2E),.rdE(rdE),.funct3E(funct3E));

  wire RegWriteM;
  wire [1:0] ResultSrcM;
  wire [31:0] pcPlus4M,ALUResultM,WriteDataM;
  wire [4:0] rdM;
  wire [2:0] funct3M;
  assign ex_mem_rd = rdM;

  forwarding_unit i_fwd(.RegWriteM(RegWriteM),.RegWriteW(RegWriteW),.rs1E(rs1E),.rs2E(rs2E),.rdM(rdM),.rdW(rdW),.ForwardAE(ForwardAE),.ForwardBE(ForwardBE));
  mux3 #(32) muxA(.d0(rd1E),.d1(ResultW),.d2(ALUResultM),.s(ForwardAE),.y(SrcA_fwd));
  mux3 #(32) muxB(.d0(rd2E),.d1(ResultW),.d2(ALUResultM),.s(ForwardBE),.y(SrcB_fwd));
  assign SrcA_E = (ALUSrcAE==2'b01) ? pcE : (ALUSrcAE==2'b10) ? 32'd0 : SrcA_fwd;
  assign SrcB_E = ALUSrcBE ? ImmExtE : SrcB_fwd;

  alu i_alu(.SrcA(SrcA_E),.SrcB(SrcB_E),.ALUControl(ALUControlE),.ALUResult(ALUResultE),.N(N),.Z(Z),.C(C),.V(V));
  branch_logic i_br(.Branch(BranchE),.funct3(funct3E),.N(N),.Z(Z),.C(C),.V(V),.Btaken(BtakenE));

  assign pcTargetE = pcE + ImmExtE;
  assign jalrTargetE = ALUResultE;

  // Redirect conditions explicitly separated for debug readability.
  wire redirectBranchE = BranchE && BtakenE;
  wire redirectJalE    = (PCSrcE==2'b01) && !BranchE;
  wire redirectJalrE   = (PCSrcE==2'b10);
  assign PCSrcE_act = redirectJalrE ? 2'b10 : (redirectBranchE || redirectJalE) ? 2'b01 : 2'b00;

  // ---------------- MEM ----------------
  ex_mem_reg i_exmem(.clk(clk),.reset(reset),.RegWriteE(RegWriteE),.MemWriteE(MemWriteE),.ResultSrcE(ResultSrcE),.pcPlus4E(pcPlus4E),.ALUResultE(ALUResultE),.WriteDataE(SrcB_fwd),.rdE(rdE),.funct3E(funct3E),
    .RegWriteM(RegWriteM),.MemWriteM(MemWriteM),.ResultSrcM(ResultSrcM),.pcPlus4M(pcPlus4M),.ALUResultM(ALUResultM),.WriteDataM(WriteDataM),.rdM(rdM),.funct3M(funct3M));

  wire [31:0] BE_WD_M,BE_RD_M;
  BE_logic i_be(.funct3(funct3M),.Addr_Last2(ALUResultM[1:0]),.WD(WriteDataM),.RD(MemRData),.BE_WD(BE_WD_M),.BE_RD(BE_RD_M),.Byte_Enable(ByteEnableM));
  assign MemAddrM = ALUResultM;
  assign MemWDataM = BE_WD_M;

  // ---------------- WB ----------------
  wire [1:0] ResultSrcW;
  wire [31:0] pcPlus4W,ALUResultW,ReadDataW;
  assign mem_wb_rd = rdW;

  mem_wb_reg i_memwb(.clk(clk),.reset(reset),.RegWriteM(RegWriteM),.ResultSrcM(ResultSrcM),.pcPlus4M(pcPlus4M),.ALUResultM(ALUResultM),.ReadDataM(BE_RD_M),.rdM(rdM),
    .RegWriteW(RegWriteW),.ResultSrcW(ResultSrcW),.pcPlus4W(pcPlus4W),.ALUResultW(ALUResultW),.ReadDataW(ReadDataW),.rdW(rdW));
  register_write_data_logic i_wbsel(.ResultSrc(ResultSrcW),.ALUResult(ALUResultW),.BE_RD(ReadDataW),.PCPlus4(pcPlus4W),.WD(ResultW));

  // Debug anchors
  assign resultW_dbg = ResultW;
  assign pcSrcE_act_dbg = PCSrcE_act;

  always @(posedge clk or posedge reset) begin
    if (reset) tohost_csr <= 32'd0;
    else if (RegWriteW && rdW==5'd31) tohost_csr <= ResultW;
  end
endmodule
