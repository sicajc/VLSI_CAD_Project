`define CV_WIDTH        11
`define HZ_CV_WIDTH     10
`define DP_STATES_WIDTH 15

`define DATA_WIDTH   16
`define ADDR_WIDTH   8

`define REG_WIDTH    4

`define IMM8_WIDTH   8
`define PC_WIDTH     8
`define OP_WIDTH     4

module datapath();
input[`HZ_CV_WIDTH-1:0] hazard_control_vector_i;
input[`CV_WIDTH   -1:0] control_vector_i;
input clk;
input rst;

output[`OP_WIDTH-1  :0] opcode_o;
output[`DP_STATES_WIDTH-1:0] path_states_o;

localparam IF_ID_PIPE_WIDTH  = `PC_WIDTH; //8
localparam ID_EX_PIPE_WIDTH  = `PC_WIDTH + `CV_WIDTH + `IMM8_WIDTH + `REG_WIDTH*3; //39
localparam EX_MEM_PIPE_WIDTH = `PC_WIDTH + `CV_WIDTH + `IMM8_WIDTH + `REG_WIDTH*2 + `DATA_WIDTH; //51
localparam MEM_WB_PIPE_WIDTH = `CV_WIDTH + `REG_WIDTH + `DATA_WIDTH; //31

//Components interconnections
wire[`PC_WIDTH-1:0]   pc_w;
reg [`PC_WIDTH-1:0]   pc_r;

wire[`PC_WIDTH-1:0]   instruction_mem_addrI;
wire[`DATA_WIDTH-1:0] instruction_mem_rD;

wire[`DATA_WIDTH-1:0] regfile_r1E;
wire[`DATA_WIDTH-1:0] regfile_r2E;

wire[`DATA_WIDTH-1:0] alu_rM;

wire[`DATA_WIDTH-1:0] data_mem_wM;
wire[`DATA_WIDTH-1:0] data_mem_rW;

//Pipeline Registers
reg[IF_ID_PIPE_WIDTH-1:0] IF_ID_pipe_r;
reg[ID_EX_PIPE_WIDTH-1:0] ID_EX_pipe_r;
reg[EX_MEM_PIPE_WIDTH-1:0] EX_MEM_pipe_r;
reg[MEM_WB_PIPE_WIDTH-1:0] MEM_WB_pipe_r;

wire[IF_ID_PIPE_WIDTH-1:0] IF_ID_pipe_w;
wire[ID_EX_PIPE_WIDTH-1:0] ID_EX_pipe_w;
wire[EX_MEM_PIPE_WIDTH-1:0] EX_MEM_pipe_w;
wire[MEM_WB_PIPE_WIDTH-1:0] MEM_WB_pipe_w;

//Hazard control
wire alu_src1;
wire alu_src2;
wire mem_src;
wire flushEX_MEM;
wire flushIF_ID;
wire flushID_EX;
wire pcstall;
wire IF_IDstall;
wire ID_EXstall;
wire EX_MEMstall;
wire MEM_WBstall;

assign {alu_src1,alu_src2,mem_src,flushEX_MEM,flushIF_ID,flushID_EX,pcstall,IF_IDstall,ID_EXstall,EX_MEMstall,MEM_WBstall}
       = hazard_control_vector_i;

//Control vector
wire RegWrite;
wire ALUop;
wire Branch;
wire MemRead;
wire RegDst;
wire MemWrite;
wire Jump;
wire MemToReg;
wire Mov;
wire Floating;
wire Stop;

//Forwarding signals
wire[`PC_WIDTH-1:0] jumpAddr;
wire[`PC_WIDTH-1:0] branchAddr;
wire PCSrc;
wire[`DATA_WIDTH-1:0] WBResultM;
wire[`DATA_WIDTH-1:0] ResultW;

//PC signals
wire[`PC_WIDTH-1:0] pcF;
wire[`PC_WIDTH-1:0] pcD;
wire[`PC_WIDTH-1:0] pcM;

//IF
assign pcF = pc_r + 8'd1;
assign pc_w = (Jump==1) ? jumpAddr : ( (PCSrc==1) ? branchAddr : (pc_r + 8'd1));

//IM

//IF/ID
always @(posedge clk)
begin
    IF_ID_pipe_r <= rst ? 'd0 : IF_ID_pipe_w;
end

assign IF_ID_pipe_w = (IF_IDstall == 1) ? IF_ID_pipe_r : pcF;

//ID
wire[`REG_WIDTH-1:0] rsD    = instruction_mem_rD[11:8];
wire[`REG_WIDTH-1:0] rtD    = instruction_mem_rD[7:4];
wire[`IMM8_WIDTH-1:0] imm8D = instruction_mem_rD[7:0];
wire[`REG_WIDTH-1:0] rdD    = instruction_mem_rD[3:0];
assign opcode_o = instruction_mem_rD[15:12];
wire[`DATA_WIDTH-1:0] r1_data_r;
wire[`DATA_WIDTH-1:0] r2_data_r;

assign {RegWrite,ALUop,Branch,MemRead,RegDst,MemWrite,Jump,MemToReg,Mov,Floating,Stop} = control_vector_i;
assign pcD = IF_ID_pipe_r;

//RF
reg_file RF(.rst(rst),.clk(clk),
            .w_en(RegWriteW),.w_addr(WriteRegW),.w_data(ResultW),
            .r1_en(1'b1),.r2_en(1'b1),.r1_addr(rsD),.r2_addr(rtD),.r1_data(r1_data_r),.r2_data(r2_data_r));

//ID/EX
always @(posedge clk)
begin
    ID_EX_pipe_r <= rst ? 'd0 : IF_ID_pipe_w;
end

assign ID_EX_pipe_w = (ID_EXstall==1) ? ID_EX_pipe_r : {pcD,control_vector_i,imm8D,rtD,rsD,rdD};

//EX
wire[`CV_WIDTH-1:0] control_vectorE;
wire[`IMM8_WIDTH-1:0] imm8E;
wire[`REG_WIDTH-1:0] rtE;
wire[`REG_WIDTH-1:0] rsE;
wire[`REG_WIDTH-1:0] rdE;

assign pcE             = ID_EX_pipe_r[39:32];
assign control_vectorE = ID_EX_pipe_r[31:21];
assign imm8E           = ID_EX_pipe_r[20:13];
assign rtE             = ID_EX_pipe_r[12:9];
assign rsE             = ID_EX_pipe_r[8:4];
assign rdE             = ID_EX_pipe_r[3:0];


reg[`DATA_WIDTH-1:0] alu_in1;
reg[`DATA_WIDTH-1:0] alu_in2;
wire[`DATA_WIDTH-1:0] WriteDataE = alu_in1;

//ALU_SRC1
always @(*)
begin
    case(alu_src1)
        'd0:
        begin
            alu_in1 = r1_data_r;
        end
        'd1:
        begin
            alu_in1 = WBResultM;
        end
        'd2:
        begin
            alu_in1 = ResultW;
        end
        default:
        begin
            alu_in1 = r1_data_r;
        end
    endcase
end

//ALU_SRC2
always @(*)
begin
    case(alu_src2)
        'd0:
        begin
            alu_in2 = r2_data_r;
        end
        'd1:
        begin
            alu_in2 = WBResultM;
        end
        'd2:
        begin
            alu_in2 = ResultW;
        end
        default:
        begin
            alu_in2 = r2_data_r;
        end
    endcase
end

//ALU
reg[`DATA_WIDTH-1:0]  alu_r;
wire[`DATA_WIDTH-1:0] alu_w;

always @(posedge clk )
begin
    alu_r <= rst ? 'd0 : alu_w;
end
assign alu_w = ALUop ? alu_in1-alu_in2 : alu_in1+alu_in2;

//RegDst
assign WriteRegE = RegDst ? rsE : rdE;


endmodule
