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
wire RegWriteE,BranchE,MemReadE,RegDstE,MemWriteE,MemToRegE ,MovE,FloatingE,jumpE;//EX
wire[1:0] ALUopE;
wire RegWriteM,BranchM,MemReadM,MemWriteM,MemToRegM ,MovM,jumpM;//MEM
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
wire[DATA_WIDTH-1:0] WBResultM_w;


wire PC_src;
wire[ADDR_WIDTH-1:0] branchAddr;
wire[ADDR_WIDTH-1:0] jumpAddr;
wire jumpM_f;

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
    .stop        ( stop_flag_rd ),
    .PCSrc       ( PC_src       ),
    .jump        ( jumpM_f      ),

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

      .jump_i       ( jumpM_f    ),
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
      .rsD                  ( rsD                  ),
      .rtD                  ( rtD                  ),

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
      .jumpE                ( jumpE                ),

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
      .jumpE_i        ( jumpE        ),

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
      .jumpM_o        ( jumpM        ),

      .WBResultM_i    ( WBResultM_w  ),
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
       .jumpM_i        ( jumpM        ),

       //!Forward to ID
       .branchAddr_o   ( branchAddr   ),
       .PC_src_o       ( PC_src       ),
       .jumpAddr_o     ( jumpAddr     ),

       //Forward to EX
       .WBResultM_w    ( WBResultM_w  ),

       //!MEM/WB
       .WBResultM_o    ( WBResultM    ),
       .WriteRegM_o    ( WriteRegW    ),

       //Control Signals
       .RegWriteM_o    ( RegWriteW    ),
       .MemToRegM_o    ( MemToRegW    ),
       .jumpM_o        ( jumpM_f      ),

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

module MEM #(parameter DATA_WIDTH = 16,
             parameter ADDR_WIDTH = 8,
             parameter IMM8_WIDTH = 8,
             parameter REG_WIDTH  = 4,
             parameter CV_WIDTH   = 11,
             parameter OP_WIDTH   = 4)
       (input clk,
        input rst,

        //From EX/MEM
        input[ADDR_WIDTH-1:0] PCM_i,
        input[DATA_WIDTH-1:0] alu_outM_i,
        input[DATA_WIDTH-1:0] WriteDataM_i,
        input[IMM8_WIDTH-1:0] imm8M_i,
        input[REG_WIDTH-1:0] rsM_i,
        input[REG_WIDTH-1:0] WriteRegM_i,

        //Hazard control
        input stall_MEM_WB_i,
        input MemSrc_i,

        //Controls
        input RegWriteM_i,
        input BranchM_i,
        input MemReadM_i,
        input MemWriteM_i,
        input MemToRegM_i,
        input MovM_i,
        input jumpM_i,

        //Forwarded signal
        input[DATA_WIDTH-1:0] ResultW_i,

        //Forward signal to IF
        output[ADDR_WIDTH-1:0] branchAddr_o,
        output[ADDR_WIDTH-1:0] jumpAddr_o,
        output jumpM_o,

        //Forwarding to EX
        output[DATA_WIDTH-1:0] WBResultM_w,

        //MEM/WB
        output reg[DATA_WIDTH-1:0] WBResultM_o,
        output reg[REG_WIDTH-1:0] WriteRegM_o,
        output reg RegWriteM_o ,
        output reg MemToRegM_o ,
        output reg MemReadM_o,

        //DM
        output dm_rd,
        output dm_wr,
        output[ADDR_WIDTH-1:0] MemAddr_o,
        output[DATA_WIDTH-1:0] WriteDataM_o,

        //Hazard control
        output PC_src_o
       );

