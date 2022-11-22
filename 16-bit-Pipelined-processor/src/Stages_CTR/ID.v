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
        input RegWriteW_i,

        //REGFILE
        output[DATA_WIDTH-1:0] reg_file_r1,
        output[DATA_WIDTH-1:0] reg_file_r2,

        //Forward to IF
        output[IMM8_WIDTH-1:0] jumpAddr,

        //Hazard unit inputs
        output[REG_WIDTH-1:0]  rsD ,
        output[REG_WIDTH-1:0]  rtD ,
        output[REG_WIDTH-1:0]  rdD ,

        //IF/ID
        output[REG_WIDTH-1:0]  rtE,
        output[REG_WIDTH-1:0]  rsE,
        output[REG_WIDTH-1:0]  rdE,
        output reg[ADDR_WIDTH-1:0] PCE,

        output reg Jump,
        output reg Stop,

        output reg RegWriteE,
        output reg ALUopE,
        output reg BranchE,
        output reg MemReadE,
        output reg RegDstE,
        output reg MemWriteE,
        output reg MemToRegE,
        output reg MovE,
        output reg FloatingE,
       );

//Instruction bit slices from IM
assign  rsD    = instruction_mem_rD_i[11:8];
assign  rtD    = instruction_mem_rD_i[7:4];
assign  rdD    = instruction_mem_rD_i[3:0];
wire[IMM8_WIDTH-1:0] imm8D = instruction_mem_rD_i[7:0];
wire[OP_WIDTH-1:0]   opcode = instruction_mem_rD_i[15:12];

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

CTR ctr(.opcode_i(opcode),
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
        .Stop(Stop));

reg_file RF(.rst(rst),.clk(clk),
            .w_en(RegWriteW),.w_addr(WriteRegW),.w_data(ResultW),
            .r1_en(1'b1),.r2_en(1'b1),.r1_addr(rsD),.r2_addr(rtD),.r1_data(reg_file_r1),.r2_data(reg_file_r2));

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
        JumpE <= 'd0;
        MemToRegE <= 'd0;
        MovE <= 'd0;
        FloatingE <= 'd0;
        StopE <= 'd0;
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
        JumpE <= JumpE;
        MemToRegE <= MemToRegE;
        MovE <= MovE;
        FloatingE <= FloatingE;
        StopE <= StopE;
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
        JumpE <= 'd0;
        MemToRegE <= 'd0;
        MovE <= 'd0;
        FloatingE <= 'd0;
        StopE <= 'd0;
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
        JumpE <= Jump;
        MemToRegE <= MemToReg;
        MovE <= Mov;
        FloatingE <= Floating;
        StopE <= Stop;
    end
end

endmodule
