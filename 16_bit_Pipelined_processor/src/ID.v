module ID#(parameter DATA_WIDTH = 16,
           parameter ADDR_WIDTH = 8,
           parameter IMM8_WIDTH = 8,
           parameter REG_WIDTH  = 4,
           parameter CV_WIDTH   = 11,
           parameter OP_WIDTH   = 4)
       (input rst,
        input clk,
        input[ADDR_WIDTH-1:0] PCD_i,
        input[DATA_WIDTH-1:0] instruction_mem_rD_i,
        input flush_ID_EX_i,
        input stall_ID_EX_i,

        //REGFILE
        output[REG_WIDTH-1:0] reg_file_r1,
        output[REG_WIDTH-1:0] reg_file_r2,

        //Hazard unit inputs
        output[REG_WIDTH-1:0]  rsD ,
        output[REG_WIDTH-1:0]  rtD ,
        output[REG_WIDTH-1:0]  rdD ,

        //LW-R hazard needed
        output RegWrite_o,
        output R_type    ,

        //IF/ID
        output reg[REG_WIDTH-1:0]  rtE,
        output reg[REG_WIDTH-1:0]  rsE,
        output reg[REG_WIDTH-1:0]  rdE,
        output reg[ADDR_WIDTH-1:0] PCE,
        output reg[IMM8_WIDTH-1:0] imm8D,

        output Stop,

        output reg RegWriteE,
        output reg[1:0] ALUopE,
        output reg BranchE,
        output reg MemReadE,
        output reg RegDstE,
        output reg MemWriteE,
        output reg MemToRegE,
        output reg MovE,
        output reg FloatingE,
        output reg jumpE
       );

//Instruction bit slices from IM
assign  rsD     = instruction_mem_rD_i[11:8];
assign  rtD     = instruction_mem_rD_i[7:4];
assign  rdD     = instruction_mem_rD_i[3:0];
wire[IMM8_WIDTH-1:0] imm8D_w = instruction_mem_rD_i[7:0];
wire[OP_WIDTH-1:0]   opcode = instruction_mem_rD_i[15:12];

//Control vector
wire[1:0] ALUop;
wire RegWrite;
wire Branch;
wire MemRead;
wire RegDst;
wire MemWrite;
wire MemToReg;
wire Mov;
wire Floating;
wire Jump;

//RF access
assign reg_file_r1 = rsD;
assign reg_file_r2 = rtD;

CTR ctr(.opcode_i(opcode),

        //Outputs
        .RegWrite(RegWrite),
        .ALUop(ALUop),
        .Branch(Branch),
        .MemRead(MemRead),
        .RegDst(RegDst),
        .MemWrite(MemWrite),
        .Jump(Jump),
        .MemToReg(MemToReg),
        .Mov(Mov),
        .Floating(Floating),
        .Stop(Stop),
        .R_type(R_type));

//LW-R hazard, ID stage R, EX stage LW
assign RegWrite_o = RegWrite;

// ID/EX
always @(posedge clk)
begin
    if(rst)
    begin
        PCE   <= PCD_i;
        RegWriteE <= 'd0;
        ALUopE <= 'd0;
        BranchE <= 'd0;
        MemReadE <= 'd0;
        RegDstE <= 'd0;
        MemWriteE <= 'd0;
        MemToRegE <= 'd0;
        MovE <= 'd0;
        FloatingE <= 'd0;

        rtE <= 'd15;
        rsE <= 'd15;
        rdE <= 'd15;
        imm8D<= 'd250;
        jumpE <= 'd0;

    end
    else if(stall_ID_EX_i)
    begin
        PCE   <= PCE;
        RegWriteE <= RegWriteE;
        ALUopE <= ALUopE;
        BranchE <= BranchE;
        MemReadE <= MemReadE;
        RegDstE <= RegDstE;
        MemWriteE <= MemWriteE;
        MemToRegE <= MemToRegE;
        MovE <= MovE;
        FloatingE <= FloatingE;

        rtE <= rtE;
        rsE <= rsE;
        rdE <= rdE;
        imm8D<= imm8D;
        jumpE <= jumpE;
    end
    else if(flush_ID_EX_i)
    begin
        PCE   <= 'd0;
        RegWriteE <= 'd0;
        ALUopE <= 'd0;
        BranchE <= 'd0;
        MemReadE <= 'd0;
        RegDstE <= 'd0;
        MemWriteE <= 'd0;
        MemToRegE <= 'd0;
        MovE <= 'd0;
        FloatingE <= 'd0;

        rtE <= 'd0;
        rsE <= 'd0;
        rdE <= 'd0;
        imm8D<='d0;
        jumpE <= 'd0;
    end
    else
    begin
        PCE   <= PCD_i;
        RegWriteE <= RegWrite;
        ALUopE <= ALUop;
        BranchE <= Branch;
        MemReadE <= MemRead;
        RegDstE <= RegDst;
        MemWriteE <= MemWrite;
        MemToRegE <= MemToReg;
        MovE <= Mov;
        FloatingE <= Floating;

        rtE <= rtD;
        rsE <= rsD;
        rdE <= rdD;
        imm8D<=imm8D_w;
        jumpE <= Jump;
    end
