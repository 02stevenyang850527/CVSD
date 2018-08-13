
module MEDIAN(i_start, x_in, m_out, o_finish, clk, reset);

    localparam TOTAL = 49;
    localparam BITS = 8;
    localparam THRESHOLD = 24;
    localparam IDLE = 0;
    localparam RUN1 = 1;
    localparam RUN2 = 2;
    
    input          clk, reset, i_start;
    input [TOTAL*BITS-1:0] x_in;
    output reg              o_finish;
    output reg [BITS-1:0] m_out;

    // I/O Signals
    reg [BITS-1:0] x_w [TOTAL-1:0];
    reg [BITS-1:0] x_r [TOTAL-1:0];
    reg [BITS-1:0]         m_out_w;
    reg                 o_finish_w;

    // Ctrl Signals & Cache
    reg       state_w, state_r;
    reg [3:0]     cnt_w, cnt_r;
    reg [5:0] sum;

    integer i;

    always@(*) begin
        
        m_out_w    = m_out;
        o_finish_w = o_finish;
        for(i=0; i<TOTAL; i=i+1) begin
            x_w[i] = x_r[i];
        end

        state_w = state_r;
        cnt_w   = cnt_r;

        case(state_r)
            IDLE: begin
                o_finish_w = 1'b0;
                if (i_start) begin
                    for (i=0; i<TOTAL; i=i+1) begin
                        x_w[i] = x_in[(i+1)*BITS-1 -: BITS];
                    end

                    state_w = RUN1;
                    cnt_w = 3'b0;
                    m_out_w = 8'b0;
                end else begin
                    state_w = IDLE;
                    cnt_w = cnt_r;
                end
            end
            ////
            RUN1: begin
                cnt_w = cnt_r + 1'b1;
                sum = x_r[0][BITS-1] + x_r[1][BITS-1] + x_r[2][BITS-1] + x_r[3][BITS-1] + x_r[4][BITS-1] +
                      x_r[5][BITS-1] + x_r[6][BITS-1] + x_r[7][BITS-1] + x_r[8][BITS-1] + x_r[9][BITS-1] +
                      x_r[10][BITS-1] + x_r[11][BITS-1] + x_r[12][BITS-1] + x_r[13][BITS-1] + x_r[14][BITS-1] +
                      x_r[15][BITS-1] + x_r[16][BITS-1] + x_r[17][BITS-1] + x_r[18][BITS-1] + x_r[19][BITS-1] +
                      x_r[20][BITS-1] + x_r[21][BITS-1] + x_r[22][BITS-1] + x_r[23][BITS-1] + x_r[24][BITS-1] +
                      x_r[25][BITS-1] + x_r[26][BITS-1] + x_r[27][BITS-1] + x_r[28][BITS-1] + x_r[29][BITS-1] +
                      x_r[30][BITS-1] + x_r[31][BITS-1] + x_r[32][BITS-1] + x_r[33][BITS-1] + x_r[34][BITS-1] +
                      x_r[35][BITS-1] + x_r[36][BITS-1] + x_r[37][BITS-1] + x_r[38][BITS-1] + x_r[39][BITS-1] +
                      x_r[40][BITS-1] + x_r[41][BITS-1] + x_r[42][BITS-1] + x_r[43][BITS-1] + x_r[44][BITS-1] +
                      x_r[45][BITS-1] + x_r[46][BITS-1] + x_r[47][BITS-1] + x_r[48][BITS-1];

                if (sum > THRESHOLD) begin
                    m_out_w = {m_out[6:0], 1'b1};
                    for(i=0; i<TOTAL; i=i+1) begin
                        if (x_r[i][7] == 1'b0) begin
                            x_w[i] = 8'd0;
                        end else begin
                            x_w[i] = {x_r[i][6:0], x_r[i][7]};
                        end
                    end
                end else begin
                    m_out_w = {m_out[6:0], 1'b0};
                    for(i=0; i<TOTAL; i=i+1) begin
                        if (x_r[i][7] == 1'b1) begin
                            x_w[i] = 8'd255;
                        end else begin
                            x_w[i] = {x_r[i][6:0], x_r[i][7]};
                        end
                    end
                end

                if (cnt_r == 3'd7) begin
                    state_w = IDLE;
                    o_finish_w = 1'b1;
                end else begin
                    state_w = RUN1;
                end
            end
            ////
        endcase
    end

    always@(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<TOTAL; i=i+1) begin
                x_r[i] <= 8'b0;
            end
            m_out    <= 8'b0;
            o_finish <= 1'b0;
            state_r  <= IDLE;
            cnt_r <= 3'b0;

        end else begin
            for (i=0; i<TOTAL; i=i+1) begin
                x_r[i] <= x_w[i];
            end
            m_out    <= m_out_w;
            o_finish <= o_finish_w;
            state_r  <= state_w;
            cnt_r <= cnt_w;

        end
    end

endmodule


module LMFE ( clk, reset, Din, in_en, busy, out_valid, Dout);

    localparam TOTAL = 49;
    localparam BITS = 8;

    localparam IDLE = 0;
    localparam READ = 1;
    localparam PREPARE = 2;
    localparam INITIAL = 3;
    localparam COMPUTE = 4;
    localparam REMAINS = 5;
    localparam ROW = 128;

    input   clk;
    input   reset;
    input   in_en;
    output  busy;
    output  out_valid;
    input   [7:0]  Din;
    output  [7:0]  Dout;

    // Memory-related signals & I/O buffers
    reg [7:0] D0_w, D1_w, D2_w, D3_w, D4_w, D5_w, D6_w, D7_w,
              D8_w, D9_w, D10_w, D11_w, D12_w, D13_w, D14_w, D15_w;

    reg [7:0] D0_r, D1_r, D2_r, D3_r, D4_r, D5_r, D6_r, D7_r,
              D8_r, D9_r, D10_r, D11_r, D12_r, D13_r, D14_r, D15_r; 

    wire [7:0] Q0_w, Q1_w, Q2_w, Q3_w, Q4_w, Q5_w, Q6_w, Q7_w,
               Q8_w, Q9_w, Q10_w, Q11_w, Q12_w, Q13_w, Q14_w, Q15_w;

    reg [9:0] A0_w, A1_w, A2_w, A3_w, A4_w, A5_w, A6_w, A7_w,
              A8_w, A9_w, A10_w, A11_w, A12_w, A13_w, A14_w, A15_w;

    reg [9:0] A0_r, A1_r, A2_r, A3_r, A4_r, A5_r, A6_r, A7_r,
              A8_r, A9_r, A10_r, A11_r, A12_r, A13_r, A14_r, A15_r;

    reg CEN0_w, CEN1_w, CEN2_w, CEN3_w, CEN4_w, CEN5_w, CEN6_w, CEN7_w,
        CEN8_w, CEN9_w, CEN10_w, CEN11_w, CEN12_w, CEN13_w, CEN14_w, CEN15_w;

    reg CEN0_r, CEN1_r, CEN2_r, CEN3_r, CEN4_r, CEN5_r, CEN6_r, CEN7_r,
        CEN8_r, CEN9_r, CEN10_r, CEN11_r, CEN12_r, CEN13_r, CEN14_r, CEN15_r;

    reg WEN0_w, WEN1_w, WEN2_w, WEN3_w, WEN4_w, WEN5_w, WEN6_w, WEN7_w,
        WEN8_w, WEN9_w, WEN10_w, WEN11_w, WEN12_w, WEN13_w, WEN14_w, WEN15_w;

    reg WEN0_r, WEN1_r, WEN2_r, WEN3_r, WEN4_r, WEN5_r, WEN6_r, WEN7_r,
        WEN8_r, WEN9_r, WEN10_r, WEN11_r, WEN12_r, WEN13_r, WEN14_r, WEN15_r;

    // MEDIAN-related signals
    reg istart_w, istart_r;
    reg [6:0] x_w, x_r;
    reg [6:0] y_w, y_r;
    reg [TOTAL*BITS-1: 0] filter_w, filter_r;

    // Ctrl signals
    reg [2:0] state_w, state_r;  // FSM for read input data

    reg busy_w, busy_r;
    reg [13:0] cnt_w, cnt_r;
    assign busy = busy_r;

    MEDIAN my_median(.clk(clk), .reset(reset), .x_in(filter_r), .m_out(Dout), .o_finish(out_valid), .i_start(istart_r));
    sram_1024x8_t13 m0(.CLK(clk), .CEN(CEN0_r), .WEN(WEN0_r), .Q(Q0_w), .A(A0_r), .D(D0_r));
    sram_1024x8_t13 m1(.CLK(clk), .CEN(CEN1_r), .WEN(WEN1_r), .Q(Q1_w), .A(A1_r), .D(D1_r));
    sram_1024x8_t13 m2(.CLK(clk), .CEN(CEN2_r), .WEN(WEN2_r), .Q(Q2_w), .A(A2_r), .D(D2_r));
    sram_1024x8_t13 m3(.CLK(clk), .CEN(CEN3_r), .WEN(WEN3_r), .Q(Q3_w), .A(A3_r), .D(D3_r));
    sram_1024x8_t13 m4(.CLK(clk), .CEN(CEN4_r), .WEN(WEN4_r), .Q(Q4_w), .A(A4_r), .D(D4_r));
    sram_1024x8_t13 m5(.CLK(clk), .CEN(CEN5_r), .WEN(WEN5_r), .Q(Q5_w), .A(A5_r), .D(D5_r));
    sram_1024x8_t13 m6(.CLK(clk), .CEN(CEN6_r), .WEN(WEN6_r), .Q(Q6_w), .A(A6_r), .D(D6_r));
    sram_1024x8_t13 m7(.CLK(clk), .CEN(CEN7_r), .WEN(WEN7_r), .Q(Q7_w), .A(A7_r), .D(D7_r));
    sram_1024x8_t13 m8(.CLK(clk), .CEN(CEN8_r), .WEN(WEN8_r), .Q(Q8_w), .A(A8_r), .D(D8_r));
    sram_1024x8_t13 m9(.CLK(clk), .CEN(CEN9_r), .WEN(WEN9_r), .Q(Q9_w), .A(A9_r), .D(D9_r));
    sram_1024x8_t13 m10(.CLK(clk), .CEN(CEN10_r), .WEN(WEN10_r), .Q(Q10_w), .A(A10_r), .D(D10_r));
    sram_1024x8_t13 m11(.CLK(clk), .CEN(CEN11_r), .WEN(WEN11_r), .Q(Q11_w), .A(A11_r), .D(D11_r));
    sram_1024x8_t13 m12(.CLK(clk), .CEN(CEN12_r), .WEN(WEN12_r), .Q(Q12_w), .A(A12_r), .D(D12_r));
    sram_1024x8_t13 m13(.CLK(clk), .CEN(CEN13_r), .WEN(WEN13_r), .Q(Q13_w), .A(A13_r), .D(D13_r));
    sram_1024x8_t13 m14(.CLK(clk), .CEN(CEN14_r), .WEN(WEN14_r), .Q(Q14_w), .A(A14_r), .D(D14_r));
    sram_1024x8_t13 m15(.CLK(clk), .CEN(CEN15_r), .WEN(WEN15_r), .Q(Q15_w), .A(A15_r), .D(D15_r));


    always@(*) begin
        D0_w = D0_r; D1_w = D1_r; D2_w = D2_r; D3_w = D3_r; D4_w = D4_r;
        D5_w = D5_r; D6_w = D6_r; D7_w = D7_r; D8_w = D8_r; D9_w = D9_r;
        D10_w = D10_r; D11_w = D11_r; D12_w = D12_r; D13_w = D13_r; D14_w = D14_r; D15_w = D15_r;

        A0_w = A0_r; A1_w = A1_r; A2_w = A2_r; A3_w = A3_r; A4_w = A4_r;
        A5_w = A5_r; A6_w = A6_r; A7_w = A7_r; A8_w = A8_r; A9_w = A9_r;
        A10_w = A10_r; A11_w = A11_r; A12_w = A12_r; A13_w = A13_r; A14_w = A14_r; A15_w = A15_r;

        CEN0_w = CEN0_r; CEN1_w = CEN1_r; CEN2_w = CEN2_r; CEN3_w = CEN3_r;
        CEN4_w = CEN4_r; CEN5_w = CEN5_r; CEN6_w = CEN6_r; CEN7_w = CEN7_r;
        CEN8_w = CEN8_r; CEN9_w = CEN9_r; CEN10_w = CEN10_r; CEN11_w = CEN11_r;
        CEN12_w = CEN12_r; CEN13_w = CEN13_r; CEN14_w = CEN14_r; CEN15_w = CEN15_r;

        WEN0_w = WEN0_r; WEN1_w = WEN1_r; WEN2_w = WEN2_r; WEN3_w = WEN3_r;
        WEN4_w = WEN4_r; WEN5_w = WEN5_r; WEN6_w = WEN6_r; WEN7_w = WEN7_r;
        WEN8_w = WEN8_r; WEN9_w = WEN9_r; WEN10_w = WEN10_r; WEN11_w = WEN11_r;
        WEN12_w = WEN12_r; WEN13_w = WEN13_r; WEN14_w = WEN14_r; WEN15_w = WEN15_r;

        filter_w = filter_r;
        cnt_w = cnt_r;
        busy_w = busy_r;
        istart_w = istart_r;
        state_w = state_r;
        y_w = y_r;
        x_w = x_r;

        // Store input data
        case (state_r)
            IDLE: begin
                WEN0_w = 1'b1; WEN1_w = 1'b1; WEN2_w = 1'b1; WEN3_w = 1'b1;
                WEN4_w = 1'b1; WEN5_w = 1'b1; WEN6_w = 1'b1; WEN7_w = 1'b1;
                WEN8_w = 1'b1; WEN9_w = 1'b1; WEN10_w = 1'b1; WEN11_w = 1'b1;
                WEN12_w = 1'b1; WEN13_w = 1'b1; WEN14_w = 1'b1; WEN15_w = 1'b1;

                if (in_en) begin
                    A0_w = 10'b0; A1_w = 10'b0; A2_w = 10'b0; A3_w = 10'b0;
                    A4_w = 10'b0; A5_w = 10'b0; A6_w = 10'b0; A7_w = 10'b0;
                    A8_w = 10'b0; A9_w = 10'b0; A10_w = 10'b0; A11_w = 10'b0;
                    A12_w = 10'b0; A13_w = 10'b0; A14_w = 10'b0; A15_w = 10'b0;
                    D0_w = Din;
                    state_w = READ;
                    WEN0_w = 1'b0;
                end
            end
            READ: begin
                cnt_w = cnt_r + 1'b1;
                if (in_en && cnt_r < 14'd16383) begin
                    if (cnt_r[10:0] < 11'd128) begin
                        A0_w = A0_r + 1'b1;
                        if (cnt_r[10:0] == 11'd127) begin
                            WEN0_w = 1'b1; WEN1_w = 1'b0; D1_w = Din;
                        end else begin
                            D0_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd128) && (cnt_r[10:0] < 11'd256)) begin
                        A1_w = A1_r + 1'b1;
                        if (cnt_r[10:0] == 11'd255) begin
                            WEN1_w = 1'b1; WEN2_w = 1'b0; D2_w = Din;
                        end else begin
                            D1_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd256) && (cnt_r[10:0] < 11'd384)) begin
                        A2_w = A2_r + 1'b1;
                        D2_w = Din;
                        if (cnt_r[10:0] == 11'd383) begin
                            WEN2_w = 1'b1; WEN3_w = 1'b0; D3_w = Din;
                        end else begin
                            D2_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd384) && (cnt_r[10:0] < 11'd512)) begin
                        A3_w = A3_r + 1'b1;
                        if (cnt_r[10:0] == 11'd511) begin
                            WEN3_w = 1'b1; WEN4_w = 1'b0; D4_w = Din;
                        end else begin
                            D3_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd512) && (cnt_r[10:0] < 11'd640)) begin
                        A4_w = A4_r + 1'b1;
                        if (cnt_r[10:0] == 11'd639) begin
                            WEN4_w = 1'b1; WEN5_w = 1'b0; D5_w = Din;
                        end else begin
                            D4_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd640) && (cnt_r[10:0] < 11'd768)) begin
                        A5_w = A5_r + 1'b1;
                        if (cnt_r[10:0] == 11'd767) begin
                            WEN5_w = 1'b1; WEN6_w = 1'b0; D6_w = Din;
                        end else begin
                            D5_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd768) && (cnt_r[10:0] < 11'd896)) begin
                        A6_w = A6_r + 1'b1;
                        if (cnt_r[10:0] == 11'd895) begin
                            WEN6_w = 1'b1; WEN7_w = 1'b0; D7_w = Din;
                        end else begin
                            D6_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd896) && (cnt_r[10:0] < 11'd1024)) begin
                        A7_w = A7_r + 1'b1;
                        if (cnt_r[10:0] == 11'd1023) begin
                            WEN7_w = 1'b1; WEN8_w = 1'b0; D8_w = Din;
                        end else begin
                            D7_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd1024) && (cnt_r[10:0] < 11'd1152)) begin
                        A8_w = A8_r + 1'b1;
                        if (cnt_r[10:0] == 11'd1151) begin
                            WEN8_w = 1'b1; WEN9_w = 1'b0; D9_w = Din;
                        end else begin
                            D8_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd1152) && (cnt_r[10:0] < 11'd1280)) begin
                        A9_w = A9_r + 1'b1;
                        if (cnt_r[10:0] == 11'd1279) begin
                            WEN9_w = 1'b1; WEN10_w = 1'b0; D10_w = Din;
                        end else begin
                            D9_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd1280) && (cnt_r[10:0] < 11'd1408)) begin
                        A10_w = A10_r + 1'b1;
                        if (cnt_r[10:0] == 11'd1407) begin
                            WEN10_w = 1'b1; WEN11_w = 1'b0; D11_w = Din;
                        end else begin
                            D10_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd1408) && (cnt_r[10:0] < 11'd1536)) begin
                        A11_w = A11_r + 1'b1;
                        if (cnt_r[10:0] == 11'd1535) begin
                            WEN11_w = 1'b1; WEN12_w = 1'b0; D12_w = Din;
                        end else begin
                            D11_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd1536) && (cnt_r[10:0] < 11'd1664)) begin
                        A12_w = A12_r + 1'b1;
                        if (cnt_r[10:0] == 11'd1663) begin
                            WEN12_w = 1'b1; WEN13_w = 1'b0; D13_w = Din;
                        end else begin
                            D12_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd1664) && (cnt_r[10:0] < 11'd1792)) begin
                        A13_w = A13_r + 1'b1;
                        if (cnt_r[10:0] == 11'd1791) begin
                            WEN13_w = 1'b1; WEN14_w = 1'b0; D14_w = Din;
                        end else begin
                            D13_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd1792) && (cnt_r[10:0] < 11'd1920)) begin
                        A14_w = A14_r + 1'b1;
                        if (cnt_r[10:0] == 11'd1919) begin
                            WEN14_w = 1'b1; WEN15_w = 1'b0; D15_w = Din;
                        end else begin
                            D14_w = Din;
                        end
                    end
                    else if ((cnt_r[10:0] >= 11'd1920) && (cnt_r[10:0] < 12'd2048)) begin
                        A15_w = A15_r + 1'b1;
                        if (cnt_r[10:0] == 11'd2047) begin
                            WEN15_w = 1'b1; WEN0_w = 1'b0; D0_w = Din;
                        end else begin
                            D15_w = Din;
                        end
                    end else begin
                    end
                end else begin
                    state_w = PREPARE;
                    WEN0_w = 1'b1; WEN1_w = 1'b1; WEN2_w = 1'b1; WEN3_w = 1'b1;
                    WEN4_w = 1'b1; WEN5_w = 1'b1; WEN6_w = 1'b1; WEN7_w = 1'b1;
                    WEN8_w = 1'b1; WEN9_w = 1'b1; WEN10_w = 1'b1; WEN11_w = 1'b1;
                    WEN12_w = 1'b1; WEN13_w = 1'b1; WEN14_w = 1'b1; WEN15_w = 1'b1;
                end
            end
            ///
            PREPARE: begin
                cnt_w = 14'd0;
                x_w = 7'b0;
                case(y_r[3:0])
                    4'd0: begin
                        if (y_r == 7'd0) begin
                            state_w = INITIAL;
                            A0_w = 10'b0; A1_w = 10'b0; A2_w = 10'b0; A3_w = 10'b0;
                        end else begin
                            state_w = INITIAL;
                            A13_w = ROW*(y_r[6:4]-1'b1); A14_w = A13_w; A15_w = A13_w;
                            A0_w = ROW*y_r[6:4]; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                        end
                    end
                    4'd1: begin
                        if (y_r == 7'd1) begin
                            state_w = INITIAL;
                            A0_w = 10'b0; A1_w = 10'b0; A2_w = 10'b0; A3_w = 10'b0;
                            A4_w = 10'b0;
                        end else begin
                            state_w = INITIAL;
                            A14_w = ROW*(y_r[6:4]-1'b1); A15_w = A14_w;
                            A0_w = ROW*y_r[6:4]; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            A4_w = A0_w;
                        end
                    end
                    4'd2: begin
                        if (y_r == 7'd2) begin
                            state_w = INITIAL;
                            A0_w = 10'b0; A1_w = 10'b0; A2_w = 10'b0; A3_w = 10'b0;
                            A4_w = 10'b0; A5_w = 10'b0;
                        end else begin
                            state_w = INITIAL;
                            A15_w = ROW*(y_r[6:4]-1'b1);
                            A0_w = ROW*y_r[6:4]; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            A4_w = A0_w; A5_w = A0_w;
                        end
                    end
                    4'd3: begin
                        state_w = INITIAL;
                        A0_w = ROW*y_r[6:4]; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                        A4_w = A0_w; A5_w = A0_w; A6_w = A0_w;
                    end
                    4'd4: begin
                        state_w = INITIAL;
                        A1_w = ROW*y_r[6:4]; A2_w = A1_w; A3_w = A1_w; A4_w = A1_w;
                        A5_w = A1_w; A6_w = A1_w; A7_w = A1_w;
                    end
                    4'd5: begin
                        state_w = INITIAL;
                        A2_w = ROW*y_r[6:4]; A3_w = A2_w; A4_w = A2_w; A5_w = A2_w;
                        A6_w = A2_w; A7_w = A2_w; A8_w = A2_w;
                    end
                    4'd6: begin
                        state_w = INITIAL;
                        A3_w = ROW*y_r[6:4]; A4_w = A3_w; A5_w = A3_w; A6_w = A3_w;
                        A7_w = A3_w; A8_w = A3_w; A9_w = A3_w;
                    end
                    4'd7: begin
                        state_w = INITIAL;
                        A4_w = ROW*y_r[6:4]; A5_w = A4_w; A6_w = A4_w; A7_w = A4_w;
                        A8_w = A4_w; A9_w = A4_w; A10_w = A4_w;
                    end
                    4'd8: begin
                        state_w = INITIAL;
                        A5_w = ROW*y_r[6:4]; A6_w = A5_w; A7_w = A5_w; A8_w = A5_w;
                        A9_w = A5_w; A10_w = A5_w; A11_w = A5_w;
                    end
                    4'd9: begin
                        state_w = INITIAL;
                        A6_w = ROW*y_r[6:4]; A7_w = A6_w; A8_w = A6_w; A9_w = A6_w;
                        A10_w = A6_w; A11_w = A6_w; A12_w = A6_w;
                    end
                    4'd10: begin
                        state_w = INITIAL;
                        A7_w = ROW*y_r[6:4]; A8_w = A7_w; A9_w = A7_w; A10_w = A7_w;
                        A11_w = A7_w; A12_w = A7_w; A13_w = A7_w;
                    end
                    4'd11: begin
                        state_w = INITIAL;
                        A8_w = ROW*y_r[6:4]; A9_w = A8_w; A10_w = A8_w; A11_w = A8_w;
                        A12_w = A8_w; A13_w = A8_w; A14_w = A8_w;
                    end
                    4'd12: begin
                        state_w = INITIAL;
                        A9_w = ROW*y_r[6:4]; A10_w = A9_w; A11_w = A9_w; A12_w = A9_w;
                        A13_w = A9_w; A14_w = A9_w; A15_w = A9_w;
                    end
                    4'd13: begin
                        if (y_r == 7'd125) begin
                            state_w = INITIAL;
                            A10_w = ROW*y_r[6:4]; A11_w = A10_w; A12_w = A10_w; A13_w = A10_w;
                            A14_w = A10_w; A15_w = A10_w;
                        end else begin
                            state_w = INITIAL;
                            A10_w = ROW*y_r[6:4]; A11_w = A10_w; A12_w = A10_w; A13_w = A10_w;
                            A14_w = A10_w; A15_w = A10_w; A0_w = ROW*(y_r[6:4]+1'b1);
                        end
                    end
                    4'd14: begin
                        if (y_r == 7'd126) begin
                            state_w = INITIAL;
                            A11_w = ROW*y_r[6:4]; A12_w = A11_w; A13_w = A11_w; A14_w = A11_w;
                            A15_w = A11_w; 
                        end else begin
                            state_w = INITIAL;
                            A11_w = ROW*y_r[6:4]; A12_w = A11_w; A13_w = A11_w; A14_w = A11_w;
                            A15_w = A11_w; A0_w = ROW*(y_r[6:4]+1'b1); A1_w = A0_w;
                        end
                    end
                    4'd15: begin
                        if (y_r == 7'd127) begin
                            state_w = INITIAL;
                            A12_w = ROW*y_r[6:4]; A13_w = A12_w; A14_w = A12_w; A15_w = A12_w;
                        end else begin
                            state_w = INITIAL;
                            A12_w = ROW*y_r[6:4]; A13_w = A12_w; A14_w = A12_w; A15_w = A12_w;
                            A0_w = ROW*(y_r[6:4]+1'b1); A1_w = A0_w; A2_w = A0_w;
                        end
                    end
                endcase
            end
            ////
            INITIAL: begin
                if (cnt_r == 14'd4) begin
                    state_w = COMPUTE;
                    istart_w = 1'b1;
                    cnt_w = 14'd0;
                end else begin
                    state_w = INITIAL;
                    cnt_w = cnt_r + 1'b1;
                end
                case(y_r[3:0])
                    4'd0: begin
                        if (y_r == 7'd0) begin
                            A0_w = (cnt_r>14'd3)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q0_w, Q1_w, Q2_w, Q3_w, 24'b0};
                        end else begin
                            A13_w = (cnt_r>14'd3)? A13_r: A13_r + 1'b1; A14_w = A13_w; A15_w = A13_w;
                            A0_w = (cnt_r>14'd3)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q13_w, Q14_w, Q15_w, Q0_w, Q1_w, Q2_w, Q3_w};
                        end
                    end
                    4'd1: begin
                        if (y_r == 7'd1) begin
                            A0_w = (cnt_r>14'd3)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            A4_w = A0_w;
                            filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], 16'b0, Q0_w, Q1_w, Q2_w, Q3_w, Q4_w};
                        end else begin
                            A14_w = (cnt_r>14'd3)? A14_r: A14_r + 1'b1; A15_w = A14_w;
                            A0_w = (cnt_r>14'd3)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            A4_w = A0_w;
                            filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q14_w, Q15_w, Q0_w, Q1_w, Q2_w, Q3_w, Q4_w};
                        end
                    end
                    4'd2: begin
                        if (y_r == 7'd2) begin
                            A0_w = (cnt_r>14'd3)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            A4_w = A0_w; A5_w = A0_w;
                            filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], 8'b0, Q0_w, Q1_w, Q2_w, Q3_w, Q4_w, Q5_w};
                        end else begin
                            A15_w = (cnt_r>14'd3)? A15_r: A15_r + 1'b1;
                            A0_w = (cnt_r>14'd3)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            A4_w = A0_w; A5_w = A0_w;
                            filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q15_w, Q0_w, Q1_w, Q2_w, Q3_w, Q4_w, Q5_w};
                        end
                    end
                    4'd3: begin
                        A0_w = (cnt_r>14'd3)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                        A4_w = A0_w; A5_w = A0_w; A6_w = A0_w;
                        filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q0_w, Q1_w, Q2_w, Q3_w, Q4_w, Q5_w, Q6_w};
                    end
                    4'd4: begin
                        A1_w = (cnt_r>14'd3)? A1_r:A1_r + 1'b1; A2_w = A1_w; A3_w = A1_w; A4_w = A1_w;
                        A5_w = A1_w; A6_w = A1_w; A7_w = A1_w;
                        filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q1_w, Q2_w, Q3_w, Q4_w, Q5_w, Q6_w, Q7_w};
                    end
                    4'd5: begin
                        A2_w = (cnt_r>14'd3)? A2_r: A2_r + 1'b1; A3_w = A2_w; A4_w = A2_w; A5_w = A2_w;
                        A6_w = A2_w; A7_w = A2_w; A8_w = A2_w;
                        filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q2_w, Q3_w, Q4_w, Q5_w, Q6_w, Q7_w, Q8_w};
                    end
                    4'd6: begin
                        A3_w = (cnt_r>14'd3)? A3_r: A3_r + 1'b1; A4_w = A3_w; A5_w = A3_w; A6_w = A3_w;
                        A7_w = A3_w; A8_w = A3_w; A9_w = A3_w;
                        filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q3_w, Q4_w, Q5_w, Q6_w, Q7_w, Q8_w, Q9_w};
                    end
                    4'd7: begin
                        A4_w = (cnt_r>14'd3)? A4_r: A4_r + 1'b1; A5_w = A4_w; A6_w = A4_w; A7_w = A4_w;
                        A8_w = A4_w; A9_w = A4_w; A10_w = A4_w;
                        filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q4_w, Q5_w, Q6_w, Q7_w, Q8_w, Q9_w, Q10_w};
                    end
                    4'd8: begin
                        A5_w = (cnt_r>14'd3)? A5_r: A5_r + 1'b1; A6_w = A5_w; A7_w = A5_w; A8_w = A5_w;
                        A9_w = A5_w; A10_w = A5_w; A11_w = A5_w;
                        filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q5_w, Q6_w, Q7_w, Q8_w, Q9_w, Q10_w, Q11_w};
                    end
                    4'd9: begin
                        A6_w = (cnt_r>14'd3)? A6_r: A6_r + 1'b1; A7_w = A6_w; A8_w = A6_w; A9_w = A6_w;
                        A10_w = A6_w; A11_w = A6_w; A12_w = A6_w;
                        filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q6_w, Q7_w, Q8_w, Q9_w, Q10_w, Q11_w, Q12_w};
                    end
                    4'd10: begin
                        A7_w = (cnt_r>14'd3)? A7_r: A7_r + 1'b1; A8_w = A7_w; A9_w = A7_w; A10_w = A7_w;
                        A11_w = A7_w; A12_w = A7_w; A13_w = A7_w;
                        filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q7_w, Q8_w, Q9_w, Q10_w, Q11_w, Q12_w, Q13_w};
                    end
                    4'd11: begin
                        A8_w = (cnt_r>14'd3)? A8_r: A8_r + 1'b1; A9_w = A8_w; A10_w = A8_w; A11_w = A8_w;
                        A12_w = A8_w; A13_w = A8_w; A14_w = A8_w;
                        filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q8_w, Q9_w, Q10_w, Q11_w, Q12_w, Q13_w, Q14_w};
                    end
                    4'd12: begin
                        A9_w = (cnt_r>14'd3)? A9_r: A9_r + 1'b1; A10_w = A9_w; A11_w = A9_w; A12_w = A9_w;
                        A13_w = A9_w; A14_w = A9_w; A15_w = A9_w;
                        filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q9_w, Q10_w, Q11_w, Q12_w, Q13_w, Q14_w, Q15_w};
                    end
                    4'd13: begin
                        if (y_r == 7'd125) begin
                            A10_w = (cnt_r>14'd3)? A10_r: A10_r + 1'b1; A11_w = A10_w; A12_w = A10_w; A13_w = A10_w;
                            A14_w = A10_w; A15_w = A10_w;
                            filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], 8'b0, Q10_w, Q11_w, Q12_w, Q13_w, Q14_w, Q15_w};
                        end else begin
                            A10_w = (cnt_r>14'd3)? A10_r: A10_r + 1'b1; A11_w = A10_w; A12_w = A10_w; A13_w = A10_w;
                            A14_w = A10_w; A15_w = A10_w; A0_w = (cnt_r>14'd3)? A0_r: A0_r + 1'b1;
                            filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q10_w, Q11_w, Q12_w, Q13_w, Q14_w, Q15_w, Q0_w};
                        end
                    end
                    4'd14: begin
                        if (y_r == 7'd126) begin
                            A11_w = (cnt_r>14'd3)? A11_r:A11_r + 1'b1; A12_w = A11_w; A13_w = A11_w; A14_w = A11_w;
                            A15_w = A11_w; 
                            filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], 16'b0, Q11_w, Q12_w, Q13_w, Q14_w, Q15_w};
                        end else begin
                            A11_w = (cnt_r>14'd3)? A11_r: A11_r + 1'b1; A12_w = A11_w; A13_w = A11_w; A14_w = A11_w;
                            A15_w = A11_w; A0_w = (cnt_r>14'd3)? A0_r: A0_r + 1'b1; A1_w = A0_w;
                            filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q11_w, Q12_w, Q13_w, Q14_w, Q15_w, Q0_w, Q1_w};
                        end
                    end
                    4'd15: begin
                        if (y_r == 7'd127) begin
                            A12_w = (cnt_r>14'd3)? A12_r: A12_r + 1'b1; A13_w = A12_w; A14_w = A12_w; A15_w = A12_w;
                            filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], 24'b0, Q12_w, Q13_w, Q14_w, Q15_w};
                        end else begin
                            A12_w = (cnt_r>14'd3)? A12_r: A12_r + 1'b1; A13_w = A12_w; A14_w = A12_w; A15_w = A12_w;
                            A0_w = (cnt_r>14'd3)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w;
                            filter_w = (cnt_r==14'd0)? 392'b0:{filter_r[335:0], Q12_w, Q13_w, Q14_w, Q15_w, Q0_w, Q1_w, Q2_w};
                        end
                    end
                endcase
            end
            ////
            COMPUTE: begin
                istart_w = 1'b0;
                if (out_valid) begin
                    if (x_r == 7'd127) begin
                        x_w = 7'b0;
                        y_w = y_r + 1'b1;
                        state_w = PREPARE;
                        filter_w = 392'b0;
                    end else begin
                        state_w = REMAINS;
                        x_w = x_r + 1'b1;
                    end
                end else begin
                    state_w = COMPUTE;
                end
            end
            ////
            REMAINS: begin
                state_w = COMPUTE;
                istart_w = 1'b1;
                case(y_r[3:0])
                    4'd0: begin
                        if (y_r == 7'd0) begin
                            A0_w = (x_r>7'd124)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], 24'b0, Q0_w, Q1_w, Q2_w, Q3_w};
                        end else begin
                            A13_w = (x_r>7'd124)? A13_r: A13_r + 1'b1; A14_w = A13_w; A15_w = A13_w;
                            A0_w = A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q13_w, Q14_w, Q15_w, Q0_w, Q1_w, Q2_w, Q3_w};
                        end
                    end
                    4'd1: begin
                        if (y_r == 7'd1) begin
                            A0_w = (x_r>7'd124)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            A4_w = A0_w;
                            filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], 16'b0, Q0_w, Q1_w, Q2_w, Q3_w, Q4_w};
                        end else begin
                            A14_w = (x_r>7'd124)? A14_r: A14_r + 1'b1; A15_w = A14_w;
                            A0_w = (x_r>7'd124)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            A4_w = A0_w;
                            filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q14_w, Q15_w, Q0_w, Q1_w, Q2_w, Q3_w, Q4_w};
                        end
                    end
                    4'd2: begin
                        if (y_r == 7'd2) begin
                            A0_w = (x_r>7'd124)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            A4_w = A0_w; A5_w = A0_w;
                            filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], 8'b0, Q0_w, Q1_w, Q2_w, Q3_w, Q4_w, Q5_w};
                        end else begin
                            A15_w = (x_r>7'd124)? A15_r: A15_r + 1'b1;
                            A0_w = (x_r>7'd124)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                            A4_w = A0_w; A5_w = A0_w;
                            filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q15_w, Q0_w, Q1_w, Q2_w, Q3_w, Q4_w, Q5_w};
                        end
                    end
                    4'd3: begin
                        A0_w = (x_r>7'd124)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w; A3_w = A0_w;
                        A4_w = A0_w; A5_w = A0_w; A6_w = A0_w;
                        filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q0_w, Q1_w, Q2_w, Q3_w, Q4_w, Q5_w, Q6_w};
                    end
                    4'd4: begin
                        A1_w = (x_r>7'd124)? A1_r:A1_r + 1'b1; A2_w = A1_w; A3_w = A1_w; A4_w = A1_w;
                        A5_w = A1_w; A6_w = A1_w; A7_w = A1_w;
                        filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q1_w, Q2_w, Q3_w, Q4_w, Q5_w, Q6_w, Q7_w};
                    end
                    4'd5: begin
                        A2_w = (x_r>7'd124)? A2_r: A2_r + 1'b1; A3_w = A2_w; A4_w = A2_w; A5_w = A2_w;
                        A6_w = A2_w; A7_w = A2_w; A8_w = A2_w;
                        filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q2_w, Q3_w, Q4_w, Q5_w, Q6_w, Q7_w, Q8_w};
                    end
                    4'd6: begin
                        A3_w = (x_r>7'd124)? A3_r: A3_r + 1'b1; A4_w = A3_w; A5_w = A3_w; A6_w = A3_w;
                        A7_w = A3_w; A8_w = A3_w; A9_w = A3_w;
                        filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q3_w, Q4_w, Q5_w, Q6_w, Q7_w, Q8_w, Q9_w};
                    end
                    4'd7: begin
                        A4_w = (x_r>7'd124)? A4_r: A4_r + 1'b1; A5_w = A4_w; A6_w = A4_w; A7_w = A4_w;
                        A8_w = A4_w; A9_w = A4_w; A10_w = A4_w;
                        filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q4_w, Q5_w, Q6_w, Q7_w, Q8_w, Q9_w, Q10_w};
                    end
                    4'd8: begin
                        A5_w = (x_r>7'd124)? A5_r: A5_r + 1'b1; A6_w = A5_w; A7_w = A5_w; A8_w = A5_w;
                        A9_w = A5_w; A10_w = A5_w; A11_w = A5_w;
                        filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q5_w, Q6_w, Q7_w, Q8_w, Q9_w, Q10_w, Q11_w};
                    end
                    4'd9: begin
                        A6_w = (x_r>7'd124)? A6_r: A6_r + 1'b1; A7_w = A6_w; A8_w = A6_w; A9_w = A6_w;
                        A10_w = A6_w; A11_w = A6_w; A12_w = A6_w;
                        filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q6_w, Q7_w, Q8_w, Q9_w, Q10_w, Q11_w, Q12_w};
                    end
                    4'd10: begin
                        A7_w = (x_r>7'd124)? A7_r: A7_r + 1'b1; A8_w = A7_w; A9_w = A7_w; A10_w = A7_w;
                        A11_w = A7_w; A12_w = A7_w; A13_w = A7_w;
                        filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q7_w, Q8_w, Q9_w, Q10_w, Q11_w, Q12_w, Q13_w};
                    end
                    4'd11: begin
                        A8_w = (x_r>7'd124)? A8_r: A8_r + 1'b1; A9_w = A8_w; A10_w = A8_w; A11_w = A8_w;
                        A12_w = A8_w; A13_w = A8_w; A14_w = A8_w;
                        filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q8_w, Q9_w, Q10_w, Q11_w, Q12_w, Q13_w, Q14_w};
                    end
                    4'd12: begin
                        A9_w = (x_r>7'd124)? A9_r: A9_r + 1'b1; A10_w = A9_w; A11_w = A9_w; A12_w = A9_w;
                        A13_w = A9_w; A14_w = A9_w; A15_w = A9_w;
                        filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q9_w, Q10_w, Q11_w, Q12_w, Q13_w, Q14_w, Q15_w};
                    end
                    4'd13: begin
                        if (y_r == 7'd125) begin
                            A10_w = (x_r>7'd124)? A10_r: A10_r + 1'b1; A11_w = A10_w; A12_w = A10_w; A13_w = A10_w;
                            A14_w = A10_w; A15_w = A10_w;
                            filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], 8'b0,Q10_w, Q11_w, Q12_w, Q13_w, Q14_w, Q15_w};
                        end else begin
                            A10_w = (x_r>7'd124)? A10_r: A10_r + 1'b1; A11_w = A10_w; A12_w = A10_w; A13_w = A10_w;
                            A14_w = A10_w; A15_w = A10_w; A0_w = A0_r + 1'b1;
                            filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q10_w, Q11_w, Q12_w, Q13_w, Q14_w, Q15_w, Q0_w};
                        end
                    end
                    4'd14: begin
                        if (y_r == 7'd126) begin
                            A11_w = (x_r>7'd124)? A11_r: A11_r + 1'b1; A12_w = A11_w; A13_w = A11_w; A14_w = A11_w;
                            A15_w = A11_w; 
                            filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q11_w, Q12_w, Q13_w, Q14_w, Q15_w, 16'b0};
                        end else begin
                            A11_w = (x_r>7'd124)? A11_r: A11_r + 1'b1; A12_w = A11_w; A13_w = A11_w; A14_w = A11_w;
                            A15_w = A11_w; A0_w = (x_r>7'd124)? A0_r:A0_r + 1'b1; A1_w = A0_w;
                            filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q11_w, Q12_w, Q13_w, Q14_w, Q15_w, Q0_w, Q1_w};
                        end
                    end
                    4'd15: begin
                        if (y_r == 7'd127) begin
                            A12_w = (x_r>7'd124)? A12_r: A12_r + 1'b1; A13_w = A12_w; A14_w = A12_w; A15_w = A12_w;
                            filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q12_w, Q13_w, Q14_w, Q15_w, 24'b0};
                        end else begin
                            A12_w = (x_r>7'd124)? A12_r: A12_r + 1'b1; A13_w = A12_w; A14_w = A12_w; A15_w = A12_w;
                            A0_w = (x_r>7'd124)? A0_r: A0_r + 1'b1; A1_w = A0_w; A2_w = A0_w;
                            filter_w = (x_r>7'd124)? {filter_r[335:0], 56'b0}:{filter_r[335:0], Q12_w, Q13_w, Q14_w, Q15_w, Q0_w, Q1_w, Q2_w};
                        end
                    end
                endcase
            end
        endcase
    end

    always@(posedge clk or posedge reset) begin
        if (reset) begin
            D0_r <= 8'b0; D1_r <= 8'b0; D2_r <= 8'b0; D3_r <= 8'b0; D4_r <= 8'b0;
            D5_r <= 8'b0; D6_r <= 8'b0; D7_r <= 8'b0; D8_r <= 8'b0; D9_r <= 8'b0;
            D10_r <= 8'b0; D11_r <= 8'b0; D12_r <= 8'b0; D13_r <= 8'b0; D14_r <= 8'b0; D15_r <= 8'b0;

            A0_r <= 10'b0; A1_r <= 10'b0; A2_r <= 10'b0; A3_r <= 10'b0; A4_r <= 10'b0;
            A5_r <= 10'b0; A6_r <= 10'b0; A7_r <= 10'b0; A8_r <= 10'b0; A9_r <= 10'b0;
            A10_r <= 10'b0; A11_r <= 10'b0; A12_r <= 10'b0; A13_r <= 10'b0; A14_r <= 10'b0; A15_r <= 10'b0;

            CEN0_r <= 1'b0; CEN1_r <= 1'b0; CEN2_r <= 1'b0; CEN3_r <= 1'b0;
            CEN4_r <= 1'b0; CEN5_r <= 1'b0; CEN6_r <= 1'b0; CEN7_r <= 1'b0;
            CEN8_r <= 1'b0; CEN9_r <= 1'b0; CEN10_r <= 1'b0; CEN11_r <= 1'b0;
            CEN12_r <= 1'b0; CEN13_r <= 1'b0; CEN14_r <= 1'b0; CEN15_r <= 1'b0;

            WEN0_r <= 1'b1; WEN1_r <= 1'b1; WEN2_r <= 1'b1; WEN3_r <= 1'b1;
            WEN4_r <= 1'b1; WEN5_r <= 1'b1; WEN6_r <= 1'b1; WEN7_r <= 1'b1;
            WEN8_r <= 1'b1; WEN9_r <= 1'b1; WEN10_r <= 1'b1; WEN11_r <= 1'b1;
            WEN12_r <= 1'b1; WEN13_r <= 1'b1; WEN14_r <= 1'b1; WEN15_r <= 1'b1;

            filter_r <= 392'b0;
            cnt_r <= 14'b0;
            busy_r <= 1'b0;
            state_r <= IDLE;
            istart_r <= 1'b0;
            x_r <= 7'b0;
            y_r <= 7'b0;

        end else begin
            D0_r <= D0_w; D1_r <= D1_w; D2_r <= D2_w; D3_r <= D3_w; D4_r <= D4_w;
            D5_r <= D5_w; D6_r <= D6_w; D7_r <= D7_w; D8_r <= D8_w; D9_r <= D9_w;
            D10_r <= D10_w; D11_r <= D11_w; D12_r <= D12_w; D13_r <= D13_w; D14_r <= D14_w; D15_r <= D15_w;

            A0_r <= A0_w; A1_r <= A1_w; A2_r <= A2_w; A3_r <= A3_w; A4_r <= A4_w;
            A5_r <= A5_w; A6_r <= A6_w; A7_r <= A7_w; A8_r <= A8_w; A9_r <= A9_w;
            A10_r <= A10_w; A11_r <= A11_w; A12_r <= A12_w; A13_r <= A13_w; A14_r <= A14_w; A15_r <= A15_w;

            CEN0_r <= CEN0_w; CEN1_r <= CEN1_w; CEN2_r <= CEN2_w; CEN3_r <= CEN3_w;
            CEN4_r <= CEN4_w; CEN5_r <= CEN5_w; CEN6_r <= CEN6_w; CEN7_r <= CEN7_w;
            CEN8_r <= CEN8_w; CEN9_r <= CEN9_w; CEN10_r <= CEN10_w; CEN11_r <= CEN11_w;
            CEN12_r <= CEN12_w; CEN13_r <= CEN13_w; CEN14_r <= CEN14_w; CEN15_r <= CEN15_w;

            WEN0_r <= WEN0_w; WEN1_r <= WEN1_w; WEN2_r <= WEN2_w; WEN3_r <= WEN3_w;
            WEN4_r <= WEN4_w; WEN5_r <= WEN5_w; WEN6_r <= WEN6_w; WEN7_r <= WEN7_w;
            WEN8_r <= WEN8_w; WEN9_r <= WEN9_w; WEN10_r <= WEN10_w; WEN11_r <= WEN11_w;
            WEN12_r <= WEN12_w; WEN13_r <= WEN13_w; WEN14_r <= WEN14_w; WEN15_r <= WEN15_w;

            filter_r <= filter_w;
            cnt_r <= cnt_w;
            busy_r <= busy_w;
            state_r <= state_w;
            istart_r <= istart_w;
            x_r <= x_w;
            y_r <= y_w;
        end
    end

endmodule

