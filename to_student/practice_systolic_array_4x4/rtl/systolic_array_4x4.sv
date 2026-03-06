module systolic_array_4x4 (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     clear,
    input  logic signed [31:0]       a_left,
    input  logic signed [31:0]       b_top,
    output logic                     valid,
    output logic signed [287:0]      c_matrix
);
    logic signed [7:0]  a_bus [0:3][0:4];
    logic signed [7:0]  b_bus [0:4][0:3];
    logic signed [17:0] c_bus [0:3][0:3];

    logic [3:0] cycle_cnt;

    genvar r, c;
    generate
        for (r = 0; r < 4; r = r + 1) begin : INJECT_A
            assign a_bus[r][0] = a_left[(r*8) +: 8];
        end

        for (c = 0; c < 4; c = c + 1) begin : INJECT_B
            assign b_bus[0][c] = b_top[(c*8) +: 8];
        end

        for (r = 0; r < 4; r = r + 1) begin : ROW
            for (c = 0; c < 4; c = c + 1) begin : COL
                pe_mac u_pe (
                    .clk   (clk),
                    .rst_n (rst_n),
                    .clear (clear),
                    .a_in  (a_bus[r][c]),
                    .b_in  (b_bus[r][c]),
                    .a_out (a_bus[r][c+1]),
                    .b_out (b_bus[r+1][c]),
                    .c_out (c_bus[r][c])
                );

                assign c_matrix[((r*4 + c)*18) +: 18] = c_bus[r][c];
            end
        end
    endgenerate

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_cnt <= 4'd0;
            valid     <= 1'b0;
        end else if (clear) begin
            cycle_cnt <= 4'd0;
            valid     <= 1'b0;
        end else begin
            if (cycle_cnt < 4'd10)
                cycle_cnt <= cycle_cnt + 4'd1;
            valid <= (cycle_cnt >= 4'd9);
        end
    end
endmodule
