`timescale 1ns/10ps
`define CYCLE      10           	  // Modify your clock period here
`define SDFFILE    "./LMFE_syn.sdf"	          // Modify your sdf file name
`define End_CYCLE  10000000               // Modify cycle times once your design need more cycle times!
`define PAT        "./pattern1.dat"    
`define EXP        "./golden1.dat"     

module test;
parameter N_EXP   = 16384;
parameter N_PAT   = N_EXP;

reg   clk ;
reg   reset ;
reg   in_en;
reg   [7:0]   Din;
wire  busy;
wire  out_valid;
wire  [7:0]   Dout;
reg   [7:0]   pat_mem   [0:N_PAT-1];
reg   [7:0]   exp_mem   [0:N_EXP-1];
reg   [7:0]   out_temp;

reg           stop;
integer       i, out_f, err, pass, exp_num, times;
reg           over;

   LMFE LMFE( .clk(clk), .reset(reset), .Din(Din), .in_en(in_en), .busy(busy), .out_valid(out_valid), .Dout(Dout));         
   

`ifdef SDF
initial $sdf_annotate(`SDFFILE, LMFE);
`endif

initial	$readmemh (`PAT, pat_mem);
initial	$readmemh (`EXP, exp_mem);


initial begin
#0;
   clk         = 1'b0;
   reset       = 1'b0;
   in_en       = 1'b0;   
   Din         = 'hz;
   stop        = 1'b0;  
   over        = 1'b0;
   exp_num     = 0;
   err         = 0;
   pass        = 0;
   times       = 1;            
end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
//$dumpfile("LMFE1.vcd");
//$dumpvars;
$fsdbDumpfile("LMFE1.fsdb");
$fsdbDumpvars(0, test, "+mda");

   out_f = $fopen("out.dat");
   if (out_f == 0) begin
        $display("Output file open error !");
        $finish;
   end
end


initial begin
   @(negedge clk)  reset = 1'b1;
   #`CYCLE         reset = 1'b0;
   
   #(`CYCLE*2);   
   @(negedge clk) i=0;
    while (i <= N_PAT) begin               
      if(!busy) begin
         Din = pat_mem[i];
         in_en = 1'b1;
         i=i+1;
      end 
      else begin
         Din = 'hz; in_en = 1'b0;
      end                    
      @(negedge clk); 
    end     
    in_en = 0; Din='hz;
end

always @(posedge clk)begin
   out_temp = exp_mem[exp_num];
   if(out_valid)begin
      $fdisplay(out_f,"%2h", Dout);      
      if(Dout !== out_temp) begin
         $display("ERROR at %5d:output %2h !=expect %2h " ,exp_num, Dout, out_temp);
         err = err + 1 ;  
      end            
      else begin      
         pass = pass + 1 ;
      end      
      #1 exp_num = exp_num + 1;
   end     
   if(exp_num === N_EXP)  over = 1'b1;   
end

always @(exp_num)begin  
  if(exp_num === (1000*times) && err === 0)begin  
      $display("Output pixel: 0 ~ %5d are correct!\n", (1000*times));
      times=times+1;
  end
end

initial  begin
 #(`CYCLE * `End_CYCLE);
   
 $display("-----------------------------------------------------\n");
 $display("Error!!! Somethings' wrong with your code ...!\n");
 $display("-------------------------FAIL------------------------\n");
 $display("-----------------------------------------------------\n");
 
 $finish;
end

initial begin
      @(posedge over)      
      if((over) && (exp_num!='d0)) begin
         $display("-----------------------------------------------------\n");
         if (err == 0)  begin
            $display("Congratulations! All data have been generated successfully!\n");
            $display("-------------------------PASS------------------------\n");
         end
         else begin
            $display("There are %d errors!\n", err);
            $display("-----------------------------------------------------\n");
         end
      end
      #(`CYCLE/2); $finish;
end
   
endmodule









