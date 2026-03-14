`timescale 1ns/1ns

module de2_115_top (
    input  wire        CLOCK_50,
    input  wire [2:0]  BUTTON,
    input  wire [9:0]  SW,

    output wire [9:0]  LEDR,
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,

    output wire        UART_TXD,
    input  wire        UART_RXD
);

    wire rst_n_sync;
    wire reset;
    wire [15:0] hex_value;

    reset_sync u_reset_sync (
        .clk      (CLOCK_50),
        .rst_n_in (BUTTON[0]),
        .rst_n_out(rst_n_sync)
    );

    assign reset = ~rst_n_sync;

    rv32i_soc #(
        .RESET_PC (32'h1000_0000),
        .DWIDTH   (32),
        .AWIDTH   (8),
        .MIF_HEX  ("led_mmio_test.hex")
    ) u_soc (
        .clk      (CLOCK_50),
        .reset    (reset),
        .sw       (SW),
        .ledr     (LEDR),
        .hex_value(hex_value)
    );

    assign HEX0 = hex7seg(hex_value[3:0]);
    assign HEX1 = hex7seg(hex_value[7:4]);
    assign HEX2 = hex7seg(hex_value[11:8]);
    assign HEX3 = hex7seg(hex_value[15:12]);

    assign UART_TXD = 1'b1;

    function [6:0] hex7seg;
        input [3:0] val;
        begin
            case (val)
                4'h0: hex7seg = 7'b1000000;
                4'h1: hex7seg = 7'b1111001;
                4'h2: hex7seg = 7'b0100100;
                4'h3: hex7seg = 7'b0110000;
                4'h4: hex7seg = 7'b0011001;
                4'h5: hex7seg = 7'b0010010;
                4'h6: hex7seg = 7'b0000010;
                4'h7: hex7seg = 7'b1111000;
                4'h8: hex7seg = 7'b0000000;
                4'h9: hex7seg = 7'b0010000;
                4'hA: hex7seg = 7'b0001000;
                4'hB: hex7seg = 7'b0000011;
                4'hC: hex7seg = 7'b1000110;
                4'hD: hex7seg = 7'b0100001;
                4'hE: hex7seg = 7'b0000110;
                4'hF: hex7seg = 7'b0001110;
                default: hex7seg = 7'b1111111;
            endcase
        end
    endfunction

endmodule
