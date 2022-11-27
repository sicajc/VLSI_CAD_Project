module CTR#(parameter OP_WIDTH = 4,
            parameter CV_WIDTH = 11)
       (input [OP_WIDTH-1:0] opcode_i,
        output RegWrite ,
        output ALUop ,
        output Branch ,
        output MemRead ,
        output RegDst ,
        output MemWrite ,
        output Jump ,
        output MemToReg ,
        output Mov ,
        output Floating ,
        output Stop);

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


//Basic instruction ControlVector
localparam ADD_CV =       11'b10000000000;
localparam SW_CV =        11'b00000100000;
localparam LW_CV =        11'b10011001000;
localparam SUB_CV =       11'b11000000000;
localparam MOV_CV =       11'b10001000100;
localparam JMPZ_CV =      11'b00100000000;
localparam STOP_CV =      11'b00000000001;
localparam ADDF_CV =      11'b10000000010;
localparam MULTF_CV =     11'b10000000010;
localparam NOP_CV =       11'b00000000000;

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
        default:
        begin
            control_vector = NOP;
        end
    endcase
end

assign {RegWrite,ALUop,Branch,MemRead,RegDst,MemWrite,Jump,MemToReg,Mov,Floating,Stop} = control_vector;

endmodule
