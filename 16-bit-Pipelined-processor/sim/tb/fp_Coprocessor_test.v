`timescale  1ns / 1ps

module tb_floating_Coprocessor;

// floating_Coprocessor Parameters
parameter PERIOD           = 10;
parameter DATA_WIDTH       = 16;
parameter SIG_WIDTH        = 11;
parameter EXP_WIDTH        = 5 ;
parameter IEEE_COMPILANCE  = 1 ;
parameter STATUS_BIT       = 8 ;

// floating_Coprocessor Inputs
reg   rst                                  = 0 ;
reg   clk                                  = 0 ;
reg   [DATA_WIDTH-1:0]  rdData_input1_i    = 0 ;
reg   [DATA_WIDTH-1:0]  rdData_input2_i    = 0 ;
reg   rdData_inst_op_i                     = 0 ;
reg   [2:0]  rdData_inst_rnd_i             = 0 ;

// floating_Coprocessor Outputs
wire  [STATUS_BIT-1:0]  getResult_status_output_ff_o ;
wire  [DATA_WIDTH-1:0]  getResult_data_ff_o ;


initial
begin
    forever
        #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst  =  1;
    #(PERIOD*2) rst  =  0;
                rdData_input1_i = 
                rdData_input2_i =
end

floating_Coprocessor #(
                         .DATA_WIDTH      ( DATA_WIDTH      ),
                         .SIG_WIDTH       ( SIG_WIDTH       ),
                         .EXP_WIDTH       ( EXP_WIDTH       ),
                         .IEEE_COMPILANCE ( IEEE_COMPILANCE ),
                         .STATUS_BIT      ( STATUS_BIT      ))
                     u_floating_Coprocessor (
                         .rst                           ( rst                                            ),
                         .clk                           ( clk                                            ),
                         .rdData_input1_i               ( rdData_input1_i                                ),
                         .rdData_input2_i               ( rdData_input2_i                                ),
                         .rdData_inst_op_i              ( rdData_inst_op_i                               ),
                         .rdData_inst_rnd_i             ( rdData_inst_rnd_i                              ),

                         .getResult_status_output_ff_o  ( getResult_status_output_ff_o                   ),
                         .getResult_data_ff_o           ( getResult_data_ff_o                            )
                     );

initial
begin
    $finish;
end

endmodule