//Branch
assign PC_src_o = ((WriteDataM_o == 'd0) && (BranchM_i) );
assign jumpM_o = jumpM_i;
assign branchAddr_o = imm8M_i;
assign jumpAddr_o   = imm8M_i;


//DM
assign  dm_wr = MemWriteM_i;
assign  dm_rd = MemReadM_i;
assign  MemAddr_o = imm8M_i;
assign WriteDataM_o = MemSrc_i ?  ResultW_i : WriteDataM_i ;

wire[DATA_WIDTH-1:0] sign_extended_val = {{8{imm8M_i[7]}},imm8M_i[7:0]};
//MEM/WB
assign WBResultM_w = MovM_i ? sign_extended_val : alu_outM_i;

always @(posedge clk )
begin
    if(rst)
    begin
        RegWriteM_o <= 'd0;
        MemToRegM_o <= 'd0;

        WBResultM_o <= 'd0;
        WriteRegM_o <= 'd0;
        MemReadM_o  <= 'd0;
    end
    else if(stall_MEM_WB_i)
    begin
        RegWriteM_o <= RegWriteM_o;
        MemToRegM_o <= MemToRegM_o;
        WBResultM_o <= WBResultM_o;
        WriteRegM_o <= WriteRegM_o;
        MemReadM_o  <= MemReadM_o;
    end
    else
    begin
        RegWriteM_o <= RegWriteM_i;
        MemToRegM_o <= MemToRegM_i;

        WBResultM_o <= WBResultM_w;
        WriteRegM_o <= WriteRegM_i;
        MemReadM_o  <= MemReadM_i;
    end
end

endmodule

module IF#(parameter DATA_WIDTH = 16,
           parameter ADDR_WIDTH = 8)
       (input rst,
        input clk,

        //Control inputs
        input jump_i,
        input PC_src_i,
        input start,

        //From stop_flag
        input stop,

        //Forwarded addr
        input[ADDR_WIDTH-1:0] branchAddr_i,
        input[ADDR_WIDTH-1:0] jumpAddr_i,

        //IF/ID control inputs
        input flushIF_ID_i,
        input stallIF_ID_i,
        input stallPC_i,

        //IM accesses
        output[ADDR_WIDTH-1:0]  im_addr_o,
        output                  im_rd_o,

        //IF/ID output
        output reg[ADDR_WIDTH-1:0] PCD_IF_ID_rd_o,

        //Status
        output reg processor_status_r_o,

        //Current PC
        output[ADDR_WIDTH-1:0] PC);

reg[ADDR_WIDTH-1:0] pc_rd;
reg[ADDR_WIDTH-1:0] pc_wr;
wire[ADDR_WIDTH-1:0] PCF;

//Processor status
always @(posedge clk)
begin
    processor_status_r_o <= (rst || stop) ? 1'b0 : (start ? 1'b1 :processor_status_r_o);
end

//PC & adder
always @(posedge clk)
begin
    pc_rd <= rst ? 'd0 : pc_wr;
end

always @(*)
begin
    if(stallPC_i)
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
    else if(processor_status_r_o)
    begin
        pc_wr = PCF;
    end
    else
    begin
        pc_wr = pc_rd;
    end
end

assign PCF = pc_rd + 8'b1;
assign PC  = pc_rd;

//IM
assign im_addr_o = pc_rd;
assign im_rd_o   = 1'b1;

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

module ID#(parameter DATA_WIDTH = 16,
           parameter ADDR_WIDTH = 8,
           parameter IMM8_WIDTH = 8,
           parameter REG_WIDTH  = 4,
           parameter CV_WIDTH   = 11,
           parameter OP_WIDTH   = 4)
       (input rst,
        input clk,
        input[ADDR_WIDTH-1:0] PCD_i,
        input[DATA_WIDTH-1:0] instruction_mem_rD_i,
        input flush_ID_EX_i,
        input stall_ID_EX_i,

        //REGFILE
        output[REG_WIDTH-1:0] reg_file_r1,
        output[REG_WIDTH-1:0] reg_file_r2,

        //Hazard unit inputs
        output[REG_WIDTH-1:0]  rsD ,
        output[REG_WIDTH-1:0]  rtD ,
        output[REG_WIDTH-1:0]  rdD ,

        //LW-R hazard needed
        output RegWrite_o,
        output R_type    ,

        //IF/ID
        output reg[REG_WIDTH-1:0]  rtE,
        output reg[REG_WIDTH-1:0]  rsE,
        output reg[REG_WIDTH-1:0]  rdE,
        output reg[ADDR_WIDTH-1:0] PCE,
        output reg[IMM8_WIDTH-1:0] imm8D,

        output Stop,

        output reg RegWriteE,
        output reg[1:0] ALUopE,
        output reg BranchE,
        output reg MemReadE,
        output reg RegDstE,
        output reg MemWriteE,
        output reg MemToRegE,
        output reg MovE,
        output reg FloatingE,
        output reg jumpE
       );

