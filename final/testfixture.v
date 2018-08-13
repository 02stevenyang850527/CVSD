`timescale 1 ns/1 ns

`define SDFFILE  "DPA_syn.sdf" // To simulation with sdf annotate 
                               // 1. modify SDFFILE define
                               // 2. uncommon line 148
                               
`define TGCOUNT                 // common this line if you want to
                                //        turn off toggle count pli 

`ifndef tb1
    `define tb1
`endif
`ifdef tb2
    `undef tb1
    `define TB_PREFIX "tb2_image"
    `define FB_INITIAL_ADDR 839680
    `define INITIAL_HOUR 12
    `define INITIAL_MIN  12
    `define INITIAL_SEC  59
    `define SIMULATION_CYCLE_NUM 2000000
    `define IMAGE_ROM "tb2_IMAGE.rcf"
    `define XPMWRITETASK "task/tb2_xpmwrite.task"
`endif
`ifdef tb3
    `undef tb1
    `define TB_PREFIX "tb3_image"
    `define FB_INITIAL_ADDR 33036
    `define INITIAL_HOUR 3
    `define INITIAL_MIN  59
    `define INITIAL_SEC  59
    `define SIMULATION_CYCLE_NUM 2000000
    `define IMAGE_ROM "tb3_IMAGE.rcf"
    `define XPMWRITETASK "task/tb3_xpmwrite.task"
`endif
`ifdef tb4
    `undef tb1
    `define TB_PREFIX "tb4_image"
    `define FB_INITIAL_ADDR 851968
    `define INITIAL_HOUR 22
    `define INITIAL_MIN  12
    `define INITIAL_SEC  02
    `define SIMULATION_CYCLE_NUM 3000000
    `define IMAGE_ROM "tb4_IMAGE.rcf"
    `define XPMWRITETASK "task/tb4_xpmwrite.task"
`endif
`ifdef tb5
    `undef tb1
    `define TB_PREFIX "tb5_image"
    `define FB_INITIAL_ADDR 917504
    `define INITIAL_HOUR 23
    `define INITIAL_MIN  59
    `define INITIAL_SEC  59
    `define SIMULATION_CYCLE_NUM 5000000
    `define IMAGE_ROM "tb5_IMAGE.rcf"
    `define XPMWRITETASK "task/tb5_xpmwrite.task"
`endif
`ifdef tb6
    `undef tb1
    `define TB_PREFIX "tb6_image"
    `define FB_INITIAL_ADDR 786432
    `define INITIAL_HOUR 00
    `define INITIAL_MIN  07
    `define INITIAL_SEC  04
    `define SIMULATION_CYCLE_NUM 3000000
    `define IMAGE_ROM "tb6_IMAGE.rcf"
    `define XPMWRITETASK "task/tb6_xpmwrite.task"
`endif
`ifdef tb7
    `undef tb1
    `define TB_PREFIX "tb7_image"
    `define FB_INITIAL_ADDR 983040
    `define INITIAL_HOUR 23
    `define INITIAL_MIN  59
    `define INITIAL_SEC  57
    `define SIMULATION_CYCLE_NUM 8000000
    `define IMAGE_ROM "tb7_IMAGE.rcf"
    `define XPMWRITETASK "task/tb7_xpmwrite.task"
`endif
`ifdef tb1
    `define TB_PREFIX "tb1_image"
    `define FB_INITIAL_ADDR 917504
    `define INITIAL_HOUR 12
    `define INITIAL_MIN  6
    `define INITIAL_SEC  30
    `define SIMULATION_CYCLE_NUM 2000000
    `define IMAGE_ROM "tb1_IMAGE.rcf"
    `define XPMWRITETASK "task/tb1_xpmwrite.task"
`endif

`define CYCLE    1000

`include "IMAGE_ROM.v"
`include "FB.v"
`include "charROM.v"


