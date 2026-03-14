`timescale 1ns/1ns

module reset_sync (
    input  wire clk,
    input  wire rst_n_in,
    output wire rst_n_out
);
    reg sync_ff1, sync_ff2;

    always @(posedge clk or negedge rst_n_in) begin
        if (!rst_n_in) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end else begin
            sync_ff1 <= 1'b1;
            sync_ff2 <= sync_ff1;
        end
    end

    assign rst_n_out = sync_ff2;

endmodule
