
module IF_stage(
    input  wire         clk              ,
    input  wire         resetn           ,
                                         
    input  wire  [31:0] ID_j_pc          , //跳转指令的pc，来自译码级
	input  wire	 [31:0] CP0_EPC          , //EPC寄存器    
	input  wire  	    Inst_Req_Ack     ,
    input  wire         IF_stall         , //阻塞信号
	input  wire		    Exception        , //例外信号
	input  wire		    Interrupt        , //中断信号
	input  wire		    Cache_inst_valid , 

	input  wire  	    ID_ERET          , //ERET指令	
	input  wire 	    ID_b_predict    , //转移预测结果	
	input  wire			Delay            , //延迟槽信号

	input  wire			MEM_predict_error  , //转移预测错信号
	input  wire	 [31:0]	MEM_correct_branch_pc     , //转移预测正确pc

	output reg   [31:0] IF_pc            , //取指级pc 
	output reg          Inst_Req_Vaild   ,   
	//output reg          IF_flush         ,   
	output reg			IF_delay_slot    
);

//wire IF_exc_addr_inst = IF_pc[1:0] != 2'b00;


always @(posedge clk)
begin
	IF_pc          <= (!resetn) ? 32'h00000000:
		              (~Inst_Req_Ack) ? IF_pc:
		              (Exception | Interrupt) ? 32'h00000380:
		              (IF_stall) ? IF_pc:
		              (ID_ERET)  ? CP0_EPC:
					  (MEM_predict_error) ? MEM_correct_branch_pc:
		              (ID_b_predict) ? ID_j_pc : (IF_pc + 4);
	
	Inst_Req_Vaild <= (!resetn) ? 1'b0 :
					  Cache_inst_valid ? 1'b1:
					  Inst_Req_Ack ? 1'b0:
					  Inst_Req_Vaild;
	
	IF_delay_slot  <= (!resetn) ? 1'b0 : 
					  Cache_inst_valid ? 1'b0:
					  IF_delay_slot | Delay;
	
	//IF_flush       <= (!resetn) ? 1'b0 :
	//		       	  (Exception | Interrupt | ID_ERET | MEM_predict_error) ? 1'b1:
	//		       	  IF_flush;
end


endmodule 
