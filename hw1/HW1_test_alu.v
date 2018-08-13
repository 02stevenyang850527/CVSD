`timescale 1ns/100ps

module test_alu;
reg [7:0] inputA,inputB;
reg [7:0] inputA_d1,inputB_d1,inputA_d2,inputB_d2;
reg clk,reset;
reg [2:0] instruction;
wire [15:0] alu_out;
reg	[15:0]	answer_d1,answer_d2;
integer i,j,outfile,pat_error;
integer true_out;
wire	[2:0]	test_instruction;
wire 	test_all_pat;

//////////////////////////////////////////////////////////////////////
// the instruction you want to test: 
//   assign test_all_ins = 1 to test all insturctions
//   assign test_all_ins = 0 to test one instruction at the same time
//   assign test_instruction from 000 ~ 111 mapping to your instruction 000 ~ 111
assign 	test_all_ins = 1'b1;
assign	test_instruction = 3'b000;
//////////////////////////////////////////////////////////////////////

alu alu_0( 
		   .clk_p_i(clk),
		   .reset_n_i(reset),
		   .data_a_i(inputA),
		   .data_b_i(inputB),
		   .inst_i(instruction),
		   .data_o(alu_out)
		   );

always #4 clk=~clk;                      //cycle time is 8ns

always@(posedge clk)
begin
	answer_d1 <= true_out[15:0];
	answer_d2 <= answer_d1;
	inputA_d1 <= inputA;
	inputB_d1 <= inputB;
	inputA_d2 <= inputA_d1;
	inputB_d2 <= inputB_d1;
end

initial begin
	$dumpfile("LEDDC.vcd");
	$dumpvars;
end

initial begin
 
  pat_error=0;

  reset=1'b1;clk=1'b1;inputA=0;inputB=0;instruction=0;
  #2 reset=1'b0;                            // system reset
  #2 reset=1'b1;
  if (test_all_ins==1'b0)
  begin
  
	case(test_instruction)
	3'b000:
	begin
		// test for instruction: Add
		$display("\n****************************** Test for Instruction=000 ****************************\n");
		instruction=3'b000;
		for(i=5;i>-5;i=i-1)
		begin
		  for(j=5;j>-5;j=j-1)
		  begin
		    inputA=i[7:0];inputB=j[7:0];
		    true_out=i+j;
		    #8
		        if((alu_out !== answer_d2)&(~((i==5)&(j==5))))
		        begin
				  $display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
		          pat_error=pat_error+1;
		        end
				else if ((~((i==5)&(j==5))))
				begin
				  $display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
	end

	3'b001:
	begin
		// test for instruction: Sub
		$display("\n****************************** Test for Instruction=001 ****************************\n");
		instruction=3'b001;
		for(i=5;i>-5;i=i-1)
		begin
		  for(j=5;j>-5;j=j-1)
		  begin
		    inputA=i[7:0];inputB=j[7:0];
		    true_out=j-i;
		    #8
		        if((alu_out !== answer_d2)&(~((i==5)&(j==5))))
		        begin
		          $display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
		          pat_error=pat_error+1;
		        end
				else if ((~((i==5)&(j==5))))
				begin
				  $display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
	end

	3'b010:
	begin
		// test for instruction: Multiple
		$display("\n****************************** Test for Instruction=010 ****************************\n");
		instruction=3'b010;
		for(i=0;i<50;i=i+5)
		begin
		  for(j=0;j<30;j=j+3)
		  begin
		    inputA=i[7:0];inputB=j[7:0];
		    true_out=j*i;
		    #8
		        if((alu_out !== answer_d2)&(~((i==0)&(j==0))))
		        begin
		          $display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
		          pat_error=pat_error+1;
		        end 
				else if ((~((i==0)&(j==0))))
				begin
				  $display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
	end
  
	3'b011:
	begin
		// test for instruction: AND
		$display("\n****************************** Test for Instruction=011 ****************************\n");
		instruction=3'b011;
		for(i=0;i<256;i=i+51)
		begin
		  for(j=0;j<256;j=j+31)
		  begin
		  	inputA=i[7:0];inputB=j[7:0];
		  	true_out=(i&j)&32'h000000ff;
		  	#8
				if((alu_out !== answer_d2)&(~((i==0)&(j==0))))
				begin
					$display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
					pat_error=pat_error+1;
				end
				else if ((~((i==0)&(j==0))))
				begin
					$display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
	end

	3'b100:
	begin
		// test for instruction: XOR
		$display("\n****************************** Test for Instruction=100 ****************************\n");
		instruction=3'b100;
		for(i=0;i<256;i=i+51)
		begin
		  for(j=0;j<256;j=j+31)
		  begin
		    inputA=i[7:0];inputB=j[7:0];
		    true_out=(i^j)&32'h000000ff;
		    #8
				if((alu_out !== answer_d2)&(~((i==0)&(j==0))))
				begin
					$display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
					pat_error=pat_error+1;
				end
				else if ((~((i==0)&(j==0))))
				begin
					$display("Correct! A=%b,  B:%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");                      
	end

	3'b101:
	begin
		// test for instruction: Abs
		$display("\n****************************** Test for Instruction=101 ****************************\n");
		instruction=3'b101;
		for(j=-128;j<128;j=j+9)
		begin
		  inputA=j[7:0];
		  true_out=(j<0) ? (~j+1)&32'h000000ff : (j)&32'h000000ff;
		  #8
		    if((alu_out !== answer_d2)&(~(j==-128)))
		    begin
				$display("  Wrong!  A=%b,  answer=%b,  yours=%b",inputA_d2,answer_d2,alu_out);
				pat_error=pat_error+1;
		    end
			else if (~(j==-128))
			begin
				$display(" Correct! A=%b,  answer=%b,  yours=%b",inputA_d2,answer_d2,alu_out);
			end
		end
		$display("\n************************************************************************************\n");
	end

	3'b110:
	begin
		// test for instruction: Add/2
		$display("\n****************************** Test for Instruction=110 ****************************\n");
		instruction=3'b110;
		for(i=0;i<256;i=i+30)
		begin
		  for(j=0;j<256;j=j+30)
		  begin
		    inputA=i[7:0];inputB=j[7:0];
		    true_out=(i+j)>>1;
		    #8
		        if((alu_out !== answer_d2)&(~((i==0)&(j<=1))))
		        begin
					$display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
					pat_error=pat_error+1;
		        end
				else if (~((i==0)&(j<=1)))
				begin
					$display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
	end

	3'b111:
	begin
		// test for instruction: Mod
		$display("\n****************************** Test for Instruction=111 ****************************\n");
		instruction=3'b111;
		for(i=30;i<256;i=i+30)
		begin
		  for(j=35;j<256;j=j+41)
		  begin
		    inputA=i[7:0];inputB=j[7:0];
		    true_out=(j%i);
		    #8
		        if((alu_out !== answer_d2)&(~((i==30)&(j==35))))
		        begin
					$display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
					pat_error=pat_error+1;
		        end
				else if (~((i==30)&(j==35)))
				begin
					$display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
	end
		
    endcase
   end
   else
   begin
	// test for instruction: Add
		$display("\n****************************** Test for Instruction=000 ****************************\n");
		instruction=3'b000;
		for(i=5;i>-5;i=i-1)
		begin
		  for(j=5;j>-5;j=j-1)
		  begin
		    inputA=i[7:0];inputB=j[7:0];
		    true_out=i+j;
		    #8
		        if((alu_out !== answer_d2)&(~((i==5)&(j==5))))
		        begin
				  $display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
		          pat_error=pat_error+1;
		        end
				else if ((~((i==5)&(j==5))))
				begin
				  $display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
	// test for instruction: Sub
		$display("\n****************************** Test for Instruction=001 ****************************\n");
		instruction=3'b001;
		for(i=5;i>-5;i=i-1)
		begin
		  for(j=5;j>-5;j=j-1)
		  begin
		    inputA=i[7:0];inputB=j[7:0];
		    true_out=j-i;
		    #8
		        if((alu_out !== answer_d2)&(~((i==5)&(j==5))))
		        begin
		          $display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
		          pat_error=pat_error+1;
		        end
				else if ((~((i==5)&(j==5))))
				begin
				  $display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
	// test for instruction: Multiple
		$display("\n****************************** Test for Instruction=010 ****************************\n");
		instruction=3'b010;
		for(i=0;i<50;i=i+5)
		begin
		  for(j=0;j<30;j=j+3)
		  begin
		    inputA=i[7:0];inputB=j[7:0];
		    true_out=j*i;
		    #8
		        if((alu_out !== answer_d2)&(~((i==0)&(j==0))))
		        begin
		          $display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
		          pat_error=pat_error+1;
		        end 
				else if ((~((i==0)&(j==0))))
				begin
				  $display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
	// test for instruction: AND
		$display("\n****************************** Test for Instruction=011 ****************************\n");
		instruction=3'b011;
		for(i=0;i<256;i=i+51)
		begin
		  for(j=0;j<256;j=j+31)
		  begin
		  	inputA=i[7:0];inputB=j[7:0];
		  	true_out=(i&j)&32'h000000ff;
		  	#8
				if((alu_out !== answer_d2)&(~((i==0)&(j==0))))
				begin
					$display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
					pat_error=pat_error+1;
				end
				else if ((~((i==0)&(j==0))))
				begin
					$display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
	// test for instruction: XOR
		$display("\n****************************** Test for Instruction=100 ****************************\n");
		instruction=3'b100;
		for(i=0;i<256;i=i+51)
		begin
		  for(j=0;j<256;j=j+31)
		  begin
		    inputA=i[7:0];inputB=j[7:0];
		    true_out=(i^j)&32'h000000ff;
		    #8
				if((alu_out !== answer_d2)&(~((i==0)&(j==0))))
				begin
					$display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
					pat_error=pat_error+1;
				end
				else if ((~((i==0)&(j==0))))
				begin
					$display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
	// test for instruction: Abs
		$display("\n****************************** Test for Instruction=101 ****************************\n");
		instruction=3'b101;
		for(j=-128;j<128;j=j+9)
		begin
		  inputA=j[7:0];
		  true_out=(j<0) ? (~j+1)&32'h000000ff : (j)&32'h000000ff;
		  #8
		    if((alu_out !== answer_d2)&(~(j==-128)))
		    begin
				$display("  Wrong!  A=%b,  answer=%b,  yours=%b",inputA_d2,answer_d2,alu_out);
				pat_error=pat_error+1;
		    end
			else if (~(j==-128))
			begin
				$display(" Correct! A:%b,  answer=%b,  yours=%b",inputA_d2,answer_d2,alu_out);
			end
		end
		$display("\n************************************************************************************\n");
	// test for instruction: Sub/2
		$display("\n****************************** Test for Instruction=110 ****************************\n");
		instruction=3'b110;
		for(i=0;i<256;i=i+30)
		begin
		  for(j=0;j<256;j=j+30)
		  begin
		    inputA=i[7:0];inputB=j[7:0];
		    true_out=(i+j)>>1;
		    #8
		        if((alu_out !== answer_d2)&(~((i==0)&(j<=1))))
		        begin
					$display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
					pat_error=pat_error+1;
		        end
				else if (~((i==0)&(j<=1)))
				begin
					$display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
	// test for instruction: Mod
		$display("\n****************************** Test for Instruction=111 ****************************\n");
		instruction=3'b111;
		for(i=30;i<256;i=i+30)
		begin
		  for(j=35;j<256;j=j+41)
		  begin
		    inputA=i[7:0];inputB=j[7:0];
		    true_out=(j%i);
		    #8
		        if((alu_out !== answer_d2)&(~((i==30)&(j==35))))
		        begin
					$display(" Wrong!  A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
					pat_error=pat_error+1;
		        end
				else if (~((i==30)&(j==35)))
				begin
					$display("Correct! A=%b,  B=%b,  answer=%b,  yours=%b",inputA_d2,inputB_d2,answer_d2,alu_out);
				end
		  end
		end
		$display("\n************************************************************************************\n");
   end
   
   
    if(!pat_error) begin
	  $display("\n==================================================\n");
      $display(" Congratulations!! Your Verilog Code is correct!!\n");
	  $display("==================================================\n");
	end
    else begin
	  $display("\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
      $display("   Your Verilog Code has %d errors. \n",pat_error);
	  $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
	end
  #10 $finish;
  
end

endmodule