//Instruction bit slices from IM
assign  rsD     = instruction_mem_rD_i[11:8];
assign  rtD     = instruction_mem_rD_i[7:4];
assign  rdD     = instruction_mem_rD_i[3:0];
wire[IMM8_WIDTH-1:0] imm8D_w = instruction_mem_rD_i[7:0];
wire[OP_WIDTH-1:0]   opcode = instruction_mem_rD_i[15:12];

//Control vector
wire[1:0] ALUop;
wire RegWrite;
wire Branch;
wire MemRead;
wire RegDst;
wire MemWrite;
wire MemToReg;
wire Mov;
wire Floating;
wire Jump;

//RF access
assign reg_file_r1 = rsD;
assign reg_file_r2 = rtD;

CTR ctr(.opcode_i(opcode),

        //Outputs
        .RegWrite(RegWrite),
        .ALUop(ALUop),
        .Branch(Branch),
        .MemRead(MemRead),
        .RegDst(RegDst),
        .MemWrite(MemWrite),
        .Jump(Jump),
        .MemToReg(MemToReg),
        .Mov(Mov),
        .Floating(Floating),
        .Stop(Stop),
        .R_type(R_type));

//LW-R hazard, ID stage R, EX stage LW
assign RegWrite_o = RegWrite;

// ID/EX
always @(posedge clk)
begin
    if(rst)
    begin
        PCE   <= PCD_i;
        RegWriteE <= 'd0;
        ALUopE <= 'd0;
        BranchE <= 'd0;
        MemReadE <= 'd0;
        RegDstE <= 'd0;
        MemWriteE <= 'd0;
        MemToRegE <= 'd0;
        MovE <= 'd0;
        FloatingE <= 'd0;

        rtE <= 'd15;
        rsE <= 'd15;
        rdE <= 'd15;
        imm8D<= 'd250;
        jumpE <= 'd0;

    end
    else if(stall_ID_EX_i)
    begin
        PCE   <= PCE;
        RegWriteE <= RegWriteE;
        ALUopE <= ALUopE;
        BranchE <= BranchE;
        MemReadE <= MemReadE;
        RegDstE <= RegDstE;
        MemWriteE <= MemWriteE;
        MemToRegE <= MemToRegE;
        MovE <= MovE;
        FloatingE <= FloatingE;

        rtE <= rtE;
        rsE <= rsE;
        rdE <= rdE;
        imm8D<= imm8D;
        jumpE <= jumpE;
    end
    else if(flush_ID_EX_i)
    begin
        PCE   <= 'd0;
        RegWriteE <= 'd0;
        ALUopE <= 'd0;
        BranchE <= 'd0;
        MemReadE <= 'd0;
        RegDstE <= 'd0;
        MemWriteE <= 'd0;
        MemToRegE <= 'd0;
        MovE <= 'd0;
        FloatingE <= 'd0;

        rtE <= 'd0;
        rsE <= 'd0;
        rdE <= 'd0;
        imm8D<='d0;
        jumpE <= 'd0;
    end
    else
    begin
        PCE   <= PCD_i;
        RegWriteE <= RegWrite;
        ALUopE <= ALUop;
        BranchE <= Branch;
        MemReadE <= MemRead;
        RegDstE <= RegDst;
        MemWriteE <= MemWrite;
        MemToRegE <= MemToReg;
        MovE <= Mov;
        FloatingE <= Floating;

        rtE <= rtD;
        rsE <= rsD;
        rdE <= rdD;
        imm8D<=imm8D_w;
        jumpE <= Jump;
    end
