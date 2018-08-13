//
//      CONFIDENTIAL AND PROPRIETARY SOFTWARE/DATA OF ARTISAN COMPONENTS, INC.
//      
//      Copyright (c) 2007 Artisan Components, Inc.  All Rights Reserved.
//      
//      Use of this Software/Data is subject to the terms and conditions of
//      the applicable license agreement between Artisan Components, Inc. and
//      Taiwan Semiconductor Manufacturing Company Ltd..  In addition, this Software/Data
//      is protected by copyright law and international treaties.
//      
//      The copyright notice(s) in this Software/Data does not indicate actual
//      or intended publication of this Software/Data.
//      name:			ROM-DIFF-HS ROM Generator
//           			TSMC CL013G Process
//      version:		2002Q3V1
//      comment:		
//      configuration:	 -instname SR -words 384 -bits 13 -frequency 20 -ring_width 2 -code_file "./romcod.txt" -mux 16 -drive 6 -top_layer met8 -power_type rings -horiz met3 -vert met4 -cust_comment "" -left_bus_delim "[" -right_bus_delim "]" -pwr_gnd_rename "VDD:VDD,GND:VSS" -prefix "" -pin_space 0.0 -name_case upper -check_instname on -diodes on -inside_ring_type GND
//
//      Verilog model for Synchronous Single-Port Rom
//
//      Instance Name:  SR
//      Words:          384
//      Word Width:     13
//
//      Creation Date:  2007-03-09 09:25:33Z
//      Version: 	2002Q3V1
//
//      Verified With: Cadence Verilog-XL
//
//      Modeling Assumptions: This model supports full gate level simulation
//          including proper x-handling and timing check behavior.  Unit
//          delay timing is included in the model. Back-annotation of SDF
//          (v2.1) is supported.  SDF can be created utilyzing the delay
//          calculation views provided with this generator and supported
//          delay calculators.  All buses are modeled [MSB:LSB].  All 
//          ports are padded with Verilog primitives.
//
//      Modeling Limitations: The output hold function has been deleted
//          completely from this model.  Most Verilog simulators are 
//          incapable of scheduling more than 1 event on the rising 
//          edge of clock.  Therefore, it is impossible to model
//          the output hold (to x) action correctly.  It is necessary
//          to run static path timing tools using Artisan supplied
//          timing models to insure that the output hold time is
//          sufficient enough to not violate hold time constraints
//          of downstream flip-flops.
//
//      Known Bugs: None.
//
//      Known Work Arounds: N/A
//


`timescale 1 ns/100 ps
`celldefine

