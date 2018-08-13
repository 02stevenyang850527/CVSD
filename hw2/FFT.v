`include "SER2PAR.v"
`include "BUTTERFLY.v"

module FFT(fir_valid, fir_d, clk, rst, fft_valid,
           fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
           fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0);

    localparam WR0 = 32'h00010000;      //The real part of the reference table about COS(x)+i*SIN(x) value , 0: 001
    localparam WR1 = 32'h0000EC83;      //The real part of the reference table about COS(x)+i*SIN(x) value , 1: 9.238739e-001
    localparam WR2 = 32'h0000B504;      //The real part of the reference table about COS(x)+i*SIN(x) value , 2: 7.070923e-001
    localparam WR3 = 32'h000061F7;      //The real part of the reference table about COS(x)+i*SIN(x) value , 3: 3.826752e-001
    localparam WR4 = 32'h00000000;      //The real part of the reference table about COS(x)+i*SIN(x) value , 4: 000
    localparam WR5 = 32'hFFFF9E09;      //The real part of the reference table about COS(x)+i*SIN(x) value , 5: -3.826752e-001
    localparam WR6 = 32'hFFFF4AFC;      //The real part of the reference table about COS(x)+i*SIN(x) value , 6: -7.070923e-001
    localparam WR7 = 32'hFFFF137D;      //The real part of the reference table about COS(x)+i*SIN(x) value , 7: -9.238739e-001


    localparam WI0 = 32'h00000000;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 0: 000
    localparam WI1 = 32'hFFFF9E09;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 1: -3.826752e-001
    localparam WI2 = 32'hFFFF4AFC;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 2: -7.070923e-001
    localparam WI3 = 32'hFFFF137D;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 3: -9.238739e-001
    localparam WI4 = 32'hFFFF0000;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 4: -01
    localparam WI5 = 32'hFFFF137D;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 5: -9.238739e-001
    localparam WI6 = 32'hFFFF4AFC;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 6: -7.070923e-001
    localparam WI7 = 32'hFFFF9E09;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 7: -3.826752e-001

    localparam IDLE = 0;
    localparam RUN = 1;

    input clk, rst;
    input fir_valid;
    input [15:0] fir_d;

    output fft_valid;
    output [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
    output [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;

    // Serial to Parallel
    wire [15:0] y0, y1, y2, y3, y4, y5, y6, y7;
    wire [15:0] y8, y9, y10, y11, y12, y13, y14, y15;
    wire fft_start;

    // FFT I/O Signal
    reg [63:0] y0_w, y1_w, y2_w, y3_w, y4_w, y5_w, y6_w, y7_w;          // [63:32] for real part; [31:0] for imaginary part
    reg [63:0] y8_w, y9_w, y10_w, y11_w, y12_w, y13_w, y14_w, y15_w;

    reg [63:0] y0_r, y1_r, y2_r, y3_r, y4_r, y5_r, y6_r, y7_r;
    reg [63:0] y8_r, y9_r, y10_r, y11_r, y12_r, y13_r, y14_r, y15_r;
    reg fft_valid_w, fft_valid_r;

    // Signals of BUTTERFLY Modules
    reg  [31:0] a1_w, b1_w, c1_w, d1_w, a2_w, b2_w, c2_w, d2_w;
    reg  [31:0] a1_r, b1_r, c1_r, d1_r, a2_r, b2_r, c2_r, d2_r;
    reg  [31:0] a3_w, b3_w, c3_w, d3_w, a4_w, b4_w, c4_w, d4_w;
    reg  [31:0] a3_r, b3_r, c3_r, d3_r, a4_r, b4_r, c4_r, d4_r;
    reg  [31:0] a5_w, b5_w, c5_w, d5_w, a6_w, b6_w, c6_w, d6_w;
    reg  [31:0] a5_r, b5_r, c5_r, d5_r, a6_r, b6_r, c6_r, d6_r;
    reg  [31:0] a7_w, b7_w, c7_w, d7_w, a8_w, b8_w, c8_w, d8_w;
    reg  [31:0] a7_r, b7_r, c7_r, d7_r, a8_r, b8_r, c8_r, d8_r;

    reg  [31:0] wr1_w, wi1_w, wr2_w, wi2_w, wr3_w, wi3_w, wr4_w, wi4_w;
    reg  [31:0] wr5_w, wi5_w, wr6_w, wi6_w, wr7_w, wi7_w, wr8_w, wi8_w;

    reg  [31:0] wr1_r, wi1_r, wr2_r, wi2_r, wr3_r, wi3_r, wr4_r, wi4_r;
    reg  [31:0] wr5_r, wi5_r, wr6_r, wi6_r, wr7_r, wi7_r, wr8_r, wi8_r;

    wire [31:0] o1_real, o1_img, o2_real, o2_img;
    wire [31:0] o3_real, o3_img, o4_real, o4_img;
    wire [31:0] o5_real, o5_img, o6_real, o6_img;
    wire [31:0] o7_real, o7_img, o8_real, o8_img;

    // FFT Ctrl Signals
    reg [3:0] cnt_w, cnt_r;
    reg state_w, state_r;

    SER2PAR s2p(.fir_d(fir_d), .fir_valid(fir_valid), .clk(clk), .rst(rst), .y0(y0),
                .y1(y1), .y2(y2), .y3(y3), .y4(y4), .y5(y5), .y6(y6), .y7(y7), .y8(y8),
                .y9(y9), .y10(y10), .y11(y11), .y12(y12), .y13(y13), .y14(y14), .y15(y15), .fft_start(fft_start)
               );
    BUTTERFLY but1(.a(a1_r), .b(b1_r), .c(c1_r), .d(d1_r), .wr(wr1_r), .wi(wi1_r), .o_real(o1_real), .o_img(o1_img));
    BUTTERFLY but2(.a(a2_r), .b(b2_r), .c(c2_r), .d(d2_r), .wr(wr2_r), .wi(wi2_r), .o_real(o2_real), .o_img(o2_img));
    BUTTERFLY but3(.a(a3_r), .b(b3_r), .c(c3_r), .d(d3_r), .wr(wr3_r), .wi(wi3_r), .o_real(o3_real), .o_img(o3_img));
    BUTTERFLY but4(.a(a4_r), .b(b4_r), .c(c4_r), .d(d4_r), .wr(wr4_r), .wi(wi4_r), .o_real(o4_real), .o_img(o4_img));
    BUTTERFLY but5(.a(a5_r), .b(b5_r), .c(c5_r), .d(d5_r), .wr(wr5_r), .wi(wi5_r), .o_real(o5_real), .o_img(o5_img));
    BUTTERFLY but6(.a(a6_r), .b(b6_r), .c(c6_r), .d(d6_r), .wr(wr6_r), .wi(wi6_r), .o_real(o6_real), .o_img(o6_img));
    BUTTERFLY but7(.a(a7_r), .b(b7_r), .c(c7_r), .d(d7_r), .wr(wr7_r), .wi(wi7_r), .o_real(o7_real), .o_img(o7_img));
    BUTTERFLY but8(.a(a8_r), .b(b8_r), .c(c8_r), .d(d8_r), .wr(wr8_r), .wi(wi8_r), .o_real(o8_real), .o_img(o8_img));

    assign fft_d0 = {y0_r[63], y0_r[54:40], y0_r[31], y0_r[22:8]};
    assign fft_d1 = {y8_r[63], y8_r[54:40], y8_r[31], y8_r[22:8]};
    assign fft_d2 = {y4_r[63], y4_r[54:40], y4_r[31], y4_r[22:8]};
    assign fft_d3 = {y12_r[63], y12_r[54:40], y12_r[31], y12_r[22:8]};
    assign fft_d4 = {y2_r[63], y2_r[54:40], y2_r[31], y2_r[22:8]};
    assign fft_d5 = {y10_r[63], y10_r[54:40], y10_r[31], y10_r[22:8]};
    assign fft_d6 = {y6_r[63], y6_r[54:40], y6_r[31], y6_r[22:8]};
    assign fft_d7 = {y14_r[63], y14_r[54:40], y14_r[31], y14_r[22:8]};
    assign fft_d8 = {y1_r[63], y1_r[54:40], y1_r[31], y1_r[22:8]};
    assign fft_d9 = {y9_r[63], y9_r[54:40], y9_r[31], y9_r[22:8]};
    assign fft_d10 = {y5_r[63], y5_r[54:40], y5_r[31], y5_r[22:8]};
    assign fft_d11 = {y13_r[63], y13_r[54:40], y13_r[31], y13_r[22:8]};
    assign fft_d12 = {y3_r[63], y3_r[54:40], y3_r[31], y3_r[22:8]};
    assign fft_d13 = {y11_r[63], y11_r[54:40], y11_r[31], y11_r[22:8]};
    assign fft_d14 = {y7_r[63], y7_r[54:40], y7_r[31], y7_r[22:8]};
    assign fft_d15 = {y15_r[63], y15_r[54:40], y15_r[31], y15_r[22:8]};

    assign fft_valid = fft_valid_r;

    always@ (*) begin
        fft_valid_w = fft_valid_r;
        cnt_w = cnt_r;
        state_w = state_r;
        y0_w = y0_r;
        y1_w = y1_r;
        y2_w = y2_r;
        y3_w = y3_r;
        y4_w = y4_r;
        y5_w = y5_r;
        y6_w = y6_r;
        y7_w = y7_r;
        y8_w = y8_r;
        y9_w = y9_r;
        y10_w = y10_r;
        y11_w = y11_r;
        y12_w = y12_r;
        y13_w = y13_r;
        y14_w = y14_r;
        y15_w = y15_r;
        a1_w = a1_r; a2_w = a2_r;
        a3_w = a3_r; a4_w = a4_r;
        a5_w = a5_r; a6_w = a6_r;
        a7_w = a7_r; a8_w = a8_r;

        b1_w = b1_r; b2_w = b2_r;
        b3_w = b3_r; b4_w = b4_r;
        b5_w = b5_r; b6_w = b8_r;
        b7_w = b7_r; b8_w = b8_r;

        c1_w = c1_r; c2_w = c2_r;
        c3_w = c3_r; c4_w = c4_r;
        c5_w = c5_r; c6_w = c6_r;
        c7_w = c7_r; c8_w = c8_r;

        d1_w = d1_r; d2_w = d2_r;
        d3_w = d3_r; d4_w = d4_r;
        d5_w = d5_r; d6_w = d6_r;
        d7_w = d7_r; d8_w = d8_r;

        wr1_w = wr1_r; wi1_w = wi1_r;
        wr2_w = wr2_r; wi2_w = wi2_r;
        wr3_w = wr3_r; wi3_w = wi3_r;
        wr4_w = wr4_r; wi4_w = wi4_r;
        wr5_w = wr5_r; wi5_w = wi5_r;
        wr6_w = wr6_r; wi6_w = wi6_r;
        wr7_w = wr7_r; wi7_w = wi7_r;
        wr8_w = wr8_r; wi8_w = wi8_r;
        
        case(state_r)
            IDLE: begin
                fft_valid_w = 1'b0;
                if (fft_start) begin
                    state_w = RUN;
                    y0_w = {{8{y0[15]}}, y0, 40'b0};
                    y1_w = {{8{y1[15]}}, y1, 40'b0};
                    y2_w = {{8{y2[15]}}, y2, 40'b0};
                    y3_w = {{8{y3[15]}}, y3, 40'b0};
                    y4_w = {{8{y4[15]}}, y4, 40'b0};
                    y5_w = {{8{y5[15]}}, y5, 40'b0};
                    y6_w = {{8{y6[15]}}, y6, 40'b0};
                    y7_w = {{8{y7[15]}}, y7, 40'b0};
                    y8_w = {{8{y8[15]}}, y8, 40'b0};
                    y9_w = {{8{y9[15]}}, y9, 40'b0};
                    y10_w = {{8{y10[15]}}, y10, 40'b0};
                    y11_w = {{8{y11[15]}}, y11, 40'b0};
                    y12_w = {{8{y12[15]}}, y12, 40'b0};
                    y13_w = {{8{y13[15]}}, y13, 40'b0};
                    y14_w = {{8{y14[15]}}, y14, 40'b0};
                    y15_w = {{8{y15[15]}}, y15, 40'b0};

                    // Calculate in advance to save meet the requirement of
                    // the number of cycles.

                    a1_w = {{8{y0[15]}}, y0, 8'b0};   c1_w = -$signed({{8{y8[15]}}, y8, 8'b0});
                    b1_w = {32'b0};   d1_w = {32'b0};
                    wr1_w = WR0;      wi1_w= WI0;

                    a2_w = {{8{y1[15]}}, y1, 8'b0};   c2_w = -$signed({{8{y9[15]}}, y9, 8'b0});
                    b2_w = {32'b0};   d2_w  = {32'b0};
                    wr2_w = WR0;        wi2_w = WI0;

                    a3_w = {{8{y0[15]}}, y0, 8'b0};   c3_w = {{8{y8[15]}}, y8, 8'b0};
                    b3_w = {32'b0};    d3_w = {32'b0};
                    wr3_w = WR0;       wi3_w = WI0;

                    a4_w = {{8{y1[15]}}, y1, 8'b0};   c4_w = {{8{y9[15]}}, y9, 8'b0};
                    b4_w = {32'b0};    d4_w = {32'b0};
                    wr4_w = WR1;       wi4_w = WI1;

                    a5_w = {{8{y2[15]}}, y2, 8'b0};   c5_w = -$signed({{8{y10[15]}}, y10, 8'b0});
                    b5_w = {32'b0};   d5_w = {32'b0};
                    wr5_w = WR0;      wi5_w= WI0;

                    a6_w = {{8{y3[15]}}, y3, 8'b0};   c6_w = -$signed({{8{y11[15]}}, y11, 8'b0});
                    b6_w = {32'b0};   d6_w  = {32'b0};
                    wr6_w = WR0;      wi6_w = WI0;

                    a7_w = {{8{y2[15]}}, y2, 8'b0};   c7_w = {{8{y10[15]}}, y10, 8'b0};
                    b7_w = {32'b0};    d7_w = {32'b0};
                    wr7_w = WR2;       wi7_w = WI2;

                    a8_w = {{8{y3[15]}}, y3, 8'b0};   c8_w = {{8{y11[15]}}, y11, 8'b0};
                    b8_w = {32'b0};    d8_w = {32'b0};
                    wr8_w = WR3;       wi8_w = WI3;

                end else begin
                    state_w = state_r;
                    y0_w = y0_r;
                    y1_w = y1_r;
                    y2_w = y2_r;
                    y3_w = y3_r;
                    y4_w = y4_r;
                    y5_w = y5_r;
                    y6_w = y6_r;
                    y7_w = y7_r;
                    y8_w = y8_r;
                    y9_w = y9_r;
                    y10_w = y10_r;
                    y11_w = y11_r;
                    y12_w = y12_r;
                    y13_w = y13_r;
                    y14_w = y14_r;
                    y15_w = y15_r;
                end
            end
            RUN: begin
                case(cnt_r)
                    4'b0000: begin// Stage1
                        cnt_w = cnt_r + 1'b1;
                        a1_w = y4_r[63:32];   c1_w = -$signed(y12_r[63:32]);
                        b1_w = y4_r[31:0];    d1_w = -$signed(y12_r[31: 0]);
                        wr1_w = WR0;      wi1_w= WI0;

                        a2_w = y5_r[63:32];   c2_w = -$signed(y13_r[63:32]);
                        b2_w = y5_r[31:0];    d2_w = -$signed(y13_r[31: 0]);
                        wr2_w = WR0;        wi2_w = WI0;

                        a3_w = y4_r[63:32];   c3_w = y12_r[63:32];
                        b3_w = y4_r[31: 0];   d3_w = y12_r[31: 0];
                        wr3_w = WR4;       wi3_w = WI4;

                        a4_w = y5_r[63:32];   c4_w = y13_r[63:32];
                        b4_w = y5_r[31: 0];   d4_w = y13_r[31: 0];
                        wr4_w = WR5;       wi4_w = WI5;

                        a5_w = y6_r[63:32];   c5_w = -$signed(y14_r[63:32]);
                        b5_w = y6_r[31: 0];   d5_w = -$signed(y14_r[31: 0]);
                        wr5_w = WR0;      wi5_w= WI0;

                        a6_w = y7_r[63:32];   c6_w = -$signed(y15_r[63:32]);
                        b6_w = y7_r[31: 0];   d6_w = -$signed(y15_r[31: 0]) ;
                        wr6_w = WR0;        wi6_w = WI0;

                        a7_w = y6_r[63:32];   c7_w = y14_r[63:32];
                        b7_w = y6_r[31: 0];   d7_w = y14_r[31: 0];
                        wr7_w = WR6;       wi7_w = WI6;

                        a8_w = y7_r[63:32];   c8_w = y15_r[63:32];
                        b8_w = y7_r[31: 0];   d8_w = y15_r[31: 0];
                        wr8_w = WR7;       wi8_w = WI7;

                        y0_w = {o1_real, o1_img};
                        y1_w = {o2_real, o2_img};
                        y8_w = {o3_real, o3_img};
                        y9_w = {o4_real, o4_img};
                        y2_w = {o5_real, o5_img};
                        y3_w = {o6_real, o6_img};
                        y10_w = {o7_real, o7_img};
                        y11_w = {o8_real, o8_img};
                    end
                    4'b0001: begin
                        cnt_w = cnt_r + 1'b1;
                        y4_w = {o1_real, o1_img};
                        y5_w = {o2_real, o2_img};
                        y12_w = {o3_real, o3_img};
                        y13_w = {o4_real, o4_img};
                        y6_w = {o5_real, o5_img};
                        y7_w = {o6_real, o6_img};
                        y14_w = {o7_real, o7_img};
                        y15_w = {o8_real, o8_img};
                    end
                    4'b0010: begin// Stage2:
                        cnt_w = cnt_r + 1'b1;
                        a1_w = y0_r[63:32];   c1_w = -$signed(y4_r[63:32]);
                        b1_w = y0_r[31:0];    d1_w = -$signed(y4_r[31: 0]);
                        wr1_w = WR0;      wi1_w= WI0;

                        a2_w = y1_r[63:32];   c2_w = -$signed(y5_r[63:32]);
                        b2_w = y1_r[31:0];    d2_w = -$signed(y5_r[31: 0]);
                        wr2_w = WR0;        wi2_w = WI0;

                        a3_w = y0_r[63:32];   c3_w = y4_r[63:32];
                        b3_w = y0_r[31: 0];   d3_w = y4_r[31: 0];
                        wr3_w = WR0;       wi3_w = WI0;

                        a4_w = y1_r[63:32];   c4_w = y5_r[63:32];
                        b4_w = y1_r[31: 0];   d4_w = y5_r[31: 0];
                        wr4_w = WR2;       wi4_w = WI2;

                        a5_w = y2_r[63:32];   c5_w = -$signed(y6_r[63:32]);
                        b5_w = y2_r[31: 0];   d5_w = -$signed(y6_r[31: 0]);
                        wr5_w = WR0;      wi5_w= WI0;

                        a6_w = y3_r[63:32];   c6_w = -$signed(y7_r[63:32]);
                        b6_w = y3_r[31: 0];   d6_w = -$signed(y7_r[31: 0]) ;
                        wr6_w = WR0;        wi6_w = WI0;

                        a7_w = y2_r[63:32];   c7_w = y6_r[63:32];
                        b7_w = y2_r[31: 0];   d7_w = y6_r[31: 0];
                        wr7_w = WR4;       wi7_w = WI4;

                        a8_w = y3_r[63:32];   c8_w = y7_r[63:32];
                        b8_w = y3_r[31: 0];   d8_w = y7_r[31: 0];
                        wr8_w = WR6;       wi8_w = WI6;

                    end
                    4'b0011: begin
                        cnt_w = cnt_r + 1'b1;
                        a1_w = y8_r[63:32];   c1_w = -$signed(y12_r[63:32]);
                        b1_w = y8_r[31:0];    d1_w = -$signed(y12_r[31: 0]);
                        wr1_w = WR0;      wi1_w= WI0;

                        a2_w = y9_r[63:32];   c2_w = -$signed(y13_r[63:32]);
                        b2_w = y9_r[31:0];    d2_w = -$signed(y13_r[31: 0]);
                        wr2_w = WR0;        wi2_w = WI0;

                        a3_w = y8_r[63:32];   c3_w = y12_r[63:32];
                        b3_w = y8_r[31: 0];   d3_w = y12_r[31: 0];
                        wr3_w = WR0;       wi3_w = WI0;

                        a4_w = y9_r[63:32];   c4_w = y13_r[63:32];
                        b4_w = y9_r[31: 0];   d4_w = y13_r[31: 0];
                        wr4_w = WR2;       wi4_w = WI2;

                        a5_w = y10_r[63:32];   c5_w = -$signed(y14_r[63:32]);
                        b5_w = y10_r[31: 0];   d5_w = -$signed(y14_r[31: 0]);
                        wr5_w = WR0;      wi5_w= WI0;

                        a6_w = y11_r[63:32];   c6_w = -$signed(y15_r[63:32]);
                        b6_w = y11_r[31: 0];   d6_w = -$signed(y15_r[31: 0]) ;
                        wr6_w = WR0;        wi6_w = WI0;

                        a7_w = y10_r[63:32];   c7_w = y14_r[63:32];
                        b7_w = y10_r[31: 0];   d7_w = y14_r[31: 0];
                        wr7_w = WR4;       wi7_w = WI4;

                        a8_w = y11_r[63:32];   c8_w = y15_r[63:32];
                        b8_w = y11_r[31: 0];   d8_w = y15_r[31: 0];
                        wr8_w = WR6;       wi8_w = WI6;

                        y0_w = {o1_real, o1_img};
                        y1_w = {o2_real, o2_img};
                        y4_w = {o3_real, o3_img};
                        y5_w = {o4_real, o4_img};
                        y2_w = {o5_real, o5_img};
                        y3_w = {o6_real, o6_img};
                        y6_w = {o7_real, o7_img};
                        y7_w = {o8_real, o8_img};
                    end
                    4'b0100: begin //Stage3
                        cnt_w = cnt_r + 1'b1;
                        a1_w = y0_r[63:32];   c1_w = -$signed(y2_r[63:32]);
                        b1_w = y0_r[31:0];    d1_w = -$signed(y2_r[31: 0]);
                        wr1_w = WR0;      wi1_w= WI0;

                        a2_w = y1_r[63:32];   c2_w = -$signed(y3_r[63:32]);
                        b2_w = y1_r[31:0];    d2_w = -$signed(y3_r[31: 0]);
                        wr2_w = WR0;        wi2_w = WI0;

                        a3_w = y0_r[63:32];   c3_w = y2_r[63:32];
                        b3_w = y0_r[31: 0];   d3_w = y2_r[31: 0];
                        wr3_w = WR0;       wi3_w = WI0;

                        a4_w = y1_r[63:32];   c4_w = y3_r[63:32];
                        b4_w = y1_r[31: 0];   d4_w = y3_r[31: 0];
                        wr4_w = WR4;       wi4_w = WI4;

                        a5_w = y4_r[63:32];   c5_w = -$signed(y6_r[63:32]);
                        b5_w = y4_r[31: 0];   d5_w = -$signed(y6_r[31: 0]);
                        wr5_w = WR0;      wi5_w= WI0;

                        a6_w = y5_r[63:32];   c6_w = -$signed(y7_r[63:32]);
                        b6_w = y5_r[31: 0];   d6_w = -$signed(y7_r[31: 0]) ;
                        wr6_w = WR0;        wi6_w = WI0;

                        a7_w = y4_r[63:32];   c7_w = y6_r[63:32];
                        b7_w = y4_r[31: 0];   d7_w = y6_r[31: 0];
                        wr7_w = WR0;       wi7_w = WI0;

                        a8_w = y5_r[63:32];   c8_w = y7_r[63:32];
                        b8_w = y5_r[31: 0];   d8_w = y7_r[31: 0];
                        wr8_w = WR4;       wi8_w = WI4;

                        y8_w = {o1_real, o1_img};
                        y9_w = {o2_real, o2_img};
                        y12_w = {o3_real, o3_img};
                        y13_w = {o4_real, o4_img};
                        y10_w = {o5_real, o5_img};
                        y11_w = {o6_real, o6_img};
                        y14_w = {o7_real, o7_img};
                        y15_w = {o8_real, o8_img};
                    end
                    4'b0101: begin
                        cnt_w = cnt_r + 1'b1;
                        a1_w = y8_r[63:32];   c1_w = -$signed(y10_r[63:32]);
                        b1_w = y8_r[31:0];    d1_w = -$signed(y10_r[31: 0]);
                        wr1_w = WR0;      wi1_w= WI0;

                        a2_w = y9_r[63:32];   c2_w = -$signed(y11_r[63:32]);
                        b2_w = y9_r[31:0];    d2_w = -$signed(y11_r[31: 0]);
                        wr2_w = WR0;        wi2_w = WI0;

                        a3_w = y8_r[63:32];   c3_w = y10_r[63:32];
                        b3_w = y8_r[31: 0];   d3_w = y10_r[31: 0];
                        wr3_w = WR0;       wi3_w = WI0;

                        a4_w = y9_r[63:32];   c4_w = y11_r[63:32];
                        b4_w = y9_r[31: 0];   d4_w = y11_r[31: 0];
                        wr4_w = WR4;       wi4_w = WI4;

                        a5_w = y12_r[63:32];   c5_w = -$signed(y14_r[63:32]);
                        b5_w = y12_r[31: 0];   d5_w = -$signed(y14_r[31: 0]);
                        wr5_w = WR0;      wi5_w= WI0;

                        a6_w = y13_r[63:32];   c6_w = -$signed(y15_r[63:32]);
                        b6_w = y13_r[31: 0];   d6_w = -$signed(y15_r[31: 0]) ;
                        wr6_w = WR0;        wi6_w = WI0;

                        a7_w = y12_r[63:32];   c7_w = y14_r[63:32];
                        b7_w = y12_r[31: 0];   d7_w = y14_r[31: 0];
                        wr7_w = WR0;       wi7_w = WI0;

                        a8_w = y13_r[63:32];   c8_w = y15_r[63:32];
                        b8_w = y13_r[31: 0];   d8_w = y15_r[31: 0];
                        wr8_w = WR4;       wi8_w = WI4;

                        y0_w = {o1_real, o1_img};
                        y1_w = {o2_real, o2_img};
                        y2_w = {o3_real, o3_img};
                        y3_w = {o4_real, o4_img};
                        y4_w = {o5_real, o5_img};
                        y5_w = {o6_real, o6_img};
                        y6_w = {o7_real, o7_img};
                        y7_w = {o8_real, o8_img};
                    end
                    4'b0110: begin // Stage4
                        cnt_w = cnt_r + 1'b1;
                        a1_w = y0_r[63:32];   c1_w = -$signed(y1_r[63:32]);
                        b1_w = y0_r[31:0];    d1_w = -$signed(y1_r[31: 0]);
                        wr1_w = WR0;      wi1_w= WI0;

                        a2_w = y0_r[63:32];   c2_w = y1_r[63:32];
                        b2_w = y0_r[31: 0];   d2_w = y1_r[31: 0];
                        wr2_w = WR0;       wi2_w = WI0;

                        a3_w = y2_r[63:32];   c3_w = -$signed(y3_r[63:32]);
                        b3_w = y2_r[31:0];    d3_w = -$signed(y3_r[31: 0]);
                        wr3_w = WR0;        wi3_w = WI0;

                        a4_w = y2_r[63:32];   c4_w = y3_r[63:32];
                        b4_w = y2_r[31: 0];   d4_w = y3_r[31: 0];
                        wr4_w = WR0;       wi4_w = WI0;

                        a5_w = y4_r[63:32];   c5_w = -$signed(y5_r[63:32]);
                        b5_w = y4_r[31:0];    d5_w = -$signed(y5_r[31: 0]);
                        wr5_w = WR0;      wi5_w= WI0;

                        a6_w = y4_r[63:32];   c6_w = y5_r[63:32];
                        b6_w = y4_r[31: 0];   d6_w = y5_r[31: 0];
                        wr6_w = WR0;       wi6_w = WI0;

                        a7_w = y6_r[63:32];   c7_w = -$signed(y7_r[63:32]);
                        b7_w = y6_r[31:0];    d7_w = -$signed(y7_r[31: 0]);
                        wr7_w = WR0;        wi7_w = WI0;

                        a8_w = y6_r[63:32];   c8_w = y7_r[63:32];
                        b8_w = y6_r[31: 0];   d8_w = y7_r[31: 0];
                        wr8_w = WR0;       wi8_w = WI0;

                        y8_w = {o1_real, o1_img};
                        y9_w = {o2_real, o2_img};
                        y10_w = {o3_real, o3_img};
                        y11_w = {o4_real, o4_img};
                        y12_w = {o5_real, o5_img};
                        y13_w = {o6_real, o6_img};
                        y14_w = {o7_real, o7_img};
                        y15_w = {o8_real, o8_img};
                    end
                    4'b0111: begin
                        cnt_w = cnt_r + 1'b1;
                        a1_w = y8_r[63:32];   c1_w = -$signed(y9_r[63:32]);
                        b1_w = y8_r[31:0];    d1_w = -$signed(y9_r[31: 0]);
                        wr1_w = WR0;      wi1_w= WI0;

                        a2_w = y8_r[63:32];   c2_w = y9_r[63:32];
                        b2_w = y8_r[31: 0];   d2_w = y9_r[31: 0];
                        wr2_w = WR0;       wi2_w = WI0;

                        a3_w = y10_r[63:32];   c3_w = -$signed(y11_r[63:32]);
                        b3_w = y10_r[31:0];    d3_w = -$signed(y11_r[31: 0]);
                        wr3_w = WR0;        wi3_w = WI0;

                        a4_w = y10_r[63:32];   c4_w = y11_r[63:32];
                        b4_w = y10_r[31: 0];   d4_w = y11_r[31: 0];
                        wr4_w = WR0;       wi4_w = WI0;

                        a5_w = y12_r[63:32];   c5_w = -$signed(y13_r[63:32]);
                        b5_w = y12_r[31:0];    d5_w = -$signed(y13_r[31: 0]);
                        wr5_w = WR0;      wi5_w= WI0;

                        a6_w = y12_r[63:32];   c6_w = y13_r[63:32];
                        b6_w = y12_r[31: 0];   d6_w = y13_r[31: 0];
                        wr6_w = WR0;       wi6_w = WI0;

                        a7_w = y14_r[63:32];   c7_w = -$signed(y15_r[63:32]);
                        b7_w = y14_r[31:0];    d7_w = -$signed(y15_r[31: 0]);
                        wr7_w = WR0;        wi7_w = WI0;

                        a8_w = y14_r[63:32];   c8_w = y15_r[63:32];
                        b8_w = y14_r[31: 0];   d8_w = y15_r[31: 0];
                        wr8_w = WR0;       wi8_w = WI0;

                        y0_w = {o1_real, o1_img};
                        y1_w = {o2_real, o2_img};
                        y2_w = {o3_real, o3_img};
                        y3_w = {o4_real, o4_img};
                        y4_w = {o5_real, o5_img};
                        y5_w = {o6_real, o6_img};
                        y6_w = {o7_real, o7_img};
                        y7_w = {o8_real, o8_img};
                    end
                    4'b1000: begin
                        cnt_w = 4'b0;
                        state_w = IDLE;
                        fft_valid_w = 1'b1;
                        y8_w = {o1_real, o1_img};
                        y9_w = {o2_real, o2_img};
                        y10_w = {o3_real, o3_img};
                        y11_w = {o4_real, o4_img};
                        y12_w = {o5_real, o5_img};
                        y13_w = {o6_real, o6_img};
                        y14_w = {o7_real, o7_img};
                        y15_w = {o8_real, o8_img};
                    end
                    default: begin
                    end
                endcase
            end
        endcase
    end

    always@ (posedge clk or posedge rst) begin
        if (rst) begin
            cnt_r       <= 4'b0;
            fft_valid_r <= 1'b0;
            state_r     <= IDLE;

            y0_r <= 64'b0;
            y1_r <= 64'b0;
            y2_r <= 64'b0;
            y3_r <= 64'b0;
            y4_r <= 64'b0;
            y5_r <= 64'b0;
            y6_r <= 64'b0;
            y7_r <= 64'b0;
            y8_r <= 64'b0;
            y9_r <= 64'b0;
            y10_r <= 64'b0;
            y11_r <= 64'b0;
            y12_r <= 64'b0;
            y13_r <= 64'b0;
            y14_r <= 64'b0;
            y15_r <= 64'b0;

            a1_r <= 32'b0; a2_r <= 32'b0;
            a3_r <= 32'b0; a4_r <= 32'b0;
            a5_r <= 32'b0; a6_r <= 32'b0;
            a7_r <= 32'b0; a8_r <= 32'b0;

            b1_r <= 32'b0; b2_r <= 32'b0;
            b3_r <= 32'b0; b4_r <= 32'b0;
            b5_r <= 32'b0; b6_r <= 32'b0;
            b7_r <= 32'b0; b8_r <= 32'b0;

            c1_r <= 32'b0; c2_r <= 32'b0;
            c3_r <= 32'b0; c4_r <= 32'b0;
            c5_r <= 32'b0; c6_r <= 32'b0;
            c7_r <= 32'b0; c8_r <= 32'b0;

            d1_r <= 32'b0; d2_r <= 32'b0;
            d3_r <= 32'b0; d4_r <= 32'b0;
            d5_r <= 32'b0; d6_r <= 32'b0;
            d7_r <= 32'b0; d8_r <= 32'b0;

            wr1_r <= 32'b0; wi1_r <= 32'b0;
            wr2_r <= 32'b0; wi2_r <= 32'b0;
            wr3_r <= 32'b0; wi3_r <= 32'b0;
            wr4_r <= 32'b0; wi4_r <= 32'b0;
            wr5_r <= 32'b0; wi5_r <= 32'b0;
            wr6_r <= 32'b0; wi6_r <= 32'b0;
            wr7_r <= 32'b0; wi7_r <= 32'b0;
            wr8_r <= 32'b0; wi8_r <= 32'b0;

        end else begin
            cnt_r       <= cnt_w;
            fft_valid_r <= fft_valid_w;
            state_r     <= state_w;

            y0_r <= y0_w;
            y1_r <= y1_w;
            y2_r <= y2_w;
            y3_r <= y3_w;
            y4_r <= y4_w;
            y5_r <= y5_w;
            y6_r <= y6_w;
            y7_r <= y7_w;
            y8_r <= y8_w;
            y9_r <= y9_w;
            y10_r <= y10_w;
            y11_r <= y11_w;
            y12_r <= y12_w;
            y13_r <= y13_w;
            y14_r <= y14_w;
            y15_r <= y15_w;

            a1_r <= a1_w; a2_r <= a2_w;
            a3_r <= a3_w; a4_r <= a4_w;
            a5_r <= a5_w; a6_r <= a6_w;
            a7_r <= a7_w; a8_r <= a8_w;

            b1_r <= b1_w; b2_r <= b2_w;
            b3_r <= b3_w; b4_r <= b4_w;
            b5_r <= b5_w; b6_r <= b6_w;
            b7_r <= b7_w; b8_r <= b8_w;

            c1_r <= c1_w; c2_r <= c2_w;
            c3_r <= c3_w; c4_r <= c4_w;
            c5_r <= c5_w; c6_r <= c6_w;
            c7_r <= c7_w; c8_r <= c8_w;

            d1_r <= d1_w; d2_r <= d2_w;
            d3_r <= d3_w; d4_r <= d4_w;
            d5_r <= d5_w; d6_r <= d6_w;
            d7_r <= d7_w; d8_r <= d8_w;

            wr1_r <= wr1_w; wi1_r <= wi1_w;
            wr2_r <= wr2_w; wi2_r <= wi2_w;
            wr3_r <= wr3_w; wi3_r <= wi3_w;
            wr4_r <= wr4_w; wi4_r <= wi4_w;
            wr5_r <= wr5_w; wi5_r <= wi5_w;
            wr6_r <= wr6_w; wi6_r <= wi6_w;
            wr7_r <= wr7_w; wi7_r <= wi7_w;
            wr8_r <= wr8_w; wi8_r <= wi8_w;

        end
    end 

endmodule
