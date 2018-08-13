module alu(
             clk_p_i,
             reset_n_i,
             data_a_i,
             data_b_i,
             inst_i,
             data_o
             );
  /* ============================================ */
      input           clk_p_i;
      input           reset_n_i;
      input   [7:0]   data_a_i;
      input   [7:0]   data_b_i;
      input   [2:0]   inst_i;

      output reg  [15:0]  data_o;

  /* ============================================ */
      wire    [15:0]   out_inst_0;
      wire    [15:0]   out_inst_1;
      wire    [15:0]   out_inst_2;
      wire    [15:0]   out_inst_3;
      wire    [15:0]   out_inst_4;
      wire    [15:0]   out_inst_5;
      wire    [15:0]   out_inst_6;
      wire    [15:0]   out_inst_7;

      reg     [15:0]   ALU_d2_w;
      reg     [7:0]    data_a_d1_r;
      reg     [7:0]    data_b_d1_r;
      reg     [2:0]    inst_d1_r;

      wire    [7:0] temp_a;
      wire    [7:0] temp_b;

      assign temp_a = data_a_d1_r[7] ? {8'b1, data_a_d1_r} : {8'b0, data_a_d1_r};
      assign temp_b = data_b_d1_r[7] ? {8'b1, data_b_d1_r} : {8'b0, data_b_d1_r};

  /* ============================================ */
      assign out_inst_0 = $signed(temp_a) + $signed(temp_b);
      assign out_inst_1 = $signed(temp_b) - $signed(temp_a);
      assign out_inst_2 = {8'b0, data_a_d1_r} * {8'b0, data_b_d1_r};
      assign out_inst_3 = {8'b0, data_a_d1_r & data_b_d1_r};
      assign out_inst_4 = {8'b0, data_a_d1_r ^ data_b_d1_r};
      assign out_inst_5 = {8'b0, data_a_d1_r[7] ? ~data_a_d1_r + 1'b1 : data_a_d1_r};
      assign out_inst_6 = ({8'b0, data_a_d1_r} + {8'b0, data_b_d1_r}) >> 1;
      assign out_inst_7 = {8'b0, data_b_d1_r} % {8'b0, data_a_d1_r};
  /* ============================================ */
      always@ (*)
      begin
          case(inst_d1_r)
            3'b000:    ALU_d2_w = out_inst_0;
            3'b001:    ALU_d2_w = out_inst_1;
            3'b010:    ALU_d2_w = out_inst_2;
            3'b011:    ALU_d2_w = out_inst_3;
            3'b100:    ALU_d2_w = out_inst_4;
            3'b101:    ALU_d2_w = out_inst_5;
            3'b110:    ALU_d2_w = out_inst_6;
            3'b111:    ALU_d2_w = out_inst_7;
            default:   ALU_d2_w = 0;
          endcase
      end

  /* ============================================ */
      always@(posedge clk_p_i or negedge reset_n_i)
      begin
          if (reset_n_i == 1'b0)
          begin
            data_a_d1_r <= 0;
            data_b_d1_r <= 0;
            inst_d1_r   <= 0;
            data_o      <= 0;
          end
          else
          begin
            data_a_d1_r <= data_a_i;
            data_b_d1_r <= data_b_i;
            inst_d1_r   <= inst_i;
            data_o      <= ALU_d2_w;
          end
      end
  /* ============================================ */

endmodule

