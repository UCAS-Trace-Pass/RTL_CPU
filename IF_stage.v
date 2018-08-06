
module IF_stage(
    input  wire         clk            ,
    input  wire         resetn         ,

    input  wire  [31:0] ID_j_pc        , //跳转指令的pc，来自译码级
	input  wire	 [31:0] CP0_EPC        , //EPC寄存器    
	input  wire  	    Inst_Req_Ack   ,
    input  wire         Stall          , //阻塞信号
	input  wire		    Exception      , //中断与例外信号

	input  wire  	    ERET           , //ERET指令	
	input  wire 	    Predict_Taken  , //转移预测结果	
	input  wire			Delay          , //延迟槽信号
	
	input  wire			MEM_taken_error, //转移预测错信号
	input  wire	 [31:0]	MEM_right_pc   , //转移预测正确pc
	
	
	output reg   [31:0] IF_pc          , //取指级pc 
	output reg          Inst_Req_Vaild ,   
	output reg          IF_flush       ,   
	output reg			IF_delay_slot    
);

wire IF_addr_error = IF_pc[1:0] != 2'b00;


always @(posedge clk)
begin
	IF_pc          <= (!resetn) ? 32'h00000000:
		              (~Inst_Req_Ack) ? IF_pc:
		              (Exception) ? 32'h00000380:
		              (Stall) ? IF_pc:
		              (ERET)  ? CP0_EPC:
					  (MEM_taken_error) ? MEM_right_pc:
		              (Predict_Taken) ? ID_j_pc : (IF_pc + 4);
	
	Inst_Req_Vaild <= (!resetn) ? 1'b0 :
					  Inst_Req_Ack ? 1'b1:
					  Inst_Req_Vaild;
	
	IF_delay_slot  <= (!resetn) ? 1'b0 : IF_delay_slot | Delay;
	
	IF_flush       <= (!resetn) ? 1'b0 :
			       	  (Exception | ERET | MEM_taken_error) ? 1'b1:
			       	  IF_flush;
end


endmodule 
