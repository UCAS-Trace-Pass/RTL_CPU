`include "head.h"
module CP0_stage(
    input  wire       clk,
    input  wire       resetn,
	
	input wire        EXE_exc_overflow  ,   //溢出
	input wire        EXE_exc_addr_load ,   //取数地址错
	input wire        EXE_exc_addr_store,   //存数地址错
	input wire        EXE_exc_addr_inst ,   //取指令地址错
	input wire        EXE_exc_syscall   ,   //
	input wire        EXE_exc_break     ,   //
	input wire        EXE_exc_no_inst   ,   //保留指令例外
	
	input wire [5:0]  EXE_irp_signal   ,    //外部传来的硬件中断信号interrupt signal
	input wire [4:0]  EXE_inst         ,    //指令的15:11位，来判断MTC0时写到哪个寄存器中
	input wire [31:0] EXE_bad_addr     ,    //出错的地址	
	input wire [31:0] EXE_wdata        ,    //写到CP0寄存器的数值
	input wire [31:0] EXE_pc           ,    //发生中断例外时指令对应的PC
	input wire		  EXE_delay_slot   ,    //例外延迟槽信号，表示例外是否在延迟槽中

	input wire        EXE_ERET         ,	//ERET指令
	input wire        EXE_MTC0         ,    //MTC0指令

	input wire        EXE_mul_finish ,	//乘法器结果是否有效   (MULT和MULTU指令)	
	input wire        EXE_div_finish ,	//除法器结果是否有效
	input wire        EXE_MTLO          ,	//MTLO指令
	input wire        EXE_MTHI          ,	//MTHI指令
	input wire [63:0] EXE_mul_result    ,	//乘法器结果
	input wire [63:0] EXE_div_result    ,	//除法器结果
	
	output reg [31:0] CP0_CAUSE,
	output reg [31:0] CP0_STATUS,
	output reg [31:0] CP0_EPC,
	output reg [31:0] CP0_BADVADDR,
	output reg [31:0] CP0_COUNT,
	output reg [31:0] CP0_COMPARE,
	
	output reg [31:0] CP0_LO,
	output reg [31:0] CP0_HI,
	
	output wire  	  Exception,
	output wire  	  Interrupt
);
////例外信号
reg        CP0_exc_overflow ;            				
reg        CP0_exc_addr_load;            				
reg        CP0_exc_addr_store;            				
reg        CP0_exc_addr_inst;            				
reg        CP0_exc_syscall  ;           				
reg        CP0_exc_break    ;            				
reg        CP0_exc_no_inst  ; 

reg [5:0]  CP0_irp_signal        ;	   
reg [4:0]  CP0_inst              ;	   		   
reg [31:0] CP0_bad_addr          ;		
reg [31:0] CP0_wdata             ;	           
reg [31:0] CP0_pc                ;		           
reg		   CP0_delay_slot        ;		   	
reg        CP0_ERET              ;			
reg        CP0_MTC0              ;	

/////hi lo寄存器相关变量
reg        CP0_mul_finish     ;	
reg        CP0_div_finish     ;	
reg        CP0_MTLO              ;	
reg        CP0_MTHI              ;	
reg        CP0_mul_lo_value      ;	
reg        CP0_div_lo_value      ;	
reg        CP0_mul_hi_value      ;	
reg        CP0_div_hi_value      ;	




always @(posedge clk) 
begin
	CP0_exc_overflow   <= (!resetn) ? 1'b0 : EXE_exc_overflow  ;
    CP0_exc_addr_load  <= (!resetn) ? 1'b0 : EXE_exc_addr_load ;
    CP0_exc_addr_store <= (!resetn) ? 1'b0 : EXE_exc_addr_store;
    CP0_exc_addr_inst  <= (!resetn) ? 1'b0 : EXE_exc_addr_inst ;
    CP0_exc_syscall    <= (!resetn) ? 1'b0 : EXE_exc_syscall   ;
    CP0_exc_break      <= (!resetn) ? 1'b0 : EXE_exc_break     ;
    CP0_exc_no_inst    <= (!resetn) ? 1'b0 : EXE_exc_no_inst   ;
	
    CP0_irp_signal     <= (!resetn) ? 6'b000000 : EXE_irp_signal ;
    CP0_inst           <= (!resetn) ? 5'b00000 : EXE_inst        ;  
    CP0_bad_addr       <= (!resetn) ? 32'h00000000 : EXE_bad_addr;
    CP0_wdata          <= (!resetn) ? 32'h00000000 : EXE_wdata   ;     
    CP0_pc             <= (!resetn) ? 32'h00000000 : EXE_pc      ;         
    CP0_delay_slot     <= (!resetn) ? 1'b0 : EXE_delay_slot      ; 
	CP0_ERET           <= (!resetn) ? 1'b0 : EXE_ERET            ;
    CP0_MTC0           <= (!resetn) ? 1'b0 : EXE_MTC0            ;

    CP0_mul_finish  <= (!resetn) ? 1'b0 : EXE_mul_finish  ;	
    EXE_div_finish  <= (!resetn) ? 1'b0 : EXE_div_finish  ;
    CP0_MTLO           <= (!resetn) ? 1'b0 : EXE_MTLO           ;
    CP0_MTHI           <= (!resetn) ? 1'b0 : EXE_MTHI           ;
    CP0_mul_lo_value   <= (!resetn) ? 1'b0 : EXE_mul_result[31: 0] ;
    CP0_mul_hi_value   <= (!resetn) ? 1'b0 : EXE_mul_result[63:32] ;
    CP0_div_lo_value   <= (!resetn) ? 1'b0 : EXE_div_result[63:32] ;
    CP0_div_hi_value   <= (!resetn) ? 1'b0 : EXE_div_result[31: 0] ;
end                    

//////////////////////---------------HI---LO-------------------//////////////////////////////////////////////////////////

always @(posedge clk)
begin
	CP0_LO <= (!resetn) ? 32'h00000000:
		  CP0_MTLO ? CP0_wdata:
		  CP0_mul_finish ? CP0_mul_lo_value:
		  EXE_div_finish ? CP0_div_lo_value:
		  CP0_LO;
		  
	CP0_HI <= (!resetn) ? 32'h00000000:
		  CP0_MTHI ? CP0_wdata:
		  CP0_mul_finish ? CP0_mul_hi_value:
		  EXE_div_finish ? CP0_div_hi_value:
		  CP0_HI;
end


//////////////////////---------------CP0-------------------/////////////////////////////////////////////////////////////

wire Clk_interrupt  = (CP0_COMPARE == CP0_COUNT & CP0_COUNT != 0) & ~CP0_STATUS[1];   						//时钟中断
wire Soft_interrupt = ((CP0_CAUSE[8] & CP0_STATUS[8])|(CP0_CAUSE[9] & CP0_STATUS[9])) & ~CP0_STATUS[1];		//软件中断
wire Hard_interrupt = ((CP0_irp_signal[0] & CP0_STATUS[10]) |
                       (CP0_irp_signal[1] & CP0_STATUS[11]) |
                       (CP0_irp_signal[2] & CP0_STATUS[12]) |
                       (CP0_irp_signal[3] & CP0_STATUS[13]) |
                       (CP0_irp_signal[4] & CP0_STATUS[14]) |
                       ((CP0_irp_signal[5] | Clk_interrupt) & CP0_STATUS[15])) & ~CP0_STATUS[1];				//硬件中断
					   
wire Irp_vec		= {(CP0_irp_signal[5] | Clk_interrupt) & CP0_STATUS[15],						//中断向量
					   CP0_irp_signal[4] & CP0_STATUS[14],
					   CP0_irp_signal[3] & CP0_STATUS[13],
					   CP0_irp_signal[2] & CP0_STATUS[12],
					   CP0_irp_signal[1] & CP0_STATUS[11],
					   CP0_irp_signal[0] & CP0_STATUS[10],
					   CP0_CAUSE[9]  & CP0_STATUS[9],
					   CP0_CAUSE[8]  & CP0_STATUS[8]  
					   };


wire CP0_choice_status   = CP0_inst[4:0] == 5'b01100;  //status,12
wire CP0_choice_cause    = CP0_inst[4:0] == 5'b01101;  //cause,13
wire CP0_choice_epc      = CP0_inst[4:0] == 5'b01110;  //epc,14
wire CP0_choice_badvaddr = CP0_inst[4:0] == 5'b01000;  //badvaddr,8
wire CP0_choice_count    = CP0_inst[4:0] == 5'b01001;  //count,9
wire CP0_choice_compare  = CP0_inst[4:0] == 5'b01011;  //compare,11
wire Epc_value = (CP0_delay_slot) ? CP0_pc - 4 : CP0_pc;

assign Interrupt = Clk_interrupt | Soft_interrupt | Hard_interrupt;
assign Exception = CP0_exc_syscall | CP0_exc_break | CP0_exc_addr_inst | CP0_exc_no_inst | CP0_exc_overflow | CP0_exc_addr_load | CP0_exc_addr_store;
//assign CP0_flush = Exception | Interrupt;

reg Count_step;

always @(posedge clk) 
begin
	CP0_STATUS   <= (!resetn) ? 32'h00400000:   //maybe 32'h0040ff00	
					(CP0_ERET	  ) ? {CP0_STATUS[31:8], 8'h01}:		  
					(Exception) ? {CP0_STATUS[31:8], 8'h02}:
					(Interrupt) ? {CP0_STATUS[31:8], 8'h03}:
					(CP0_MTC0 & CP0_choice_status) ? CP0_wdata: //mtc0
					CP0_STATUS;
					
	CP0_CAUSE    <= (!resetn) ? 32'h00000000:	
					(CP0_ERET | (CP0_MTC0 & CP0_choice_compare)) ? {CP0_CAUSE[31:16], 8'h00, CP0_CAUSE[7:0]}:
					(Interrupt         & ~CP0_STATUS[1]) ? (~CP0_delay_slot) ?  {CP0_CAUSE[31:16],Irp_vec,8'h00}:
																			{CP0_CAUSE[31:16] | 16'hc000, Irp_vec, 8'h00}:
					(CP0_exc_addr_inst & ~CP0_STATUS[1]) ? (~CP0_delay_slot) ?  {CP0_CAUSE[31:8], 8'h10}:
																			{CP0_CAUSE[31:8] | 24'h800000, 8'h10}:
					(CP0_exc_no_inst   & ~CP0_STATUS[1]) ? (~CP0_delay_slot) ?  {CP0_CAUSE[31:8], 8'h28}:
																			{CP0_CAUSE[31:8] | 24'h800000, 8'h28}:
					(CP0_exc_overflow  & ~CP0_STATUS[1]) ? (~CP0_delay_slot) ?  {CP0_CAUSE[31:8], 8'h30}:
																			{CP0_CAUSE[31:8] | 24'h800000, 8'h30}:
					(CP0_exc_syscall  		   & ~CP0_STATUS[1]) ? (~CP0_delay_slot) ?  {CP0_CAUSE[31:8], 8'h20}:
																			{CP0_CAUSE[31:8] | 24'h800000, 8'h20}: 
					(CP0_exc_break  		   & ~CP0_STATUS[1]) ? (~CP0_delay_slot) ?  {CP0_CAUSE[31:8], 8'h24}:
																			{CP0_CAUSE[31:8] | 24'h800000, 8'h24}: 
					(CP0_exc_addr_load & ~CP0_STATUS[1]) ? (~CP0_delay_slot) ?  {CP0_CAUSE[31:8], 8'h10}:
																			{CP0_CAUSE[31:8] | 24'h800000, 8'h10}:
					(CP0_exc_addr_store& ~CP0_STATUS[1]) ? (~CP0_delay_slot) ?  {CP0_CAUSE[31:8], 8'h14}:
																			{CP0_CAUSE[31:8] | 24'h800000, 8'h14}:		
					(CP0_MTC0 & CP0_choice_cause) ? CP0_wdata: //mtc0		  
					CP0_CAUSE;
					
	CP0_EPC      <= (!resetn) ? 32'h00000000:	
					(Exception | Interrupt) ? (CP0_STATUS[1]) ? CP0_EPC:   //CP0_STATUS寄存器的EXL位为1时，发生例外不更新EPC寄存器
																Epc_value: 
					(CP0_MTC0 & CP0_choice_epc) ? CP0_wdata: //mtc0
					CP0_EPC;
					
	CP0_BADVADDR <= (!resetn) ? 32'h00000000:	
					(CP0_exc_addr_inst) ? CP0_pc:	  
					(CP0_exc_addr_load | CP0_exc_addr_store) ? CP0_bad_addr:	              
					(CP0_MTC0 & CP0_choice_badvaddr) ? CP0_wdata: //mtc0
					CP0_BADVADDR;
					
	Count_step   <= (!resetn) ? 1'b0:					//CP0_COUNT寄存器两拍加1
					(CP0_MTC0 & CP0_choice_count) ? 1'b1:
					~Count_step;
					
	CP0_COUNT    <= (!resetn) ? 32'h00000000:			  			  
					(CP0_MTC0 & CP0_choice_count) ? CP0_wdata: //mtc0
					(Count_step) ? CP0_COUNT:
					CP0_COUNT + 1;
					
	CP0_COMPARE  <= (!resetn) ? 32'h00000000:
					(CP0_MTC0 & CP0_choice_compare) ? CP0_wdata: //mtc0	
					CP0_COMPARE;
end

endmodule 