end

endmodule


module CTR#(parameter OP_WIDTH = 4,
            parameter CV_WIDTH = 12)
       (input [OP_WIDTH-1:0] opcode_i,
        output RegWrite ,
        output[1:0] ALUop ,
        output Branch ,
        output MemRead ,
        output RegDst ,
        output MemWrite ,
        output Jump ,
        output MemToReg ,
        output Mov ,
        output Floating ,
        output Stop,
        output R_type);

//Basic instructions OP
localparam ADD =    4'b0010 ;
localparam SW =     4'b0001 ;
localparam LW =     4'b0000 ;
localparam SUB =    4'b0100 ;
localparam MOV =    4'b0011 ;
localparam JMPZ =   4'b0101 ;
localparam STOP =   4'b0111 ;
localparam ADDF =   4'b1000 ;
localparam MULTF =  4'b1001 ;
localparam NOP =    4'b1111 ;
localparam SLT =    4'b1010 ;
localparam JUMP =   4'b0110 ;


wire _ADD_       = opcode_i == ADD;
wire _SW_        = opcode_i == SW;
wire _LW_        = opcode_i == LW;
wire _SUB_       = opcode_i == SUB;
wire _MOV_       = opcode_i == MOV;
wire _JMPZ_      = opcode_i == JMPZ;
wire _STOP_      = opcode_i == STOP;
wire _ADDF_      = opcode_i == ADDF;
wire _MULTF_     = opcode_i == MULTF;
wire _NOP_       = opcode_i == NOP;
wire _SLT_       = opcode_i == SLT;
wire _JUMP_      = opcode_i == JUMP;
assign R_type    = _ADD_ || _SUB_ || _MULTF_ || _NOP_ || _STOP_ || _JMPZ_ || _SLT_; //Note JMPZ is not R_type but is needs forwarding.


//Basic instruction ControlVector
localparam ADD_CV   =       12'b100000000000;
localparam SW_CV    =       12'b000000100000;
localparam LW_CV    =       12'b100011001000;
localparam SUB_CV   =       12'b101000000000;
localparam MOV_CV   =       12'b100001000100;
localparam JMPZ_CV  =       12'b000100000000;
localparam STOP_CV  =       12'b000000000001;
localparam ADDF_CV  =       12'b100000000010;
localparam MULTF_CV =       12'b100000000010;
localparam NOP_CV   =       12'b000000000000;
localparam SLT_CV   =       12'b110000000000;
localparam JUMP_CV  =       12'b000000010000;

reg[CV_WIDTH-1:0] control_vector;
//Main CTR decoder
always @(*)
begin
    case(opcode_i)
        ADD:
        begin
            control_vector = ADD_CV;
        end
        SW:
        begin
            control_vector = SW_CV;
        end
        LW:
        begin
            control_vector = LW_CV;
        end
        SUB:
        begin
            control_vector = SUB_CV;
        end
        MOV:
        begin
            control_vector = MOV_CV;
        end
        JMPZ:
        begin
            control_vector = JMPZ_CV;
        end
        STOP:
        begin
            control_vector = STOP_CV;
        end
        ADDF:
        begin
            control_vector = ADDF_CV;
        end
        MULTF:
        begin
            control_vector = MULTF_CV;
        end
        NOP:
        begin
            control_vector = NOP_CV;
        end
        JUMP:
        begin
            control_vector = JUMP_CV;
        end
        default:
        begin
            control_vector = NOP;
        end
    endcase
end

assign {RegWrite,ALUop[1:0],Branch,MemRead,RegDst,MemWrite,Jump,MemToReg,Mov,Floating,Stop} = control_vector;

endmodule

