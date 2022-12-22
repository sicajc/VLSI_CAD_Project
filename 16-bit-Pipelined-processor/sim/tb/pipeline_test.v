`timescale 1ns/10ps
`define CYCLE      10.0
`define End_CYCLE  10000000  // Modify cycle times once your design need more cycle times!
`define tb5
`define FILE_DIR "C:/Users/User/Desktop/cad_final_project/VLSI_CAD_Project/16-bit-Pipelined-processor/sim"
`define RTL
`define SDFFILE  "/home/rain/VLSI_CAD_Project/16_bit_Pipelined_processor/Netlist/pipelinedPS_SYN.sdf"

// synopsys translate_off
`ifdef tb1
   `define PAT_DM "C:/Users/User/Desktop/cad_final_project/VLSI_CAD_Project/16-bit-Pipelined-processor/sim/data/Test1/dm_data.txt"
   `define PAT_IM "C:/Users/User/Desktop/cad_final_project/VLSI_CAD_Project/16-bit-Pipelined-processor/sim/data/Test1/im_data.txt"
`endif


`ifdef tb2
   `define PAT_DM "C:/Users/User/Desktop/cad_final_project/VLSI_CAD_Project/16-bit-Pipelined-processor/sim/data/Test2/dm_data.txt"
   `define PAT_IM "C:/Users/User/Desktop/cad_final_project/VLSI_CAD_Project/16-bit-Pipelined-processor/sim/data/Test2/im_data.txt"
`endif


`ifdef tb3
   `define PAT_DM "C:/Users/User/Desktop/cad_final_project/VLSI_CAD_Project/16-bit-Pipelined-processor/sim/data/Test3/dm_data.txt"
   `define PAT_IM "C:/Users/User/Desktop/cad_final_project/VLSI_CAD_Project/16-bit-Pipelined-processor/sim/data/Test3/im_data.txt"
`endif


`ifdef tb4
   `define PAT_DM "C:/Users/User/Desktop/cad_final_project/VLSI_CAD_Project/16-bit-Pipelined-processor/sim/data/Test4/dm_data.txt"
   `define PAT_IM "C:/Users/User/Desktop/cad_final_project/VLSI_CAD_Project/16-bit-Pipelined-processor/sim/data/Test4/im_data.txt"
`endif


`ifdef tb5
   `define PAT_DM "C:/Users/User/Desktop/cad_final_project/VLSI_CAD_Project/16-bit-Pipelined-processor/sim/data/Test5/dm_data.txt"
   `define PAT_IM "C:/Users/User/Desktop/cad_final_project/VLSI_CAD_Project/16-bit-Pipelined-processor/sim/data/Test5/im_data.txt"
`endif
// synopsys_translate_on


// `ifdef RTL
//    `include "../../src/pipelinedPS.v"
// `endif

// synopsys translate_off
`ifdef GATE
   `include "/home/rain/VLSI_CAD_Project/16_bit_Pipelined_processor/Netlist/pipelinedPS_SYN.v"
