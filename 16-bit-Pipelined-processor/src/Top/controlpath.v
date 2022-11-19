//Basic parameters
`define OP_WIDTH    4
`define CV_WIDTH    11
`define DP_STATES_WIDTH  13
`define HZ_CV_WIDTH 13

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

module controlpath();

//Main CTR
input  wire[`OP_WIDTH-1:0]   opcode_i;
output reg[`CV_WIDTH-1:0]   control_vector_o;


//Hazard unit
input  wire[`DP_STATES_WIDTH-1:0] path_states_i;
input  clk;
input  rst;

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
reg      flushID_EX;
reg      IF_IDstall;
reg      ID_EXstall;
reg      EX_MEMstall;
reg      MEM_WBstall;

assign hazard_control_vector_o = {alu_src1,alu_src2,mem_src,flushEX_MEM,flushIF_ID,flushID_EX,pcstall,IF_IDstall,ID_EXstall,EX_MEMstall,MEM_WBstall};

//Hazard_control_inputs
//Forwarding
wire rsE        = path_states_i[0];
wire rtE        = path_states_i[1];
wire WriteRegM  = path_states_i[2];
wire WriteRegW  = path_states_i[3];
wire RegWriteM  = path_states_i[4];
wire RegWriteW  = path_states_i[5];
wire rsM        = path_states_i[6];

//Stall detection
wire rsI        = path_states_i[7];
wire rtI        = path_states_i[8];
wire MemReadE   = path_states_i[9];
wire stop       = path_states_i[10];

//Control hazard
wire PCSrc      = path_states_i[11];
wire jump       = path_states_i[12];


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
//Fowarding
always @(*)
begin
    if((rsE != 0 ) && (rsE == WriteRegM) && (RegWriteM == 1))
    begin
        alu_src1 = 2'b01;
    end
    else if ((rsE !=0 ) && (rsE == WriteRegW) && (RegWriteW == 1))
    begin
        alu_src1 = 2'b10;
    end
    else
    begin
        alu_src1 = 2'b00;
    end
end


always @(*)
begin
    if((rtE != 0 ) && (rtE == WriteRegM) && (RegWriteM == 1))
    begin
        alu_src2 = 2'b01;
    end
    else if ((rtE !=0 ) && (rtE == WriteRegW) && (RegWriteW == 1))
    begin
        alu_src2 = 2'b10;
    end
    else
    begin
        alu_src2 = 2'b00;
    end
end

always @(*)
begin
    if((rsM!= 0 ) && (rsM == WriteRegW) && (MemReadE == 1))
    begin
        mem_src = 1'b1;
    end
    else
    begin
        mem_src = 1'b0;
    end
end

//Stall
always @(*)
begin
    if(stop)
    begin
        IF_IDstall  = 1'b1;
        ID_EXstall  = 1'b1;
        EX_MEMstall = 1'b1;
        MEM_WBstall = 1'b1;
        pcstall     = 1'b1;

        flushID_EX  = 1'b0;
    end
    else if((rsI == rsE) && (rsI!=0) || ((rsI==rsE) && (rtI!=0) && (MemReadE == 1)))
    begin
        IF_IDstall  = 1'b0;
        ID_EXstall  = 1'b0;
        EX_MEMstall = 1'b0;
        MEM_WBstall = 1'b0;
        pcstall     = 1'b1;

        flushID_EX   = 1'b1;
    end
    else
    begin
        IF_IDstall  = 1'b0;
        ID_EXstall  = 1'b0;
        EX_MEMstall = 1'b0;
        MEM_WBstall = 1'b0;
        pcstall     = 1'b0;

        flushID_EX   = 1'b0;
    end
end

reg branch_hazard_flag_w;
reg branch_hazard_flag_r;

wire branch_flush_flag = branch_hazard_flag_w && branch_hazard_flag_r;
//Control Hazard
always @(*)
begin
    if(jump==1)
    begin
        //Only need to flush for 1 cycle.
        flushIF_ID  = 1'b1;
        flushEX_MEM = 1'b0;
    end
    else if(branch_flush_flag)
    begin
        // need to flush for 3 cycles.
        flushIF_ID  = 1'b0;
        flushEX_MEM = 1'b1;
    end
    else
    begin
        flushIF_ID  = 1'b0;
        flushEX_MEM = 1'b0;
    end
end

reg[2:0] flush_cnt;
wire flush_done_flag  = (flush_cnt == 'd2);

always @(posedge clk)
begin
    if(rst)
    begin
        flush_cnt <= 3'd0;
    end
    else if(branch_hazard_flag_r || branch_hazard_flag_w)
    begin
        flush_cnt <= flush_cnt + 3'd1;
    end
    else if(flush_done_flag)
    begin
        flush_cnt <= 3'd0;
    end
    else
    begin
        flush_cnt <= flush_cnt;
    end
end

always @(posedge clk)
begin
    branch_hazard_flag_r <= rst ? 1'd0 : branch_hazard_flag_w;
end
always @(*)
begin
    if(rst)
    begin
        branch_hazard_flag_w = 1'b0;
    end
    else if(PCSrc)
    begin
        branch_hazard_flag_w = 1'd1;
    end
    else if(flush_done_flag)
    begin
        branch_hazard_flag_w = 1'b0;
    end
    else
    begin
        branch_hazard_flag_w = branch_hazard_flag_r;
    end
end

endmodule
