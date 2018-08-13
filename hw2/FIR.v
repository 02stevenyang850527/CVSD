module FIR(data_valid, data, fir_valid, fir_d, clk, rst);

`include "./dat/FIR_coefficient.dat"
    input   clk, rst;
    input   data_valid;
    input   [15:0] data;

    output reg fir_valid;
    output reg [15:0] fir_d;

    reg        fir_valid_w;
    reg [ 5:0] cnt_w, cnt_r;
    reg signed [43:0] fir_d_tmp;    // To prevent overflow
    reg [15:0] fir_d_w;
    //reg signed [43:0] x_w[31:0], x_r[31:0];
    reg signed [33:0] x_w[31:0], x_r[31:0];
    integer i;

    always@ (*) begin
        
        if (data_valid) begin
            x_w[0] = $signed({data, 8'b0});
            /*
            fir_d_tmp = x_r[0]*FIR_C00 + x_r[1]*FIR_C01 + x_r[2]*FIR_C02 + x_r[3]*FIR_C03 + x_r[4]*FIR_C04 + x_r[5]*FIR_C05 + x_r[6]*FIR_C06 +
                      x_r[7]*FIR_C07 + x_r[8]*FIR_C08 + x_r[9]*FIR_C09 + x_r[10]*FIR_C10 + x_r[11]*FIR_C11 + x_r[12]*FIR_C12 + x_r[13]*FIR_C13 +
                      x_r[14]*FIR_C14 + x_r[15]*FIR_C15 + x_r[16]*FIR_C16 + x_r[17]*FIR_C17 + x_r[18]*FIR_C18 + x_r[19]*FIR_C19 + x_r[20]*FIR_C20 +
                      x_r[21]*FIR_C21 + x_r[22]*FIR_C22 + x_r[23]*FIR_C23 + x_r[24]*FIR_C24 + x_r[25]*FIR_C25 + x_r[26]*FIR_C26 + x_r[27]*FIR_C27 +
                      x_r[28]*FIR_C28 + x_r[29]*FIR_C29 + x_r[30]*FIR_C30 + x_r[31]*FIR_C31;
            */
            x_w[1] = x_r[0]*FIR_C31;
            x_w[2] = x_r[0]*FIR_C30 + x_r[1];
            x_w[3] = x_r[0]*FIR_C29 + x_r[2];
            x_w[4] = x_r[0]*FIR_C28 + x_r[3];
            x_w[5] = x_r[0]*FIR_C27 + x_r[4];
            x_w[6] = x_r[0]*FIR_C26 + x_r[5];
            x_w[7] = x_r[0]*FIR_C25 + x_r[6];
            x_w[8] = x_r[0]*FIR_C24 + x_r[7];
            x_w[9] = x_r[0]*FIR_C23 + x_r[8];
            x_w[10] = x_r[0]*FIR_C22 + x_r[9];
            x_w[11] = x_r[0]*FIR_C21 + x_r[10];
            x_w[12] = x_r[0]*FIR_C20 + x_r[11];
            x_w[13] = x_r[0]*FIR_C19 + x_r[12];
            x_w[14] = x_r[0]*FIR_C18 + x_r[13];
            x_w[15] = x_r[0]*FIR_C17 + x_r[14];
            x_w[16] = x_r[0]*FIR_C16 + x_r[15];
            x_w[17] = x_r[0]*FIR_C15 + x_r[16];
            x_w[18] = x_r[0]*FIR_C14 + x_r[17];
            x_w[19] = x_r[0]*FIR_C13 + x_r[18];
            x_w[20] = x_r[0]*FIR_C12 + x_r[19];
            x_w[21] = x_r[0]*FIR_C11 + x_r[20];
            x_w[22] = x_r[0]*FIR_C10 + x_r[21];
            x_w[23] = x_r[0]*FIR_C09 + x_r[22];
            x_w[24] = x_r[0]*FIR_C08 + x_r[23];
            x_w[25] = x_r[0]*FIR_C07 + x_r[24];
            x_w[26] = x_r[0]*FIR_C06 + x_r[25];
            x_w[27] = x_r[0]*FIR_C05 + x_r[26];
            x_w[28] = x_r[0]*FIR_C04 + x_r[27];
            x_w[29] = x_r[0]*FIR_C03 + x_r[28];
            x_w[30] = x_r[0]*FIR_C02 + x_r[29];
            x_w[31] = x_r[0]*FIR_C01 + x_r[30];
            fir_d_tmp = x_r[0]*FIR_C00 + x_r[31];

            fir_d_w = fir_d_tmp[43]? {fir_d_tmp[43], fir_d_tmp[38:24]}+1'b1 : {fir_d_tmp[43], fir_d_tmp[38:24]};

            if (cnt_r == 6'd33) begin
                cnt_w = cnt_r;
                fir_valid_w = 1'b1;
            end else begin
                cnt_w = cnt_r + 1'b1;
                fir_valid_w = fir_valid;
                fir_d_w = fir_d;
            end

        end else begin
            for(i=0; i<32; i=i+1) begin
                x_w[i] = x_r[i];
            end
            cnt_w = cnt_r;
            fir_valid_w = fir_valid;
            fir_d_w = fir_d;
        end
    end

    always@ (posedge clk or posedge rst) begin
        if (rst) begin
            fir_valid <= 1'b0;
            fir_d     <= 16'b0;
            cnt_r     <= 6'b0;
            for (i=0; i<32; i=i+1) begin
                x_r[i] <= 43'b0;
            end
        end else begin
            fir_valid <= fir_valid_w;
            fir_d     <= fir_d_w;
            cnt_r     <= cnt_w;
            for (i=0; i<32; i=i+1) begin
                x_r[i] <= x_w[i];
            end
        end
    end

endmodule