`endif
// synopsys_translate_on

module pipeline_test;

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

reg	[15:0] IM_MEM	[0:24];
reg	[15:0] DM_MEM	[0:24];

integer total_cycles = 0;
integer cycles = 0;
integer stop_flag = 0;

// synopsys translate_off
initial
begin
`ifdef GATE
    $sdf_annotate(`SDFFILE, u_pipelinedPS);
`endif
end
// synopsys_translate_on

// synopsys translate_off
`ifdef RTL
pipelinedPS#(
               .OP_WIDTH     ( 4 ),
               .CV_WIDTH     ( 10 ),
               .HZ_CV_WIDTH  ( 10 ),
               .STATES_WIDTH ( 15 ),
               .ADDR_WIDTH   ( 8 ),
               .DATA_WIDTH   ( 16 ),
               .REG_WIDTH    ( 4 ),
               .IMM8_WIDTH   ( 8 ),
               .REG_NUM      ( 16 )
           )u_pipelinedPS(
               .clk          ( clk          ),
               .rst          ( rst          ),

               .start        ( start        ),
               .stop_o       ( stop         ),

               .im_r_data    ( im_r_data    ),
               .im_addr      ( im_addr      ),
               .im_rd        ( im_rd        ),

               .dm_addr      ( dm_addr      ),
               .dm_rd        ( dm_rd        ),
               .dm_wr        ( dm_wr        ),

               .dm_r_data    ( dm_r_data    ),
               .dm_w_data    ( dm_w_data    )
           );
`endif
// synopsys_translate_on

// synopsys translate_off
`ifdef GATE
pipelinedPS u_pipelinedPS(
                .clk          ( clk          ),
                .rst          ( rst          ),

                .start        ( start        ),
                .stop_o       ( stop         ),

                .im_r_data    ( im_r_data    ),
                .im_addr      ( im_addr      ),
                .im_rd        ( im_rd        ),

                .dm_addr      ( dm_addr      ),
                .dm_rd        ( dm_rd        ),
                .dm_wr        ( dm_wr        ),

                .dm_r_data    ( dm_r_data    ),
                .dm_w_data    ( dm_w_data    )
            );
`endif
// synopsys_translate_on

always
begin
    #(`CYCLE/2) clk = ~clk;
end


// initial
// begin
//     $fsdbDumpfile("spu_test.fsdb");  //your waveform file for nWave
//     $fsdbDumpvars;
// end

// instruction memory model ,
always@(*)
begin
    if (im_rd == 1)
    begin
        im_r_data = IM_MEM[im_addr];
    end
end

// data memory model for read
always@(*)
begin
    if (dm_rd == 1)
    begin
        dm_r_data = DM_MEM[dm_addr];
    end
end

// data memory model	for write
always@(posedge clk)
begin
    if (dm_wr == 1)
        DM_MEM[dm_addr] <= #1 dm_w_data;
end

//-------------------------------------------------------------------------------------------------------------------
initial
begin
    #`End_CYCLE ;
    $display("-----------------------------------------------------\n");
    $display("Error!!! The simulation can't be terminated under normal operation!\n");
    $display("-------------------------FAIL------------------------\n");
    $display("-----------------------------------------------------\n");
    $finish;
end

initial
begin
    $display("-----------------------------------------------------\n");
    $display("START!!! Simulation Start .....\n");
    $display("-----------------------------------------------------\n");

    @(negedge clk);
    #1;
    rst = 1'b1;
    #(`CYCLE*3);
    #1;
    rst = 1'b0;
    @(posedge clk);
    #1;
    start = 1'b1;
    #(`CYCLE);
    #5;
    start = 1'b0;
    wait_stop;
    checkans;
    check;
end

initial
begin
    wait(rst==1);
    $readmemb(`PAT_IM, IM_MEM);
    $readmemh(`PAT_DM, DM_MEM);
end


task wait_stop ;
    begin
        cycles = 0;
        while(stop === 0)
        begin
            cycles = cycles + 1;
            @(negedge clk);
        end
        total_cycles = total_cycles + cycles;
        stop_flag = 1;
    end
endtask

task checkans;
    begin
        // synopsys translate_off
`ifdef tb1
        if(DM_MEM[12] !== 16'd7)
        begin
            err = err + 1;
            $display("DM_MEM[12] = %d\n", DM_MEM[12]);
            $display("Correct Value should be DM_MEM[12] = %d\n", 16'd7);
        end
`endif


`ifdef tb2
        if(DM_MEM[3] !== 16'd160)
        begin
            err = err + 1;
            $display("DM_MEM[3] = %d\n", DM_MEM[3]);
            $display("Correct Value should be DM_MEM[3] = %d\n", 16'd160);
        end


        if(DM_MEM[4] !== -16'd10)
        begin
            err = err +1 ;
            $display("DM_MEM[4] = %d\n", DM_MEM[4]);
            $display("Correct Value should be DM_MEM[4] = %d\n", -16'd10);
        end
`endif


`ifdef tb3
        if(DM_MEM[0] !== 16'd50)
        begin
            err = err + 1;
            $display("DM_MEM[0] = %d\n", DM_MEM[0]);
            $display("Correct Value should be DM_MEM[0] = %d\n", 16'd50);
        end
        if(DM_MEM[1] !== 16'd100)
        begin
            err = err +1 ;
            $display("DM_MEM[1] = %d\n", DM_MEM[1]);
            $display("Correct Value should be DM_MEM[1] = %d\n", 16'd100);
        end
`endif

`ifdef t4

        if(DM_MEM[1] !== 16'd10)
        begin
            err = err + 1;
            $display("DM_MEM[0] = %d\n", DM_MEM[1]);
            $display("Correct Value should be DM_MEM[1] = %d\n", 16'd10);
        end
`endif



`ifdef tb5
        if(DM_MEM[0] !== 16'd7)
        begin
            err = err + 1;
            $display("DM_MEM[1] = %d\n", DM_MEM[0]);
        end
`endif

`ifdef tb6

        if(DM_MEM[0] !== 16'd7)
        begin
            err = err + 1;
            $display("DM_MEM[1] = %d\n", DM_MEM[0]);
        end
`endif
        // synopsys_translate_on
    end
endtask

task check;
    begin
        if(stop_flag == 1)
        begin
            if(err>=1)
            begin
                $display("============================================================================");
                $display("      ▄▄           ▄▄  ");
                $display("       ██         ██ ");
                $display("        ██       ██ ");
                $display("          ██   ██ ");
                $display("           ██ ██  ");
                $display("        ▄▄██████████▄  		FAIL!!!  There are %d errors! \n", err);
                $display("      █▀             ▀█ ");
                $display("      █   █████████   █ 	MY GRANDMA writes a better program than you.");
                $display("      █  ▄█▀    ▀█▄   █");
                $display("██    █  █   ▄█▄   █  █     ██");
                $display("███   █  █   ███   █  █   ▄███");
                $display("█ ██  █  █   ▀█▀   █  █  ▄█ █");
                $display("▀█ ██ █  ▀█▄     ▄█▀  █ ▄█ █▀ ");
                $display(" ▀█ █▄█     ▀███▀     █▄█ █▀");
                $display("   ▀██                █▀");
                $display("      █  ▄████████▄   █▌");
                $display("      █  █        █   █");
                $display("      █  █        █   █");
                $display("      █  ▀▀▀▀▀▀▀▀▀▀   █ ");
                $display("      ██             ██");
                $display("       ██           ██ ");
                $display("        █ ▄██████▄ █ ");
                $display("        █ █      █ █ ");
                $display("        █ █      █ █  ");
                $display("        ██▀      ▀██   ");
                $display("============================================================================");
                $finish;
                $finish;
            end
            else
            begin
                YOU_PASS_task;
            end
        end
    end
endtask

task YOU_PASS_task;
    begin
        $display ("----------------------------------------------------------------------------------------------------------------------");
        $display ("                                                  Congratulations!                                                   ");
        $display ("                                           You have passed all patterns!                                             ");
        $display ("                                           Your execution cycles = %5d cycles                                    ", total_cycles);
        $display ("                                           Your clock period = %.1f ns                                           ", `CYCLE);
        $display ("                                           Your total latency = %.1f ns                                          ", total_cycles*`CYCLE);
        $display ("----------------------------------------------------------------------------------------------------------------------");
        $display("============================================================================");
        $display("\n");
        $display("\n");
        $display("/ /##########\                                  #########");
        $display("// /############/                           #############");
        $display("  /  (#############       /            ##################");
        $display("       ################################################  ");
        $display("        /###########################################     ");
        $display("          //(#####################################(      ");
        $display("           (##################################(/         ");
        $display("    ...   /####################################(         ");
        $display("    ..    #####(   /###############(    ########(        ");
        $display("         (#####     ###############     (########  	   ");
        $display(".        #######(  (################   (#########( 	   ");
        $display(".       /###############/  (######################/	   ");
        $display("       .    /############################/ ///(###( 	   ");
        $display("//    . /////(##########################///////####  	   ");
        $display("      .  ////#########(       /#########(//////####(     ");
        $display("       (#((###########(        (#########(((((######/    ");
        $display("       /###############(      /(####################(    ");
        $display("/////// /#################(  (#######################    ");
        $display("//////   (###########################################(   ");
        $display("	^o^		WOOOOOW  YOU  PASSED!!!");
        $display("\n");
        $display("============================================================================");
        $finish;
    end
endtask

endmodule
