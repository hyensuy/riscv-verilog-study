`timescale 1ns/1ps

module tb_systolic_array_4x4;
    logic clk;
    logic rst_n;
    logic clear;
    logic signed [31:0] a_left;
    logic signed [31:0] b_top;
    logic valid;
    logic signed [287:0] c_matrix;

    integer cycle;
    integer i, j;

    logic signed [7:0]  A [0:3][0:3];
    logic signed [7:0]  B [0:3][0:3];
    logic signed [17:0] C_EXP [0:3][0:3];

    systolic_array_4x4 dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .clear    (clear),
        .a_left   (a_left),
        .b_top    (b_top),
        .valid    (valid),
        .c_matrix (c_matrix)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic drive_stream(input integer t);
        integer r, c;
        integer kA, kB;
        begin
            a_left = 32'sd0;
            b_top  = 32'sd0;

            for (r = 0; r < 4; r = r + 1) begin
                kA = t - r;
                if (kA >= 0 && kA < 4)
                    a_left[(r*8) +: 8] = A[r][kA];
            end

            for (c = 0; c < 4; c = c + 1) begin
                kB = t - c;
                if (kB >= 0 && kB < 4)
                    b_top[(c*8) +: 8] = B[kB][c];
            end
        end
    endtask

    initial begin
        A[0][0]=  1; A[0][1]=  2; A[0][2]=  3; A[0][3]=  4;
        A[1][0]=  5; A[1][1]=  6; A[1][2]=  7; A[1][3]=  8;
        A[2][0]= -1; A[2][1]= -2; A[2][2]= -3; A[2][3]= -4;
        A[3][0]=  2; A[3][1]=  0; A[3][2]= -1; A[3][3]=  3;

        B[0][0]=  1; B[0][1]=  0; B[0][2]=  2; B[0][3]= -1;
        B[1][0]=  3; B[1][1]= -2; B[1][2]=  1; B[1][3]=  4;
        B[2][0]=  0; B[2][1]=  5; B[2][2]= -3; B[2][3]=  2;
        B[3][0]= -2; B[3][1]=  1; B[3][2]=  4; B[3][3]=  0;

        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1)
                C_EXP[i][j] = A[i][0]*B[0][j] + A[i][1]*B[1][j] + A[i][2]*B[2][j] + A[i][3]*B[3][j];

        rst_n  = 1'b0;
        clear  = 1'b1;
        a_left = 32'sd0;
        b_top  = 32'sd0;
        cycle  = 0;

        repeat (2) @(posedge clk);
        rst_n = 1'b1;

        @(negedge clk);
        clear = 1'b0;

        for (cycle = 0; cycle < 10; cycle = cycle + 1) begin
            @(negedge clk);
            drive_stream(cycle);
            @(posedge clk);
            $display("cycle=%0d valid=%0d c00=%0d c33=%0d",
                     cycle, valid,
                     $signed(c_matrix[(0*4+0)*18 +: 18]),
                     $signed(c_matrix[(3*4+3)*18 +: 18]));
        end

        @(posedge clk);

        if (!valid) begin
            $display("[FAIL] valid가 예상 시점에 올라오지 않았습니다.");
            $fatal(1);
        end

        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                if ($signed(c_matrix[((i*4+j)*18) +: 18]) !== C_EXP[i][j]) begin
                    $display("[FAIL] C[%0d][%0d] expected=%0d got=%0d",
                             i, j, C_EXP[i][j],
                             $signed(c_matrix[((i*4+j)*18) +: 18]));
                    $fatal(1);
                end
            end
        end

        $display("[PASS] 4x4 systolic array 결과가 기대값과 일치합니다.");
        $finish;
    end
endmodule
