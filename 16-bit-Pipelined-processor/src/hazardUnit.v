module hazardUnit#(parameter REG_WIDTH = 4)
       (
           //Hazard unit
           input  clk,
           input  rst,

           //Forwarding
           input[REG_WIDTH-1:0] rsE        ,
           input[REG_WIDTH-1:0] rtE        ,

           input RegWriteD  ,
           input RegWriteM  ,
           input RegWriteW  ,
           input R_type     ,

           input[REG_WIDTH-1:0] WriteRegM  ,
           input[REG_WIDTH-1:0] WriteRegW  ,

           input[REG_WIDTH-1:0] rsM        ,
           input[REG_WIDTH-1:0] rsD        ,
           input[REG_WIDTH-1:0] rtD        ,

           input MemReadE   ,
           input MemWriteM  ,
           input MemReadW   ,
           input stop       ,
           input PCSrc      ,
           input jump       ,

           //Hazard_control_outputs
           //Forwarding
           output reg[1:0] alu_src1,
           output reg[1:0] alu_src2,
           output reg      mem_src,

           //Stall detection
           output reg      flushEX_MEM,
           output reg      flushIF_ID,
           output reg      pcstall,

           //Control hazard
           output reg      flushID_EX,
           output reg      IF_IDstall,
           output reg      ID_EXstall,
           output reg      EX_MEMstall,
           output reg      MEM_WBstall);

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
    if((rsM!= 0 ) && (rsM == WriteRegW) && (MemReadW == 1) && (MemWriteM == 1))
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
    else if((((rsD==rsE) || (rtD == rsE)) && (MemReadE == 1)) && (R_type == 1))
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
