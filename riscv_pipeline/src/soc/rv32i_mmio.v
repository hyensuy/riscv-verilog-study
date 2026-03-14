`timescale 1ns/1ns

module rv32i_mmio (
    input  wire        clk,
    input  wire        reset,

    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire [3:0]  byte_enable,

    input  wire [9:0]  sw,
    output reg  [9:0]  ledr,
    output reg  [15:0] hex_value,

    output reg  [31:0] rdata
);

    localparam MMIO_LED_ADDR = 32'h2000_0000;
    localparam MMIO_SW_ADDR  = 32'h2000_0004;
    localparam MMIO_HEX_ADDR = 32'h2000_0008;

    integer i;
    reg [31:0] led_next;
    reg [31:0] hex_next;

    always @(*) begin
        case (addr)
            MMIO_SW_ADDR:  rdata = {22'd0, sw};
            MMIO_LED_ADDR: rdata = {22'd0, ledr};
            MMIO_HEX_ADDR: rdata = {16'd0, hex_value};
            default:       rdata = 32'd0;
        endcase
    end

    always @(*) begin
        led_next = {22'd0, ledr};
        hex_next = {16'd0, hex_value};

        if (we && (addr == MMIO_LED_ADDR)) begin
            for (i = 0; i < 4; i = i + 1) begin
                if (byte_enable[i])
                    led_next[i*8 +: 8] = wdata[i*8 +: 8];
            end
        end

        if (we && (addr == MMIO_HEX_ADDR)) begin
            for (i = 0; i < 4; i = i + 1) begin
                if (byte_enable[i])
                    hex_next[i*8 +: 8] = wdata[i*8 +: 8];
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ledr      <= 10'd0;
            hex_value <= 16'd0;
        end else begin
            ledr      <= led_next[9:0];
            hex_value <= hex_next[15:0];
        end
    end

endmodule
