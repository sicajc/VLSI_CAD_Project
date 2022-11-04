`timescale 1ns/10ps

module spu_ctrl(

input   clk,
input   rst,

input   start,                 // to start the processor
output  reg stop,              // to show that the processor is stopped

//control signal for rf[a] equals to 0
input	  pco_en,		

//control signals for instruction memory (im)
input   [15:0] im_r_data,      // 16-bit read data of im
output  [7:0]  im_addr,        // 8-bit data address of im
output  reg im_rd,             // read enable of im

//control signals for data memory (dm)
output  [7:0] dm_addr,         // 8-bit data address of dm
output  reg dm_rd,             // read enable of dm
output  reg dm_wr,             // write enable of dm

//control signal for mux
output  reg rf_s1,
output  reg rf_s0,

//control signals for register file (rf)
output  reg [3:0] rf_w_addr,   // 4-bit write address 
output  reg rf_w_wr,           // write enable
 
output  reg [3:0] rf_rp_addr,  // 4-bit p-port read address 
output  reg rf_rp_rd,          // p-port read enable

output  reg [3:0] rf_rq_addr,  // 4-bit q-port read address 
output  reg rf_rq_rd,          // q-port read enable

//control signal for ALU
output  reg alu_s1,
output  reg	alu_s0,

//control signal for constant number is assigned
output  [7:0] loac
);

parameter [3:0]  INIT   = 4'd0, 
                 FETCH  = 4'd1,
					  DECODE = 4'd2,
					  LOAD   = 4'd3,
					  STORE  = 4'd4,
                 ADD    = 4'd5,
					  LOAC	= 4'd6,
					  SUB		= 4'd7,
					  JMPZ	= 4'd8,
					  JUMP	= 4'd9,
                 STOP   = 4'd15;

parameter [3:0]  OP_LOAD   = 4'd0,
					  OP_STORE  = 4'd1,
                 OP_ADD    = 4'd2,
					  OP_LOAC	= 4'd3,
					  OP_SUB		= 4'd4,
					  OP_JMPZ	= 4'd5,
					  OP_JUMP	= 4'd6,
	              OP_STOP  	= 4'd15;				  
					  
reg [7:0] pc;    // 8-bit program counter
reg pc_inc;
reg pc_clr;
reg pc_jmpz;
reg pc_jump;

reg [15:0] ir;    // 16-bit instruction register
reg ir_ld;

reg [3:0] cs, ns;  // current state and next state

wire [3:0] ra, rb, rc;  // address for rf

wire [3:0] op;          // op code

wire [7:0] pco;	// offset value for pc

assign im_addr = pc;

assign op = ir[15:12];

assign ra = ir[11:8];
assign rb = ir[7:4];
assign rc = ir[3:0];

assign dm_addr = ir[7:0];
assign loac = ir[7:0];
assign pco = ir[7:0];

// program counter
always@(posedge clk or posedge rst)
begin
	 if(rst)
		 pc <= #1 8'd0;
	 else if(pc_clr)
		 pc <= #1 8'd0;
	 else
		 case({pc_jump,pc_jmpz,pc_inc})
			3'b100:pc <= #1 (pc + pco - 1'b1);
			3'b010:pc <= #1 (pco_en? (pc + pco - 1'b1) : (pc));
			3'b001:pc <= #1 (pc + 8'd1);
			default:pc <= #1 pc;
		 endcase
//  if(rst)
//     pc <= #1 8'd0;
//  else if(pc_clr)
//     pc <= #1 8'd0;
//  else if(pc_jump)
//	  pc <= #1 pc + pco - 1'b1;
//  else if(pc_jmpz)
//	  pc <= #1 pco_en? (pc + pco - 1'b1) : (pc);
//  else if(pc_inc)
//     pc <= #1 (pc + 8'd1);
end

// ir
always@(posedge clk or posedge rst)
begin
  if(rst)
     ir <= #1 16'd0;
  else if(ir_ld)
     ir <= #1 im_r_data;
end

// current state register
always@(posedge clk or posedge rst)
begin
  if(rst)
     cs <= #1 INIT;
  else 
     cs <= #1 ns;
end

// next state combinational logic
always@(*)
begin
  case(cs)
  INIT:    if(start)
              ns = FETCH;
			  else
			     ns = INIT;
  
  FETCH:   ns = DECODE;
  
  DECODE:  case(op)
           OP_LOAD:  ns = LOAD;
			  OP_STORE: ns = STORE;
			  OP_ADD:   ns = ADD;
			  OP_LOAC:	ns	= LOAC;
			  OP_SUB:	ns = SUB;
			  OP_JMPZ:	ns	= JMPZ;
			  OP_JUMP:  ns = JUMP;
			  OP_STOP:  ns = STOP; 
           default:  ns = INIT;
			  endcase
			 
  LOAD:    ns = FETCH;
  
  STORE:   ns = FETCH;
  
  ADD:     ns = FETCH;
  
  LOAC:	  ns = FETCH;
  
  SUB:	  ns = FETCH;
  
  JMPZ:    ns = FETCH;
  
  JUMP:	  ns = FETCH;
  
  STOP:    ns = INIT;
  
  default: ns = INIT;
  endcase
end
  

// controller output combinational logic
always@(*)
begin
  im_rd = 1'b0;
  
  pc_clr = 1'b0;
  pc_inc = 1'b0;
  pc_jmpz = 1'b0;
  pc_jump = 1'b0;
  
  ir_ld = 1'b0;  
  
  dm_rd = 1'b0;
  dm_wr = 1'b0;
  
  rf_s1 = 1'b0;
  rf_s0 = 1'b0;
  
  rf_w_addr  = 4'd0;
  rf_w_wr = 1'b0;
  
  rf_rp_addr = 4'd0;
  rf_rp_rd = 1'b0;  
  
  rf_rq_addr = 4'd0;
  rf_rq_rd = 1'b0;  
  
  alu_s1 = 1'b0;
  alu_s0 = 1'b0;
  
  stop = 1'b0; 

  case(cs)
  INIT:    begin
             pc_clr = 1'b1;  
           end
  
  FETCH:   begin
             im_rd  = 1'b1;
				 ir_ld  = 1'b1;
			    pc_inc = 1'b1;  
           end
 
  LOAD:    begin
             dm_rd = 1'b1;
			    rf_s0 = 1'b1; 
			    rf_w_addr = ra;
			    rf_w_wr = 1'b1;			  
           end
  
  STORE:   begin
             dm_wr = 1'b1; 
			    rf_rp_addr = ra;
			    rf_rp_rd = 1'b1;			  
           end
  
  ADD:     begin           
			    rf_rp_addr = rb;
			    rf_rp_rd = 1'b1;

			    rf_rq_addr = rc;
			    rf_rq_rd = 1'b1;

			    rf_w_addr = ra;
			    rf_w_wr = 1'b1;	
	        
	          alu_s0 = 1'b1;		  
           end
			  
  LOAC:	  begin
				 rf_s1 = 1'b1;
				 rf_w_addr = ra;
				 rf_w_wr = 1'b1;
			  end
  
  SUB:	  begin
				 rf_rp_addr = rb;
			    rf_rp_rd = 1'b1;

			    rf_rq_addr = rc;
			    rf_rq_rd = 1'b1;

			    rf_w_addr = ra;
			    rf_w_wr = 1'b1;	
	        
	          alu_s1 = 1'b1;
			  end
  
  JMPZ:    begin
				 rf_rp_addr = ra;
				 rf_rp_rd = 1'b1;
				 pc_jmpz = 1'b1;
			  end
			  
  JUMP:	  begin
				 pc_jump = 1'b1;
			  end
  
  STOP:    begin
             stop = 1'b1;  
           end
			  
  default: begin
             im_rd = 1'b0;
  
             pc_clr = 1'b0;
             pc_inc = 1'b0;
				 pc_jmpz = 1'b0;
				 pc_jump = 1'b0;
				 
             ir_ld = 1'b0;  
  
             dm_rd = 1'b0;
             dm_wr = 1'b0;
				 
				 rf_s1 = 1'b0;
             rf_s0 = 1'b0;
  
             rf_w_addr  = 4'd0;
             rf_w_wr = 1'b0;
  
             rf_rp_addr = 4'd0;
             rf_rp_rd = 1'b0;  
  
             rf_rq_addr = 4'd0;
             rf_rq_rd = 1'b0;
				 
				 alu_s1 = 1'b0;
             alu_s0 = 1'b0;
  
             stop = 1'b0;
			  end
  endcase
end

endmodule








