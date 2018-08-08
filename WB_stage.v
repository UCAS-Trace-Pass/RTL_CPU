`include "head.h"
module WB_stage(
    input wire          clk             ,
    input wire          resetn          ,

	input wire [31:0]   EXE_result      , // EXE级计算结果
	???//没有cp0结果？
	input wire [31:0]   MEM_pc          ,
	input wire [31:0]   MEM_inst        ,
	input wire [1:0]    MEM_reg_we      , // 访存地址最后两位
	input wire [4:0]    MEM_dest        ,
	input wire          MEM_goto_MEM    , // 是否经过MEM级
	input wire [31:0]   MEM_mem_rdata   ,
	input wire [31:0]   MEM_reg_rt      , // 从MEM传来的当前指令的 rt寄存器值
    input wire          MEM_LB          , //load的各种one hot
    input wire          MEM_LBU         ,
    input wire          MEM_LH          ,
    input wire          MEM_LHU         ,
    input wire          MEM_LW          ,
    input wire          MEM_LWL         ,
    input wire          MEM_LWR          


    output wire [31:0]  WB_reg_wdata    , 
	output reg  [4:0]   WB_reg_addr     ,

    output reg  [31:0]  WB_pc            
);

	reg  [1:0]  WB_reg_we;
	reg  [31:0] WB_inst;
	reg         WB_goto_MEM;
	reg  [31:0] WB_result;
	reg  [31:0] WB_reg_rt;
	reg  [31:0] WB_mem_rdata;
	wire [31:0] WB_memdata_temp;
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			WB_pc       <= 32'hbfc00000;
			WB_inst     <= 32'h00000000;
			WB_reg_we   <= 2'bXX;
			WB_reg_addr <= 5'd0;      		 
			WB_goto_MEM <= 1'bX;    
			WB_result   <= 32'd0;     	
            WB_mem_rdata <= 32'd0;	
			WB_reg_rt   <= 32'd0;
		end
		else begin
			WB_pc       <= MEM_pc;
			WB_inst     <= MEM_inst;
			WB_reg_we   <= MEM_reg_we;
			WB_reg_addr <= MEM_dest;      		 
			WB_goto_MEM <= MEM_goto_MEM;    
			WB_result   <= EXE_result;     
			WB_mem_rdata <= MEM_mem_rdata;
			WB_reg_rt   <= MEM_reg_rt;
		end
	end


	assign WB_reg_wdata = (WB_goto_MEM) ? WB_memdata_temp : WB_result;

	assign WB_memdata_temp = (`WB_func == `LB)  ? (WB_reg_we == 2'b00 ? {{24{WB_mem_rdata[7]}},WB_mem_rdata[7:0]} :
												   WB_reg_we == 2'b01 ? {{24{WB_mem_rdata[15]}},WB_mem_rdata[15:8]} :
												   WB_reg_we == 2'b10 ? {{24{WB_mem_rdata[23]}},WB_mem_rdata[23:16]} :
												  {{24{WB_mem_rdata[31]}},WB_mem_rdata[31:24]} ) :
							 (`WB_func == `LBU) ? (WB_reg_we == 2'b00 ? {{24{1'b0}},WB_mem_rdata[7:0]} :
												   WB_reg_we == 2'b01 ? {{24{1'b0}},WB_mem_rdata[15:8]} :
												   WB_reg_we == 2'b10 ? {{24{1'b0}},WB_mem_rdata[23:16]} :
												  {{24{1'b0}},WB_mem_rdata[31:24]} ) :
                             (`WB_func == `LH)  ? (WB_reg_we[1] == 1'b0 ? {{16{WB_mem_rdata[15]}},WB_mem_rdata[15:0]} :
												  {{16{WB_mem_rdata[31]}},WB_mem_rdata[31:16]} ) :
                             (`WB_func == `LHU) ? (WB_reg_we[1] == 1'b0 ? {{16{1'b0}},WB_mem_rdata[15:0]} :
												  {{16{1'b0}},WB_mem_rdata[31:16]} ) :		
							 (`WB_func == `LWL) ? (WB_reg_we == 2'b00 ? {WB_mem_rdata[7:0],WB_reg_rt[23:0]} :
												   WB_reg_we == 2'b01 ? {WB_mem_rdata[15:0],WB_reg_rt[15:0]} :
												   WB_reg_we == 2'b10 ? {WB_mem_rdata[23:0],WB_reg_rt[7:0]} :
												   WB_mem_rdata ) :
                             (`WB_func == `LWR) ? (WB_reg_we == 2'b00 ? WB_mem_rdata :
												   WB_reg_we == 2'b01 ? {WB_reg_rt[31:24],WB_mem_rdata[31:8]} :
												   WB_reg_we == 2'b10 ? {WB_reg_rt[31:16],WB_mem_rdata[31:16]} :
												  {WB_reg_rt[31:8],WB_mem_rdata[31:24]} ) :											   
							 WB_mem_rdata;

endmodule