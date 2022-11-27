module MEM #(parameter DATA_WIDTH = 16,
             parameter ADDR_WIDTH = 8,
             parameter IMM8_WIDTH = 8,
             parameter REG_WIDTH  = 4,
             parameter CV_WIDTH   = 11,
             parameter OP_WIDTH   = 4)
       (input clk,
        input rst,

        //From EX/MEM
        input[ADDR_WIDTH-1:0] PCM_i,
        input[DATA_WIDTH-1:0] alu_outM_i,
        input[DATA_WIDTH-1:0] WriteDataM_i,
        input[IMM8_WIDTH-1:0] imm8M_i,
        input[REG_WIDTH-1:0] rsM_i,
        input[REG_WIDTH-1:0] WriteRegM_i,

        //Hazard control
        input stall_MEM_WB_i,
        input MemSrc_i,

        //Controls
        input RegWriteM_i,
        input BranchM_i,
        input MemReadM_i,
        input MemWriteM_i,
        input MemToRegM_i,
        input MovM_i,

        //Forwarded signal
        input[DATA_WIDTH-1:0] ResultW_i,

        //Forward signal to IF
        output[ADDR_WIDTH-1:0] branchAddr_o,

        //MEM/WB
        output reg[DATA_WIDTH-1:0] WBResultM_o,
        output reg[REG_WIDTH-1:0] WriteRegM_o,
        output reg RegWriteM_o ,
        output reg MemToRegM_o ,
        output reg MemReadM_o,

        //DM
        output dm_rd,
        output dm_wr,
        output[ADDR_WIDTH-1:0] MemAddr_o,
        output[DATA_WIDTH-1:0] WriteDataM_o,

        //Hazard control
        output PC_src_o
       );

//Branch
assign PC_src_o = ((WriteDataM_o == 'd0) && (BranchM_i) );
assign branchAddr_o = PCM_i + imm8M_i;


//DM
assign  dm_wr = MemWriteM_i;
assign  dm_rd = MemReadM_i;
assign  MemAddr_o = imm8M_i;
assign WriteDataM_o = MemSrc_i ?  ResultW_i : WriteDataM_i ;

wire[DATA_WIDTH-1:0] sign_extended_val = {{8{imm8M_i[7]}},imm8M_i[7:0]};
//MEM/WB
wire[DATA_WIDTH-1:0] WBResult_w = MovM_i ? sign_extended_val : alu_outM_i;

always @(posedge clk )
begin
    if(rst)
    begin
        RegWriteM_o <= 'd0;
        MemToRegM_o <= 'd0;

        WBResultM_o <= 'd0;
        WriteRegM_o <= 'd0;
        MemReadM_o  <= 'd0;
    end
    else if(stall_MEM_WB_i)
    begin
        RegWriteM_o <= RegWriteM_o;
        MemToRegM_o <= MemToRegM_o;
        WBResultM_o <= WBResultM_o;
        WriteRegM_o <= WriteRegM_o;
        MemReadM_o  <= MemReadM_o;
    end
    else
    begin
        RegWriteM_o <= RegWriteM_i;
        MemToRegM_o <= MemToRegM_i;

        WBResultM_o <= WBResult_w;
        WriteRegM_o <= WriteRegM_i;
        MemReadM_o  <= MemReadM_i;
    end
end

endmodule
