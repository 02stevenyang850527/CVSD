module MEDIAN(i_start, x_in, m_out, o_finish, clk, reset);

    localparam TOTAL = 49;
    localparam PRECISION = 8;
    localparam IDLE = 0;
    localparam RUN1 = 1;
    localparam RUN2 = 2;
    
    input          clk, reset, i_start;
    input [TOTAL*PRECISION-1:0] x_in;
    output reg              o_finish;
    output reg [PRECISION-1:0] m_out;

    // I/O Signals
    reg [TOTAL*PRECISION-1:0] x_w, x_r;
    reg [PRECISION-1:0]        m_out_w;
    reg                     o_finish_w;

    // Ctrl Signals & Cache
    reg [1:0] state_w, state_r;
    reg [5:0]     cnt_w, cnt_r;

    // Results of Comparison
    reg [TOTAL-2:0] s_w, s_r;  // smaller than other or not 
    reg [TOTAL-2:0] e_w, e_r;  // equal to other or not
    reg [5:0] sum_s;
    reg [5:0] sum_e;

    integer i;

    always@(*) begin
        x_w        = x_r;
        m_out_w    = m_out;
        o_finish_w = o_finish;

        state_w = state_r;
        cnt_w   = cnt_r;
        s_w = x_r;
        e_w = e_r;

        case(state_r)
            IDLE: begin
                o_finish_w = 1'b0;
                if (i_start) begin
                    x_w = x_in;
                    state_w = RUN1;
                    cnt_w = 6'b0;
                    s_w = 48'b0;
                    e_w = 48'b0;
                end else begin
                    x_w = x_r;
                    state_w = IDLE;
                    cnt_w = cnt_r;
                    s_w = s_r;
                    e_w = e_r;
                end
            end
            ////
            RUN1: begin
                for(i=0; i < TOTAL-1; i=i+1) begin
                    s_w[i] = (x_r[PRECISION-1:0]  < x_r[(i+2)*PRECISION-1 -: PRECISION])? 1'b1:1'b0;
                    e_w[i] = (x_r[PRECISION-1:0] == x_r[(i+2)*PRECISION-1 -: PRECISION])? 1'b1:1'b0;
                end
                state_w = RUN2;
            end
            RUN2: begin
                cnt_w = cnt_r + 1'b1;
                x_w = {x_r[PRECISION-1:0], x_r[TOTAL*PRECISION-1: PRECISION]};
                sum_s = s_r[0] + s_r[1] + s_r[2] + s_r[3] + s_r[4] + s_r[5] + s_r[6] +
                        s_r[7] + s_r[8] + s_r[9] +s_r[10] +s_r[11] +s_r[12] +s_r[13] +
                        s_r[14]+s_r[15] +s_r[16] +s_r[17] +s_r[18] +s_r[19] +s_r[20] +
                        s_r[21]+s_r[22] +s_r[23] +s_r[24] +s_r[25] +s_r[26] +s_r[27] +
                        s_r[28]+s_r[29] +s_r[30] +s_r[31] +s_r[32] +s_r[33] +s_r[34] +
                        s_r[35]+s_r[36] +s_r[37] +s_r[38] +s_r[39] +s_r[40] +s_r[41] +
                        s_r[42]+s_r[43] +s_r[44] +s_r[45] +s_r[46] +s_r[47];

                sum_e = e_r[0] + e_r[1] + e_r[2] + e_r[3] + e_r[4] + e_r[5] + e_r[6] +
                        e_r[7] + e_r[8] + e_r[9] +e_r[10] +e_r[11] +e_r[12] +e_r[13] +
                        e_r[14]+e_r[15] +e_r[16] +e_r[17] +e_r[18] +e_r[19] +e_r[20] +
                        e_r[21]+e_r[22] +e_r[23] +e_r[24] +e_r[25] +e_r[26] +e_r[27] +
                        e_r[28]+e_r[29] +e_r[30] +e_r[31] +e_r[32] +e_r[33] +e_r[34] +
                        e_r[35]+e_r[36] +e_r[37] +e_r[38] +e_r[39] +e_r[40] +e_r[41] +
                        e_r[42]+e_r[43] +e_r[44] +e_r[45] +e_r[46] +e_r[47] + 1'b1;
                if ((6'd25 > sum_s) && (sum_s + sum_e >= 6'd25)) begin
                    o_finish_w = 1'b1;
                    state_w = IDLE;
                    m_out_w = x_r[PRECISION-1:0];
                end else begin
                    if (cnt_r == 6'd48) begin
                        state_w = IDLE;
                        o_finish_w = 1'b1;
                        m_out_w = 8'b0;
                    end else begin
                        state_w = RUN1;
                    end
                    s_w = 48'b0;
                    e_w = 48'b0;
                end
            end
        endcase
    end

    always@(posedge clk or negedge reset) begin
        if (reset) begin
            x_r      <= 392'b0;
            m_out    <= 8'b0;
            o_finish <= 1'b0;
            state_r  <= IDLE;

            cnt_r <= 6'b0;
            s_r   <= 48'b0;
            e_r   <= 48'b0;

        end else begin
            x_r      <= x_w;
            m_out    <= m_out_w;
            o_finish <= o_finish_w;
            state_r  <= state_w;

            cnt_r <= cnt_w;
            s_r   <= s_w;
            e_r   <= e_w;

        end
    end

endmodule

