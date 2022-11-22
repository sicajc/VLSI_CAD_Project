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
wire[OP_WIDTH-1:0] opcode;

//Main CTRs
wire RegWrite,ALUop,Branch,MemRead,RegDst,MemWrite,Jump,MemToReg ,Mov,Floating,Stop;//ID
wire RegWriteE,ALUopE,BranchE,MemReadE,RegDstE,MemWriteE,MemToRegE ,MovE,FloatingE;//EX
wire RegWriteM,BranchM,MemReadM,MemWriteM,MemToRegM ,MovM;//MEM
wire RegWriteW,MemToRegW;//WB

//Hazard units
wire alu_src1,alu_src2,mem_src,flushEX_MEM,flushIF_ID,pcstall,flushID_EX ,IF_IDstall ,ID_EXstall ,EX_MEMstall,MEM_WBstall ;

//IF
wire PCD,rsD,rtD,rdD;

//EX
wire rtE,rsE,rdE,PCE;

CTR#(
       .OP_WIDTH  ( 4 )
   )u_CTR(
       .opcode_i  ( opcode    ),
       .RegWrite  ( RegWrite  ),
       .ALUop     ( ALUop     ),
       .Branch    ( Branch    ),
       .MemRead   ( MemRead   ),
       .RegDst    ( RegDst    ),
       .MemWrite  ( MemWrite  ),
       .Jump      ( Jump      ),
       .MemToReg  ( MemToReg  ),
       .Mov       ( Mov       ),
       .Floating  ( Floating  ),
       .Stop      ( Stop      )
   );

hazardUnit u_hazardUnit(
               .clk         ( clk         ),
               .rst         ( rst         ),

               //Inputs
               .rsE         ( rsE         ),
               .rtE         ( rtE         ),
               .RegWriteM   ( RegWriteM   ),
               .RegWriteW   ( RegWriteW   ),
               .rsM         ( rsM         ),
               .rsI         ( rsI         ),
               .rtI         ( rtI         ),
               .MemReadE    ( MemReadE    ),
               .stop        ( stop        ),
               .PCSrc       ( PCSrc       ),
               .jump        ( jump        ),

               //Hazard units outputs
               .alu_src1    ( alu_src1    ),
               .alu_src2    ( alu_src2    ),
               .mem_src     ( mem_src     ),
               .flushEX_MEM ( flushEX_MEM ),
               .flushIF_ID  ( flushIF_ID  ),
               .pcstall     ( pcstall     ),
               .flushID_EX  ( flushID_EX  ),
               .IF_IDstall  ( IF_IDstall  ),
               .ID_EXstall  ( ID_EXstall  ),
               .EX_MEMstall ( EX_MEMstall ),
               .MEM_WBstall ( MEM_WBstall )
           );

IF#(
      .DATA_WIDTH   ( 16 ),
      .ADDR_WIDTH   ( 8 )
  )u_IF(
      .rst          ( rst          ),
      .clk          ( clk          ),

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
      .stallPC_i    ( pcstall    )
  );

ID#(
      .DATA_WIDTH           ( 16 ),
      .ADDR_WIDTH           ( 8 ),
      .IMM8_WIDTH           ( 8 ),
      .REG_WIDTH            ( 4 ),
      .CV_WIDTH             ( 11 ),
      .OP_WIDTH             ( 4 )
  )u_ID(
      .rst                  ( rst                  ),
      .clk                  ( clk                  ),

      //IF/ID
      .PCD_i                ( PCD_i                ),
      .instruction_mem_rD_i ( instruction_mem_rD_i ),
      .flush_ID_EX_i        ( flush_ID_EX_i        ),
      .stall_ID_EX_i        ( stall_ID_EX_i        ),
      .RegWriteW_i          ( RegWriteW_i          ),

      //RF
      .reg_file_r1          ( reg_file_r1          ),
      .reg_file_r2          ( reg_file_r2          ),
      //Forwarding
      .jumpAddr             ( jumpAddr             ),

      .rsD                  ( rsD                  ),
      .rtD                  ( rtD                  ),
      .rdD                  ( rdD                  ),

      .Jump                ( Jump                ),
      .Stop                ( Stop                ),
      //ID/EX
      .rtE                  ( rtE                  ),
      .rsE                  ( rsE                  ),
      .rdE                  ( rdE                  ),
      .PCE                  ( PCE                  ),

      //Control signals
      .RegWriteE            ( RegWriteE            ),
      .ALUopE               ( ALUopE               ),
      .BranchE              ( BranchE              ),
      .MemReadE             ( MemReadE             ),
      .RegDstE              ( RegDstE              ),
      .MemWriteE            ( MemWriteE            ),
      .MemToRegE            ( MemToRegE            ),
      .MovE                 ( MovE                 ),
      .FloatingE            ( FloatingE            )
  );