module EX#(parameter DATA_WIDTH = 16,
           parameter ADDR_WIDTH = 8,
           parameter IMM8_WIDTH = 8,
           parameter REG_WIDTH  = 4,
           parameter CV_WIDTH   = 11,
           parameter OP_WIDTH   = 4)
       (input clk,
        input rst,

        input[ADDR_WIDTH-1:0] PCE_i,

        //RF
        input[DATA_WIDTH-1:0] r1_data_r_i,
        input[DATA_WIDTH-1:0] r2_data_r_i,

        //ID/EX
        input[IMM8_WIDTH-1:0] imm8E_i,
        input[REG_WIDTH-1:0] rsE_i,
        input[REG_WIDTH-1:0] rdE_i,
        input flush_EX_MEM_i,
        input stall_EX_MEM_i,

        //Control Vector
        input RegWriteE_i ,
        input[1:0] ALUopE_i ,
        input BranchE_i ,
        input MemReadE_i ,
        input RegDstE_i ,
        input MemWriteE_i ,
        input MemToRegE_i ,
        input MovE_i ,
        input FloatingE_i ,
        input jumpE_i,


        //EX/ME
        //Data
        output reg[ADDR_WIDTH-1:0] PCM_o,
        output reg[DATA_WIDTH-1:0] WriteDataM_o,
        output reg[IMM8_WIDTH-1:0] imm8M_o,
        output reg[REG_WIDTH-1:0]  rsM_o,
        output reg[REG_WIDTH-1:0]  WriteRegM_o,
        output reg[DATA_WIDTH-1:0] alu_outM_o,

        //Control signals
        output reg RegWriteM_o ,
        output reg BranchM_o ,
        output reg MemReadM_o ,
        output reg MemWriteM_o ,
        output reg MemToRegM_o ,
        output reg MovM_o,
        output reg jumpM_o,

        //Hazard signals
        //Forwarded data
        input[DATA_WIDTH-1:0] WBResultM_i,
        input[DATA_WIDTH-1:0] ResultW_i,
        //Forward signal
        input[1:0] alu_src1_i,
        input[1:0] alu_src2_i);

reg[DATA_WIDTH-1:0] alu_in1;
reg[DATA_WIDTH-1:0] alu_in2;

wire[DATA_WIDTH-1:0] WriteDataE_w;
wire[DATA_WIDTH-1:0] WriteRegE_w;
reg[DATA_WIDTH-1:0] alu_w;

//ALU_SRC1
always @(*)
begin
    case(alu_src1_i)
        'd0:
        begin
            alu_in1 = r1_data_r_i;
        end
        'd1:
        begin
            alu_in1 = WBResultM_i;
        end
        'd2:
        begin
            alu_in1 = ResultW_i;
        end
        default:
        begin
            alu_in1 = r1_data_r_i;
        end
    endcase
end

//ALU_SRC2
always @(*)
begin
    case(alu_src2_i)
        'd0:
        begin
            alu_in2 = r2_data_r_i;
        end
        'd1:
        begin
            alu_in2 = WBResultM_i;
        end
        'd2:
        begin
            alu_in2 = ResultW_i;
        end
        default:
        begin
            alu_in2 = r2_data_r_i;
        end
    endcase
end

//ALU
always @(*)
begin
    case(ALUopE_i)
    2'b00: alu_w = alu_in1 + alu_in2;
    2'b01: alu_w = alu_in1 - alu_in2;
    2'b10: alu_w = alu_in1 < alu_in2;
    endcase
end

