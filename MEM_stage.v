`include "head.h"

//问题：
//1.mm级如何判断ex级数据要不要进来？
//2.如何判断cp0级和mem级谁的数据应该出去？
//3.是否需要把bpu整合进来？
//4.branch的数据来源？
//5.为branch跳转提供哪些输出数据？
module MEM_stage(
    input  wire		    clk,
	input  wire		    resetn,
	input  wire 	    MEM_stall,
	//I
    //非流水线信号
    input wire          EXE_stall,
    input wire          Cache_data_Mem_req_ack,
    input wire[31:0]    Cache_data_Read_data  ,
    input wire          Cache_data_Read_data_valid,
    //流水线信号
    input wire[31:0]    EXE_alu_result  , //MEM级用
    input wire[31:0]    EXE_mem_wdata   ,
    input wire[ 4:0]    EXE_mem_wen     ,
    input wire          EXE_load        ,
    input wire          EXE_store       ,
    input wire          EXE_jump        ,
    input wire          EXE_jump_reg    ,
    input wire          EXE_b           ,
    input wire          EXE_b_taken     ,
    input wire          EXE_b_predict   ,
    input wire[31:0]    EXE_pc          , //后面级用
    input wire[31:0]    EXE_inst        ,
    input wire          EXE_goto_MEM    ,
    input wire          EXE_goto_WB     ,
    input wire[4:0]     EXE_dest        ,
    input wire          EXE_LB          ,
    input wire          EXE_LBU         ,
    input wire          EXE_LH          ,
    input wire          EXE_LHU         ,
    input wire          EXE_LW          ,
    input wire          EXE_LWL         ,
    input wire          EXE_LWR         ,
    
    //O
    //非流水线信号
    output wire[31:0]   Cache_data_Address,
    output wire         Cache_data_MemWrite,
    output wire[31:0]   Cache_data_Write_data,
    output wire[3:0]    Cache_data_Write_strb,
    output wire         Cache_data_MemRead,
    output wire         Cache_data_Read_data_Ack,
    output wire         MEM_predict_error,
    output wire[31:0]   MEM_correct_branch_pc,
    output wire[31:0]   MEM_mem_rdata   ,
    
    //流水线信号
    output reg[31:0]    MEM_alu_result  ,//MEM级用
    output reg[31:0]    MEM_mem_wdata   ,
    output reg[ 4:0]    MEM_mem_wen     ,
    output reg          MEM_load        ,
    output reg          MEM_store       ,
    output reg          MEM_b           ,
    output reg          MEM_b_taken     ,
    output reg          MEM_b_predict   ,
    output reg[31:0]    MEM_pc          ,//后面级用
    output reg[31:0]    MEM_inst        ,
    output reg          MEM_goto_MEM    ,
    output reg          MEM_goto_WB     ,
    output reg[4:0]     MEM_dest        ,
    output reg          MEM_LB          ,
    output reg          MEM_LBU         ,
    output reg          MEM_LH          ,
    output reg          MEM_LHU         ,
    output reg          MEM_LW          ,
    output reg          MEM_LWL         ,
    output reg          MEM_LWR          
    
    
);

    //流水线寄存器
    //寄存器更新规则？
    always@(posedge clk) begin
    	if (!resetn || !MEM_stall && !(EXE_goto_Mem && !EXE_stall)) begin
            MEM_alu_result  <= 0 ; //MEM级用
            MEM_mem_wdata   <= 0 ; 
            MEM_mem_wen     <= 0 ; 
            MEM_load        <= 0 ; 
            MEM_store       <= 0 ; 
            MEM_jump        <= 0 ;
            MEM_jump_reg    <= 0 ;
            MEM_b           <= 0 ; 
            MEM_b_taken     <= 0 ; 
            MEM_b_predict   <= 0 ; 
            MEM_pc          <= 0 ; //后面级用
            MEM_inst        <= 0 ; 
            MEM_goto_MEM    <= 0 ; 
            MEM_goto_WB     <= 0 ; 
            MEM_dest        <= 0 ; 
            MEM_LB          <= 0 ;
            MEM_LBU         <= 0 ;
            MEM_LH          <= 0 ;
            MEM_LHU         <= 0 ;
            MEM_LW          <= 0 ;
            MEM_LWL         <= 0 ;
            MEM_LWR         <= 0 ;
		end
		else if (MEM_stall ) begin
			;
		end 
		else begin
            MEM_alu_result  <= EXE_alu_result  ; //MEM级用
            MEM_mem_wdata   <= EXE_mem_wdata   ; 
            MEM_mem_wen     <= EXE_mem_wen     ; 
            MEM_load        <= EXE_load        ; 
            MEM_store       <= EXE_store       ; 
            MEM_jump        <= EXE_jump        ;
            MEM_jump_reg    <= EXE_jump_reg    ;
            MEM_b           <= EXE_b           ; 
            MEM_b_taken     <= EXE_b_taken     ; 
            MEM_b_predict   <= EXE_b_predict   ; 
            MEM_pc          <= EXE_pc          ; //后面级用
            MEM_inst        <= EXE_inst        ; 
            MEM_goto_MEM    <= EXE_goto_MEM    ; 
            MEM_goto_WB     <= EXE_goto_WB     ; 
            MEM_dest        <= EXE_dest        ;
            MEM_LB          <= EXE_LB          ;
            MEM_LBU         <= EXE_LBU         ;
            MEM_LH          <= EXE_LH          ;
            MEM_LHU         <= EXE_LHU         ;
            MEM_LW          <= EXE_LW          ;
            MEM_LWL         <= EXE_LWL         ;
            MEM_LWR         <= EXE_LWR         ;
            
		end
    end

    wire MEM_flow;
    assign MEM_flow = resetn && !MEM_stall && EXE_goto_MEM && !EXE_stall;

    //状态机
    parameter Init    = 2'b0;
    parameter Write_1 = 2'b1;
    parameter Read_1  = 2'b2;
    parameter Read_2  = 3'b3;
    reg[1:0] Mem_state;
    //todo:状态待优化
    always@(posedge clk) begin
        if(resetn)
            Mem_state <= Init;
        else begin
            case (Mem_state)
              Init:     Mem_state <= (MEM_load)? Read_1:
                                     (MEM_store)?Write_1:
                                                 Init; 
              Write_1:  Mem_state <= (Cache_data_Mem_req_ack)?  Init   : Mem_state;
              Read_1:   Mem_state <= (Cache_data_Mem_req_ack)?  Read_2 : Mem_state;
              Read_2:   Mem_state <= (Cache_data_Read_data_valid)? Init: Mem_state;
              default:  Mem_state <= Mem_state;
            endcase
        end
    end
    //Cache_data信号
    assign Cache_data_MemWrit       = (Mem_state == Write_1);
    assign Cache_data_MemRead       = (Mem_state == Read_1);
    assign Cache_data_Read_data_Ack = (Mem_state == Read_2);
    assign Cache_data_Address     = MEM_alu_result;
    assign Cache_data_Write_data  = MEM_store_data;
    assign Cache_data_Write_strb  = MEM_mem_wen;
    
    assign MEM_mem_rdata      = Cache_data_Read_data;

    //branch:
    assign MEM_predict_error = MEM_b_predict ^ MEM_b_taken;
    assign MEM_correct_branch_pc = (MEM_b_taken)? MEM_alu_result+4 : MEM_pc+8;
    
endmodule // MEM_stage