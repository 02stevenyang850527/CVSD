module SER2PAR(fir_d, fir_valid, clk, rst, y0, y1, y2, y3, y4, y5, y6, y7,
               y8, y9, y10, y11, y12, y13, y14, y15, fft_start);

    input clk, rst;
    input fir_valid;

    input [15:0] fir_d;

    output reg [15:0] y0, y1, y2, y3, y4, y5, y6, y7;
    output reg [15:0] y8, y9, y10, y11, y12, y13, y14, y15;
    output reg fft_start;

    reg [ 3:0] cnt_r, cnt_w;
    reg [15:0] y0_w, y1_w, y2_w, y3_w, y4_w, y5_w, y6_w, y7_w, y8_w;
    reg [15:0] y9_w, y10_w, y11_w, y12_w, y13_w, y14_w, y15_w;

    reg fft_start_w;

    always@ (*) begin
        if (fir_valid) begin

            y15_w = fir_d;
            y14_w = y15;
            y13_w = y14;
            y12_w = y13;
            y11_w = y12;
            y10_w = y11;
            y9_w = y10;
            y8_w = y9;
            y7_w = y8;
            y6_w = y7;
            y5_w = y6;
            y4_w = y5;
            y3_w = y4;
            y2_w = y3;
            y1_w = y2;
            y0_w = y1;

            if (cnt_r==4'b1111) begin
                cnt_w = 4'b0;
                fft_start_w = 1'b1;
            end else begin
                cnt_w = cnt_r + 1'b1;
                fft_start_w = 1'b0;
            end

        end else begin
            fft_start_w = fft_start;
            cnt_w = cnt_r;
            y0_w = y0;
            y1_w = y1;
            y2_w = y2;
            y3_w = y3;
            y4_w = y4;
            y5_w = y5;
            y6_w = y6;
            y7_w = y7;
            y8_w = y8;
            y9_w = y9;
            y10_w = y10;
            y11_w = y11;
            y12_w = y12;
            y13_w = y13;
            y14_w = y14;
            y15_w = y15;
        end
    end

    always@ (posedge clk or posedge rst) begin
        if (rst) begin
            cnt_r <= 4'b0;
            fft_start <= 1'b0;
            y0 <= 16'b0;
            y1 <= 16'b0;
            y2 <= 16'b0;
            y3 <= 16'b0;
            y4 <= 16'b0;
            y5 <= 16'b0;
            y6 <= 16'b0;
            y7 <= 16'b0;
            y8 <= 16'b0;
            y9 <= 16'b0;
            y10 <= 16'b0;
            y11 <= 16'b0;
            y12 <= 16'b0;
            y13 <= 16'b0;
            y14 <= 16'b0;
            y15 <= 16'b0;

        end else begin
            cnt_r <= cnt_w;
            fft_start <= fft_start_w;
            y0 <= y0_w;
            y1 <= y1_w;
            y2 <= y2_w;
            y3 <= y3_w;
            y4 <= y4_w;
            y5 <= y5_w;
            y6 <= y6_w;
            y7 <= y7_w;
            y8 <= y8_w;
            y9 <= y9_w;
            y10 <= y10_w;
            y11 <= y11_w;
            y12 <= y12_w;
            y13 <= y13_w;
            y14 <= y14_w;
            y15 <= y15_w;
        end
    end

endmodule

