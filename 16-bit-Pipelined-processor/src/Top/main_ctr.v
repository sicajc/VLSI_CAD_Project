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
`define NOP   4'b1111

//Basic instruction ControlVector
`define ADD_CV      11'b10000000000
`define SW_CV       11'b00000100000
`define LW_CV       11'b10011001000
`define SUB_CV      11'b11000000000
`define MOV_CV      11'b10001000100
`define JMPZ_CV     11'b00100000000
`define STOP_CV     11'b00000000001
`define ADDF_CV     11'b10000000010
`define MULTF_CV    11'b10000000010
`define NOP_CV      11'b00000000000

module Controlpath();

//Main CTR
input wire[`OP_WIDTH-1:0]   opcode_i;
output reg[`CV_WIDTH-1:0]   control_vector_o;

//Hazard unit
input wire[`STATES_WIDTH-1:0] path_states_i;
output wire[`HZ_CV_WIDTH-1:0] hazard_control_vector_o;

//Hazard_control_outputs
//Forwarding
reg[1:0] alu_src1;
reg[1:0] alu_src2;
reg      mem_src;

//Stall detection
reg      flushEX_MEM;
reg      flushIF_ID;
reg      pcstall;

//Control hazard
reg      flushIDEX;
reg      IFIDstall;

assign hazard_control_vector_o = {alu_src1,alu_src2,mem_src,flushEX_MEM,flushIF_ID,flushIDEX,pcstall,IFIDstall};

//Hazard_control_inputs
//Forwarding
wire rsE = path_states_i[0];
wire rtE = path_states_i[1];
wire WriteRegM = path_states_i[2];
wire WriteRegW = path_states_i[3];
wire RegWriteM = path_states_i[4];
wire RegWriteW = path_states_i[5];
wire rsM       = path_states_i[6];


//Main CTR decoder
always @(*)
begin
    case(opcode_i)
        `ADD:
        begin
            control_vector_o = `ADD_CV;
        end
        `SW:
        begin
            control_vector_o = `SW_CV;
        end
        `LW:
        begin
            control_vector_o = `LW_CV;
        end
        `SUB:
        begin
            control_vector_o = `SUB_CV;
        end
        `MOV:
        begin
            control_vector_o = `MOV_CV;
        end
        `JMPZ:
        begin
            control_vector_o = `JMPZ_CV;
        end
        `STOP:
        begin
            control_vector_o = `STOP_CV;
        end
        `ADDF:
        begin
            control_vector_o = `ADDF_CV;
        end
        `MULTF:
        begin
            control_vector_o = `MULTF_CV;
        end
        `NOP:
        begin
            control_vector_o = `NOP_CV;
        end
        default:
        begin
            control_vector_o = `NOP;
        end
    endcase
end

//Hazard unit control
//ALU_SRC1





endmodule
