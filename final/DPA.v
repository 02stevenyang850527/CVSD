
module DPA (clk,reset,IM_A, IM_Q,IM_D,IM_WEN,CR_A,CR_Q);
    input clk;
    input reset;
    output [19:0] IM_A;
    input [23:0] IM_Q;
    output [23:0] IM_D;
    output IM_WEN;      // low for write data
    output [8:0] CR_A;
    input [12:0] CR_Q;

    localparam INIT = 0;        // Get initial time, address of frame buffer, photo number
    localparam READ_HD = 1;     // Get address and size of the photo 
    localparam TRAN = 2;        // Transition
    localparam UPDATE_CLK = 3;  // Update CLK
    localparam WAIT = 4;
    localparam DUMMY = 5;       // dummy stage

    localparam HALF_TRAN = 32768; // 128*256
    localparam BASE_ADDR = 3;  // Beginning of the photo information
    localparam COLON = 10;
    localparam ROW_NUM = 24;

    localparam CLK_BASE_ADDR = 59544; // 256*232 + 152

    reg IM_WEN_w, IM_WEN_r;
    reg e_sec_w, e_sec_r;               // At even second, time should be add 1 second in advance.
    reg [2:0]  state_w, state_r;
    reg [2:0]  s_cnt_r, s_cnt_w;        // small count
    reg [15:0] b_cnt_r, b_cnt_w;        // big count, b_cnt_r = 40000 => 0.2 sec passed.
    reg [2:0]  cnt5_r, cnt5_w;          // if cnt5_r == 5 => 1 sec passed
    reg [19:0] addr_r, addr_w;          // I/O address
    reg [8:0]  ch_addr_r, ch_addr_w;    // Char I/O
    reg [23:0] time_w, time_r;          // Display time
    reg [19:0] FB_addr_w, FB_addr_r;
    reg [2:0]  p_num_w, p_num_r;        // photo number
    reg [19:0] p_addr_w, p_addr_r;      // current photo address
    reg [1:0]  p_size_w, p_size_r;      // current photo size
    reg [1:0]  photo_id_w, photo_id_r;  // current photo id
    reg [11:0] bitmap_w, bitmap_r;      // Buffer for input row of bit map
    reg [2:0]  char_cnt_w, char_cnt_r;  // count for 8 characters => hh:mm:ss
    reg [3:0]  bit_cnt_w, bit_cnt_r;    // count for 13 output pixel
    reg [4:0]  row_cnt_w, row_cnt_r;    // count for 24 rows of bit map for 1 character

    reg [15:0] output_id_w, output_id_r;        // output index for frame buffer

    // buffer (2 additional bits to prevent overflow)
    reg [9:0] red_w, red_r;
    reg [9:0] green_w, green_r;
    reg [9:0] blue_w, blue_r;

    reg [3:0] char_sel;
    reg  first_w, first_r;    // first phtot or not

    // Address offset
    wire [15:0] addr_128_0, addr_128_1, addr_128_2, addr_128_3;
    wire [17:0] addr_512_0, addr_512_1, addr_512_2, addr_512_3;
    wire [6:0]  row_128, col_128;               // edge detection for 128x128 image
    wire [3:0]  hr1, hr0, min1, min0, sec1, sec0;

    assign sec1 = (time_r[7:0]< 8'd10)? 0:
                  (time_r[7:0]< 8'd20)? 1:
                  (time_r[7:0]< 8'd30)? 2:
                  (time_r[7:0]< 8'd40)? 3:
                  (time_r[7:0]< 8'd50)? 4:
                  (time_r[7:0]< 8'd60)? 5: 6; // 6 is used to detect error;
    assign sec0 = time_r[7:0] - 10*sec1;

    assign min1 = (time_r[15:8]< 8'd10)? 0:
                  (time_r[15:8]< 8'd20)? 1:
                  (time_r[15:8]< 8'd30)? 2:
                  (time_r[15:8]< 8'd40)? 3:
                  (time_r[15:8]< 8'd50)? 4:
                  (time_r[15:8]< 8'd60)? 5: 6; // 6 is used to detect error;
    assign min0 = time_r[15:8] - 10*min1;

    assign hr1 = (time_r[23:16]< 8'd10)? 0:
                 (time_r[23:16]< 8'd20)? 1:
                 (time_r[23:16]< 8'd30)? 2: 3; // 3 is used to detect error;
    assign hr0 = time_r[23:16] - 10*hr1;

    // Address offset for photo size = 128x128
    assign row_128 = (b_cnt_r[14:8]==7'd127)? b_cnt_r[14:8]: b_cnt_r[14:8] + 1'b1;
    assign col_128 = (b_cnt_r[6:0]==7'd127)? b_cnt_r[6:0]: b_cnt_r[6:0] + 1'b1;

    assign addr_128_0 = {b_cnt_r[14:8], b_cnt_r[6:0]};  // left  & up
    assign addr_128_1 = {b_cnt_r[14:8], col_128};       // right & up
    assign addr_128_2 = {row_128, b_cnt_r[6:0]};        // left  & down
    assign addr_128_3 = {row_128, col_128};             // right & down

    // Adress offset for photo size = 512x512
    assign addr_512_0 = {output_id_r[15:8], 1'b0, output_id_r[7:0], 1'b0};
    assign addr_512_1 = {output_id_r[15:8], 1'b0, output_id_r[7:0], 1'b1};
    assign addr_512_2 = {output_id_r[15:8], 1'b1, output_id_r[7:0], 1'b0};
    assign addr_512_3 = {output_id_r[15:8], 1'b1, output_id_r[7:0], 1'b1};

    assign IM_A = addr_r;
    assign CR_A = ch_addr_r;
    assign IM_D = (IM_WEN_r)? 24'b0: {red_r[9:2], green_r[9:2], blue_r[9:2]};
    assign IM_WEN = IM_WEN_r;

    always@(*) begin
        state_w = state_r;
        addr_w = addr_r;
        time_w = time_r;
        ch_addr_w = ch_addr_r;
        FB_addr_w = FB_addr_r;
        p_num_w = p_num_r;
        p_addr_w = p_addr_r;
        p_size_w = p_size_r;
        IM_WEN_w = IM_WEN_r;
        red_w = red_r;
        green_w = green_r;
        blue_w = blue_r;
        photo_id_w = photo_id_r;
        e_sec_w = e_sec_r;
        bitmap_w = bitmap_r;
        char_cnt_w = char_cnt_r;
        bit_cnt_w = bit_cnt_r;
        row_cnt_w = row_cnt_r;
        first_w = first_r;
        char_sel = 4'b0;

        // Update output_id
        // check if it is in 0.2 sec ==>
        // check if it is odd row
        if (state_r == UPDATE_CLK || state_r == WAIT) begin
            output_id_w = output_id_r;
        end else begin
            if (cnt5_r==3'd0) begin
                output_id_w = (b_cnt_r[7])? {b_cnt_r[14:0], 1'b0} : {b_cnt_r[14:0], 1'b1};
            end else begin
                output_id_w = (b_cnt_r[7])? {b_cnt_r[14:0], 1'b1} : {b_cnt_r[14:0], 1'b0};
            end
        end

        // Update s_cnt && b_cnt
        if (s_cnt_r < 3'd5) begin
            s_cnt_w = s_cnt_r + 1'b1;
            b_cnt_w = b_cnt_r;
        end else begin
            s_cnt_w = 3'd1;
            b_cnt_w = (b_cnt_r == 16'd39999)? 16'd0: b_cnt_r + 1'b1;
        end

        // Update cnt5
        if (b_cnt_r == 16'd39999 && s_cnt_r==3'd5) begin
            cnt5_w = (cnt5_r == 3'd4)? 3'd0: cnt5_r + 1'b1;
        end else begin
            cnt5_w = cnt5_r;
        end
        
        // Update time:
        // 1. If it is in even second, update clk in advance, excluding the
        // first displayed photo
        // (s_cnt_r==3'd1; b_cnt_r==16'd0; cnt5_r == 3'd4)
        // 2. If it is in odd second, update clk on time
        // (s_cnt_r==3'd1; b_cnt_r==16'd39999; cnt5_r == 3'd4)

        if (~first_r && s_cnt_r==3'd1 && ((e_sec_r && b_cnt_r==16'd0 && cnt5_r==3'd0) || (e_sec_r && b_cnt_r==16'd39999 && cnt5_r==3'd4))) begin
            if (time_r[7:0] == 8'd59) begin             // Check sec
                time_w[7:0] = 8'd0;
                if (time_r[15:8] == 8'd59) begin        // Check min
                    time_w[15:8] = 8'd0;
                    if (time_r[23:16] == 8'd23) begin   // Checl hour
                        time_w[23:16] = 8'd0;
                    end else begin
                        time_w[23:16] = time_r[23:16] + 1'b1;
                    end
                end else begin
                    time_w[15:8] = time_r[15:8] + 1'b1;
                end
            end else begin
                time_w[7:0] = time_r[7:0] + 1'b1;
            end
        end else begin
            time_w = time_r;
        end

        // Update "it is even second or not"
        if (cnt5_r == 3'd4 && b_cnt_r==16'd39999 && s_cnt_r==3'd5) begin
            e_sec_w = ~e_sec_r;
        end else begin
            e_sec_w = e_sec_r;
        end

        case(state_r)
            INIT: begin
                addr_w = addr_r + 1'b1;
                case(s_cnt_r)
                    3'd1: time_w = IM_Q;
                    3'd2: FB_addr_w = IM_Q[19:0];
                    3'd3: begin
                        p_num_w = IM_Q[2:0];
                        state_w = READ_HD;
                    end
                    default: begin
                    end
                endcase
            end
            ////
            READ_HD: begin
                if (s_cnt_r >= 3'd4) begin
                    if (!addr_r[0]) begin // s_cnt_r = 3'd4
                        addr_w = addr_r + 1'b1;
                        p_addr_w = IM_Q[19:0];
                    end else begin       // s_cnt_r = 3'd5
                        if (IM_Q[7]) begin
                            p_size_w = 2'b01; // size: 128x128
                            addr_w = p_addr_r;
                            state_w = DUMMY;
                        end else if (IM_Q[8]) begin
                            p_size_w = 2'b10; // size: 256x256
                            addr_w = p_addr_r + 1'b1;
                            state_w = TRAN;
                        end else if (IM_Q[9]) begin
                            p_size_w = 2'b11; // size: 512x512
                            addr_w = p_addr_r + 2'd2;
                            state_w = DUMMY;
                        end
                    end
                end else begin
                    if (s_cnt_r==3'd3) begin
                        addr_w = addr_r + 1'b1;
                    end
                    state_w = state_r;
                end
            end
            ////
            TRAN: begin // At the beginning, b_cnt_r = 0
                if (b_cnt_r < HALF_TRAN) begin
                    if (output_id_r[7:0] < 8'd152 || output_id_r[15:8] < 8'd232) begin
                        case(p_size_r)
                            2'b01: begin  // 128x128
                                case(s_cnt_r)
                                    3'd1: begin  // output_stage & b_cnt_r change
                                        red_w = IM_Q[23:16];
                                        green_w = IM_Q[15:8];
                                        blue_w = IM_Q[7:0];
                                        IM_WEN_w = 1'b1;
                                        if (b_cnt_r[6:0]==7'd0 && b_cnt_r[15:7]!=9'd0) begin
                                            if (cnt5_r==3'd0) begin
                                                addr_w = (output_id_r[8])? // odd row
                                                         p_addr_r + addr_128_1:
                                                         p_addr_r + addr_128_0;
                                            end else begin
                                                addr_w = (output_id_r[8])? // odd row
                                                         p_addr_r + addr_128_0:
                                                         p_addr_r + addr_128_1;
                                            end
                                        end else begin
                                            if (output_id_r[0]) begin  // odd column
                                                addr_w =  p_addr_r + addr_128_1;
                                            end else begin
                                                addr_w =  p_addr_r + addr_128_0;
                                            end
                                        end
                                    end
                                    3'd2: begin // output_id_r change
                                        if (b_cnt_r ==16'b0) begin
                                            red_w = IM_Q[23:16];                                                                                        
                                            green_w = IM_Q[15:8];
                                            blue_w = IM_Q[7:0];
                                        end else begin
                                            red_w = red_r; 
                                            green_w = green_r;
                                            blue_w = blue_r;
                                        end
                                        ////
                                        if (output_id_r[8]) // odd row
                                            addr_w = p_addr_r + addr_128_2;
                                        else
                                            addr_w = p_addr_r + addr_128_0;
                                    end
                                    3'd3: begin
                                        red_w = red_r + IM_Q[23:16];
                                        green_w = green_r + IM_Q[15:8];
                                        blue_w = blue_r + IM_Q[7:0];
                                        ////
                                        if (output_id_r[0] && output_id_r[8]) // odd column & odd row
                                            addr_w = p_addr_r + addr_128_3;
                                        else begin
                                            if (output_id_r[0]) // odd column & even row
                                                addr_w = p_addr_r + addr_128_1;
                                            else if (output_id_r[8]) // even column & odd row
                                                addr_w = p_addr_r + addr_128_2;
                                            else    // even column & even row
                                                addr_w = p_addr_r + addr_128_0;
                                        end
                                    end
                                    3'd4: begin
                                        red_w = red_r + IM_Q[23:16];
                                        green_w = green_r + IM_Q[15:8];
                                        blue_w = blue_r + IM_Q[7:0];
                                        if (b_cnt_r[7:0]==8'd127) begin
                                            addr_w = p_addr_r + addr_128_0 + 1'b1 - 8'd128;
                                        end else begin
                                            addr_w = p_addr_r + addr_128_0 + 1'b1;
                                        end
                                    end
                                    3'd5: begin
                                        red_w = red_r + IM_Q[23:16];
                                        green_w = green_r + IM_Q[15:8];
                                        blue_w = blue_r + IM_Q[7:0];
                                        IM_WEN_w = 1'b0;
                                        addr_w = FB_addr_r + output_id_r;
                                    end
                                    default: begin
                                    end
                                endcase
                            end
                            2'b10: begin // size: 256x256
                                case(s_cnt_r)
                                    3'd2: begin
                                        addr_w = p_addr_r + output_id_r;
                                    end
                                    3'd4: begin
                                        red_w = {IM_Q[23:16], 2'b0};
                                        green_w = {IM_Q[15:8], 2'b0};
                                        blue_w = {IM_Q[7:0], 2'b0};
                                        IM_WEN_w = 1'b0;
                                        addr_w = FB_addr_r + output_id_r;
                                    end
                                    default: begin
                                        IM_WEN_w = 1'b1;
                                    end
                                endcase
                            end
                            2'b11: begin // size: 512x512
                                case(s_cnt_r)
                                    3'd1: begin // output stage & b_cnt_r change
                                        IM_WEN_w = 1'b1;
                                        if ((b_cnt_r[6:0]==7'd0) && (b_cnt_r[15:7]!=9'd0)) begin
                                            if (cnt5_r == 3'd0) begin
                                                addr_w = (b_cnt_r[7])? 
                                                         p_addr_r + addr_512_1 + 3'd2 + 10'd512:
                                                         p_addr_r + addr_512_1 + 3'd6 + 10'd512;
                                            end else begin
                                                addr_w = (b_cnt_r[7])? 
                                                         p_addr_r + addr_512_1 + 3'd6 + 10'd512:
                                                         p_addr_r + addr_512_1 + 3'd2 + 10'd512;
                                            end
                                        end else begin
                                            addr_w = p_addr_r + addr_512_1 + 3'd4;
                                        end
                                        red_w = IM_Q[23:16];
                                        green_w = IM_Q[15:8];
                                        blue_w = IM_Q[7:0];
                                    end
                                    3'd2: begin // output_id_r change
                                        addr_w = p_addr_r + addr_512_2;
                                        if (b_cnt_r==16'b0) begin
                                            red_w = IM_Q[23:16];
                                            green_w = IM_Q[15:8];
                                            blue_w = IM_Q[7:0];
                                        end else begin
                                            red_w = red_r;
                                            green_w = green_r;
                                            blue_w = blue_r;
                                        end
                                    end
                                    3'd3: begin
                                        addr_w = p_addr_r + addr_512_3;
                                        red_w = red_r + IM_Q[23:16];
                                        green_w = green_r + IM_Q[15:8];
                                        blue_w = blue_r + IM_Q[7:0];
                                    end
                                    3'd4: begin
                                        ////
                                        if (b_cnt_r[6:0]==7'd127) begin
                                            if (cnt5_r == 3'd0) begin
                                                addr_w = (b_cnt_r[7])? 
                                                         p_addr_r + addr_512_0 + 3'd6 + 10'd512:
                                                         p_addr_r + addr_512_0 + 3'd2 + 10'd512;
                                            end else begin
                                                addr_w = (b_cnt_r[7])? 
                                                         p_addr_r + addr_512_0 + 3'd2 + 10'd512:
                                                         p_addr_r + addr_512_0 + 3'd6 + 10'd512;
                                            end
                                        end else begin
                                            addr_w = p_addr_r + addr_512_0 + 3'd4;
                                        end
                                        ////
                                        red_w = red_r + IM_Q[23:16];
                                        green_w = green_r + IM_Q[15:8];
                                        blue_w = blue_r + IM_Q[7:0];
                                    end
                                    3'd5: begin // At the same time, b_cnt_w = b_cnt_r + 1'b1;
                                        IM_WEN_w = 1'b0;
                                        addr_w = FB_addr_r + output_id_r;
                                        red_w = red_r + IM_Q[23:16];
                                        green_w = green_r + IM_Q[15:8];
                                        blue_w = blue_r + IM_Q[7:0];
                                    end
                                    default: begin
                                    end
                                endcase
                            end
                            default: begin
                            end
                        endcase
                    end else begin
                        if (p_size_r==2'b11) begin
                            case(s_cnt_r)
                                3'd1: begin
                                    IM_WEN_w = 1'b1;
                                    if ((b_cnt_r[6:0]==7'd0) && (b_cnt_r[15:7]!=9'd0)) begin
                                        if (cnt5_r == 3'd0) begin
                                            addr_w = (b_cnt_r[7])? 
                                                     p_addr_r + addr_512_1 + 3'd2 + 10'd512:
                                                     p_addr_r + addr_512_1 + 3'd6 + 10'd512;
                                        end else begin
                                            addr_w = (b_cnt_r[7])? 
                                                     p_addr_r + addr_512_1 + 3'd6 + 10'd512:
                                                     p_addr_r + addr_512_1 + 3'd2 + 10'd512;
                                        end
                                    end else begin
                                        addr_w = p_addr_r + addr_512_1 + 3'd4;
                                    end
                                    red_w = IM_Q[23:16];
                                    green_w = IM_Q[15:8];
                                    blue_w = IM_Q[7:0];
                                end
                                3'd4: begin
                                    if (b_cnt_r[6:0]==7'd127) begin
                                        if (cnt5_r == 3'd0) begin
                                            addr_w = (b_cnt_r[7])? 
                                                     p_addr_r + addr_512_0 + 3'd6 + 10'd512:
                                                     p_addr_r + addr_512_0 + 3'd2 + 10'd512;
                                        end else begin
                                            addr_w = (b_cnt_r[7])? 
                                                     p_addr_r + addr_512_0 + 3'd2 + 10'd512:
                                                     p_addr_r + addr_512_0 + 3'd6 + 10'd512;
                                        end
                                    end else begin
                                        addr_w = p_addr_r + addr_512_0 + 3'd4;
                                    end
                                end
                                default: begin
                                    addr_w = addr_r;
                                end
                            endcase
                        end else if (p_size_r==2'b01) begin
                            case(s_cnt_r)
                                3'd1: begin
                                    red_w = IM_Q[23:16];
                                    green_w = IM_Q[15:8];
                                    blue_w = IM_Q[7:0];
                                    IM_WEN_w = 1'b1;
                                    if (b_cnt_r[6:0]==7'd0 && b_cnt_r[15:7]!=9'd0) begin
                                        if (cnt5_r==3'd0) begin
                                            addr_w = (output_id_r[8])? // odd row
                                                     p_addr_r + addr_128_1:
                                                     p_addr_r + addr_128_0;
                                        end else begin
                                            addr_w = (output_id_r[8])? // odd row
                                                     p_addr_r + addr_128_0:
                                                     p_addr_r + addr_128_1;
                                        end
                                    end else begin
                                        if (output_id_r[0]) begin  // odd column
                                            addr_w =  p_addr_r + addr_128_1;
                                        end else begin
                                            addr_w =  p_addr_r + addr_128_0;
                                        end
                                    end
                                end
                                3'd4: begin
                                    if (b_cnt_r[7:0]==8'd127) begin
                                        addr_w = p_addr_r + addr_128_0 + 1'b1 - 8'd128;
                                    end else begin
                                        addr_w = p_addr_r + addr_128_0 + 1'b1;
                                    end
                                end
                                default: begin
                                    addr_w = addr_r;
                                end
                            endcase
                        end
                    end
                end else begin
                    IM_WEN_w = 1'b1;
                    state_w = UPDATE_CLK;
                    ch_addr_w = ROW_NUM*hr1;
                    bit_cnt_w = 4'd0;
                    row_cnt_w = 5'd0;
                    char_cnt_w = 3'd0;
                end
            end
            UPDATE_CLK: begin
                ////
                if  (bit_cnt_r==4'd12 && row_cnt_r==5'd23) begin
                    state_w = (char_cnt_r==3'd7)? WAIT: state_r;
                end
                ////
                if (bit_cnt_r == 4'd13) begin
                    addr_w = addr_r;
                    IM_WEN_w = 1'b1;
                end else begin
                    addr_w = FB_addr_r + CLK_BASE_ADDR + char_cnt_r*13 + row_cnt_r*256 + bit_cnt_r;
                    IM_WEN_w = 1'b0;
                end
                ////
                case(char_cnt_r)
                    3'd0: char_sel = (row_cnt_r==5'd23)? hr0: hr1;
                    3'd1: char_sel = (row_cnt_r==5'd23)? COLON: hr0; 
                    3'd2: char_sel = (row_cnt_r==5'd23)? min1:COLON; 
                    3'd3: char_sel = (row_cnt_r==5'd23)? min0: min1; 
                    3'd4: char_sel = (row_cnt_r==5'd23)? COLON: min0; 
                    3'd5: char_sel = (row_cnt_r==5'd23)? sec1: COLON; 
                    3'd6: char_sel = (row_cnt_r==5'd23)? sec0: sec1; 
                    3'd7: char_sel = (row_cnt_r==5'd23)? hr1: sec0; 
                endcase
                ////
                bit_cnt_w = bit_cnt_r + 1'b1;
                if (bit_cnt_r == 4'd0) begin
                    bitmap_w = CR_Q[11:0];
                    red_w = (CR_Q[12])? 10'd1023: 10'd0;
                    green_w = (CR_Q[12])? 10'd1023: 10'd0;
                    blue_w = (CR_Q[12])? 10'd1023: 10'd0;
                end else begin
                    if (bit_cnt_r == 4'd13) begin
                        if (row_cnt_r == 5'd23) begin
                            row_cnt_w = 5'd0;
                            char_cnt_w = (char_cnt_r==3'd7)? 3'd0: char_cnt_r + 1'b1;
                        end else begin
                            row_cnt_w = row_cnt_r + 1'b1;
                        end
                        bit_cnt_w = 4'd0;
                    end else if (bit_cnt_r == 4'd12) begin
                        if (row_cnt_r == 5'd23) begin
                            ch_addr_w = ROW_NUM*char_sel;
                        end else begin
                            ch_addr_w = ROW_NUM*char_sel + row_cnt_r + 1'b1;
                        end
                    end

                    bitmap_w = {bitmap_r[10:0], bitmap_r[11]};
                    red_w = (bitmap_r[11])? 10'd1023: 10'd0;
                    green_w = (bitmap_r[11])? 10'd1023: 10'd0;
                    blue_w = (bitmap_r[11])? 10'd1023: 10'd0;
                end
                ////
            end
            WAIT: begin
                IM_WEN_w = 1'b1;
                first_w = 1'b0;
                if (cnt5_r==3'd0 && b_cnt_r == 16'd39999 && s_cnt_r==3'd5) begin
                    case(p_size_r)
                        2'b01: begin                // size: 128x128
                            addr_w = p_addr_r;
                            state_w = DUMMY;
                        end
                        2'b10: begin
                            addr_w = p_addr_r;      // size: 256x256
                            state_w = TRAN;
                        end
                        2'b11: begin                // size: 512x512
                            addr_w = p_addr_r;
                            state_w = DUMMY;
                        end
                    endcase
                end else if (cnt5_r==3'd4 && b_cnt_r==16'd39998 && s_cnt_r==3'd5) begin
                    if (e_sec_r) begin
                        state_w = UPDATE_CLK;
                    end else begin
                        state_w = READ_HD;
                        if (photo_id_r == p_num_r-1'b1) begin
                            addr_w = BASE_ADDR;
                            photo_id_w = 2'd0;
                        end else begin
                            addr_w = BASE_ADDR + 2*(photo_id_r + 1'b1);
                            photo_id_w = photo_id_r + 1'b1;
                        end
                    end
                end
            end
            DUMMY: begin
                state_w = TRAN;
                if (p_size_r==2'b11) begin
                    addr_w = (cnt5_r==3'd0)? p_addr_r+2'd3: p_addr_r+2'd1;
                    red_w = 10'b0;
                    green_w = 10'b0;
                    blue_w = 10'b0;
                end else if (p_size_r==2'b01) begin
                    addr_w = (cnt5_r==3'd0)? p_addr_r+2'd1: p_addr_r;
                    red_w = 10'b0;
                    green_w = 10'b0;
                    blue_w = 10'b0;
                end
            end
        endcase
    end

    always@(posedge clk or posedge reset) begin
        if (reset) begin
            IM_WEN_r <= 1'b1;
            s_cnt_r <= 3'b0;
            b_cnt_r <= 16'hffff;
            cnt5_r <= 3'b0;
            state_r <= INIT;
            addr_r <= 20'b0;
            time_r <= 24'b0;
            ch_addr_r <= 9'b0;
            FB_addr_r <= 20'b0;
            p_num_r <= 3'b0;
            p_addr_r <= 20'b0;
            p_size_r <= 2'b0;
            red_r <= 10'b0;
            green_r <= 10'b0;
            blue_r <= 10'b0;
            output_id_r <= 16'b0;
            photo_id_r <= 2'b0;
            e_sec_r <= 1'b1;
            bitmap_r <= 12'b0;
            char_cnt_r <= 3'b0;
            bit_cnt_r <= 4'b0;
            row_cnt_r <= 5'b0;
            first_r <= 1'b1;

        end else begin
            IM_WEN_r <= IM_WEN_w;
            s_cnt_r <= s_cnt_w;
            b_cnt_r <= b_cnt_w;
            cnt5_r <= cnt5_w;
            state_r <= state_w;
            addr_r <= addr_w;
            time_r <= time_w;
            ch_addr_r <= ch_addr_w;
            FB_addr_r <= FB_addr_w;
            p_num_r <= p_num_w;
            p_addr_r <= p_addr_w;
            p_size_r <= p_size_w;
            red_r <= red_w;
            green_r <= green_w;
            blue_r <= blue_w;
            output_id_r <= output_id_w;
            photo_id_r <= photo_id_w;
            e_sec_r <= e_sec_w;
            bitmap_r <= bitmap_w;
            char_cnt_r <= char_cnt_w;
            bit_cnt_r <= bit_cnt_w;
            row_cnt_r <= row_cnt_w;
            first_r <= first_w;
        end
    end

endmodule
