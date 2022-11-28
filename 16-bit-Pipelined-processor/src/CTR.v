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
