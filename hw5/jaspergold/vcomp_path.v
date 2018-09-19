module vcomp_path #(
  parameter DWIDTH=8,     // data width
  parameter PWIDTH=8
)
(
  input clk,
  input rst_n,
  input req_o,
  input gnt_i,
  input stall_o,
  input valid_i,
  input [DWIDTH-1:0] data_i,
  input [DWIDTH-1:0] data_o,
  input overflow_o,
  input underflow_o,
  input write_i,
  input read_i,
  input empty,
  input full,
  input [PWIDTH-1:0] rd_ptr,
  input [PWIDTH-1:0] wr_ptr
  );

  // ************* Protocol Assumptions ***************

  // fairness: grant has to eventually come if there is a request
  assume_arbitration_is_fair : assume property (@(posedge clk)
    (req_o |-> (##[0:$] gnt_i)) );

  // if path is stalling then valid_i must be deasserted
  assume_no_valid_if_stall: assume property (@(posedge clk) (stall_o |-> !valid_i));

  // grant can only be asserted if there is a request
  assume_no_gnt_without_req: assume property (@(posedge clk) (gnt_i |-> req_o));

  // ************* Black Box Control Assertions *****************

  // if valid is asserted, the request should be asserted in the same cycle
  assert_valid2req_bb : assert property (@(posedge clk) valid_i |-> req_o);

   // should never get a request without a prior valid
  assert_never_req_without_valid_bb : assert property (@(posedge clk) disable iff (!rst_n) valid_i |-> (##[0:$] req_o));

  // should never see overflow or underflow
  assert_never_overflow_bb : assert property (@(posedge clk)  (!overflow_o));
  assert_never_underflow_bb : assert property (@(posedge clk) (!underflow_o));

  // ************* Black Box Data Assertions *****************


  //Indeterminate constant declared. In formal this will take all possible values

  wire [DWIDTH-1:0] data;
  assume_data_sample_hold: assume property (@(posedge clk)(data==$past(data)));
  
   // data that comes in, eventually must come out
  assert_data_good_bb: assert property (@(posedge clk) (write_i && (data_i==data)) |=> ##[0:$] (read_i && (data_o == data)));

  // if req rises and gnt is asserted (bypass) then data_o should equal data_i
  assert_data_bypass_bb : assert property (@(posedge clk) ($rose(req_o) && gnt_i) |-> (data_o==data_i));

  // ************* White Box Control Assertions ******************

  // full and empty asserted at the same time would be an error
  assert_never_full_empty_wb : assert property (@(posedge clk) (!(empty && full)));

  // if empty, the read and write points must be equal
  assert_empty_ptr_wb : assert property (@(posedge clk) empty |-> (rd_ptr == wr_ptr));

  // if full, the read and write points must be equal
  assert_full_ptr_wb : assert property (@(posedge clk) full |-> (rd_ptr == wr_ptr));

  // if full and no reads, it must stay full
  assert_noPopRemainFull_wb : assert property (@(posedge clk) (full && !read_i) |=> full);

  // if empty and no writes, it must stay empty
  assert_noPushRemainEmpty_wb : assert property (@(posedge clk) (empty && !write_i) |=> empty);

  // ************* White Box Data Assertions ******************

  // if FIFO is empty, valid is asserted, and gnt the input data should be seen 
  //immediately on the output
  assert_emptyData_wb : assert property (@(posedge clk) (empty && valid_i && gnt_i) |-> (data_i == data_o));

  // if FIFO is empty, valid is asserted, but no gnt the input data should be seen on 
  //the next cycle on the output
  assert_emptyDataBypass_wb : assert property (@(posedge clk) (empty && valid_i && !gnt_i) |=> (data_o == $past(data_i)));

endmodule