// EX/MEM
always @(posedge clk)
begin
    if(rst)
    begin
        PCM_o <= 'd0;

        WriteDataM_o<='d0;
        imm8M_o<='d0;
        rsM_o<='d0;
        WriteRegM_o<='d0;
        alu_outM_o<='d0;

        RegWriteM_o<='d0;
        BranchM_o<='d0;
        MemReadM_o<='d0;
        MemWriteM_o<='d0;
        MemToRegM_o<='d0;
        MovM_o<='d0;
        jumpM_o <= 'd0;
    end
    else if(flush_EX_MEM_i)
    begin
        PCM_o <= 'd0;

        WriteDataM_o<='d0;
        imm8M_o<= 'd15;
        rsM_o<= 'd15;
        WriteRegM_o<= 'd15;
        alu_outM_o<= 'd15;

        RegWriteM_o<='d0;
        BranchM_o<='d0;
        MemReadM_o<='d0;
        MemWriteM_o<='d0;
        MemToRegM_o<='d0;
        MovM_o<='d0;
        jumpM_o <= 'd0;
    end
    else if(stall_EX_MEM_i)
    begin
        PCM_o <= PCM_o;

        WriteDataM_o        <=  WriteDataM_o;
        imm8M_o             <=  imm8M_o;
        rsM_o               <=  rsM_o;
        WriteRegM_o         <=  WriteRegM_o;
        alu_outM_o          <=  alu_outM_o;

        RegWriteM_o         <=  RegWriteM_o;
        BranchM_o           <=  BranchM_o;
        MemReadM_o          <=  MemReadM_o;
        MemWriteM_o         <=  MemWriteM_o;
        MemToRegM_o         <=  MemToRegM_o;
        MovM_o              <=  MovM_o;
        jumpM_o <= jumpM_o;
    end
    else
    begin
        PCM_o <= PCE_i;

        WriteDataM_o        <=  WriteDataE_w;
        imm8M_o             <=  imm8E_i;
        rsM_o               <=  rsE_i;
        WriteRegM_o         <=  WriteRegE_w;
        alu_outM_o          <=  alu_w;

        RegWriteM_o         <=  RegWriteE_i;
        BranchM_o           <=  BranchE_i;
        MemReadM_o          <=  MemReadE_i;
        MemWriteM_o         <=  MemWriteE_i;
        MemToRegM_o         <=  MemToRegE_i;
        MovM_o              <=  MovE_i;
        jumpM_o <= jumpE_i;
    end
end

//EX
assign WriteDataE_w = alu_in1;
assign WriteRegE_w  = RegDstE_i ? rsE_i : rdE_i;

endmodule


module hazardUnit#(parameter REG_WIDTH = 4)
       (
           //Hazard unit
           input  clk,
           input  rst,

           //Forwarding
           input[REG_WIDTH-1:0] rsE        ,
           input[REG_WIDTH-1:0] rtE        ,

           input RegWriteD  ,
           input RegWriteM  ,
           input RegWriteW  ,
           input R_type     ,

           input[REG_WIDTH-1:0] WriteRegM  ,
           input[REG_WIDTH-1:0] WriteRegW  ,

           input[REG_WIDTH-1:0] rsM        ,
           input[REG_WIDTH-1:0] rsD        ,
           input[REG_WIDTH-1:0] rtD        ,

           input MemReadE   ,
           input MemWriteM  ,
           input MemReadW   ,
           input stop       ,
           input PCSrc      ,
           input jump       ,

           //Hazard_control_outputs
           //Forwarding
           output reg[1:0] alu_src1,
           output reg[1:0] alu_src2,
           output reg      mem_src,

           //Stall detection
           output reg      flushEX_MEM,
           output reg      flushIF_ID,
           output reg      pcstall,

           //Control hazard
           output reg      flushID_EX,
           output reg      IF_IDstall,
           output reg      ID_EXstall,
           output reg      EX_MEMstall,
           output reg      MEM_WBstall);

reg branch_hazard_flag_w;
reg branch_hazard_flag_r;

wire branch_flush_flag = branch_hazard_flag_w ;

