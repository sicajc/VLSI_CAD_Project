module IF#(parameter DATA_WIDTH = 16,
           parameter ADDR_WIDTH = 8)
       (input rst,
        input clk,

        //Control inputs
        input jump_i,
        input PC_src_i,

        //Forwarded addr
        input branchAddr_i,
        input jumpAddr_i,

        //IF/ID control inputs
        input flushIF_ID_i,
        input stallIF_ID_i,
        input stallPC_i,

        //IM accesses
        output[ADDR_WIDTH-1:0]  im_addr_o,
        output                  im_rd_o,

        //IF/ID output
        output reg[ADDR_WIDTH-1:0] PCD_IF_ID_rd_o);

reg[ADDR_WIDTH-1:0] pc_rd;
reg[ADDR_WIDTH-1:0] pc_wr;
wire[ADDR_WIDTH-1:0] PCF;


//PC & adder
always @(posedge clk )
begin
    pc_rd <= rst ? 'd0 : pc_wr;
end

always @(*)
begin
    if(stallIF_ID_i)
    begin
        pc_wr = pc_rd;
    end
    else if(PC_src_i)
    begin
        pc_wr = branchAddr_i;
    end
    else if(jump_i)
    begin
        pc_wr = jumpAddr_i;
    end
    else
    begin
        pc_wr = PCF;
    end
end

assign PCF = pc_rd + 8'b1;

//IM
assign im_addr_o = pc_rd;
assign im_addr_o = 1'b1;


//IF/ID
always @(posedge clk)
begin
    if(rst)
    begin
        PCD_IF_ID_rd_o <= 8'd0;
    end
    else if(stallIF_ID_i)
    begin
        PCD_IF_ID_rd_o <= PCD_IF_ID_rd_o;
    end
    else if(flushIF_ID_i)
    begin
        PCD_IF_ID_rd_o <= 8'd0;
    end
    else
    begin
        PCD_IF_ID_rd_o <= PCF;
    end
end

endmodule
