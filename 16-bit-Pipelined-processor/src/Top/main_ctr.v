//Basic parameters
`define OP_WIDTH    4
`define CV_WIDTH    10
`define STATES_WIDTH  10
`define HZ_CV_WIDTH 10

//Basic instructions OP
`define ADD 4'b0010
`define SW  4'b0001
`define LW  4'b0000
`define SUB 4'b0100
`define MOV 4'b0011
`define JMPZ 4'b0101
`define STOP 4'b0111
`define ADDF 4'b1000
`define MULTF 4'b1001

//Basic instruction ControlVector
`define ADD_CV 10'b1000000000
`define SW_CV  10'b0000010000
`define LW_CV  10'b1001100100
`define SUB_CV 10'b1100000000
`define MOV_CV 10'b1000100010
`define JMPZ_CV 10'b0010000000
`define STOP_CV 10'b0000000000
`define ADDF_CV 10'
`define MULTF_CV






module Controlpath();

//Main CTR
input wire[`OP_WIDTH-1:0]   opcode_i;
output wire[`CV_WIDTH-1:0]  control_vector_o;

//Hazard unit
input wire[`STATES_WIDTH-1:0] path_states_i;
output wire[`HZ_CV_WIDTH-1:0] hazard_control_vector_o;


endmodule