end

endmodule
module CTR#(parameter OP_WIDTH = 4,
            parameter CV_WIDTH = 12)
       (input [OP_WIDTH-1:0] opcode_i,
        output RegWrite ,
        output[1:0] ALUop ,
        output Branch ,
        output MemRead ,
        output RegDst ,
        output MemWrite ,
        output Jump ,
        output MemToReg ,
        output Mov ,
        output Floating ,
        output Stop,
        output R_type);

//Basic instructions OP
localparam ADD =    4'b0010 ;
localparam SW =     4'b0001 ;
localparam LW =     4'b0000 ;
localparam SUB =    4'b0100 ;
localparam MOV =    4'b0011 ;
localparam JMPZ =   4'b0101 ;
localparam STOP =   4'b0111 ;
localparam ADDF =   4'b1000 ;
localparam MULTF =  4'b1001 ;
localparam NOP =    4'b1111 ;
localparam SLT =    4'b1010 ;
localparam JUMP =   4'b0110 ;


wire _ADD_       = opcode_i == ADD;
wire _SW_        = opcode_i == SW;
wire _LW_        = opcode_i == LW;
wire _SUB_       = opcode_i == SUB;
wire _MOV_       = opcode_i == MOV;
wire _JMPZ_      = opcode_i == JMPZ;
wire _STOP_      = opcode_i == STOP;
wire _ADDF_      = opcode_i == ADDF;
wire _MULTF_     = opcode_i == MULTF;
wire _NOP_       = opcode_i == NOP;
wire _SLT_       = opcode_i == SLT;
wire _JUMP_      = opcode_i == JUMP;
assign R_type    = _ADD_ || _SUB_ || _MULTF_ || _NOP_ || _STOP_ || _JMPZ_ || _SLT_; //Note JMPZ is not R_type but is needs forwarding.


//Basic instruction ControlVector
localparam ADD_CV   =       12'b100000000000;
localparam SW_CV    =       12'b000000100000;
localparam LW_CV    =       12'b100011001000;
localparam SUB_CV   =       12'b101000000000;
localparam MOV_CV   =       12'b100001000100;
localparam JMPZ_CV  =       12'b000100000000;
localparam STOP_CV  =       12'b000000000001;
localparam ADDF_CV  =       12'b100000000010;
localparam MULTF_CV =       12'b100000000010;
localparam NOP_CV   =       12'b000000000000;
localparam SLT_CV   =       12'b110000000000;
localparam JUMP_CV  =       12'b000000010000;

reg[CV_WIDTH-1:0] control_vector;
//Main CTR decoder
always @(*)
begin
    case(opcode_i)
        ADD:
        begin
            control_vector = ADD_CV;
        end
        SW:
        begin
            control_vector = SW_CV;
        end
        LW:
        begin
            control_vector = LW_CV;
        end
        SUB:
        begin
            control_vector = SUB_CV;
        end
        MOV:
        begin
            control_vector = MOV_CV;
        end
        JMPZ:
        begin
            control_vector = JMPZ_CV;
        end
        STOP:
        begin
            control_vector = STOP_CV;
        end
        ADDF:
        begin
            control_vector = ADDF_CV;
        end
        MULTF:
        begin
            control_vector = MULTF_CV;
        end
        NOP:
        begin
            control_vector = NOP_CV;
        end
        JUMP:
        begin
            control_vector = JUMP_CV;
        end
        default:
        begin
            control_vector = NOP;
        end
    endcase
end

assign {RegWrite,ALUop[1:0],Branch,MemRead,RegDst,MemWrite,Jump,MemToReg,Mov,Floating,Stop} = control_vector;

endmodule
