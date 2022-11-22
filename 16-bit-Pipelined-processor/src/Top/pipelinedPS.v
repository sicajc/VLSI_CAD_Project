module pipelinedPS#(parameter OP_WIDTH  = 4,
                    parameter CV_WIDTH  = 10,
                    parameter HZ_CV_WIDTH  = 10,
                    parameter STATES_WIDTH  = 15,
                    parameter ADDR_WIDTH  = 8,
                    parameter DATA_WIDTH  = 16)
       (
           input  clk,
           input  rst,

           input  start,                  // to start the processor
           output stop,                   // to show that the processor is stopped

           //control signals for instruction memory (im)
           input   [DATA_WIDTH-1:0] im_r_data,      // 16-bit read data of im
           output  [ADDR_WIDTH-1:0]  im_addr,        // 8-bit data address of im
           output  im_rd,                 // read enable of im

           //control signals for data memory (dm)
           output  [ADDR_WIDTH-1:0] dm_addr,         // 8-bit data address of dm
           output  dm_rd,                 // read enable of dm
           output  dm_wr,                 // write enable of dm

           //data for data memory (dm)
           input  [DATA_WIDTH-1:0] dm_r_data,       // 16-bit read data
           output [DATA_WIDTH-1:0] dm_w_data        // 16-bit write data
       );
//IM and DM are inside the testbench, so one must access them through interfaces.

CTR ctr();

hazardUnit hazardunit();

IF  IFstage();

ID  IDstage();
reg_file REG_file();

EX  EXstage();

MEM MEMstage();

WB  WBstage();




endmodule