reg[2:0] flush_cnt;
wire flush_done_flag  = (flush_cnt == 'd3);

//Hazard unit control
//Fowarding
always @(*)
begin
    if((rsE == WriteRegM) && (RegWriteM == 1) && (MemReadE != 1))
    begin
        alu_src1 = 2'b01;
    end
    else if ((rsE == WriteRegW) && (RegWriteW == 1) && (MemReadE != 1))
    begin
        alu_src1 = 2'b10;
    end
    else
    begin
        alu_src1 = 2'b00;
    end
end


always @(*)
begin
    if((rtE == WriteRegM) && (RegWriteM == 1) && (MemReadE != 1))
    begin
        alu_src2 = 2'b01;
    end
    else if ((rtE == WriteRegW) && (RegWriteW == 1) && (MemReadE != 1))
    begin
        alu_src2 = 2'b10;
    end
    else
    begin
        alu_src2 = 2'b00;
    end
end

always @(*)
begin
    if((rsM == WriteRegW) && (MemReadW == 1) && (MemWriteM == 1))
    begin
        mem_src = 1'b1;
    end
    else
    begin
        mem_src = 1'b0;
    end
end

//Stall
always @(*)
begin
    if(stop)
    begin
        IF_IDstall  = 1'b1;
        ID_EXstall  = 1'b1;
        EX_MEMstall = 1'b1;
        MEM_WBstall = 1'b1;
        pcstall     = 1'b1;

        flushID_EX  = 1'b0;
    end
    else if(((((rsD == rsE) || (rtD == rsE)) && (MemReadE == 1)) && (R_type == 1)) || (branch_flush_flag))
    begin
        IF_IDstall  = 1'b0;
        ID_EXstall  = 1'b0;
        EX_MEMstall = 1'b0;
        MEM_WBstall = 1'b0;

        pcstall     = 1'b1;
        flushID_EX   = 1'b1;
    end
    else
    begin
        IF_IDstall  = 1'b0;
        ID_EXstall  = 1'b0;
        EX_MEMstall = 1'b0;
        MEM_WBstall = 1'b0;
        pcstall     = 1'b0;

        flushID_EX   = 1'b0;
    end
end




//Control Hazard
always @(*)
begin
    if(jump==1)
    begin
        //Only need to flush for 1 cycle.
        flushIF_ID  = 1'b1;
        flushEX_MEM = 1'b0;
    end
    else if(branch_flush_flag)
    begin
        // need to flush for 3 cycles.
        flushIF_ID  = 1'b1;
        flushEX_MEM = 1'b1;
    end
    else
    begin
        flushIF_ID  = 1'b0;
        flushEX_MEM = 1'b0;
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        flush_cnt <= 3'd0;
    end
    else if(branch_hazard_flag_r || branch_hazard_flag_w)
    begin
        flush_cnt <= flush_cnt + 3'd1;
    end
    else if(flush_done_flag)
    begin
        flush_cnt <= 3'd0;
    end
    else
    begin
        flush_cnt <= flush_cnt;
    end
end

always @(posedge clk)
begin
    branch_hazard_flag_r <= rst ? 1'd0 : branch_hazard_flag_w;
end
always @(*)
begin
    if(rst)
    begin
        branch_hazard_flag_w = 1'b0;
    end
    else if(PCSrc)
    begin
        branch_hazard_flag_w = 1'd1;
    end
    else if(flush_done_flag)
    begin
        branch_hazard_flag_w = 1'b0;
    end
    else
    begin
        branch_hazard_flag_w = branch_hazard_flag_r;
    end
end

endmodule


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

always@(negedge clk or posedge rst)
begin: rf_block
  integer i;
  if(rst)
     for(i=0; i<DEPTH; i=i+1)
           rf[i] <= {(WIDTH){1'b0}};
  else if(w_en)
           rf[w_addr] <= w_data;
end

endmodule

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
             input  RegWriteW_i,
             input  MemToRegW_i,
             output RegWriteW_o,
             //DM
             input[DATA_WIDTH-1:0] memData_r_i,
             //To ID
             //RF_WB
             output[DATA_WIDTH-1:0] ResultW_o,
             //RF_WB_Addr
             output[REG_WIDTH-1:0] WriteRegW_o
             );

//Outputs to ID
assign ResultW_o = MemToRegW_i ? memData_r_i : WBResultW_i;
assign WriteRegW_o = WriteRegW_i;
assign RegWriteW_o = RegWriteW_i;

endmodule
