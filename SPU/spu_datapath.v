module spu_datapath(

input clk,
input rst,


output pco_en, // if rf[a] equals to 0

//control signal for mux
input rf_s1,
input rf_s0,

//control signals for register file (rf)
input  [3:0] rf_w_addr,  // 4-bit write address 
input  rf_w_wr,          // write enable

input  [3:0] rf_rp_addr, // 4-bit p-port read address 
input  rf_rp_rd,         // p-port read enable

input  [3:0] rf_rq_addr, // 4-bit q-port read address 
input  rf_rq_rd,         // q-port read enable

//control signal for ALU
input	 alu_s1,
input  alu_s0,

//control signal for constant number is assigned
input	 [7:0] loac,

//data for data memory (dm)
input  [15:0] dm_r_data, // 16-bit read data
output [15:0] dm_w_data  // 16-bit write data
);

wire   [15:0] mux_out;

//data for rf
wire   [15:0] rf_rp_data;  // 16-bit rf p-port read data
wire   [15:0] rf_rq_data;  // 16-bit rf q-port read data

reg    [15:0] alu_out;

//mux
assign mux_out = rf_s1? loac : rf_s0? dm_r_data : alu_out;

assign dm_w_data = rf_rp_data;

assign pco_en = !rf_rp_data;

//register file
reg_file #(
 .DEPTH(16),
 .ADDR(4),
 .WIDTH(16))
  
rf(.rst(rst),
   .clk(clk),
   .w_en(rf_w_wr),        // write enable
   .w_addr(rf_w_addr),    // write address
   .r1_en(rf_rp_rd),      // #1-port read enable
   .r2_en(rf_rq_rd),      // #2-port read enable
   .r1_addr(rf_rp_addr),  // #1-port read address
   .r2_addr(rf_rq_addr),  // #2-port read address
   .w_data(mux_out),      // write data
   .r1_data(rf_rp_data),  // #1-port read data
   .r2_data(rf_rq_data)   // #2-port read data
);

always@(*)
begin
  case({alu_s1, alu_s0})
  2'd0: alu_out = rf_rp_data;
  2'd1: alu_out = rf_rp_data + rf_rq_data;
  2'd2: alu_out = rf_rp_data - rf_rq_data;
  default: alu_out = 16'd0;
  endcase
end


endmodule























