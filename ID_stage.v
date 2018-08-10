`include "head.h"
module ID_stage(
	input  wire		     clk                ,
	input  wire		     resetn             ,
	input  wire 	     ID_stall           ,
	input  wire 	     ID_clear           ,
  
	//I  
	//来自流水线的信号  
	input  wire[31:0]    IF_pc		         ,
	input  wire		     IF_delay_slot       ,
	//非流水线信号        
	input  wire[31:0]    ID_reg_rdata1       ,
    input  wire[31:0]    ID_reg_rdata2       ,
	input                ID_reg_valid1       , // 从主寄存器堆接过�??
	input                ID_reg_valid2       , 
	input  wire[31:0]    Cache_inst          ,
	input  wire          Cache_inst_valid    ,
	input  wire          MEM_b               ,
	input  wire          MEM_b_taken         ,
	//O  
	//ID产生  
	output wire          Cache_inst_ack      ,
	output wire          Delay               ,
	
	output wire[4:0]     ID_reg_raddr1       , //???????????应为id_src1 id_src2 ?
	output wire[4:0]     ID_reg_raddr2       ,
	output wire          ID_vsrc1_valid      ,
	output wire          ID_vsrc2_valid      ,
	output wire          ID_rt1_valid        ,
	output wire          ID_rt2_valid        ,
	output wire          ID_goto_MEM         ,   // 是否经过MEM�??
	output wire          ID_goto_CP0         ,   // 是否经过CP0�?? (将LO HI 的修改也放在CP0�??)
	output wire          ID_goto_WB          ,    // 是否经过WB�??
	output wire[31:0]    ID_rt1              ,    // BR指令用，记录两个源寄存器的�??
	output wire[31:0]    ID_rt2              ,
       
	output wire[31:0]    ID_vsrc1            , //以下是assign了但是没有声明的
    output wire[31:0]    ID_vsrc2            ,
    output wire[5:0]     ID_ALUop            ,
    output wire          ID_MULT             ,
    output wire          ID_DIV              ,
    output wire          ID_unsigned         ,
    output wire          ID_store            ,
    output wire          ID_SB               ,
    output wire          ID_SH               ,
    output wire          ID_SW               ,
    output wire          ID_SWL              ,
    output wire          ID_SWR              ,
    output wire          ID_load             ,
    output wire          ID_LB               ,
    output wire          ID_LBU              ,
    output wire          ID_LH               ,
    output wire          ID_LHU              ,
    output wire          ID_LW               ,
    output wire          ID_LWL              ,
    output wire          ID_LWR              ,
    output wire          ID_jump             ,
    output wire          ID_jump_reg         ,
    output wire          ID_b                ,
    output wire          ID_bne              ,
    output wire          ID_beq              ,
    output wire          ID_bgz              ,
    output wire          ID_bez              ,
    output wire          ID_blz              ,
    output wire          ID_b_predict        ,
    output wire[4:0]     ID_dest             ,
    //output wire[5:0]     ID_irp_signal       , ???   //外部传来的硬件中断信号interrupt signal
	output wire          ID_ERET             ,
	output wire          ID_MTC0             ,
	output wire          ID_MTLO             ,
	output wire          ID_MTHI             ,
	output wire          ID_no_inst          ,
	output wire          ID_syscall          ,
	output wire          ID_break            ,
	output wire          ID_use_rt1          ,
	output wire          ID_use_rt2          ,
	output wire          ID_arithmetic_unimm , //下面这些信号，后面的级似乎没用到
    output wire          ID_arithmetic_imm   ,
    output wire          ID_arithmetic       ,
    output wire          ID_logic_unimm      ,
    output wire          ID_logic_imm        ,
    output wire          ID_logic            ,
    output wire          ID_shift            ,
    output wire          ID_branch_1         ,
    output wire          ID_branch_2         ,
    output wire          ID_move             ,
    output wire[4:0]     ID_src1             ,
    output wire[4:0]     ID_src2             ,
    output wire[1:0]     ID_vsrc1_op         ,
    output wire[1:0]     ID_vsrc2_op         ,
    output wire[31:0]    ID_vsrc1_temp       ,
    output wire[31:0]    ID_vsrc2_temp       ,
	
	//ID传�??
	output reg[31:0] 	ID_pc                ,
	output reg[31:0] 	ID_inst              ,
	output reg			ID_delay_slot        ,
    output wire [25:0]  ID_j_index           ,     //instr_index for type "j"
    output wire [31:0]  ID_jr_index                //target for type "jr"
);
	assign Cache_inst_ack = !(ID_stall | ID_clear | !resetn);
	
	/*
	wire ID_arithmetic_unimm; // 不带立即数的算术运算，不包括乘除�??(dest地址为[15:11])
	wire ID_arithmetic_imm;   // 带立即数的算术运�??
	wire ID_arithmetic;       // �??有算术运算，包括乘除�??
	*/
	
	
	
	
	// 算术运算 
	wire 		 ADD;
	wire         ADDI;
	wire         ADDU;
	wire         ADDIU;
	wire         SUB;
	wire         SUBU;
	wire         SLT;
	wire         SLTI;
	wire         SLTU;
	wire         SLTIU;
	wire         DIV;
	wire         DIVU;
	wire         MULT;
	wire         MULTU;
	
	// 逻辑运算
	wire         AND;
	wire         ANDI;
	wire         LUI;
	wire         NOR;
	wire         OR;
	wire         ORI;
	wire         XOR;
	wire         XORI;
	
	
	// 移位指令 
	wire         SLL;
	wire         SLLV;
	wire         SRA;
	wire         SRAV;
	wire         SRL;
	wire         SRLV;
	
	// 分支跳转
	wire         BEQ;
	wire         BNE;
	wire         BGEZ;
	wire         BGTZ;
	wire         BLEZ;
	wire         BLTZ;
	wire         BLEZAL;
	wire         BLTZAL;
	wire         BGEZAL;
	wire         J;
	wire         JAL;
	wire         JR;
	wire         JALR;
	
	// 数据移动
	wire         MFHI;
	wire         MFLO;
	wire         MTHI;
	wire         MTLO;
	
	
	// 自陷指令
	wire         BREAK;
	wire         SYSCALL;
	
	// 访存指令
	wire         LB;
	wire         LBU;
	wire         LH;
	wire         LHU;
	wire         LW;
	wire         SB;
	wire         SH;
	wire         SW;
	wire         SWL;
	wire         SWR;
	wire         LWL;
	wire         LWR;
	
	
	// 特权指令
	wire         ERET;
	wire         MFC0;
	wire         MTC0;
	
	
	assign ADD = `ID_func == `ADD && `ID_func_2 == 5'b00000 && `ID_func_3 == `ADD_2;
	assign ADDI = `ID_func == `ADDI;
	assign ADDU = `ID_func == `ADDU && `ID_func_2 == 5'b00000 && `ID_func_3 == `ADDU_2;
	assign ADDIU = `ID_func == `ADDIU;
	assign SUB = `ID_func == `SUB && `ID_func_2 == 5'b00000 && `ID_func_3 == `SUB_2;
	assign SUBU = `ID_func == `SUBU && `ID_func_2 == 5'b00000 && `ID_func_3 == `SUBU_2;
	assign SLT = `ID_func == `SLT && `ID_func_2 == 5'b00000 && `ID_func_3 == `SLT_2;
	assign SLTI = `ID_func == `ADD && `ID_func_2 == 5'b00000 && `ID_func_3 == `ADD_2;
	assign SLTU = `ID_func == `SLTU && `ID_func_2 == 5'b00000 && `ID_func_3 == `SLTU_2;
	assign SLTIU = `ID_func == `SLTIU;
	assign DIV = `ID_func == `DIV && ID_inst[15:6] == 10'b0000000000 && `ID_func_3 == `DIV_2;
	assign DIVU = `ID_func == `DIVU && ID_inst[15:6] == 10'b0000000000 && `ID_func_3 == `DIVU_2;
	assign MULT = `ID_func == `MULT && ID_inst[15:6] == 10'b0000000000 && `ID_func_3 == `MULT_2;
	assign MULTU = `ID_func == `MULTU && ID_inst[15:6] == 10'b0000000000 && `ID_func_3 == `MULTU_2;
	
	assign AND = `ID_func == `AND && `ID_func_2 == 5'b00000 && `ID_func_3 == `AND_2;
	assign ANDI = `ID_func == `ANDI;
	assign LUI = `ID_func == `LUI;
	assign NOR = `ID_func == `NOR && `ID_func_2 == 5'b00000 && `ID_func_3 == `NOR_2;
	assign OR = `ID_func == `OR && `ID_func_2 == 5'b00000 && `ID_func_3 == `OR_2;
	assign ORI = `ID_func == `ORI && `ID_func_2 == 5'b00000 && `ID_func_3 == `ORI_2;
	assign XOR = `ID_func == `XOR && `ID_func_2 == 5'b00000 && `ID_func_3 == `XOR_2;
	assign XORI = `ID_func == `XORI && `ID_func_2 == 5'b00000 && `ID_func_3 == `XORI_2;
	
	
	assign SLLV = `ID_func == `SLLV && `ID_func_2 == 5'b00000 && `ID_func_3 == `SLLV_2;
	assign SLL = `ID_func == `SLL && ID_inst[25:21] == 5'b00000 && `ID_func_3 == `SLL_2;
	assign SRAV = `ID_func == `SRAV && `ID_func_2 == 5'b00000 && `ID_func_3 == `SRAV_2;
	assign SRA = `ID_func == `SRA && ID_inst[25:21] == 5'b00000 && `ID_func_3 == `SRA_2;
	assign SRLV = `ID_func == `SRLV && `ID_func_2 == 5'b00000 && `ID_func_3 == `SRLV_2;
	assign SRL = `ID_func == `SRL && ID_inst[25:21] == 5'b00000 && `ID_func_3 == `SRL_2;
	
	
	assign BEQ = `ID_func == `BEQ;
	assign BNE = `ID_func == `BNE;
	assign BGEZ = `ID_func == `BGEZ && ID_inst[20:16] == `BGEZ_2;
	assign BGTZ = `ID_func == `BGTZ && ID_inst[20:16] == `BGTZ_2;
	assign BLEZ = `ID_func == `BLEZ && ID_inst[20:16] == `BLEZ_2;
	assign BLTZ = `ID_func == `BLTZ && ID_inst[20:16] == `BLTZ_2;
	assign BGEZAL = `ID_func == `BGEZAL && ID_inst[20:16] == `BGEZAL_2;
	assign BLTZAL = `ID_func == `BLTZAL && ID_inst[20:16] == `BLTZAL_2;
	assign J = `ID_func == `J;
	assign JAL = `ID_func == `JAL;
	assign JR = `ID_func == `JR && ID_inst[20:6] == 15'b000000000000000 && `ID_func_3 == `JR_2;
	assign JALR = `ID_func == `JALR && ID_inst[20:16] == 5'b00000 && `ID_func_2 == 5'b00000 && `ID_func_3 == `JALR_2;
	
	
	assign MFHI = `ID_func == `MFHI && ID_inst[25:16] == 10'b0000000000 && `ID_func_2 == 5'b00000 && `ID_func_3 == `MFHI_2;
	assign MFLO = `ID_func == `MFLO && ID_inst[25:16] == 10'b0000000000 && `ID_func_2 == 5'b00000 && `ID_func_3 == `MFLO_2;	
	assign MTHI = `ID_func == `MTHI && ID_inst[20:6] == 15'b000000000000000 && `ID_func_3 == `MTHI_2;
	assign MTLO = `ID_func == `MTLO && ID_inst[20:6] == 15'b000000000000000 && `ID_func_3 == `MTHI_2;
	
	
	assign BREAK = `ID_func == `BREAK && `ID_func_3 == `BREAK_2;
	assign SYSCALL = `ID_func == `SYSCALL && `ID_func_3 == `SYSCALL_2;
	
	
	assign LB = `ID_func == `LB;
	assign LBU = `ID_func == `LBU;
	assign LH = `ID_func == `LH;
	assign LHU = `ID_func == `LHU;
	assign LW = `ID_func == `LW;
	assign SB = `ID_func == `SB;
	assign SH = `ID_func == `SH;
	assign SW = `ID_func == `SW;


	assign ERET = ID_func == 32'01000010000000000000000000011000;
	assign MFC0 = `ID_func == `MFC0 && ID_inst[25:21] == `MFC0_2 && ID_inst[10:3] == 8'b00000000;
	assign MTC0 = `ID_func == `MTC0 && ID_inst[25:21] == `MTC0_2 && ID_inst[10:3] == 8'b00000000;	
	
	
	assign ID_arithmetic_unimm = ADD | ADDU | SUB | SUBU | SLT | SLTU; 
	assign ID_arithmetic_imm = ADDI | ADDIU | SLTI | SLTIU;
	assign ID_arithmetic = ID_arithmetic_imm | ID_arithmetic_unimm | MULT | MULTU | DIV | DIVU;
	
	assign ID_logic_unimm = AND | NOR | OR | XOR;
	assign ID_logic_imm = ANDI | LUI | ORI | XORI;
	assign ID_logic = ID_logic_imm | ID_logic_unimm;
	
	assign ID_shift = SLLV | SLL | SRAV | SRA | SRLV | SRL;
	
	assign ID_branch_1 = BEQ | BNE;
	assign ID_branch_2 = BGEZ | BGTZ | BLEZ | BLTZ | BGEZAL | BLTZAL;
	
	assign ID_jump = J | JAL;
	assign ID_jump_reg = JR | JALR;
	
	assign ID_move = MFHI | MFLO | MTHI | MTLO;
	
	assign ID_load = LB | LBU | LH | LHU | LW;
	assign ID_store = SB | SH | SW;
	
	assign ID_no_inst = (ID_arithmetic | ID_logic | ID_shift | ID_branch_1 | ID_branch_2 |
						 ID_jump | ID_jump_reg | ID_move | ID_load | ID_store |
						 BREAK | SYSCALL | ERET | MFC0 | MTC0)? 1'b0 : 1'b1;
	
	
	assign ID_dest = (ID_arithmetic_unimm | ID_logic_unimm | ID_shift | JALR | MFHI | MFLO) ? ID_inst[15:11] :
					 (ID_arithmetic_imm | ID_logic_imm | ID_load | MFC0) ? ID_inst[20:16] :
					 (BLTZAL | BGEZAL | JAL)?  5'd31 : 
					 5'd0;
					 
	assign ID_src1 = (ID_jump | MFC0 | MTC0 | ERET | BREAK | SYSCALL) ? 5'd0 :
					 ID_inst[25:21];
	
	assign ID_src2 = (ID_arithmetic_imm | ID_logic_imm | ID_branch_2 | ID_jump | ID_load | ERET | BREAK | SYSCALL | MFC0) ? 5'd0 :
					 ID_inst[20:16];
	
	
	
	
	
	assign ID_vsrc1_valid = ID_reg_valid1;   
	assign ID_vsrc2_valid = ID_reg_valid2;
	
	assign ID_rt1_valid = ID_reg_valid1;
	assign ID_rt2_valid = ID_reg_valid2;
	
	
	assign ID_rt1 = ID_reg_rdata1;
	assign ID_rt2 = ID_reg_rdata2;
	
	
	
	// 6'b111111 表示不进行ALU运算
	// 6'b001001 表示加法
	// 其余按照算术指令的[5:0]定义含义
	assign ID_ALUop = (ID_arithmetic_unimm | ID_shift) ? ID_inst[5:0] :
					  (ID_arithmetic_imm) ? ID_inst[31:26] :
					  (ID_jump_reg | ID_load | ID_store) ? 6'b001001 : 6'b111111;
	
	
	// 00 : reg_rdata1   01 : PC       10: sa 

	
	assign ID_vsrc1_op = (BGEZAL | BLTZAL | JALR | JAL) ? 2'b01 :
                         (SLL | SRA | SRL) ? 2'b10 :
						  2'b00;
						  
	// 00 : reg_rdata2   01 : sign-16  10 : zero-16   11 : 8			  
	assign ID_vsrc2_op = (ID_load || ID_store || ID_arithmetic_imm) ? 2'b01 : 
						 (ID_logic_imm || ID_branch_1 || ID_branch_2) ? 2'b10 :
						 (JALR | JAL) ? 2'b11 : 
						  2'b00;
	
	
	assign ID_vsrc1_temp = (MFHI) ? HI :
						   (MFLO) ? LO :
						   (MFC0) ? (
						   (ID_inst[15:11] == 5'd0 ) ? CP0_INDEX :
	                       (ID_inst[15:11] == 5'd2 ) ? CP0_ENTRYLO0 :
	                       (ID_inst[15:11] == 5'd3 ) ? CP0_ENTRYLO1 :
	                       (ID_inst[15:11] == 5'd5 ) ? CP0_PAGEMASK :
	                       (ID_inst[15:11] == 5'd8 ) ? CP0_BADVADDR :
	                       (ID_inst[15:11] == 5'd9 ) ? CP0_COUNT :
						   (ID_inst[15:11] == 5'd10) ? CP0_ENTRYHI :
	                       (ID_inst[15:11] == 5'd11) ? CP0_COMPARE :
	                       (ID_inst[15:11] == 5'd12) ? CP0_STATUS :
	                       (ID_inst[15:11] == 5'd13) ? CP0_CAUSE :
	                       (ID_inst[15:11] == 5'd14) ? CP0_EPC : 32'd0) :
							ID_reg_rdata1;
					       
	
	assign ID_vsrc2_temp = ID_reg_rdata2;
	
	
	
	assign ID_vsrc1 = (ID_vsrc1_op == 2'b00) ? ID_vsrc1_temp :
					  (ID_vsrc1_op == 2'b01) ? ID_pc :
					  (ID_vsrc1_op == 2'b10) ? {27'd0,ID_inst[10:6]} : 32'd0;
					  
	assign ID_vsrc2 = (ID_vsrc2_op == 2'b00) ? ID_vsrc2_temp :
					  (ID_vsrc2_op == 2'b01) ? {{16{ID_inst[15]}},ID_inst[15:0]} :
					  (ID_vsrc2_op == 2'b10) ? {16'd0,ID_inst[15:0]} :
					   32'd8;
	
	
	assign ID_goto_MEM = ID_load;
	assign ID_goto_CP0 = DIV | DIVU | MULT | MULTU | MTLO | MTHI | BREAK | SYSCALL | MTC0;
	assign ID_goto_WB = ID_arithmetic | ID_logic | MFHI | MFLO | ID_jump | ID_jump_reg | ID_branch_1 | ID_branch_2;
	
	always @(posedge clk)
	begin
		if (!resetn || ID_clear) begin
			ID_pc         <= 32'hbfc00000;
			ID_inst       <= 32'h00000000;
			ID_delay_slot <= 0           ;
		end
		else if (ID_stall | !Cache_inst_valid) begin
			ID_pc         <= ID_pc         ;
			ID_inst       <= ID_inst       ;
			ID_delay_slot <= ID_delay_slot ;
		end 
		else begin
			ID_pc         <= IF_pc         ;
			ID_inst       <= Cache_inst    ;
			ID_delay_slot <= IF_delay_slot ;
		end
	end

	//////////////////////////////////////////////////////////////////////////////////////////////////
	assign Delay = (ID_b || ID_jump || ID_jump_reg)? 1'b1: 1'b0;
	
	assign ID_unsigned = ADDU | SUBU | SLTU | ADDIU | SLTIU | MULTU | DIVU;
	assign ID_MULT   = MULT | MULTU;
	assign ID_DIV    = DIV  | DIVU ;
	
	assign ID_b      = ID_branch_1 | ID_branch_2;
	assign ID_bne    = BNE;
	assign ID_beq	 = BEQ;
	assign ID_bgz    = BGEZ | BGTZ | BGEZAL;
	assign ID_bez	 = BGEZ | BLEZ | BGEZAL;
	assign ID_blz	 = BLEZ | BLTZ | BLTZAL;

	assign ID_SB     = SB  	;
    assign ID_SH     = SH  	;
    assign ID_SW     = SW  	;
    assign ID_SWL    = SWL 	;
    assign ID_SWR    = SWR 	;
    assign ID_LB     = LB  	;
    assign ID_LBU    = LBU 	;
    assign ID_LH     = LH  	;
    assign ID_LHU    = LHU 	;
    assign ID_LW     = LW  	;
    assign ID_LWL    = LWL 	;
    assign ID_LWR    = LWR 	;
    
	assign ID_ERET   = ERET ;
	assign ID_MTC0   = MTC0 ;
	assign ID_MTLO   = MTLO ;
	assign ID_MTHI   = MTHI ;
	assign ID_syscall= SYSCALL ;
	assign ID_break  = BREAK;

	bpu BPU(
        .clk            (clk         ),
        .resetn         (resetn      ),
	    .id_j           (ID_jump     ), //id级是否是j型指�??
        .mm_b           (MEM_b       ), //mm级是否是b型指�??
        .mm_b_taken     (MEM_b_taken ),	//mm级b型指令是否发生跳�??
	    .id_PC          (ID_pc       ),	//id级处理的pc
        .id_b           (ID_b        ),
	    .predict_taken  (ID_b_predict)
	);

	assign ID_use_rt1 = BNE | BEQ | MTHI | MTLO 	| ID_branch_2;
	assign ID_use_rt2 = BNE | BEQ | MTC0 | ID_store ;

	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	
	assign ID_jr_index = ID_vsrc1_temp;
	assign ID_j_index = ID_inst[25:0];
	
	assign ID_rt1 = ID_reg_rdata1;
	assign ID_rt2 = ID_reg_rdata2;
	
	assign ID_reg_raddr1 = ID_src1;
	assign ID_reg_raddr2 = ID_src2;

endmodule // EXE_stage	
