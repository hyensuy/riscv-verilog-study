module pe_mac (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    clear,
    input  logic signed [7:0]       a_in,
    input  logic signed [7:0]       b_in,
    output logic signed [7:0]       a_out,
    output logic signed [7:0]       b_out,
    output logic signed [17:0]      c_out
);
    logic signed [15:0] mul;

    assign mul = a_in * b_in;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out <= 8'sd0;
            b_out <= 8'sd0;
            c_out <= 18'sd0;
        end else if (clear) begin
            a_out <= 8'sd0;
            b_out <= 8'sd0;
            c_out <= 18'sd0;
        end else begin
            a_out <= a_in;
            b_out <= b_in;
            c_out <= c_out + {{2{mul[15]}}, mul};
        end
    end
endmodule
