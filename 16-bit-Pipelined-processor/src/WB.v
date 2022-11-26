module WB #(parameter DATA_WIDTH = 16,
            parameter ADDR_WIDTH = 8,
            parameter IMM8_WIDTH = 8,
            parameter REG_WIDTH  = 4,
            parameter CV_WIDTH   = 11,
            parameter OP_WIDTH   = 4
           )(input clk,
             input rst,
             //MEM/WB
             //Data
             input[DATA_WIDTH-1:0] WBResultW_i,
             input[REG_WIDTH-1:0] WriteRegW_i,
             //Controls
             input  RegWriteW_i ,
             input  MemToRegW_i ,
             output RegWriteW_o,
             //DM
             input[DATA_WIDTH-1:0] memData_r_i,
             //To ID
             //RF_WB
             output[DATA_WIDTH-1:0] ResultW_o,
             //RF_WB_Addr
             output[REG_WIDTH-1:0] WriteRegW_o);

//Outputs to ID
assign ResultW_o = MemToRegW_i ? memData_r_i : WBResultW_i;
assign WriteRegW_o = WriteRegW_i;

endmodule
