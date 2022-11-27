`include "reg_file.v"
`include "EX.v"
`include "hazardUnit.v"
`include "ID.v"
`include "IF.v"
`include "MEM.v"
`include "WB.v"

module pipelinedPS#(parameter OP_WIDTH  = 4,
                    parameter CV_WIDTH  = 10,
                    parameter HZ_CV_WIDTH  = 10,
                    parameter STATES_WIDTH  = 15,
                    parameter ADDR_WIDTH  = 8,
                    parameter DATA_WIDTH  = 16,
                    parameter REG_WIDTH   = 4,
                    parameter IMM8_WIDTH  = 8,
                    parameter REG_NUM     = 16)
       (
           input  clk,
           input  rst,

           input  start,                  // to start the processor
           output stop,                   // to show that the processor is stopped

           //control signals for instruction memory (im)
           input   [DATA_WIDTH-1:0]  im_r_data,      // 16-bit read data of im
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
wire[OP_WIDTH-1:0] opcode;

//Main CTRs
wire RegWriteD;//ID
wire RegWriteE,ALUopE,BranchE,MemReadE,RegDstE,MemWriteE,MemToRegE ,MovE,FloatingE;//EX
wire RegWriteM,BranchM,MemReadM,MemWriteM,MemToRegM ,MovM;//MEM
wire RegWriteW,MemToRegW;//WB

//Hazard units
wire[1:0] alu_src1,alu_src2;
wire mem_src,flushEX_MEM,flushIF_ID,pcstall,flushID_EX ,IF_IDstall ,ID_EXstall ,EX_MEMstall,MEM_WBstall ;
wire[REG_WIDTH-1:0] rsI,rtI;
wire R_type;

//IF
wire[ADDR_WIDTH-1:0] PCD;
wire[ADDR_WIDTH-1:0] PC;
wire[REG_WIDTH-1:0] rsD,rtD,rdD;

wire[REG_WIDTH-1:0] rf_r1_addr,rf_r2_addr;
wire[DATA_WIDTH-1:0] rf_r1_data,rf_r2_data;

//EX
wire[ADDR_WIDTH-1:0]PCE;
wire[REG_WIDTH-1:0] rtE,rsE,rdE;
wire[IMM8_WIDTH-1:0] imm8E;

//MEM
wire[ADDR_WIDTH-1:0] PCM;
wire[DATA_WIDTH-1:0] WriteDataM;
wire[IMM8_WIDTH-1:0] imm8M;
wire[REG_WIDTH-1:0] rsM;
wire[REG_WIDTH-1:0] WriteRegM;
wire[DATA_WIDTH-1:0] alu_outM;
wire[DATA_WIDTH-1:0] WBResultM;


wire PC_src;

wire[ADDR_WIDTH-1:0] branchAddr;
wire[ADDR_WIDTH-1:0] jumpAddr;

//WB
wire[DATA_WIDTH-1:0] ResultW;
wire[REG_WIDTH-1:0]  WriteRegW;

wire[REG_WIDTH-1:0] WriteRegW_rf;
wire RegWriteW_rf; //Control

//Stop Register
reg  stop_flag;
wire stop_flag_rd = stop_flag;

always @(posedge clk)
begin
    stop_flag <= rst ? 'd0 : ((PC >= 3)? stop : stop_flag);
end



hazardUnit#(
    .REG_WIDTH   ( REG_WIDTH )
)u_hazardUnit(
    .clk         ( clk         ),
    .rst         ( rst         ),

    //Fowarding and stall
    .rsE         ( rsE         ),
    .rtE         ( rtE         ),
    .RegWriteM   ( RegWriteM   ),
    .RegWriteW   ( RegWriteW   ),
    .WriteRegM   ( WriteRegM   ),
    .WriteRegW   ( WriteRegW   ),
    .rsM         ( rsM         ),

    //Stall
    .rsD         ( rsD         ),
    .rtD         ( rtD         ),
    .MemReadE    ( MemReadE    ),
    .RegWriteD   ( RegWriteD   ),
    .R_type      ( R_type      ),

    //Control hazard
    .stop        ( stop_flag_rd),
    .PCSrc       ( PC_src       ),
    .jump        ( jump        ),

    //Forwarding
    .alu_src1    ( alu_src1    ),
    .alu_src2    ( alu_src2    ),
    .mem_src     ( mem_src     ),

    //Stall
    .flushEX_MEM ( flushEX_MEM ),
    .flushIF_ID  ( flushIF_ID  ),
    .pcstall     ( pcstall     ),
    .MemReadW    ( MemReadW    ),
    .MemWriteM   ( MemWriteM   ),

    //Control hazard
    .flushID_EX  ( flushID_EX  ),
    .IF_IDstall  ( IF_IDstall  ),
    .ID_EXstall  ( ID_EXstall  ),
    .EX_MEMstall ( EX_MEMstall ),
    .MEM_WBstall ( MEM_WBstall )
);


IF#(
      .DATA_WIDTH   ( DATA_WIDTH ),
      .ADDR_WIDTH   ( ADDR_WIDTH )
  )u_IF(
      .rst          ( rst          ),
      .clk          ( clk          ),

      //PC
      .start(start),
      .stop(stop_flag_rd ),

      .jump_i       ( jump       ),
      .PC_src_i     ( PC_src     ),
      .branchAddr_i ( branchAddr ),
      .jumpAddr_i   ( jumpAddr   ),

      //IM
      .im_addr_o    ( im_addr    ),
      .im_rd_o      ( im_rd      ),

      //IF/ID
      .PCD_IF_ID_rd_o ( PCD ),
      .flushIF_ID_i ( flushIF_ID ),
      .stallIF_ID_i ( IF_IDstall ),

      //PC
      .PC(PC),
      .stallPC_i    ( pcstall    )

  );

ID#(
      .DATA_WIDTH           ( DATA_WIDTH ),
      .ADDR_WIDTH           ( ADDR_WIDTH ),
      .IMM8_WIDTH           ( IMM8_WIDTH ),
      .REG_WIDTH            ( REG_WIDTH ),
      .CV_WIDTH             ( CV_WIDTH ),
      .OP_WIDTH             ( OP_WIDTH )
  )u_ID(
      .rst                  ( rst                  ),
      .clk                  ( clk                  ),

      //IF/ID
      .PCD_i                ( PCD                ),
      .instruction_mem_rD_i ( im_r_data ),
      .flush_ID_EX_i        ( flushID_EX        ),
      .stall_ID_EX_i        ( ID_EXstall        ),

      //RF read Addr
      .reg_file_r1          ( rf_r1_addr          ),
      .reg_file_r2          ( rf_r2_addr          ),

      //Forwarding
      .jumpAddr             ( jumpAddr             ),

      .rsD                  ( rsD                  ),
      .rtD                  ( rtD                  ),

      .Jump                 ( jump                  ),
      .Stop                 ( stop                  ),

      //ID/EX
      .rtE                  ( rtE                  ),
      .rsE                  ( rsE                  ),
      .rdE                  ( rdE                  ),
      .PCE                  ( PCE                  ),
      .imm8D                ( imm8E                ),

      //Control signals
      .RegWriteE            ( RegWriteE            ),
      .ALUopE               ( ALUopE               ),
      .BranchE              ( BranchE              ),
      .MemReadE             ( MemReadE             ),
      .RegDstE              ( RegDstE              ),
      .MemWriteE            ( MemWriteE            ),
      .MemToRegE            ( MemToRegE            ),
      .MovE                 ( MovE                 ),
      .FloatingE            ( FloatingE            ),

      //Hazard
      .RegWrite_o(RegWriteD),
      .R_type(R_type)
  );

reg_file#(
            .DEPTH   ( REG_NUM ),
            .ADDR    ( REG_WIDTH ),
            .WIDTH   ( DATA_WIDTH )
        )u_reg_file(
            .rst     ( rst     ),
            .clk     ( clk     ),


            .r1_en   ( 1'b1   ),
            .r2_en   ( 1'b1   ),

            .r1_addr ( rf_r1_addr ),
            .r2_addr ( rf_r2_addr ),

            .w_data  ( ResultW    ),
            .w_addr  ( WriteRegW_rf  ),
            .w_en    ( RegWriteW_rf  ),

            .r1_data ( rf_r1_data ),
            .r2_data ( rf_r2_data )
        );

EX#(
      .DATA_WIDTH     ( DATA_WIDTH ),
      .ADDR_WIDTH     ( ADDR_WIDTH ),
      .IMM8_WIDTH     ( IMM8_WIDTH ),
      .REG_WIDTH      ( REG_WIDTH ),
      .CV_WIDTH       ( CV_WIDTH ),
      .OP_WIDTH       ( OP_WIDTH )
  )u_EX(
      .clk            ( clk            ),
      .rst            ( rst            ),

      .PCE_i          ( PCE          ),

      .r1_data_r_i    ( rf_r1_data    ),
      .r2_data_r_i    ( rf_r2_data    ),

      .imm8E_i        ( imm8E        ),
      .rtE_i          ( rtE          ),
      .rsE_i          ( rsE          ),
      .rdE_i          ( rdE          ),

      //Control
      .flush_EX_MEM_i ( flushEX_MEM ),
      .stall_EX_MEM_i ( EX_MEMstall ),

      .RegWriteE_i    ( RegWriteE    ),
      .ALUopE_i       ( ALUopE       ),
      .BranchE_i      ( BranchE      ),
      .MemReadE_i     ( MemReadE     ),
      .RegDstE_i      ( RegDstE      ),
      .MemWriteE_i    ( MemWriteE    ),
      .MemToRegE_i    ( MemToRegE    ),
      .MovE_i         ( MovE         ),
      .FloatingE_i    ( FloatingE    ),

      .PCM_o          ( PCM          ),
      .WriteDataM_o   ( WriteDataM   ),
      .imm8M_o        ( imm8M        ),
      .rsM_o          ( rsM          ),

      .WriteRegM_o    ( WriteRegM    ),
      .RegWriteM_o    ( RegWriteM    ),

      .alu_outM_o     ( alu_outM     ),
      .BranchM_o      ( BranchM      ),

      .MemReadM_o     ( MemReadM     ),
      .MemWriteM_o    ( MemWriteM    ),
      .MemToRegM_o    ( MemToRegM    ),
      .MovM_o         ( MovM         ),

      .WBResultM_i    ( WBResultM    ),
      .ResultW_i      ( ResultW      ),
      .alu_src1_i     ( alu_src1     ),
      .alu_src2_i     ( alu_src2     )
  );

MEM#(
       .DATA_WIDTH     ( DATA_WIDTH ),
       .ADDR_WIDTH     ( ADDR_WIDTH ),
       .IMM8_WIDTH     ( IMM8_WIDTH ),
       .REG_WIDTH      ( REG_WIDTH ),
       .CV_WIDTH       ( CV_WIDTH ),
       .OP_WIDTH       ( OP_WIDTH )
   )u_MEM(
       .clk            ( clk            ),
       .rst            ( rst            ),

       .PCM_i          ( PCM          ),
       .alu_outM_i     ( alu_outM     ),
       .WriteDataM_i   ( WriteDataM   ),
       .imm8M_i        ( imm8M        ),
       .rsM_i          ( rsM          ),

       //Hazard controls
       .stall_MEM_WB_i ( MEM_WBstall   ),
       .MemSrc_i       ( mem_src       ),

       .WriteRegM_i    ( WriteRegM    ),
       .RegWriteM_i    ( RegWriteM    ),
       .MemReadM_o     ( MemReadW     ),

       //Forwarded data
       .ResultW_i      ( ResultW      ),

       //Control signals
       .BranchM_i      ( BranchM      ),
       .MemToRegM_i    ( MemToRegM    ),
       .MovM_i         ( MovM         ),

       //!Forward to ID
       .branchAddr_o   ( branchAddr   ),
       .PC_src_o       ( PC_src       ),

       //!MEM/WB
       .WBResultM_o    ( WBResultM    ),
       .WriteRegM_o    ( WriteRegW    ),

       //Control Signals
       .RegWriteM_o    ( RegWriteW    ),
       .MemToRegM_o    ( MemToRegW    ),

       //DM
       .MemWriteM_i    ( MemWriteM    ),
       .MemReadM_i     ( MemReadM     ),

       .dm_rd(dm_rd),
       .dm_wr(dm_wr),
       .MemAddr_o      ( dm_addr      ),
       .WriteDataM_o   ( dm_w_data    )
   );

WB#(
      .DATA_WIDTH   ( DATA_WIDTH ),
      .ADDR_WIDTH   ( ADDR_WIDTH ),
      .IMM8_WIDTH   ( IMM8_WIDTH ),
      .REG_WIDTH    ( REG_WIDTH  ),
      .CV_WIDTH     ( CV_WIDTH   ),
      .OP_WIDTH     ( OP_WIDTH   )
  )u_WB(
      .clk          ( clk          ),
      .rst          ( rst          ),

      //MEM/WB
      .WBResultW_i  ( WBResultM  ),

      .WriteRegW_i  ( WriteRegW  ),
      .RegWriteW_i  ( RegWriteW  ),
      .MemToRegW_i  ( MemToRegW  ),

      .RegWriteW_o  ( RegWriteW_rf  ),

      .memData_r_i  ( dm_r_data  ),
      .ResultW_o    ( ResultW    ),
      .WriteRegW_o  ( WriteRegW_rf  )
);


endmodule
