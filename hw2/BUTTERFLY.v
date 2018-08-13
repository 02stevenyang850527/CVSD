module BUTTERFLY(a, b, c, d, wr, wi, o_real, o_img);
    // Pure Combinational part
    
    input [31:0] a;     // 1 signed bit, 15 integer bits, 16 decimal bits
    input [31:0] b;
    input [31:0] c;
    input [31:0] d;

    input [31:0] wr;    // 1 signed bit, 15 integer bits, 16 decimal bits
    input [31:0] wi;

    output reg [31:0] o_real;
    output reg [31:0] o_img;

    reg signed [63:0] tmp_r, tmp_i;

    always@ (*) begin
        tmp_r = ($signed(a) - $signed(c)) * $signed(wr) + ($signed(d) - $signed(b)) * $signed(wi);
        o_real = tmp_r[63]? {tmp_r[63], tmp_r[46:16]} + 1'b1 : {tmp_r[63],tmp_r[46:16]};
        //o_real = {tmp_r[63],tmp_r[46:16]};

        tmp_i = ($signed(a) - $signed(c)) * $signed(wi) + ($signed(b) - $signed(d)) * $signed(wr);
        o_img  = tmp_i[63]? {tmp_i[63], tmp_i[46:16]} + 1'b1 : {tmp_i[63],tmp_i[46:16]};

    end

endmodule
