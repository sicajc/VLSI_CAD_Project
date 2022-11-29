module EX#(parameter DATA_WIDTH = 16,
           parameter ADDR_WIDTH = 8,
           parameter IMM8_WIDTH = 8,
           parameter REG_WIDTH  = 4,
           parameter CV_WIDTH   = 11,
           parameter OP_WIDTH   = 4)
       (input clk,
        input rst,

        input[ADDR_WIDTH-1:0] PCE_i,

        //RF
        input[DATA_WIDTH-1:0] r1_data_r_i,
        input[DATA_WIDTH-1:0] r2_data_r_i,

        //ID/EX
        input[IMM8_WIDTH-1:0] imm8E_i,
        input[REG_WIDTH-1:0] rsE_i,
        input[REG_WIDTH-1:0] rdE_i,
        input flush_EX_MEM_i,
        input stall_EX_MEM_i,

        //Control Vector
        input RegWriteE_i ,
        input[1:0] ALUopE_i ,
        input BranchE_i ,
        input MemReadE_i ,
        input RegDstE_i ,
        input MemWriteE_i ,
        input MemToRegE_i ,
        input MovE_i ,
        input FloatingE_i ,
        input jumpE_i,


        //EX/ME
        //Data
        output reg[ADDR_WIDTH-1:0] PCM_o,
        output reg[DATA_WIDTH-1:0] WriteDataM_o,
        output reg[IMM8_WIDTH-1:0] imm8M_o,
        output reg[REG_WIDTH-1:0]  rsM_o,
        output reg[REG_WIDTH-1:0]  WriteRegM_o,
        output reg[DATA_WIDTH-1:0] alu_outM_o,

        //Control signals
        output reg RegWriteM_o ,
        output reg BranchM_o ,
        output reg MemReadM_o ,
        output reg MemWriteM_o ,
        output reg MemToRegM_o ,
        output reg MovM_o,
        output reg jumpM_o,

        //Hazard signals
        //Forwarded data
        input[DATA_WIDTH-1:0] WBResultM_i,
        input[DATA_WIDTH-1:0] ResultW_i,
        //Forward signal
        input[1:0] alu_src1_i,
        input[1:0] alu_src2_i);

reg[DATA_WIDTH-1:0] alu_in1;
reg[DATA_WIDTH-1:0] alu_in2;

wire[DATA_WIDTH-1:0] WriteDataE_w;
wire[DATA_WIDTH-1:0] WriteRegE_w;
reg[DATA_WIDTH-1:0] alu_w;

//ALU_SRC1
always @(*)
begin
    case(alu_src1_i)
        'd0:
        begin
            alu_in1 = r1_data_r_i;
        end
        'd1:
        begin
            alu_in1 = WBResultM_i;
        end
        'd2:
        begin
            alu_in1 = ResultW_i;
        end
        default:
        begin
            alu_in1 = r1_data_r_i;
        end
    endcase
end

//ALU_SRC2
always @(*)
begin
    case(alu_src2_i)
        'd0:
        begin
            alu_in2 = r2_data_r_i;
        end
        'd1:
        begin
            alu_in2 = WBResultM_i;
        end
        'd2:
        begin
            alu_in2 = ResultW_i;
        end
        default:
        begin
            alu_in2 = r2_data_r_i;
        end
    endcase
end

//ALU
always @(*)
begin
    case(ALUopE_i)
    2'b00: alu_w = alu_in1 + alu_in2;
    2'b01: alu_w = alu_in1 - alu_in2;
    2'b10: alu_w = alu_in1 < alu_in2;
    default: alu_w = 2'd0;
    endcase
end

// EX/MEM
always @(posedge clk)
begin
    if(rst)
    begin
        PCM_o <= 'd0;

        WriteDataM_o<='d0;
        imm8M_o<='d0;
        rsM_o<='d0;
        WriteRegM_o<='d0;
        alu_outM_o<='d0;

        RegWriteM_o<='d0;
        BranchM_o<='d0;
        MemReadM_o<='d0;
        MemWriteM_o<='d0;
        MemToRegM_o<='d0;
        MovM_o<='d0;
        jumpM_o <= 'd0;
    end
    else if(flush_EX_MEM_i)
    begin
        PCM_o <= 'd0;

        WriteDataM_o<='d0;
        imm8M_o<= 'd15;
        rsM_o<= 'd15;
        WriteRegM_o<= 'd15;
        alu_outM_o<= 'd15;

        RegWriteM_o<='d0;
        BranchM_o<='d0;
        MemReadM_o<='d0;
        MemWriteM_o<='d0;
        MemToRegM_o<='d0;
        MovM_o<='d0;
        jumpM_o <= 'd0;
    end
    else if(stall_EX_MEM_i)
    begin
        PCM_o <= PCM_o;

        WriteDataM_o        <=  WriteDataM_o;
        imm8M_o             <=  imm8M_o;
        rsM_o               <=  rsM_o;
        WriteRegM_o         <=  WriteRegM_o;
        alu_outM_o          <=  alu_outM_o;

        RegWriteM_o         <=  RegWriteM_o;
        BranchM_o           <=  BranchM_o;
        MemReadM_o          <=  MemReadM_o;
        MemWriteM_o         <=  MemWriteM_o;
        MemToRegM_o         <=  MemToRegM_o;
        MovM_o              <=  MovM_o;
        jumpM_o <= jumpM_o;
    end
    else
    begin
        PCM_o <= PCE_i;

        WriteDataM_o        <=  WriteDataE_w;
        imm8M_o             <=  imm8E_i;
        rsM_o               <=  rsE_i;
        WriteRegM_o         <=  WriteRegE_w;
        alu_outM_o          <=  alu_w;

        RegWriteM_o         <=  RegWriteE_i;
        BranchM_o           <=  BranchE_i;
        MemReadM_o          <=  MemReadE_i;
        MemWriteM_o         <=  MemWriteE_i;
        MemToRegM_o         <=  MemToRegE_i;
        MovM_o              <=  MovE_i;
        jumpM_o <= jumpE_i;
    end
end

//EX
assign WriteDataE_w = alu_in1;
assign WriteRegE_w  = RegDstE_i ? rsE_i : rdE_i;

endmodule
