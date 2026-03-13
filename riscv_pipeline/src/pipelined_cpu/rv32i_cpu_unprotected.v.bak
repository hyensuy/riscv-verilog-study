`timescale 1ns/1ns

module rv32i_cpu (
    input         clk,
    input         reset,
    output [31:0] pc,
    input  [31:0] inst,
    output        MemWrite,
    output [31:0] MemAddr,
    output [31:0] MemWData,
    output [3:0]  ByteEnable,
    input  [31:0] MemRData
);
  parameter RESET_PC = 32'h1000_0000;

  pipelined_datapath #(
      .RESET_PC(RESET_PC)
  ) i_datapath (
      .clk(clk),
      .reset(reset),
      .if_pc(pc),
      .if_inst(inst),
      .mem_write(MemWrite),
      .mem_addr(MemAddr),
      .mem_wdata(MemWData),
      .mem_byte_en(ByteEnable),
      .mem_rdata(MemRData)
  );
endmodule

module pipelined_datapath (
    input         clk,
    input         reset,
    output [31:0] if_pc,
    input  [31:0] if_inst,
    output        mem_write,
    output [31:0] mem_addr,
    output [31:0] mem_wdata,
    output [3:0]  mem_byte_en,
    input  [31:0] mem_rdata
);
  parameter RESET_PC = 32'h1000_0000;

  localparam OPC_LUI    = 7'b0110111;
  localparam OPC_AUIPC  = 7'b0010111;
  localparam OPC_JAL    = 7'b1101111;
  localparam OPC_JALR   = 7'b1100111;
  localparam OPC_BRANCH = 7'b1100011;
  localparam OPC_LOAD   = 7'b0000011;
  localparam OPC_STORE  = 7'b0100011;
  localparam OPC_OPIMM  = 7'b0010011;
  localparam OPC_OP     = 7'b0110011;

  reg [31:0] pc_reg;
  assign if_pc = pc_reg;

  wire [31:0] pc_plus4 = pc_reg + 32'd4;

  reg [31:0] if_id_pc, if_id_inst;

  reg [31:0] id_ex_pc, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
  reg [4:0]  id_ex_rs1, id_ex_rs2, id_ex_rd;
  reg [2:0]  id_ex_funct3;
  reg [6:0]  id_ex_opcode, id_ex_funct7;
  reg        id_ex_regwrite, id_ex_memread, id_ex_memwrite, id_ex_branch, id_ex_jal, id_ex_jalr;
  reg [1:0]  id_ex_wb_sel;
  reg        id_ex_alu_src_imm, id_ex_alu_src_pc;
  reg [3:0]  id_ex_alu_ctrl;

  reg [31:0] ex_mem_pc4, ex_mem_alu_result, ex_mem_rs2_forward;
  reg [4:0]  ex_mem_rd;
  reg [2:0]  ex_mem_funct3;
  reg        ex_mem_regwrite, ex_mem_memread, ex_mem_memwrite;
  reg [1:0]  ex_mem_wb_sel;

  reg [31:0] mem_wb_pc4, mem_wb_alu_result, mem_wb_mem_data;
  reg [4:0]  mem_wb_rd;
  reg        mem_wb_regwrite;
  reg [1:0]  mem_wb_wb_sel;

  wire [6:0] id_opcode = if_id_inst[6:0];
  wire [2:0] id_funct3 = if_id_inst[14:12];
  wire [6:0] id_funct7 = if_id_inst[31:25];
  wire [4:0] id_rs1 = if_id_inst[19:15];
  wire [4:0] id_rs2 = if_id_inst[24:20];
  wire [4:0] id_rd  = if_id_inst[11:7];

  wire [31:0] rf_rd1, rf_rd2;
  wire [31:0] wb_data;

  reg_file_async rf (
      .clk(clk),
      .clkb(clk),
      .we(mem_wb_regwrite),
      .ra1(id_rs1),
      .ra2(id_rs2),
      .wa(mem_wb_rd),
      .wd(wb_data),
      .rd1(rf_rd1),
      .rd2(rf_rd2)
  );

  wire [31:0] id_imm;
  imm_gen imm_gen_u (
      .instr(if_id_inst),
      .imm(id_imm)
  );

  reg        dec_regwrite, dec_memread, dec_memwrite, dec_branch, dec_jal, dec_jalr;
  reg [1:0]  dec_wb_sel;
  reg        dec_alu_src_imm, dec_alu_src_pc;
  reg [3:0]  dec_alu_ctrl;

  always @(*) begin
    dec_regwrite = 1'b0; dec_memread = 1'b0; dec_memwrite = 1'b0;
    dec_branch = 1'b0; dec_jal = 1'b0; dec_jalr = 1'b0;
    dec_wb_sel = 2'b00; dec_alu_src_imm = 1'b0; dec_alu_src_pc = 1'b0;
    dec_alu_ctrl = 4'b0000;
    case (id_opcode)
      OPC_OP: begin
        dec_regwrite = 1'b1;
        case ({id_funct7[5], id_funct3})
          4'b0_000: dec_alu_ctrl = 4'b0000;
          4'b1_000: dec_alu_ctrl = 4'b0001;
          4'b0_001: dec_alu_ctrl = 4'b0010;
          4'b0_010: dec_alu_ctrl = 4'b0011;
          4'b0_011: dec_alu_ctrl = 4'b0100;
          4'b0_100: dec_alu_ctrl = 4'b0101;
          4'b0_101: dec_alu_ctrl = 4'b0110;
          4'b1_101: dec_alu_ctrl = 4'b0111;
          4'b0_110: dec_alu_ctrl = 4'b1000;
          4'b0_111: dec_alu_ctrl = 4'b1001;
          default:  dec_alu_ctrl = 4'b0000;
        endcase
      end
      OPC_OPIMM: begin
        dec_regwrite = 1'b1;
        dec_alu_src_imm = 1'b1;
        case (id_funct3)
          3'b000: dec_alu_ctrl = 4'b0000;
          3'b010: dec_alu_ctrl = 4'b0011;
          3'b011: dec_alu_ctrl = 4'b0100;
          3'b100: dec_alu_ctrl = 4'b0101;
          3'b110: dec_alu_ctrl = 4'b1000;
          3'b111: dec_alu_ctrl = 4'b1001;
          3'b001: dec_alu_ctrl = 4'b0010;
          3'b101: dec_alu_ctrl = id_funct7[5] ? 4'b0111 : 4'b0110;
          default: dec_alu_ctrl = 4'b0000;
        endcase
      end
      OPC_LOAD: begin
        dec_regwrite = 1'b1; dec_memread = 1'b1; dec_wb_sel = 2'b01;
        dec_alu_src_imm = 1'b1; dec_alu_ctrl = 4'b0000;
      end
      OPC_STORE: begin
        dec_memwrite = 1'b1; dec_alu_src_imm = 1'b1; dec_alu_ctrl = 4'b0000;
      end
      OPC_BRANCH: begin
        dec_branch = 1'b1; dec_alu_ctrl = 4'b0001;
      end
      OPC_JAL: begin
        dec_regwrite = 1'b1; dec_jal = 1'b1; dec_wb_sel = 2'b10;
      end
      OPC_JALR: begin
        dec_regwrite = 1'b1; dec_jalr = 1'b1; dec_wb_sel = 2'b10;
        dec_alu_src_imm = 1'b1; dec_alu_ctrl = 4'b0000;
      end
      OPC_LUI: begin
        dec_regwrite = 1'b1; dec_alu_src_imm = 1'b1; dec_alu_ctrl = 4'b1010;
      end
      OPC_AUIPC: begin
        dec_regwrite = 1'b1; dec_alu_src_imm = 1'b1; dec_alu_src_pc = 1'b1; dec_alu_ctrl = 4'b0000;
      end
      default: begin end
    endcase
  end

  wire load_use_hazard = id_ex_memread && (id_ex_rd != 5'd0) &&
                         ((id_ex_rd == id_rs1) || (id_ex_rd == id_rs2));
  wire stall = load_use_hazard;

  reg [1:0] fwd_a_sel, fwd_b_sel;
  always @(*) begin
    fwd_a_sel = 2'b00;
    if (ex_mem_regwrite && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1)) fwd_a_sel = 2'b10;
    else if (mem_wb_regwrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1)) fwd_a_sel = 2'b01;

    fwd_b_sel = 2'b00;
    if (ex_mem_regwrite && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2)) fwd_b_sel = 2'b10;
    else if (mem_wb_regwrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2)) fwd_b_sel = 2'b01;
  end

  wire [31:0] ex_fwd_from_mem = (ex_mem_wb_sel == 2'b10) ? ex_mem_pc4 : ex_mem_alu_result;
  wire [31:0] ex_fwd_from_wb  = wb_data;
  wire [31:0] ex_rs1_val = (fwd_a_sel == 2'b10) ? ex_fwd_from_mem :
                           ((fwd_a_sel == 2'b01) ? ex_fwd_from_wb : id_ex_rs1_data);
  wire [31:0] ex_rs2_val = (fwd_b_sel == 2'b10) ? ex_fwd_from_mem :
                           ((fwd_b_sel == 2'b01) ? ex_fwd_from_wb : id_ex_rs2_data);

  wire [31:0] ex_alu_a = id_ex_alu_src_pc ? id_ex_pc : ex_rs1_val;
  wire [31:0] ex_alu_b = id_ex_alu_src_imm ? id_ex_imm : ex_rs2_val;

  wire [31:0] ex_alu_result;
  alu_u alu_inst (
      .a(ex_alu_a),
      .b(ex_alu_b),
      .alu_ctrl(id_ex_alu_ctrl),
      .result(ex_alu_result)
  );

  wire ex_branch_taken = id_ex_branch && branch_taken(id_ex_funct3, ex_rs1_val, ex_rs2_val);
  wire [31:0] ex_branch_target = id_ex_pc + id_ex_imm;
  wire [31:0] ex_jal_target = id_ex_pc + id_ex_imm;
  wire [31:0] ex_jalr_target = (ex_rs1_val + id_ex_imm) & 32'hffff_fffe;
  wire [31:0] ex_seq_target = id_ex_pc + 32'd4;

  wire ex_branch_redirect = ex_branch_taken && (ex_branch_target != ex_seq_target);
  wire ex_jal_redirect    = id_ex_jal  && (ex_jal_target  != ex_seq_target);
  wire ex_jalr_redirect   = id_ex_jalr && (ex_jalr_target != ex_seq_target);

  wire ex_redirect = ex_branch_redirect | ex_jal_redirect | ex_jalr_redirect;
  wire [31:0] ex_redirect_pc = ex_jalr_redirect ? ex_jalr_target :
                               ((ex_jal_redirect | ex_branch_redirect) ? ex_jal_target : pc_plus4);

  wire [3:0] ex_store_byte_en;
  wire [31:0] ex_store_data;
  store_data_align store_align_u (
      .funct3(ex_mem_funct3),
      .addr_lsb(ex_mem_alu_result[1:0]),
      .rs2_data(ex_mem_rs2_forward),
      .byte_en(ex_store_byte_en),
      .store_data(ex_store_data)
  );

  wire [31:0] mem_load_data;
  load_data_align load_align_u (
      .funct3(ex_mem_funct3),
      .addr_lsb(ex_mem_alu_result[1:0]),
      .raw_data(mem_rdata),
      .load_data(mem_load_data)
  );

  assign mem_addr = ex_mem_alu_result;
  assign mem_wdata = ex_store_data;
  assign mem_byte_en = ex_store_byte_en;
  assign mem_write = ex_mem_memwrite;

  assign wb_data = (mem_wb_wb_sel == 2'b00) ? mem_wb_alu_result :
                   (mem_wb_wb_sel == 2'b01) ? mem_wb_mem_data :
                   (mem_wb_wb_sel == 2'b10) ? mem_wb_pc4 : 32'd0;

  always @(posedge clk) begin
    if (reset) begin
      pc_reg <= RESET_PC;
      if_id_pc <= 32'd0; if_id_inst <= 32'd0;
      id_ex_pc <= 32'd0; id_ex_rs1_data <= 32'd0; id_ex_rs2_data <= 32'd0; id_ex_imm <= 32'd0;
      id_ex_rs1 <= 5'd0; id_ex_rs2 <= 5'd0; id_ex_rd <= 5'd0;
      id_ex_funct3 <= 3'd0; id_ex_opcode <= 7'd0; id_ex_funct7 <= 7'd0;
      id_ex_regwrite <= 1'b0; id_ex_memread <= 1'b0; id_ex_memwrite <= 1'b0; id_ex_branch <= 1'b0; id_ex_jal <= 1'b0; id_ex_jalr <= 1'b0;
      id_ex_wb_sel <= 2'b00; id_ex_alu_src_imm <= 1'b0; id_ex_alu_src_pc <= 1'b0; id_ex_alu_ctrl <= 4'b0;
      ex_mem_pc4 <= 32'd0; ex_mem_alu_result <= 32'd0; ex_mem_rs2_forward <= 32'd0; ex_mem_rd <= 5'd0; ex_mem_funct3 <= 3'd0;
      ex_mem_regwrite <= 1'b0; ex_mem_memread <= 1'b0; ex_mem_memwrite <= 1'b0; ex_mem_wb_sel <= 2'b00;
      mem_wb_pc4 <= 32'd0; mem_wb_alu_result <= 32'd0; mem_wb_mem_data <= 32'd0; mem_wb_rd <= 5'd0; mem_wb_regwrite <= 1'b0; mem_wb_wb_sel <= 2'b00;
    end else begin
      pc_reg <= stall ? pc_reg : (ex_redirect ? ex_redirect_pc : pc_plus4);

      if (!stall) begin
        if_id_pc <= pc_reg;
        if_id_inst <= ex_redirect ? 32'h00000013 : if_inst;
      end

      if (stall || ex_redirect) begin
        id_ex_pc <= 32'd0; id_ex_rs1_data <= 32'd0; id_ex_rs2_data <= 32'd0; id_ex_imm <= 32'd0;
        id_ex_rs1 <= 5'd0; id_ex_rs2 <= 5'd0; id_ex_rd <= 5'd0; id_ex_funct3 <= 3'd0; id_ex_opcode <= 7'd0; id_ex_funct7 <= 7'd0;
        id_ex_regwrite <= 1'b0; id_ex_memread <= 1'b0; id_ex_memwrite <= 1'b0; id_ex_branch <= 1'b0; id_ex_jal <= 1'b0; id_ex_jalr <= 1'b0;
        id_ex_wb_sel <= 2'b00; id_ex_alu_src_imm <= 1'b0; id_ex_alu_src_pc <= 1'b0; id_ex_alu_ctrl <= 4'b0;
      end else begin
        id_ex_pc <= if_id_pc;
        id_ex_rs1_data <= rf_rd1;
        id_ex_rs2_data <= rf_rd2;
        id_ex_imm <= id_imm;
        id_ex_rs1 <= id_rs1;
        id_ex_rs2 <= id_rs2;
        id_ex_rd <= id_rd;
        id_ex_funct3 <= id_funct3;
        id_ex_opcode <= id_opcode;
        id_ex_funct7 <= id_funct7;
        id_ex_regwrite <= dec_regwrite;
        id_ex_memread <= dec_memread;
        id_ex_memwrite <= dec_memwrite;
        id_ex_branch <= dec_branch;
        id_ex_jal <= dec_jal;
        id_ex_jalr <= dec_jalr;
        id_ex_wb_sel <= dec_wb_sel;
        id_ex_alu_src_imm <= dec_alu_src_imm;
        id_ex_alu_src_pc <= dec_alu_src_pc;
        id_ex_alu_ctrl <= dec_alu_ctrl;
      end

      ex_mem_pc4 <= id_ex_pc + 32'd4;
      ex_mem_alu_result <= ex_alu_result;
      ex_mem_rs2_forward <= ex_rs2_val;
      ex_mem_rd <= id_ex_rd;
      ex_mem_funct3 <= id_ex_funct3;
      ex_mem_regwrite <= id_ex_regwrite;
      ex_mem_memread <= id_ex_memread;
      ex_mem_memwrite <= id_ex_memwrite;
      ex_mem_wb_sel <= id_ex_wb_sel;

      mem_wb_pc4 <= ex_mem_pc4;
      mem_wb_alu_result <= ex_mem_alu_result;
      mem_wb_mem_data <= mem_load_data;
      mem_wb_rd <= ex_mem_rd;
      mem_wb_regwrite <= ex_mem_regwrite;
      mem_wb_wb_sel <= ex_mem_wb_sel;
    end
  end

  function branch_taken;
    input [2:0] funct3;
    input [31:0] lhs;
    input [31:0] rhs;
    begin
      case (funct3)
        3'b000: branch_taken = (lhs == rhs);
        3'b001: branch_taken = (lhs != rhs);
        3'b100: branch_taken = ($signed(lhs) < $signed(rhs));
        3'b101: branch_taken = ($signed(lhs) >= $signed(rhs));
        3'b110: branch_taken = (lhs < rhs);
        3'b111: branch_taken = (lhs >= rhs);
        default: branch_taken = 1'b0;
      endcase
    end
  endfunction
endmodule

module reg_file_async (
  input clk,
  input clkb,
  input we,
  input [4:0] ra1, ra2, wa,
  input [31:0] wd,
  output [31:0] rd1, rd2
);
  parameter DEPTH = 32;
  reg [31:0] mem [0:31];

  assign rd1 = (ra1 == 5'd0) ? 32'd0 : mem[ra1];
  assign rd2 = (ra2 == 5'd0) ? 32'd0 : mem[ra2];

  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1) mem[i] = 32'd0;
  end

  always @(posedge clkb) begin
    if (we && (wa != 5'd0)) mem[wa] <= wd;
    mem[0] <= 32'd0;
  end
endmodule

module imm_gen (
    input [31:0] instr,
    output reg [31:0] imm
);
  wire [6:0] opcode = instr[6:0];
  always @(*) begin
    case (opcode)
      7'b0010011, 7'b0000011, 7'b1100111: imm = {{20{instr[31]}}, instr[31:20]};
      7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
      7'b0110111, 7'b0010111: imm = {instr[31:12], 12'd0};
      7'b1101111: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
      default: imm = 32'd0;
    endcase
  end
endmodule

module alu_u (
    input [31:0] a,
    input [31:0] b,
    input [3:0]  alu_ctrl,
    output reg [31:0] result
);
  always @(*) begin
    case (alu_ctrl)
      4'b0000: result = a + b;
      4'b0001: result = a - b;
      4'b0010: result = a << b[4:0];
      4'b0011: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
      4'b0100: result = (a < b) ? 32'd1 : 32'd0;
      4'b0101: result = a ^ b;
      4'b0110: result = a >> b[4:0];
      4'b0111: result = $signed(a) >>> b[4:0];
      4'b1000: result = a | b;
      4'b1001: result = a & b;
      4'b1010: result = b;
      default: result = 32'd0;
    endcase
  end
endmodule

module store_data_align (
    input [2:0]  funct3,
    input [1:0]  addr_lsb,
    input [31:0] rs2_data,
    output reg [3:0] byte_en,
    output reg [31:0] store_data
);
  always @(*) begin
    byte_en = 4'b0000;
    store_data = 32'd0;
    case (funct3)
      3'b000: begin
        case (addr_lsb)
          2'b00: begin byte_en = 4'b0001; store_data = {24'd0, rs2_data[7:0]}; end
          2'b01: begin byte_en = 4'b0010; store_data = {16'd0, rs2_data[7:0], 8'd0}; end
          2'b10: begin byte_en = 4'b0100; store_data = {8'd0, rs2_data[7:0], 16'd0}; end
          2'b11: begin byte_en = 4'b1000; store_data = {rs2_data[7:0], 24'd0}; end
        endcase
      end
      3'b001: begin
        case (addr_lsb[1])
          1'b0: begin byte_en = 4'b0011; store_data = {16'd0, rs2_data[15:0]}; end
          1'b1: begin byte_en = 4'b1100; store_data = {rs2_data[15:0], 16'd0}; end
        endcase
      end
      3'b010: begin byte_en = 4'b1111; store_data = rs2_data; end
      default: begin byte_en = 4'b0000; store_data = 32'd0; end
    endcase
  end
endmodule

module load_data_align (
    input [2:0]  funct3,
    input [1:0]  addr_lsb,
    input [31:0] raw_data,
    output reg [31:0] load_data
);
  reg [7:0] sel_b;
  reg [15:0] sel_h;
  always @(*) begin
    case (addr_lsb)
      2'b00: sel_b = raw_data[7:0];
      2'b01: sel_b = raw_data[15:8];
      2'b10: sel_b = raw_data[23:16];
      default: sel_b = raw_data[31:24];
    endcase

    sel_h = addr_lsb[1] ? raw_data[31:16] : raw_data[15:0];

    case (funct3)
      3'b000: load_data = {{24{sel_b[7]}}, sel_b};
      3'b001: load_data = {{16{sel_h[15]}}, sel_h};
      3'b010: load_data = raw_data;
      3'b100: load_data = {24'd0, sel_b};
      3'b101: load_data = {16'd0, sel_h};
      default: load_data = 32'd0;
    endcase
  end
endmodule
