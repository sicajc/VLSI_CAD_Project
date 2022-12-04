#======================================================
#
# Synopsys Synthesis Scripts (Design Vision dctcl mode)
#
#======================================================

#======================================================
#  Set Libraries
#======================================================

source synopsys_dc.setup

#======================================================
#  Global Parameters
#======================================================
set DESIGN "pipelinedPS"
set clk_period 60.0

#======================================================
#  Read RTL Code
#======================================================
set hdlin_auto_save_templates TRUE

analyze -library WORK -format verilog {/home/rain/VLSI_CAD_Project/16_bit_Pipelined_processor/pipelinedPS.v}
elaborate pipelinedPS -architecture verilog -library DEFAULT
current_design $DESIGN
link > Report/$DESIGN\.link


#======================================================
#  Set Design Constraints
#======================================================

create_clock -name "clk" -period $clk_period clk 
set_input_delay  [ expr $clk_period*0.5 ] -clock clk [all_inputs]
set_output_delay [ expr $clk_period*0.5 ] -clock clk [all_outputs]
set_input_delay 0 -clock clk clk
set_input_delay 0 -clock clk rst

set_load 0.05 [all_outputs]
set_max_delay $clk_period -from [all_inputs] -to [all_outputs]

#set_dont_use slow/JKFF*
#======================================================
#  Optimization
#======================================================
check_design > Report/$DESIGN\.check
uniquify
set_fix_multiple_port_nets -all -buffer_constants

current_design $DESIGN
#set_false_path -from clk -to [get_cells */latch_or_sleep_reg ]

#uniquify
compile_ultra -timing -retime

#======================================================
#  Output Reports 
#======================================================
report_timing >  Report/$DESIGN\.timing
report_area >  Report/$DESIGN\.area
report_power >  Report/$DESIGN\.power
report_resource >  Report/$DESIGN\.resource


#======================================================
#  Change Naming Rule
#======================================================
set bus_inference_style "%s\[%d\]"
set bus_naming_style "%s\[%d\]"
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "a-z A-Z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "a-z A-Z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
change_names -hierarchy -rules name_rule

#======================================================
#  Output Results
#======================================================

set verilogout_higher_designs_first true
write -format verilog -output Netlist/$DESIGN\_SYN.v -hierarchy

#set_annotated_delay 0 -cell -to [get_pins -filter "pin_direction == out" -of_objects [get_cells "GATED_*/U*" -filter "ref_name==OR2X1"]]
#set_annotated_delay 0 -cell -to [get_pins -filter "pin_direction == out" -of_objects [get_cells "GATED_*/latch*" -filter "ref_name==TLATRX1"]]

write_sdf -version 3.0 -context verilog -load_delay cell Netlist/$DESIGN\_SYN.sdf -significant_digits 6
write_sdc Netlist/$DESIGN\_SYN.sdc

#======================================================
#  Finish and Quit
#======================================================

exit