reg_file#(
            .DEPTH   ( 4 ),
            .ADDR    ( 2 ),
            .WIDTH   ( 8 )
        )u_reg_file(
            .rst     ( rst     ),
            .clk     ( clk     ),


            .r1_en   ( 1'b1   ),
            .r2_en   ( 1'b1   ),

            .r1_addr ( reg_file_r1),
            .r2_addr ( reg_file_r2 ),

            .w_data  ( ResultW    ),
            .w_addr  ( WriteRegW  ),
            .w_en    ( RegWriteW  ),

            .r1_data ( r1_data_r ),
            .r2_data ( r2_data_r )
        );

EX#(
      .DATA_WIDTH     ( 16 ),
      .ADDR_WIDTH     ( 8 ),
      .IMM8_WIDTH     ( 8 ),
      .REG_WIDTH      ( 4 ),
      .CV_WIDTH       ( 11 ),
      .OP_WIDTH       ( 4 )
  )u_EX(
      .clk            ( clk            ),
      .rst            ( rst            ),

      .PCE_i          ( PCE_i          ),

      .r1_data_r_i    ( r1_data_r_i    ),
      .r2_data_r_i    ( r2_data_r_i    ),

      .imm8E_i        ( imm8E_i        ),
      .rtE_i          ( rtE_i          ),
      .rsE_i          ( rsE_i          ),
      .rdE_i          ( rdE_i          ),

      //Control
      .flush_EX_MEM_i ( flush_EX_MEM_i ),
      .stall_EX_MEM_i ( stall_EX_MEM_i ),
      .RegWriteE_i    ( RegWriteE_i    ),
      .ALUopE_i       ( ALUopE_i       ),
      .BranchE_i      ( BranchE_i      ),
      .MemReadE_i     ( MemReadE_i     ),
      .RegDstE_i      ( RegDstE_i      ),
      .MemWriteE_i    ( MemWriteE_i    ),
      .JumpE_i        ( JumpE_i        ),
      .MemToRegE_i    ( MemToRegE_i    ),
      .MovE_i         ( MovE_i         ),
      .FloatingE_i    ( FloatingE_i    ),
      .StopE_i        ( StopE_i        ),

      .PCM_o          ( PCM_o          ),
      .WriteDataM_o   ( WriteDataM_o   ),
      .imm8M_o        ( imm8M_o        ),
      .rsM_o          ( rsM_o          ),
      .WriteRegM_o    ( WriteRegM_o    ),
      .alu_outM_o     ( alu_outM_o     ),
      .RegWriteM_o    ( RegWriteM_o    ),
      .BranchM_o      ( BranchM_o      ),
      .MemReadM_o     ( MemReadM_o     ),
      .MemWriteM_o    ( MemWriteM_o    ),
      .MemToRegM_o    ( MemToRegM_o    ),
      .MovM_o         ( MovM_o         ),

      .WBResultM_i    ( WBResultM_i    ),
      .ResultW_i      ( ResultW_i      ),
      .alu_src1_i     ( alu_src1_i     ),
      .alu_src2_i     ( alu_src2_i     )
  );

MEM#(
       .DATA_WIDTH     ( 16 ),
       .ADDR_WIDTH     ( 8 ),
       .IMM8_WIDTH     ( 8 ),
       .REG_WIDTH      ( 4 ),
       .CV_WIDTH       ( 11 ),
       .OP_WIDTH       ( 4 )
   )u_MEM(
       .clk            ( clk            ),
       .rst            ( rst            ),

       .PCM_i          ( PCM_i          ),
       .alu_outM_i     ( alu_outM_i     ),
       .WriteDataM_i   ( WriteDataM_i   ),
       .imm8M_i        ( imm8M_i        ),
       .rsM_i          ( rsM_i          ),
       .WriteRegM_i    ( WriteRegM_i    ),
       .stall_MEM_WB_i ( stall_MEM_WB_i ),
       .MemSrc_i       ( MemSrc_i       ),
       .RegWriteM_i    ( RegWriteM_i    ),
       .BranchM_i      ( BranchM_i      ),
       .MemReadM_i     ( MemReadM_i     ),
       .MemWriteM_i    ( MemWriteM_i    ),
       .MemToRegM_i    ( MemToRegM_i    ),
       .MovM_i         ( MovM_i         ),
       .ResultW_i      ( ResultW_i      ),

       .branchAddr_o   ( branchAddr_o   ),
       .WBResultM_o    ( WBResultM_o    ),
       .WriteRegM_o    ( WriteRegM_o    ),
       .RegWriteM_o    ( RegWriteM_o    ),
       .MemToRegM_o    ( MemToRegM_o    ),
       .MemAddr_o      ( MemAddr_o      ),
       .WriteDataM_o   ( WriteDataM_o   ),
       .PC_src_o       ( PC_src_o       )
   );

WB#(
      .DATA_WIDTH   ( 16 ),
      .ADDR_WIDTH   ( 8 ),
      .IMM8_WIDTH   ( 8 ),
      .REG_WIDTH    ( 4 ),
      .CV_WIDTH     ( 11 ),
      .OP_WIDTH     ( 4 )
  )u_WB(
      .clk          ( clk          ),
      .rst          ( rst          ),
      .WBResultW_i  ( WBResultW_i  ),
      .WriteRegW_i  ( WriteRegW_i  ),
      .RegWriteW_i  ( RegWriteW_i  ),
      .MemToRegW_i  ( MemToRegW_i  ),
      .RegWriteW_o  ( RegWriteW_o  ),
      .memData_r_i  ( memData_r_i  ),
      .ResultW_o    ( ResultW_o    ),
      .WriteRegW_o  ( WriteRegW_o  )
  );


endmodule
