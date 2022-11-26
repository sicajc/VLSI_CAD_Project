`timescale 1ns/10ps

`define CYCLE      20.0
`define End_CYCLE  10000000  // Modify cycle times once your design need more cycle times!

module spu_test;

reg  clk = 1'b0;
reg  rst = 1'b0;

reg  start = 1'b0;           // to start the processor
wire stop;                   // to show that the processor is stopped

integer err = 0;

//control signals for instruction memory (im)
reg   [15:0] im_r_data;      // 16-bit read data of im
wire  [7:0]  im_addr;        // 8-bit data address of im
wire  im_rd;                 // read enable of im

//control signals for data memory (dm)
wire  [7:0] dm_addr;         // 8-bit data address of dm
wire  dm_rd;                 // read enable of dm
wire  dm_wr;                 // write enable of dm

//data for data memory (dm)
reg   [15:0] dm_r_data;       // 16-bit read data
wire  [15:0] dm_w_data;        // 16-bit write data

reg	[15:0] IM_MEM	[0:255];
reg	[15:0] DM_MEM	[0:255];

spu spu_inst(.clk(clk),
             .rst(rst),

             .start(start),          // to start the processor
             .stop(stop),            // to show that the processor is stopped

             //control signals for instruction memory (im)
             .im_r_data(im_r_data),  // 16-bit read data of im
             .im_addr(im_addr),      // 8-bit data address of im
             .im_rd(im_rd),          // read enable of im

             //control signals for data memory (dm)
             .dm_addr(dm_addr),      // 8-bit data address of dm
             .dm_rd(dm_rd),          // read enable of dm
             .dm_wr(dm_wr),          // write enable of dm

             //data for data memory (dm)
             .dm_r_data(dm_r_data),  // 16-bit read data
             .dm_w_data(dm_w_data)   // 16-bit write data
             );


always begin #(`CYCLE/2) clk = ~clk; end

initial begin  // global control

	$display("-----------------------------------------------------\n");
 	$display("START!!! Simulation Start .....\n");
 	$display("-----------------------------------------------------\n");

	@(negedge clk);
	#1; rst = 1'b1;

	#(`CYCLE*3);
	#1; rst = 1'b0;

	@(posedge clk);
	#1; start = 1'b1;

   #(`CYCLE);
	#5; start = 1'b0;
end

initial begin // initial pattern
	wait(rst==1);
	$readmemb("E:/Final/spu/src/im_data.txt", IM_MEM);
	$readmemh("E:/Final/spu/src/dm_data.txt", DM_MEM);
end

initial
begin
  $fsdbDumpfile("spu_test.fsdb");  //your waveform file for nWave
  $fsdbDumpvars;
end

// instruction memory model
always@(negedge clk)
begin
	if (im_rd == 1)
		 im_r_data <= #1 IM_MEM[im_addr];
end

// data memory model	for read
always@(negedge clk)
begin
	if (dm_rd == 1)
		 dm_r_data <= #1 DM_MEM[dm_addr];
end

// data memory model	for write
always@(posedge clk)
begin
	if (dm_wr == 1)
	    DM_MEM[dm_addr] <= #1 dm_w_data;
end

//-------------------------------------------------------------------------------------------------------------------
initial  begin
 #`End_CYCLE ;
 	$display("-----------------------------------------------------\n");
 	$display("Error!!! The simulation can't be terminated under normal operation!\n");
 	$display("-------------------------FAIL------------------------\n");
 	$display("-----------------------------------------------------\n");
 	$finish;
end

always@(posedge clk)
begin
  if(stop==1) begin
	 if(DM_MEM[10] !== DM_MEM[0]+DM_MEM[1])
       err = err +1;
	 if(DM_MEM[11] !== 16'h002f)
       err = err +1;
	 if(DM_MEM[12] !== DM_MEM[8]-DM_MEM[9])
       err = err +1;
	 if(DM_MEM[13] !== 16'h00ff)
       err = err +1;
	 if(DM_MEM[14] !== 16'h0000)
       err = err +1;
     if(DM_MEM[15] !== 16'h000a)
       err = err +1;
     if(DM_MEM[16] !== 16'h0001)
       err = err +1;
     if(DM_MEM[17] !== 16'h0002)
       err = err +1;

	  $display("DM_MEM[10] = %h\n", DM_MEM[10]);
	  $display("DM_MEM[11] = %h\n", DM_MEM[11]);
	  $display("DM_MEM[12] = %h\n", DM_MEM[12]);
	  $display("DM_MEM[13] = %h\n", DM_MEM[13]);
	  $display("DM_MEM[14] = %h\n", DM_MEM[14]);
	  $display("DM_MEM[15] = %h\n", DM_MEM[15]);
	  $display("DM_MEM[16] = %h\n", DM_MEM[16]);
	  $display("DM_MEM[17] = %h\n", DM_MEM[17]);
    $display(" ");
    $display("-----------------------------------------------------\n");
    $display("--------------------- S U M M A R Y -----------------\n");

    if(err==0)
         $display("Congratulations! The result is PASS!!\n");
    else
         $display("FAIL!!!  There are %d errors! \n", err);

    $display("-----------------------------------------------------\n");

    #(`CYCLE/2);
    $finish;
    end
end

endmodule
