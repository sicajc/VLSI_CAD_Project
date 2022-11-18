`define OP_WIDTH 4
`define CV_WIDTH 10
`define HZ_CV_WIDTH 10
`define STATES_WIDTH 15
`define ADDR_WIDTH 8
`define DATA_WIDTH 16

module pipelinedPS(
           input  clk,
           input  rst,

           input  start,                  // to start the processor
           output stop,                   // to show that the processor is stopped

           //control signals for instruction memory (im)
           input   [`DATA_WIDTH-1:0] im_r_data,      // 16-bit read data of im
           output  [`ADDR_WIDTH-1:0]  im_addr,        // 8-bit data address of im
           output  im_rd,                 // read enable of im

           //control signals for data memory (dm)
           output  [`ADDR_WIDTH-1:0] dm_addr,         // 8-bit data address of dm
           output  dm_rd,                 // read enable of dm
           output  dm_wr,                 // write enable of dm

           //data for data memory (dm)
           input  [`DATA_WIDTH-1:0] dm_r_data,       // 16-bit read data
           output [`DATA_WIDTH-1:0] dm_w_data        // 16-bit write data
       );

//Controlpath
wire[`OP_WIDTH-1:0] opcode;
wire[`CV_WIDTH-1:0] control_vector;
wire[`STATES_WIDTH-1:0] path_states;
wire[`HZ_CV_WIDTH-1:0]  hazard_control_vector;

controlpath CP(
                //Main CTR
                .opcode_i(opcode),
                .control_vector_o(control_vector),

                //Hazard unit
                .path_states_i(path_states),
                .hazard_control_vector_o(hazard_control_vector)
            );

datapath DP(
             //Perpherals
             .clk_i(clk),
             .rst_i(rst),
             .start_i(start),

             .stop_o(stop),

             //data memory
             .dm_r_data_i(dm_r_data),

             .dm_addr_o(dm_addr),
             .dm_rd_o(dm_rd),
             .dm_w_dat_o(dm_w_data),
             .dm_wr_o(dm_wr),

             //instruction memory
             .im_r_data_i(im_r_data),

             .im_addr_o(im_addr),
             .im_rd(im_rd)
);

endmodule
