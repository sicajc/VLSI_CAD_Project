###################################################################

# Created by write_sdc on Mon Nov 28 20:45:39 2022

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_load -pin_load 0.05 [get_ports stop]
set_load -pin_load 0.05 [get_ports {im_addr[7]}]
set_load -pin_load 0.05 [get_ports {im_addr[6]}]
set_load -pin_load 0.05 [get_ports {im_addr[5]}]
set_load -pin_load 0.05 [get_ports {im_addr[4]}]
set_load -pin_load 0.05 [get_ports {im_addr[3]}]
set_load -pin_load 0.05 [get_ports {im_addr[2]}]
set_load -pin_load 0.05 [get_ports {im_addr[1]}]
set_load -pin_load 0.05 [get_ports {im_addr[0]}]
set_load -pin_load 0.05 [get_ports im_rd]
set_load -pin_load 0.05 [get_ports {dm_addr[7]}]
set_load -pin_load 0.05 [get_ports {dm_addr[6]}]
set_load -pin_load 0.05 [get_ports {dm_addr[5]}]
set_load -pin_load 0.05 [get_ports {dm_addr[4]}]
set_load -pin_load 0.05 [get_ports {dm_addr[3]}]
set_load -pin_load 0.05 [get_ports {dm_addr[2]}]
set_load -pin_load 0.05 [get_ports {dm_addr[1]}]
set_load -pin_load 0.05 [get_ports {dm_addr[0]}]
set_load -pin_load 0.05 [get_ports dm_rd]
set_load -pin_load 0.05 [get_ports dm_wr]
set_load -pin_load 0.05 [get_ports {dm_w_data[15]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[14]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[13]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[12]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[11]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[10]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[9]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[8]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[7]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[6]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[5]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[4]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[3]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[2]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[1]}]
set_load -pin_load 0.05 [get_ports {dm_w_data[0]}]
create_clock [get_ports clk]  -period 60  -waveform {0 30}
set_max_delay 60  -from [list [get_ports clk] [get_ports rst] [get_ports start] [get_ports      \
{im_r_data[15]}] [get_ports {im_r_data[14]}] [get_ports {im_r_data[13]}]       \
[get_ports {im_r_data[12]}] [get_ports {im_r_data[11]}] [get_ports             \
{im_r_data[10]}] [get_ports {im_r_data[9]}] [get_ports {im_r_data[8]}]         \
[get_ports {im_r_data[7]}] [get_ports {im_r_data[6]}] [get_ports               \
{im_r_data[5]}] [get_ports {im_r_data[4]}] [get_ports {im_r_data[3]}]          \
[get_ports {im_r_data[2]}] [get_ports {im_r_data[1]}] [get_ports               \
{im_r_data[0]}] [get_ports {dm_r_data[15]}] [get_ports {dm_r_data[14]}]        \
[get_ports {dm_r_data[13]}] [get_ports {dm_r_data[12]}] [get_ports             \
{dm_r_data[11]}] [get_ports {dm_r_data[10]}] [get_ports {dm_r_data[9]}]        \
[get_ports {dm_r_data[8]}] [get_ports {dm_r_data[7]}] [get_ports               \
{dm_r_data[6]}] [get_ports {dm_r_data[5]}] [get_ports {dm_r_data[4]}]          \
[get_ports {dm_r_data[3]}] [get_ports {dm_r_data[2]}] [get_ports               \
{dm_r_data[1]}] [get_ports {dm_r_data[0]}]]  -to [list [get_ports stop] [get_ports {im_addr[7]}] [get_ports {im_addr[6]}]  \
[get_ports {im_addr[5]}] [get_ports {im_addr[4]}] [get_ports {im_addr[3]}]     \
[get_ports {im_addr[2]}] [get_ports {im_addr[1]}] [get_ports {im_addr[0]}]     \
[get_ports im_rd] [get_ports {dm_addr[7]}] [get_ports {dm_addr[6]}] [get_ports \
{dm_addr[5]}] [get_ports {dm_addr[4]}] [get_ports {dm_addr[3]}] [get_ports     \
{dm_addr[2]}] [get_ports {dm_addr[1]}] [get_ports {dm_addr[0]}] [get_ports     \
dm_rd] [get_ports dm_wr] [get_ports {dm_w_data[15]}] [get_ports                \
{dm_w_data[14]}] [get_ports {dm_w_data[13]}] [get_ports {dm_w_data[12]}]       \
[get_ports {dm_w_data[11]}] [get_ports {dm_w_data[10]}] [get_ports             \
{dm_w_data[9]}] [get_ports {dm_w_data[8]}] [get_ports {dm_w_data[7]}]          \
[get_ports {dm_w_data[6]}] [get_ports {dm_w_data[5]}] [get_ports               \
{dm_w_data[4]}] [get_ports {dm_w_data[3]}] [get_ports {dm_w_data[2]}]          \
[get_ports {dm_w_data[1]}] [get_ports {dm_w_data[0]}]]
set_input_delay -clock clk  0  [get_ports clk]
set_input_delay -clock clk  0  [get_ports rst]
set_input_delay -clock clk  30  [get_ports start]
set_input_delay -clock clk  30  [get_ports {im_r_data[15]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[14]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[13]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[12]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[11]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[10]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[9]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[8]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[7]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[6]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[5]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[4]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[3]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[2]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[1]}]
set_input_delay -clock clk  30  [get_ports {im_r_data[0]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[15]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[14]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[13]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[12]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[11]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[10]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[9]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[8]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[7]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[6]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[5]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[4]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[3]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[2]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[1]}]
set_input_delay -clock clk  30  [get_ports {dm_r_data[0]}]
set_output_delay -clock clk  30  [get_ports stop]
set_output_delay -clock clk  30  [get_ports {im_addr[7]}]
set_output_delay -clock clk  30  [get_ports {im_addr[6]}]
set_output_delay -clock clk  30  [get_ports {im_addr[5]}]
set_output_delay -clock clk  30  [get_ports {im_addr[4]}]
set_output_delay -clock clk  30  [get_ports {im_addr[3]}]
set_output_delay -clock clk  30  [get_ports {im_addr[2]}]
set_output_delay -clock clk  30  [get_ports {im_addr[1]}]
set_output_delay -clock clk  30  [get_ports {im_addr[0]}]
set_output_delay -clock clk  30  [get_ports im_rd]
set_output_delay -clock clk  30  [get_ports {dm_addr[7]}]
set_output_delay -clock clk  30  [get_ports {dm_addr[6]}]
set_output_delay -clock clk  30  [get_ports {dm_addr[5]}]
set_output_delay -clock clk  30  [get_ports {dm_addr[4]}]
set_output_delay -clock clk  30  [get_ports {dm_addr[3]}]
set_output_delay -clock clk  30  [get_ports {dm_addr[2]}]
set_output_delay -clock clk  30  [get_ports {dm_addr[1]}]
set_output_delay -clock clk  30  [get_ports {dm_addr[0]}]
set_output_delay -clock clk  30  [get_ports dm_rd]
set_output_delay -clock clk  30  [get_ports dm_wr]
set_output_delay -clock clk  30  [get_ports {dm_w_data[15]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[14]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[13]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[12]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[11]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[10]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[9]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[8]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[7]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[6]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[5]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[4]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[3]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[2]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[1]}]
set_output_delay -clock clk  30  [get_ports {dm_w_data[0]}]
