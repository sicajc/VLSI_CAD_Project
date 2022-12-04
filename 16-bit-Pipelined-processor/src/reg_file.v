module reg_file #(
parameter  DEPTH = 4,
parameter  ADDR = 2,
parameter  WIDTH = 8)

(
input     rst,
input     clk,

input     w_en,                   // write enable
input     [ADDR-1:0]    w_addr,   // write address

input     r1_en,                  // #1-port read enable
input     r2_en,                  // #2-port read enable
input     [ADDR-1:0]    r1_addr,  // #1-port read address
input     [ADDR-1:0]    r2_addr,  // #2-port read address

input     [WIDTH-1:0]   w_data,   // write data

output reg   [WIDTH-1:0]   r1_data,  // #1-port read data
output reg   [WIDTH-1:0]   r2_data   // #2-port read data
);

reg [WIDTH-1:0]    rf[0:DEPTH-1];
always @(posedge clk)
begin
  r1_data <= (r1_en) ? rf[r1_addr] : {(WIDTH){1'b0}};
  r2_data <= (r2_en) ? rf[r2_addr] : {(WIDTH){1'b0}};
end

always@(posedge clk or posedge rst) // negedge wb
begin: rf_block
  integer i;
  if(rst)
     for(i=0; i<DEPTH; i=i+1)
           rf[i] <= {(WIDTH){1'b0}};
  else if(w_en)
           rf[w_addr] <= w_data;
end

endmodule
