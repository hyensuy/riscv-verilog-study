`timescale 1ns/1ns

module rv32i_soc #(
    parameter RESET_PC = 32'h1000_0000,
    parameter DWIDTH   = 32,
    parameter AWIDTH   = 12,
    parameter MIF_HEX  = ""
)(
    input  wire        clk,
    input  wire        reset,

    input  wire [9:0]  sw,
    output wire [9:0]  ledr,
    output wire [15:0] hex_value
);

    localparam MEM_BASE      = 32'h1000_0000;
    localparam MEM_END       = MEM_BASE + ((1 << AWIDTH) * 4) - 1;
    localparam MMIO_LED_ADDR = 32'h2000_0000;
    localparam MMIO_SW_ADDR  = 32'h2000_0004;
    localparam MMIO_HEX_ADDR = 32'h2000_0008;

    wire [31:0] pc;
    wire [31:0] inst;
    wire        mem_write;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  byte_enable;
    reg  [31:0] mem_rdata;

    wire [31:0] bram_q0;
    wire [31:0] bram_q1;
    wire [31:0] mmio_rdata;

    wire mem_sel;
    wire mmio_sel;
    wire mmio_we;

    assign mem_sel  = (mem_addr >= MEM_BASE) && (mem_addr <= MEM_END);
    assign mmio_sel = (mem_addr == MMIO_LED_ADDR) ||
                      (mem_addr == MMIO_SW_ADDR)  ||
                      (mem_addr == MMIO_HEX_ADDR);

    assign mmio_we = mem_write && mmio_sel;

    rv32i_cpu #(
        .RESET_PC(RESET_PC)
    ) u_cpu (
        .clk        (clk),
        .reset      (reset),
        .pc         (pc),
        .inst       (inst),
        .MemWrite   (mem_write),
        .MemAddr    (mem_addr),
        .MemWData   (mem_wdata),
        .ByteEnable (byte_enable),
        .MemRData   (mem_rdata)
    );

    SYNC_RAM_DP_WBE #(
        .DWIDTH  (DWIDTH),
        .AWIDTH  (AWIDTH),
        .MIF_HEX (MIF_HEX)
    ) u_bram (
        .clk0  (clk),
        .addr0 (pc[AWIDTH+2-1:2]),
        .en0   (1'b1),
        .wbe0  (4'b0000),
        .d0    (32'd0),
                .q0    (bram_q0),
        .clk1  (clk),
        .addr1 (mem_addr[AWIDTH+2-1:2]),
        .en1   (mem_sel | mem_write),
        .wbe1  (mem_sel ? byte_enable : 4'b0000),
        .d1    (mem_wdata),
                .q1    (bram_q1)
    );

    rv32i_mmio u_mmio (
        .clk         (clk),
        .reset       (reset),
        .we          (mmio_we),
        .addr        (mem_addr),
        .wdata       (mem_wdata),
        .byte_enable (byte_enable),
        .sw          (sw),
        .ledr        (ledr),
        .hex_value   (hex_value),
        .rdata       (mmio_rdata)
    );

    assign inst = bram_q0;

    always @(*) begin
        if (mem_sel)
            mem_rdata = bram_q1;
        else if (mmio_sel)
            mem_rdata = mmio_rdata;
        else
            mem_rdata = 32'd0;
    end

endmodule
