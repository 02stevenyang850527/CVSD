# clear the session
clear -all
#parsing HDL files
analyze -sv ./vcomp_path.v
analyze +incdir+./../../defines -sv ./../rtl/fifo.v
analyze -verilog ./../rtl/path.v +define+ABV_ON
# elaborating the whole design
elaborate -top path 
#setting up primary clock
clock clk

#in simple reset commands the -expression switch can be omitted
reset !rst_n

# deliberate overconstraints to simplify problem
assume -name case1asm1 -env enable_i
assume -name case1asm2 -env !flush_i

# set time limit
# set_prove_time_limit 120s

#prove -all -bg
