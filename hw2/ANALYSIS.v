
module ANALYSIS (fft_valid, fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
                 fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0, clk, rst, done, freq
                );

    localparam IDLE = 0;
    localparam RUN  = 1;

    input clk, rst;
    input fft_valid;

    input [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
    input [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;

    output done;
    output [3:0] freq;

    reg state_w, state_r;
    reg [479:0] f_w, f_r;
    reg [  3:0] cnt_w, cnt_r;
    reg [ 31:0] sum_w, sum_r;
    reg done_w, done_r;
    reg [3:0] freq_w, freq_r;

    reg [31:0]tmp;

    assign freq = freq_r;
    assign done = done_r;

    always@ (*) begin
            state_w = state_r;
            cnt_w = cnt_r;
            sum_w = sum_r;
            f_w   = f_r;

            done_w = done_r;
            freq_w = freq_r;

        case(state_r)
            IDLE: begin
                if (fft_valid) begin
                    state_w = RUN;
                    sum_w = $signed(fft_d0[15:0])*$signed(fft_d0[15:0]) + $signed(fft_d0[31:16])*$signed(fft_d0[31:16]);
                    freq_w = 4'b0000;
                    done_w = 1'b0;
                    f_w[ 31:  0] = fft_d1;
                    f_w[ 63: 32] = fft_d2;
                    f_w[ 95: 64] = fft_d3;
                    f_w[127: 96] = fft_d4;
                    f_w[159:128] = fft_d5;
                    f_w[191:160] = fft_d6;
                    f_w[223:192] = fft_d7;
                    f_w[255:224] = fft_d8;
                    f_w[287:256] = fft_d9;
                    f_w[319:288] = fft_d10;
                    f_w[351:320] = fft_d11;
                    f_w[383:352] = fft_d12;
                    f_w[415:384] = fft_d13;
                    f_w[447:416] = fft_d14;
                    f_w[479:448] = fft_d15;
                end else begin
                    state_w = IDLE;
                    f_w = f_r;
                end
            end
            RUN: begin
                if (cnt_r==4'b1111) begin
                    done_w = 1'b1;
                    state_w = IDLE;
                    cnt_w = 4'b1;
                end else begin
                    cnt_w = cnt_r + 1'b1;
                    f_w = {f_r[31:0], f_r[479:32]};

                    tmp = $signed(f_r[15:0])*$signed(f_r[15:0]) + $signed(f_r[31:16])*$signed(f_r[31:16]);
                    if (tmp > sum_r) begin
                        sum_w = tmp;
                        freq_w = cnt_r;
                    end else begin
                        sum_w = sum_r;
                        freq_w = freq_r;
                    end
                end
            end

        endcase
    end

    always@ (posedge clk or posedge rst) begin
        if (rst) begin
            state_r <= IDLE;
            cnt_r <= 4'b1;
            sum_r <= 32'b0;
            f_r   <= 512'b0;

            done_r <= 1'b0;
            freq_r <= 4'b0;
        end else begin
            state_r <= state_w;
            cnt_r <= cnt_w;
            sum_r <= sum_w;
            f_r <= f_w;
            done_r <= done_w;
            freq_r <= freq_w;
        end
    end

endmodule
