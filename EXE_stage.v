`include "head.h"

//执行级如何判断数字来自id级还是前递寄存器？
module EXE_stage(
    input  wire		    clk,
	input  wire		    resetn,
	input  wire 	    EXE_stall,
	input  wire 	    EXE_clear,
	//I
    //非流水线信号
    input wire[31:0]    fwd_vsrc1,
    input wire[31:0]    fwd_vsrc2,
    input wire          fwd_vsrc1_valid,
    input wire          fwd_vsrc2_valid,
    
    //来自流水线的信号
    input wire[31:0]    ID_vsrc1       , //**** EXE级使用 ****
    input wire[31:0]    ID_vsrc2       ,
    input wire[5:0]     ID_ALUop       ,
    input wire          ID_MULT        ,
    input wire          ID_DIV         ,
    input wire          ID_unsigned    ,
    input wire          ID_store       ,
    input wire          ID_SB          ,
    input wire          ID_SH          ,
    input wire          ID_SW          ,
    input wire          ID_SWL         ,
    input wire          ID_SWR         ,
    input wire          ID_load        ,
    input wire          ID_LB          ,
    input wire          ID_LBU         ,
    input wire          ID_LH          ,
    input wire          ID_LHU         ,
    input wire          ID_LW          ,
    input wire          ID_LWL         ,
    input wire          ID_LWR         ,
    input wire          ID_jump        ,
    input wire          ID_jump_reg    ,
    input wire          ID_b           ,
    input wire          ID_bne         ,
    input wire          ID_beq         ,
    input wire          ID_bgz         ,
    input wire          ID_bez         ,
    input wire          ID_blz         ,
    input wire          ID_syscall     ,
    input wire          ID_break       ,
    input wire          ID_no_inst     ,
    input wire          ID_b_predict   , //**** 后续使用 ****
    input wire[31:0]    ID_pc          ,
    input wire[31:0]    ID_inst        ,
    input wire          ID_goto_CP0    ,
    input wire          ID_goto_MEM    ,
    input wire          ID_goto_WB     ,
    input wire[4:0]     ID_dest        ,
    input wire[5:0]     ID_irp_signal  ,   //外部传来的硬件中断信号interrupt signal
	input wire		    ID_delay_slot  ,
	input wire          ID_ERET        ,
	input wire          ID_MTC0        ,
	input wire          ID_MTLO        ,
	input wire          ID_MTHI        ,

    //O
    //EXE级产生
    output wire[31:0]   EXE_alu_result ,
    output wire[63:0]   EXE_mul_result ,
    output reg          EXE_mul_finish ,
    output wire[63:0]   EXE_div_result , //高32位：余数 低32位：商
    output wire         EXE_div_finish ,
    output wire[3:0]    EXE_mem_wen    ,
    output wire[31:0]   EXE_mem_wdata  , 

    output wire         EXE_exc_overflow  ,
    output wire         EXE_exc_addr_load , //取指或读数据错误 //取值地址错我咋判断
    output wire         EXE_exc_addr_store, //写数据地址错误
    output wire         EXE_exc_addr_inst ,
    output wire         EXE_exc_syscall   ,
    output wire         EXE_exc_break     ,
    output wire         EXE_exc_no_inst   ,
    output wire         EXE_b_taken       ,
    output wire[31:0]   EXE_bad_addr      , //出错的地址	
	output wire[31:0]   EXE_cp0_wdata     , //写到CP0寄存器的数值
	
    
    //EXE级传递
    output reg[31:0]   EXE_vsrc1       , //EXE级使用
    output reg[31:0]   EXE_vsrc2       ,
    output reg[5:0]    EXE_ALUop       ,
    output reg         EXE_MULT        ,
    output reg         EXE_DIV         ,
    output reg         EXE_unsigned    ,
    output reg         EXE_store       ,
    output reg         EXE_SB          ,
    output reg         EXE_SH          ,
    output reg         EXE_SW          ,
    output reg         EXE_SWL         ,
    output reg         EXE_SWR         ,
    output reg         EXE_load        ,
    output reg         EXE_LB          ,
    output reg         EXE_LBU         ,
    output reg         EXE_LH          ,
    output reg         EXE_LHU         ,
    output reg         EXE_LW          ,
    output reg         EXE_LWL         ,
    output reg         EXE_LWR         ,
    output reg         EXE_jump        ,
    output reg         EXE_jump_reg    ,
    output reg         EXE_b           ,
    output reg         EXE_bne         ,
    output reg         EXE_beq         ,
    output reg         EXE_bgz         ,
    output reg         EXE_bez         ,
    output reg         EXE_blz         ,
    output reg         EXE_syscall     ,
    output reg         EXE_break       ,
    output reg         EXE_no_inst     ,
    output reg         EXE_b_predict   , //CP0/MM/WB级使用
    output reg[31:0]   EXE_pc          ,
    output reg[31:0]   EXE_inst        ,
    output reg         EXE_goto_CP0    ,
    output reg         EXE_goto_MEM    ,
    output reg         EXE_goto_WB     ,
    output reg[4:0]    EXE_dest        ,
    output reg[5:0]    EXE_irp_signal  ,   //外部传来的硬件中断信号interrupt signal
	output reg		   EXE_delay_slot  ,
	output reg         EXE_ERET        ,
	output reg         EXE_MTC0        ,
	output reg         EXE_MTLO        ,
	output reg         EXE_MTHI         
);
    //来了拍新指令？
    reg EXE_new_inst;
    always@(posedge clk) begin
        EXE_new_inst <= resetn & ~EXE_clear & ~EXE_stall;
    end
    //流水线流动？
    wire EXE_flow;
    assign EXE_flow = resetn && !EXE_clear && !EXE_stall;
    //数据有效？
    wire EXE_vsrc_valid;
    assign EXE_vsrc_valid = ???;//todo

    //流水线寄存器
    always@(posedge clk) begin
    	if (!resetn || EXE_clear) begin
            EXE_vsrc1       <= 0 ; //EXE级使用
            EXE_vsrc2       <= 0 ;
            EXE_ALUop       <= 0 ;
            EXE_MULT        <= 0 ;
            EXE_DIV         <= 0 ;
            EXE_unsigned    <= 0 ;
            EXE_store       <= 0 ;
            EXE_SB          <= 0 ;
            EXE_SH          <= 0 ;
            EXE_SW          <= 0 ;
            EXE_SWL         <= 0 ;
            EXE_SWR         <= 0 ;
            EXE_load        <= 0 ;
            EXE_LB          <= 0 ;
            EXE_LBU         <= 0 ;
            EXE_LH          <= 0 ;
            EXE_LHU         <= 0 ;
            EXE_LW          <= 0 ;
            EXE_LWL         <= 0 ;
            EXE_LWR         <= 0 ;
            EXE_jump        <= 0 ;
            EXE_jump_reg    <= 0 ;
            EXE_b           <= 0 ;
            EXE_bne         <= 0 ;
            EXE_beq         <= 0 ;
            EXE_bgz         <= 0 ;
            EXE_bez         <= 0 ;
            EXE_blz         <= 0 ;
            EXE_syscall     <= 0 ;
            EXE_break       <= 0 ;
            EXE_no_inst     <= 0 ;
            EXE_b_predict   <= 0 ; //CP0/MM/WB级使用
            EXE_pc          <= 0 ;
            EXE_inst        <= 0 ;
            EXE_goto_CP0    <= 0 ;
            EXE_goto_MEM    <= 0 ;
            EXE_goto_WB     <= 0 ;
            EXE_dest        <= 0 ;
            EXE_irp_signal  <= 0 ; 
            EXE_delay_slot  <= 0 ;
            EXE_ERET        <= 0 ;
            EXE_MTC0        <= 0 ;
            EXE_MTLO        <= 0 ;
            EXE_MTHI        <= 0 ;
		end
		else if (EXE_stall) begin
			;
		end 
		else begin
            EXE_vsrc1       <= ID_vsrc1      ; //EXE级使用
            EXE_vsrc2       <= ID_vsrc2      ;
            EXE_ALUop       <= ID_ALUop      ;
            EXE_MULT        <= ID_MULT       ;
            EXE_DIV         <= ID_DIV        ;
            EXE_unsigned    <= ID_unsigned   ;
            EXE_store       <= ID_store      ;
            EXE_SB          <= ID_SB         ;
            EXE_SH          <= ID_SH         ;
            EXE_SW          <= ID_SW         ;
            EXE_SWL         <= ID_SWL        ;
            EXE_SWR         <= ID_SWR        ;
            EXE_load        <= ID_load       ;
            EXE_LB          <= ID_LB         ;
            EXE_LBU         <= ID_LBU        ;
            EXE_LH          <= ID_LH         ;
            EXE_LHU         <= ID_LHU        ;
            EXE_LW          <= ID_LW         ;
            EXE_LWL         <= ID_LWL        ;
            EXE_LWR         <= ID_LWR        ;
            EXE_jump        <= ID_jump       ;
            EXE_jump_reg    <= ID_jump_reg   ;
            EXE_b           <= ID_b          ;
            EXE_bne         <= ID_bne        ;
            EXE_beq         <= ID_beq        ;
            EXE_bgz         <= ID_bgz        ;
            EXE_bez         <= ID_bez        ;
            EXE_blz         <= ID_blz        ;
            EXE_syscall     <= ID_syscall    ;
            EXE_break       <= ID_break      ;
            EXE_no_inst     <= ID_no_inst    ;
            EXE_b_predict   <= ID_b_predict  ; //CP0/MM/WB级使用
            EXE_pc          <= ID_pc         ;
            EXE_inst        <= ID_inst       ;
            EXE_goto_CP0    <= ID_goto_CP0   ;
            EXE_goto_MEM    <= ID_goto_MEM   ;
            EXE_goto_WB     <= ID_goto_WB    ;
            EXE_dest        <= ID_dest       ;
            EXE_irp_signal  <= ID_irp_signal ; 
            EXE_delay_slot  <= ID_delay_slot ;
            EXE_ERET        <= ID_ERET       ;
            EXE_MTC0        <= ID_MTC0       ;
            EXE_MTLO        <= ID_MTLO       ;
            EXE_MTHI        <= ID_MTHI       ;
		end
    end

    //源数据：
    wire[31:0] vsrc1,vsrc2;
    assign vsrc1 = ???;
    assign vsrc2 = ???;

    assign EXE_mem_wdata = ??? ;
    assign EXE_cp0_wdata = ??? ;

    //alu
    wire EXE_alu_overflow;
    alu ALU(
        .aluop      (EXE_ALUop  ),
        .vsrc1      (vsrc1      ),
        .vsrc2      (vsrc2      ),
        .result     (EXE_alu_result     ),
        .overflow   (EXE_alu_overflow   ),
    );
    

    //乘法器
    multiply Multiplier(
        .clk        (clk        ),
        .resetn     (resetn     ),
        .A          (vsrc1      ),
        .B          (vsrc2      ),
        .sign       (~EXE_unsigned  ),
        .result     (EXE_mul_result)
    );
    //是否完成
    /*
    //版本1
    reg mul_unfinish;
    always@(posedge clk) begin
        mul_unfinish <= resetn & ~EXE_clear & ~EXE_stall & ID_MULT;
    end
    assign EXE_mul_finish = ~mul_unfinish;
    */
    //版本2
    //assign EXE_mul_finish = !(EXE_new_inst && EXE_MULT);
    //版本3
    always@(posedge clk) begin
        EXE_mul_finish <= resetn && !EXE_flow && EXE_MULT && EXE_vsrc_valid;
    end

    //除法器
    divider Divider(
   	      .clk      (clk                        ),
	      .resetn   (resetn  && !EXE_flow       ),
	      .div      (EXE_DIV && EXE_vsrc_valid  ),
	      .isSigned (!EXE_unsigned              ),
	      .A        (vsrc1                      ),
	      .B        (vsrc2                      ),
	      .Q        (EXE_div_result[31: 0]      ),
	      .R        (EXE_div_result[63:32]      ),
	      .complete (EXE_div_finish             )
    );

    //mem写使能
    wire[3:0] wen_SB, wen_SH, wen_SW, wen_SWL, wen_SWR;
    assign EXE_mem_wen = wen_SB | wen_SH | wen_SW | wen_SWL | wen_SWR;
    assign wen_SB = {3'b0, {1{EXE_SB}} } << EXE_alu_result[1:0];
    assign wen_SH = {2'b0, {2{EXE_SH}} } << EXE_alu_result[1:0];
    assign wen_SW =        {4{EXE_SW}} ;
    assign wen_SWL = ({ 3'b0, {5{EXE_SWL}} } << EXE_alu_result[1:0])[7:4];
    assign wen_SWR = ({ {4{EXE_SWR}}, 4'b0 } << EXE_alu_result[1:0])[7:4];

    //例外判断
    assign EXE_exc_addr_store = EXE_SH && EXE_alu_result[0]  !=1'b0  || 
                                EXE_SW && EXE_alu_result[1:0]!=2'b00 ;
    assign EXE_exc_addr_load  = (EXE_LH||EXE_LHU) && EXE_alu_result[0]  !=1'b0  || 
                                EXE_LW            && EXE_alu_result[1:0]!=2'b00 ;
    assign EXE_exc_addr_inst  = EXE_pc[1:0] != 2'b00 ;
    assign EXE_exc_overflow = EXE_alu_overflow && !EXE_unsigned;
    assign EXE_exc_syscall  = EXE_syscall;
    assign EXE_exc_break    = EXE_break;
    assign EXE_exc_no_inst  = EXE_no_inst;
    
    assign EXE_bad_addr = (EXE_exc_no_inst)? EXE_pc : EXE_alu_result;
    
    //branch
    wire gez = (rs[31]==0);
    wire eqz = (rs == 0);
    wire ltz = (rs[31]==1);
    assign EXE_b_taken      = EXE_beq && (rs==rt)||
                              EXE_bne && (rs!=rt)||
                              EXE_bgz && (rs >0) ||
                              EXE_bez && (rs==0) ||
                              EXE_blz && (rs <0)  ;
endmodule // EXE_stage