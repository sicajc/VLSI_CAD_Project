module floating_Coprocessor#(
           parameter DATA_WIDTH      = 16,
           parameter SIG_WIDTH       = 11,
           parameter EXP_WIDTH       = 5,
           parameter IEEE_COMPILANCE = 1,
           parameter STATUS_BIT      = 8
       ) ( input rst,
           input clk,
           input       [DATA_WIDTH-1:0] rdData_input1_i,
           input       [DATA_WIDTH-1:0] rdData_input2_i,
           input            rdData_inst_op_i,
           input[2:0]       rdData_inst_rnd_i,
           output  reg [STATUS_BIT-1:0] getResult_status_output_ff_o,
           output  reg [DATA_WIDTH-1:0] getResult_data_ff_o
       );

// DW_fp_addsub_inst Inputs
wire   [SIG_WIDTH+EXP_WIDTH : 0]  inst_a    = rdData_input1_i   ;
wire   [SIG_WIDTH+EXP_WIDTH : 0]  inst_b    = rdData_input2_i   ;
wire   [2 : 0]                    inst_rnd  = rdData_inst_rnd_i ;

// DW_fp_addsub_inst Outputs
wire  [SIG_WIDTH+EXP_WIDTH : 0]  z_inst    ;
wire  [7 : 0]  status_inst                 ;

DW_fp_addsub_inst #(
                      .sig_width       ( SIG_WIDTH       ),
                      .exp_width       ( EXP_WIDTH       ),
                      .ieee_compliance ( IEEE_COMPILANCE ))
                  u_DW_fp_addsub_inst (
                      .inst_a                  ( inst_a                          ),
                      .inst_b                  ( inst_b                          ),
                      .inst_rnd                ( inst_rnd                        ),
                      .inst_op                 ( rdData_inst_op_i                       ),

                      .z_inst                  ( z_inst                          ),
                      .status_inst             ( status_inst                     )
                  );

always @(posedge clk or negedge rst)
begin
    if(rst)
    begin
        getResult_data_ff_o <= 'd0;
        getResult_status_output_ff_o <= 'd0;
    end
    else
    begin
        getResult_data_ff_o          <= z_inst;
        getResult_status_output_ff_o <= status_inst;
    end
end

endmodule