module test;
parameter t_reset = `CYCLE;
parameter A_SEC_CYCLE=(1000000000/`CYCLE);
parameter PRE_CHECK_TIME=        (1000/`CYCLE);  //pre check at -0.000001 sec
parameter TRANS_CHECK_TIME= (200000000/`CYCLE);  //pre check at  0.200000 sec
parameter POST_CHECK_TIME=  (400001000/`CYCLE);  //post check at 0.400001 sec

reg  clk;
reg reset;
wire [23:0] IRQ;
wire [19:0] IRA;

wire [23:0] FBQ;
wire [15:0] FBA;
wire [23:0] FBD; wire FBWEN;

wire [19:0] IM_A;
wire [23:0] IM_Q;
wire [23:0] IM_D;
wire IM_WEN;
wire [8:0] CR_A;
wire [12:0] CR_Q;

reg SAVEIMAGE;
reg CHECKIMAGE;
reg CHECKTRANS;

reg [5:0]  hour,min,sec;
reg [23:0] init_time;
wire FB_CEN;
reg latchforQ;
reg IRwfobid;
reg [15:0] FBAlatch;
reg [19:0] IRAlatch;

wire AinFB = ((IM_A>=`FB_INITIAL_ADDR)&&(IM_A<(`FB_INITIAL_ADDR+65536)))?1:0;
assign FBWEN =(AinFB)?IM_WEN:1;
assign FBA   = (AinFB)?IM_A-`FB_INITIAL_ADDR:FBAlatch;
assign IM_Q  =(latchforQ==1)? FBQ:
               (IRwfobid==0)? IRQ:24'bz;
assign FBD   = IM_D;
assign IRA   =(AinFB)?IRAlatch:IM_A;
assign FB_CEN = (AinFB)? 0:1;

IMAGE_ROM #(`IMAGE_ROM) IR(.Q(IRQ),.CLK(clk),.CEN(1'b0),.A(IRA));
FB #(`TB_PREFIX) FB (.Q(FBQ),.CLK(clk),.CEN(FB_CEN),.WEN(FBWEN),.A(FBA),.D(FBD),.CHECKIMAGE(CHECKIMAGE),.SAVEIMAGE(SAVEIMAGE),.CHECKTRANS(CHECKTRANS));

DPA DPA (.clk(clk),.reset(reset),.IM_A(IM_A), .IM_Q(IM_Q),.IM_D(IM_D),.IM_WEN(IM_WEN),.CR_A(CR_A),.CR_Q(CR_Q));

charROM CHARROM(.Q(CR_Q), .CLK(clk), .CEN(1'b0), .A(CR_A));

//initial $sdf_annotate(`SDFFILE, DPA);

always @(posedge clk) begin
    if(AinFB) begin
        FBAlatch=FBA;
        #1 latchforQ=1;
    end 
    else
    begin
        IRAlatch=IRA;
        #1 latchforQ=0;
    end
end

always @(posedge clk) begin
    if((!reset)&&(!AinFB)&&(IM_WEN==0))begin
        IRwfobid=1;
        $display("Warning at %d ns, IM_A=%h, IM_WEN=%h :",$time,IM_A,IM_WEN); 
        $display("    Forbid to write Image Memory except in the range of Frame Buffer");
    end
    else begin
        IRwfobid=0;
    end
end

integer count_time ;
reg [8:0] tick;
reg check_FB;
initial begin
`ifdef FSDB
    $fsdbDumpfile("DPA.fsdb");
    $fsdbDumpvars;
`endif
`ifdef TGCOUNT 
    $toggle_count(DPA);
`endif
    clk=1'b1;
    reset= 1'b0;
    count_time=-1;
    tick=-1;
    check_FB=0;
    SAVEIMAGE=0;
    CHECKIMAGE=0;
    CHECKTRANS=0;
    hour=`INITIAL_HOUR;
    min=`INITIAL_MIN;
    sec=`INITIAL_SEC;
    $display("FB init addr = %h",`FB_INITIAL_ADDR);
end
always begin #(`CYCLE/2) clk = ~clk; end

initial begin
    @(negedge clk)  
       reset=1'b1;
    @(negedge clk)  
       reset=1'b0;
end

////compare
always @(posedge clk) begin
    count_time=count_time+1;
    if(count_time%A_SEC_CYCLE==0) begin
        tick=tick+1;
        $display("=======  tick%d,  time=%d:%d:%d  ========",tick,hour,min,sec);
        sec=sec+1;
        if(sec==60) begin
            sec=0;
            min=min+1;
            if(min==60)begin
                min=0;
                hour=hour+1;
                if(hour==24)
                    hour=0;
            end
        end
    end
        if((count_time+PRE_CHECK_TIME)%A_SEC_CYCLE==0) begin
            #(`CYCLE/2) check_FB=1;
            $display(" check at %d.999999 sec",tick);
            CHECKIMAGE=1;
        end
        else if((count_time-TRANS_CHECK_TIME)%(2*A_SEC_CYCLE)==0) begin
            if(tick!=0) begin
                $display(" check transfer image at %d.2 sec",tick);
                #(`CYCLE/2) check_FB=1;
                CHECKTRANS=1;
            end
        end
        else if((count_time-POST_CHECK_TIME)%A_SEC_CYCLE==0) begin
            $display(" check at %d.400001 sec",tick);
            #(`CYCLE/2) check_FB=1;
            SAVEIMAGE=1;
            CHECKIMAGE=1;
        end
        else begin
            #(`CYCLE/2) check_FB=0;
            CHECKTRANS=0;
            SAVEIMAGE=0;
            CHECKIMAGE=0;
        end
end

always @(posedge clk) begin
    if(count_time == `SIMULATION_CYCLE_NUM)begin
        $display("\n");
`ifdef TGCOUNT 
        $toggle_count_report;
`endif
        $display("\n");
        $display("\n");
        $display("        ****************************              ");
        $display("        **                        **        /|__/|");
        $display("        **  Congratulations !!    **      / O,O  |");
        $display("        **                        **    /_____   |");
        $display("        **  Simulation Complete!! **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w|");
        $display("        *************** ************   \\m___m__|_|");
        $display("\n");
        $finish;
    end
end
endmodule