module IMAGE_ROM (
   Q,
   CLK,
   CEN,
   A
);
   parameter           rcffile= "tbx_IMAGE.rcf";
   parameter		   BITS = 24;
   parameter		   word_depth = 1048756;
   parameter		   addr_width = 20;
   parameter		   wordx = {BITS{1'bx}};
   parameter		   addrx = {addr_width{1'bx}};
	
   output [23:0] Q;
   input CLK;
   input CEN;
   input [19:0] A;

   reg [BITS-1:0]	   mem [word_depth-1:0];

   reg			   NOT_CEN;


   reg			   NOT_A0;
   reg			   NOT_A1;
   reg			   NOT_A2;
   reg			   NOT_A3;
   reg			   NOT_A4;
   reg			   NOT_A5;
   reg			   NOT_A6;
   reg			   NOT_A7;
   reg			   NOT_A8;
   reg			   NOT_A9;
   reg			   NOT_A10;
   reg			   NOT_A11;
   reg			   NOT_A12;
   reg			   NOT_A13;
   reg			   NOT_A14;
   reg			   NOT_A15;
   reg			   NOT_A16;
   reg			   NOT_A17;
   reg			   NOT_A18;
   reg			   NOT_A19;
   reg [addr_width-1:0]	   NOT_A;

   reg			   NOT_CLK_PER;
   reg			   NOT_CLK_MINH;
   reg			   NOT_CLK_MINL;

   reg			   LAST_NOT_CEN;
   reg [addr_width-1:0]	   LAST_NOT_A;
   reg			   LAST_NOT_CLK_PER;
   reg			   LAST_NOT_CLK_MINH;
   reg			   LAST_NOT_CLK_MINL;


   wire [BITS-1:0]         _Q;
   wire [addr_width-1:0]   _A;
   wire			   _CLK;
   wire			   _CEN;




   reg			   LATCHED_CEN;
   reg [addr_width-1:0]	   LATCHED_A;

   reg			   CENi;
   reg [addr_width-1:0]	   Ai;
   reg [BITS-1:0]	   Qi;

   reg			   LAST_CLK;
 
   wire re_flag ;
   assign re_flag = !(_CEN) ;


   assign _Q = Qi ;

initial 
	$readmemb({"romfile/",rcffile}, mem );


   task update_notifier_buses;
   begin
      NOT_A = {
               NOT_A19,
               NOT_A18,
               NOT_A17,
               NOT_A16,
               NOT_A15,
               NOT_A14,
               NOT_A13,
               NOT_A12,
               NOT_A11,
               NOT_A10,
               NOT_A9,
               NOT_A8,
               NOT_A7,
               NOT_A6,
               NOT_A5,
               NOT_A4,
               NOT_A3,
               NOT_A2,
               NOT_A1,
               NOT_A0};
   end
   endtask


   task mem_cycle;
   begin
      casez({CENi})
	1'b0: begin
	   	read_mem(1,0);
	      end
	1'b1: ;
	1'bx: begin
	        read_mem(0,1);
	      end
      endcase
   end
   endtask
      
      
   task update_last_notifiers;
   begin
      LAST_NOT_A = NOT_A;
      LAST_NOT_CEN = NOT_CEN;
      LAST_NOT_CLK_PER = NOT_CLK_PER;
      LAST_NOT_CLK_MINH = NOT_CLK_MINH;
      LAST_NOT_CLK_MINL = NOT_CLK_MINL;
   end
   endtask


   task latch_inputs;
   begin
      LATCHED_A = _A ;
      LATCHED_CEN = _CEN ;
   end
   endtask


   task update_logic;
      integer n;
   begin
      CENi = LATCHED_CEN;
      Ai = LATCHED_A;
   end
   endtask


   task x_inputs;
      integer n;
   begin
      for (n=0; n<addr_width; n=n+1)
	    LATCHED_A[n] = (NOT_A[n]!==LAST_NOT_A[n]) ? 1'bx : LATCHED_A[n] ;
      LATCHED_CEN = (NOT_CEN!==LAST_NOT_CEN) ? 1'bx : LATCHED_CEN ;
   end
   endtask

   task read_mem;
      input r_wb;
      input xflag;
   begin
      if (r_wb)
	    if (valid_address(Ai))
	          Qi=mem[Ai];
	    else
		  Qi=wordx;
      else
	    if (xflag)
		  Qi=wordx;
   end
   endtask

   task process_violations;
   begin
      if ((NOT_CLK_PER!==LAST_NOT_CLK_PER) ||
	  (NOT_CLK_MINH!==LAST_NOT_CLK_MINH) ||
	  (NOT_CLK_MINL!==LAST_NOT_CLK_MINL))
	 begin
	    if (CENi !== 1'b1)
               begin
		  read_mem(0,1);
	       end
	 end
      else
	 begin
	    update_notifier_buses;
	    x_inputs;
	    update_logic;
	    mem_cycle;
	 end
      update_last_notifiers;
   end
   endtask

   function valid_address;
      input [addr_width-1:0] a;
   begin
      valid_address = (^(a) !== 1'bx);
   end
   endfunction

   buf (Q[0], _Q[0]);
   buf (Q[1], _Q[1]);
   buf (Q[2], _Q[2]);
   buf (Q[3], _Q[3]);
   buf (Q[4], _Q[4]);
   buf (Q[5], _Q[5]);
   buf (Q[6], _Q[6]);
   buf (Q[7], _Q[7]);
   buf (Q[8], _Q[8]);
   buf (Q[9], _Q[9]);
   buf (Q[10], _Q[10]);
   buf (Q[11], _Q[11]);
   buf (Q[12], _Q[12]);
   buf (Q[13], _Q[13]);
   buf (Q[14], _Q[14]);
   buf (Q[15], _Q[15]);
   buf (Q[16], _Q[16]);
   buf (Q[17], _Q[17]);
   buf (Q[18], _Q[18]);
   buf (Q[19], _Q[19]);
   buf (Q[20], _Q[20]);
   buf (Q[21], _Q[21]);
   buf (Q[22], _Q[22]);
   buf (Q[23], _Q[23]);

   buf (_A[0], A[0]);
   buf (_A[1], A[1]);
   buf (_A[2], A[2]);
   buf (_A[3], A[3]);
   buf (_A[4], A[4]);
   buf (_A[5], A[5]);
   buf (_A[6], A[6]);
   buf (_A[7], A[7]);
   buf (_A[8], A[8]);
   buf (_A[9], A[9]);
   buf (_A[10], A[10]);
   buf (_A[11], A[11]);
   buf (_A[12], A[12]);
   buf (_A[13], A[13]);
   buf (_A[14], A[14]);
   buf (_A[15], A[15]);
   buf (_A[16], A[16]);
   buf (_A[17], A[17]);
   buf (_A[18], A[18]);
   buf (_A[19], A[19]);
   buf (_CLK, CLK);
   buf (_CEN, CEN);



   always @(
	    NOT_A0 or
	    NOT_A1 or
	    NOT_A2 or
	    NOT_A3 or
	    NOT_A4 or
	    NOT_A5 or
	    NOT_A6 or
	    NOT_A7 or
	    NOT_A8 or
	    NOT_A9 or
	    NOT_A10 or
	    NOT_A11 or
	    NOT_A12 or
	    NOT_A13 or
	    NOT_A14 or
	    NOT_A15 or
	    NOT_A16 or
	    NOT_A17 or
	    NOT_A18 or
	    NOT_A19 or
	    NOT_CEN or
	    NOT_CLK_PER or
	    NOT_CLK_MINH or
	    NOT_CLK_MINL
	    )
      begin
         process_violations;
      end


   always @( _CLK )
      begin
         casez({LAST_CLK,_CLK})
	   2'b01: begin
	      latch_inputs;
	      update_logic;
	      mem_cycle;
	   end

	   2'b10,
	   2'bx?,
	   2'b00,
	   2'b11: ;

	   2'b?x: read_mem(0,1);
	   
	 endcase
	 LAST_CLK = _CLK;
      end

   specify
      $setuphold(posedge CLK, posedge CEN, 1.000, 0.500, NOT_CEN);
      $setuphold(posedge CLK, negedge CEN, 1.000, 0.500, NOT_CEN);
      $setuphold(posedge CLK &&& re_flag, posedge A[0], 1.000, 0.500, NOT_A0);
      $setuphold(posedge CLK &&& re_flag, negedge A[0], 1.000, 0.500, NOT_A0);
      $setuphold(posedge CLK &&& re_flag, posedge A[1], 1.000, 0.500, NOT_A1);
      $setuphold(posedge CLK &&& re_flag, negedge A[1], 1.000, 0.500, NOT_A1);
      $setuphold(posedge CLK &&& re_flag, posedge A[2], 1.000, 0.500, NOT_A2);
      $setuphold(posedge CLK &&& re_flag, negedge A[2], 1.000, 0.500, NOT_A2);
      $setuphold(posedge CLK &&& re_flag, posedge A[3], 1.000, 0.500, NOT_A3);
      $setuphold(posedge CLK &&& re_flag, negedge A[3], 1.000, 0.500, NOT_A3);
      $setuphold(posedge CLK &&& re_flag, posedge A[4], 1.000, 0.500, NOT_A4);
      $setuphold(posedge CLK &&& re_flag, negedge A[4], 1.000, 0.500, NOT_A4);
      $setuphold(posedge CLK &&& re_flag, posedge A[5], 1.000, 0.500, NOT_A5);
      $setuphold(posedge CLK &&& re_flag, negedge A[5], 1.000, 0.500, NOT_A5);
      $setuphold(posedge CLK &&& re_flag, posedge A[6], 1.000, 0.500, NOT_A6);
      $setuphold(posedge CLK &&& re_flag, negedge A[6], 1.000, 0.500, NOT_A6);
      $setuphold(posedge CLK &&& re_flag, posedge A[7], 1.000, 0.500, NOT_A7);
      $setuphold(posedge CLK &&& re_flag, negedge A[7], 1.000, 0.500, NOT_A7);
      $setuphold(posedge CLK &&& re_flag, posedge A[8], 1.000, 0.500, NOT_A8);
      $setuphold(posedge CLK &&& re_flag, negedge A[8], 1.000, 0.500, NOT_A8);
      $setuphold(posedge CLK &&& re_flag, posedge A[9], 1.000, 0.500, NOT_A9);
      $setuphold(posedge CLK &&& re_flag, negedge A[9], 1.000, 0.500, NOT_A9);
      $setuphold(posedge CLK &&& re_flag, posedge A[10], 1.000, 0.500, NOT_A10);
      $setuphold(posedge CLK &&& re_flag, negedge A[10], 1.000, 0.500, NOT_A10);
      $setuphold(posedge CLK &&& re_flag, posedge A[11], 1.000, 0.500, NOT_A11);
      $setuphold(posedge CLK &&& re_flag, negedge A[11], 1.000, 0.500, NOT_A11);
      $setuphold(posedge CLK &&& re_flag, posedge A[12], 1.000, 0.500, NOT_A12);
      $setuphold(posedge CLK &&& re_flag, negedge A[12], 1.000, 0.500, NOT_A12);
      $setuphold(posedge CLK &&& re_flag, posedge A[13], 1.000, 0.500, NOT_A13);
      $setuphold(posedge CLK &&& re_flag, negedge A[13], 1.000, 0.500, NOT_A13);
      $setuphold(posedge CLK &&& re_flag, posedge A[14], 1.000, 0.500, NOT_A14);
      $setuphold(posedge CLK &&& re_flag, negedge A[14], 1.000, 0.500, NOT_A14);
      $setuphold(posedge CLK &&& re_flag, posedge A[15], 1.000, 0.500, NOT_A15);
      $setuphold(posedge CLK &&& re_flag, negedge A[15], 1.000, 0.500, NOT_A15);
      $setuphold(posedge CLK &&& re_flag, posedge A[16], 1.000, 0.500, NOT_A16);
      $setuphold(posedge CLK &&& re_flag, negedge A[16], 1.000, 0.500, NOT_A16);
      $setuphold(posedge CLK &&& re_flag, posedge A[17], 1.000, 0.500, NOT_A17);
      $setuphold(posedge CLK &&& re_flag, negedge A[17], 1.000, 0.500, NOT_A17);
      $setuphold(posedge CLK &&& re_flag, posedge A[18], 1.000, 0.500, NOT_A18);
      $setuphold(posedge CLK &&& re_flag, negedge A[18], 1.000, 0.500, NOT_A18);
      $setuphold(posedge CLK &&& re_flag, posedge A[19], 1.000, 0.500, NOT_A19);
      $setuphold(posedge CLK &&& re_flag, negedge A[19], 1.000, 0.500, NOT_A19);
      $period(posedge CLK, 3.000, NOT_CLK_PER);
      $width(posedge CLK, 1.000, 0, NOT_CLK_MINH);
      $width(negedge CLK, 1.000, 0, NOT_CLK_MINL);


      (CLK => Q[0]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[1]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[2]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[3]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[4]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[5]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[6]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[7]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[8]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[9]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[10]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[11]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[12]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[13]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[14]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[15]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[16]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[17]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[18]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[19]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[20]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[21]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[22]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);
      (CLK => Q[23]) = (1.000, 1.000, 0.500, 1.000, 0.500, 1.000);

endspecify

endmodule
`endcelldefine
