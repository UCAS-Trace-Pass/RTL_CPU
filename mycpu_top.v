/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

module mycpu_top(
    input  wire        aclk,
    input  wire        aresetn,            //low active

    output  wire    [3:0]   awid,
    output wire [31:0]      awaddr,
    output  wire    [7:0]   awlen,
    output wire [2:0] awsize,
    output  wire    [1:0]   awburst,
    output  wire    [1:0]   awlock,
    output  wire    [3:0]   awcache,
    output  wire    [2:0]   awprot,
    output wire awvalid,
    input  wire awready,

    output   wire    [3:0]   wid,
    output wire [31:0]      wdata,
    output wire [3:0]    wstrb,
    output  wire    wlast,
    output wire wvalid,
    input  wire wready,

    input   wire    [3:0]   bid,
    input   wire    [1:0]   bresp,
    input  wire bvalid,
    output wire bready,

    output wire [3:0] arid,
    output wire [31:0]      araddr,
    output  wire    [7:0]   arlen,
    output wire [2:0] arsize,
    output  wire    [1:0]   arburst,
    output  wire    [1:0]   arlock,
    output  wire    [3:0]   arcache,
    output  wire    [2:0]   arprot,
    output wire arvalid,
    input  wire arready,

    input wire [3:0] rid,
    input  wire [31:0]      rdata,
    input   wire    [1:0]   rresp,
    input   wire    rlast,
    input  wire rvalid,
    output wire rready,

    output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_wen,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata,
    
    input   wire    [7:0]   int ////////??????是中断信号吗
);

assign  awid = 'd0;
assign  awlen = 'd0;
assign  awburst = 2'b01;
assign  awlock = 'd0;
assign  awcache = 'd0;
assign  awprot = 'd0;

assign  wlast = wvalid;
assign  wid = 'd0;

assign  arlen = 'd0;
assign  arburst = 2'b01;
assign  arlock = 'd0;
assign  arcache = 'd0;
assign  arprot = 'd0;



////////////////////////----------------IF_stage---------------------//////////////////////////////////////////
wire [31:0]   ID_j_pc          	  ;
wire  	      Inst_Req_Ack     	  ;	
wire [31:0]   IF_pc            	  ;
wire          Inst_Req_Vaild   	  ;
//wire          IF_flush          	;
wire		  IF_delay_slot    	  ;

////////////////////////----------------ID_stage---------------------//////////////////////////////////////////
wire[31:0]    Cache_inst          ;
wire          Cache_inst_valid    ;

wire          Cache_inst_ack      ;
wire          Delay               ;

wire[4:0]     ID_reg_raddr1       ; //应为id_src1 id_src2 ?
wire[4:0]     ID_reg_raddr2       ;
wire          ID_vsrc1_valid      ;
wire          ID_vsrc2_valid      ;
wire          ID_goto_MEM         ;   // 是否经过MEM级
wire          ID_goto_CP0         ;   // 是否经过CP0级 (将LO HI 的修改也放在CP0级)
wire          ID_goto_WB          ;    // 是否经过WB级
wire[31:0]    ID_reg1_br          ;    // BR指令用，记录两个源寄存器的值
wire[31:0]    ID_reg2_br          ;

wire[31:0]    ID_vsrc1            ; //以下是assign了但是没有声明的
wire[31:0]    ID_vsrc2            ;/**************** end *******************/
wire[5:0]     ID_ALUop            ;endmodule //mycpu_top
wire          ID_MULT             ;
wire          ID_DIV              ;
wire          ID_unsigned         ;
wire          ID_store            ;
wire          ID_SB               ;
wire          ID_SH               ;
wire          ID_SW               ;
wire          ID_SWL              ;
wire          ID_SWR              ;
wire          ID_load             ;
wire          ID_LB               ;
wire          ID_LBU              ;
wire          ID_LH               ;
wire          ID_LHU              ;
wire          ID_LW               ;
wire          ID_LWL              ;
wire          ID_LWR              ;
wire          ID_jump             ;
wire          ID_jump_reg         ;
wire          ID_b                ;
wire          ID_bne              ;
wire          ID_beq              ;
wire          ID_bgz              ;
wire          ID_bez              ;
wire          ID_blz              ;
wire          ID_b_predict        ;
wire[4:0]     ID_dest             ;
//wire[5:0]     ID_irp_signal       ; ???   //外部传来的硬件中断信号interrupt signal
wire          ID_ERET             ;
wire          ID_MTC0             ;
wire          ID_MTLO             ;
wire          ID_MTHI             ;
wire          ID_no_inst          ;
wire          ID_syscall          ;
wire          ID_break            ;
wire          ID_arithmetic_unimm ; //下面这些信号，后面的级似乎没用到
wire          ID_arithmetic_imm   ;
wire          ID_arithmetic       ;
wire          ID_logic_unimm      ;
wire          ID_logic_imm        ;
wire          ID_logic            ;
wire          ID_shift            ;
wire          ID_branch_1         ;
wire          ID_branch_2         ;
wire          ID_move             ;
wire[4:0]     ID_src1             ;
wire[4:0]     ID_src2             ;
wire[1:0]     ID_vsrc1_op         ;
wire[1:0]     ID_vsrc2_op         ;
wire[31:0]    ID_vsrc1_temp       ;
wire[31:0]    ID_vsrc2_temp       ;

wire[31:0] 	  ID_pc               ;
wire[31:0] 	  ID_inst             ;
wire		  ID_delay_slot       ; 


////////////////////////----------------EXE_stage---------------------//////////////////////////////////////////
wire[31:0]   fwd_vsrc1			;
wire[31:0]   fwd_vsrc2			;
wire         fwd_vsrc1_valid	;
wire         fwd_vsrc2_valid	;


wire[31:0]   EXE_alu_result 	;
wire[63:0]   EXE_mul_result 	;
reg          EXE_mul_finish 	;
wire[63:0]   EXE_div_result 	;//高32位：余数 低32位：商
wire         EXE_div_finish 	;
wire[3:0]    EXE_mem_wen    	;
wire[31:0]   EXE_mem_wdata  	;

wire         EXE_exc_overflow  	;
wire         EXE_exc_addr_load 	;//取指或读数据错误 //取值地址错我咋判断
wire         EXE_exc_addr_store	;//写数据地址错误
wire         EXE_exc_addr_inst 	;
wire         EXE_exc_syscall   	;
wire         EXE_exc_break     	;
wire         EXE_exc_no_inst   	;
wire         EXE_b_taken       	;
wire[31:0]   EXE_bad_addr      	;//出错的地址	
wire[31:0]   EXE_cp0_wdata     	;//写到CP0寄存器的数值

wire[31:0]   EXE_vsrc1       	;//EXE级使用
wire[31:0]   EXE_vsrc2       	;
wire[5:0]    EXE_ALUop       	;
wire         EXE_MULT        	;
wire         EXE_DIV         	;
wire         EXE_unsigned    	;
wire         EXE_store       	;
wire         EXE_SB          	;
wire         EXE_SH          	;
wire         EXE_SW          	;
wire         EXE_SWL         	;
wire         EXE_SWR         	;
wire         EXE_load        	;
wire         EXE_LB          	;
wire         EXE_LBU         	;
wire         EXE_LH          	;
wire         EXE_LHU         	;
wire         EXE_LW          	;
wire         EXE_LWL         	;
wire         EXE_LWR         	;
wire         EXE_jump        	;
wire         EXE_jump_reg    	;
wire         EXE_b           	;
wire         EXE_bne         	;
wire         EXE_beq         	;
wire         EXE_bgz         	;
wire         EXE_bez         	;
wire         EXE_blz         	;
wire         EXE_syscall     	;
wire         EXE_break       	;
wire         EXE_no_inst     	;
wire         EXE_b_predict   	;//CP0/MM/WB级使用
wire[31:0]   EXE_pc          	;
wire[31:0]   EXE_inst        	;
wire         EXE_goto_CP0    	;
wire         EXE_goto_MEM    	;
wire         EXE_goto_WB     	;
wire[4:0]    EXE_dest        	;
wire[5:0]    EXE_irp_signal  	;  //外部传来的硬件中断信号interrupt signal
wire		 EXE_delay_slot  	;
wire         EXE_ERET        	;
wire         EXE_MTC0        	;
wire         EXE_MTLO        	;
wire         EXE_MTHI           ;

////////////////////////----------------MEM_stage---------------------//////////////////////////////////////////
wire[31:0]   Cache_data_Address			;
wire         Cache_data_MemWrite		;
wire[31:0]   Cache_data_Write_data		;
wire[3:0]    Cache_data_Write_strb		;
wire         Cache_data_MemRead			;
wire         Cache_data_Read_data_Ack	;
wire         MEM_predict_error			;
wire[31:0]   MEM_correct_branch_pc		;
wire[31:0]   MEM_mem_rdata   			;

wire[31:0]   MEM_alu_result  			;//MEM级用
wire[31:0]   MEM_mem_wdata   			;
wire[ 4:0]   MEM_mem_wen     			;
wire         MEM_load        			;
wire         MEM_store       			;
wire         MEM_b           			;
wire         MEM_b_taken     			;
wire         MEM_b_predict   			;
wire[31:0]   MEM_pc          			;//后面级用
wire[31:0]   MEM_inst        			;
wire         MEM_goto_MEM    			;
wire         MEM_goto_WB     			;
wire[4:0]    MEM_dest        			;
wire         MEM_LB          			;
wire         MEM_LBU         			;
wire         MEM_LH          			;
wire         MEM_LHU         			;
wire         MEM_LW          			;
wire         MEM_LWL         			;
wire         MEM_LWR         			;

////////////////////////----------------WB_stage---------------------//////////////////////////////////////////
wire [31:0]  WB_reg_wdata    ; 
wire [4:0]   WB_reg_addr     ;
wire [31:0]  WB_pc           ;

////////////////////////----------------CP0_stage---------------------//////////////////////////////////////
wire [31:0] CP0_CAUSE	;
wire [31:0] CP0_STATUS	;
wire [31:0] CP0_EPC		;
wire [31:0] CP0_BADVADDR;
wire [31:0] CP0_COUNT	;
wire [31:0] CP0_COMPARE	;
wire [31:0] CP0_LO		;
wire [31:0] CP0_HI		;
wire  	    Exception	;
wire  	    Interrupt	;

////////////////////////----------------stall---------------------/////////////////////////////////
wire         IF_stall		;
wire         ID_stall		;
wire         EXE_stall		;
wire         MEM_stall		;          
wire         EXE_srcA_for	;
wire         EXE_srcB_for	;

////////////////////////----------------regfile---------------------/////////////////////////////////
wire [31:0] rdata1			;
wire        rdata1_valid	;
wire [31:0] rdata2			;
wire        rdata2_valid	;

////////////////////////----------------flush---------------------/////////////////////////////////
wire 		IF_flush 		;
wire 		ID_flush 	    ;
wire 		EXE_flush	    ;
wire 		Cache_flush	    ;




/****************** axi_slate *****************/
cache_wrapper 
#(
    .C_M_AXI_DATA_WIDTH     (32)
)cache_wrapper
(
    .M_AXI_ACLK(aclk),
    .M_AXI_ARESETN(aresetn),

    .M_AXI_AWADDR(awaddr),
    .M_AXI_AWSIZE(awsize),
    .M_AXI_AWVALID(awvalid),
    .M_AXI_AWREADY(awready),

    .M_AXI_WDATA(wdata),
    .M_AXI_WSTRB(wstrb),
    .M_AXI_WVALID(wvalid),
    .M_AXI_WREADY(wready),

    .M_AXI_BVALID(bvalid),
    .M_AXI_BREADY(bready),

    .M_AXI_ARID(arid),
    .M_AXI_ARADDR(araddr),
    .M_AXI_ARSIZE(arsize),
    .M_AXI_ARVALID(arvalid),
    .M_AXI_ARREADY(arready),

    .M_AXI_RID(rid),
    .M_AXI_RDATA(rdata),
    .M_AXI_RVALID(rvalid),
    .M_AXI_RREADY(rready),
    .M_AXI_RLAST(rlast),

    .PC              (IF_pc),
    .Inst_Req_Valid  (Inst_Req_Valid),
    .Inst_Req_Ack    (Inst_Req_Ack),  
    .Inst_Ack        (Cache_inst_ack),
    .instruction     (Cache_inst),
    .pc_req          (),////////////?????????????????????????????????????????????????这是啥信号
    .Inst_Valid      (Cache_inst_valid),

    .Flush           (Cache_flush),

    .Address         (Cache_data_Address	),
    .MemWrite        (Cache_data_MemWrite	),
    .Write_data      (Cache_data_Write_data	),
    .Write_strb      (Cache_data_Write_strb	),
    .MemRead         (Cache_data_MemRead	),
    .Mem_Req_Ack     (Cache_data_Mem_req_ack),
    .Read_data       (Cache_data_Read_data),
    .Read_data_Valid (Cache_data_Read_data_valid),
    .Read_data_Ack   (Cache_data_Read_data_Ack)
);


module IF_stage(
    .clk             	  (clk             		) ,
    .resetn          	  (resetn          		) ,
								
    .ID_j_pc         	  (ID_pc           		) , //跳转指令的pc，来自译码级
	.CP0_EPC         	  (CP0_EPC         		) , //EPC寄存器    
	.Inst_Req_Ack    	  (Inst_Req_Ack    		) ,
    .IF_stall        	  (IF_stall        		) , //阻塞信号
	.Exception       	  (Exception       		) , //例外信号
	.Interrupt       	  (Interrupt       		) , //中断信号
	.Cache_inst_valid	  (Cache_inst_valid		) , 
								
	.ID_ERET         	  (ID_ERET         		) , //ERET指令	
	.ID_b_predict    	  (ID_b_predict    		) , //转移预测结果	
	.Delay           	  (Delay           		) , //延迟槽信号

	.MEM_predict_error 	  (MEM_predict_error 	) , //转移预测错信号
	.MEM_correct_branch_pc(MEM_correct_branch_pc) , //转移预测正确pc
 
	.IF_pc           	  (IF_pc           		) , //取指级pc 
	.Inst_Req_Vaild  	  (Inst_Req_Vaild  		) ,   
	//.IF_flush      	    (IF_flush      		  ) ,   
	.IF_delay_slot   	  (IF_delay_slot   		) 
);


module ID_stage(
	.clk                (clk                ),
	.resetn             (resetn             ),
	.ID_stall           (ID_stall           ),
	.ID_clear           (ID_clear           ),

	.IF_pc		        (IF_pc		        ),
	.IF_delay_slot      (IF_delay_slot      ),

	.ID_reg_rdata1      (rdata1      ),
    .ID_reg_rdata2      (rdata2      ),
	.ID_reg_valid1      (rdata1_valid      ), // 从主寄存器堆接过来
	.ID_reg_valid2      (rdata2_valid      ), 
	.Cache_inst         (Cache_inst         ),
	.Cache_inst_valid   (Cache_inst_valid   ),

	.Cache_inst_ack     (Cache_inst_ack     ),
	.Delay              (Delay              ),

	.ID_reg_raddr1      (ID_reg_raddr1      ),  //应为??????????id_src1 id_src2 ?
	.ID_reg_raddr2      (ID_reg_raddr2      ),
	.ID_vsrc1_valid     (ID_vsrc1_valid     ),
	.ID_vsrc2_valid     (ID_vsrc2_valid     ),
	.ID_goto_MEM        (ID_goto_MEM        ),   // 是否经过MEM级
	.ID_goto_CP0        (ID_goto_CP0        ),   // 是否经过CP0级 (将LO HI 的修改也放在CP0级)
	.ID_goto_WB         (ID_goto_WB         ),    // 是否经过WB级
	.ID_reg1_br         (ID_reg1_br         ),    // BR指令用，记录两个源寄存器的值
	.ID_reg2_br         (ID_reg2_br         ),

	.ID_vsrc1           (ID_vsrc1           ), //以下是assign了但是没有声明的
    .ID_vsrc2           (ID_vsrc2           ),
    .ID_ALUop           (ID_ALUop           ),
    .ID_MULT            (ID_MULT            ),
    .ID_DIV             (ID_DIV             ),
    .ID_unsigned        (ID_unsigned        ),
    .ID_store           (ID_store           ),
    .ID_SB              (ID_SB              ),
    .ID_SH              (ID_SH              ),
    .ID_SW              (ID_SW              ),
    .ID_SWL             (ID_SWL             ),
    .ID_SWR             (ID_SWR             ),
    .ID_load            (ID_load            ),
    .ID_LB              (ID_LB              ),
    .ID_LBU             (ID_LBU             ),
    .ID_LH              (ID_LH              ),
    .ID_LHU             (ID_LHU             ),
    .ID_LW              (ID_LW              ),
    .ID_LWL             (ID_LWL             ),
    .ID_LWR             (ID_LWR             ),
    .ID_jump            (ID_jump            ),
    .ID_jump_reg        (ID_jump_reg        ),
    .ID_b               (ID_b               ),
    .ID_bne             (ID_bne             ),
    .ID_beq             (ID_beq             ),
    .ID_bgz             (ID_bgz             ),
    .ID_bez             (ID_bez             ),
    .ID_blz             (ID_blz             ),
    .ID_b_predict       (ID_b_predict       ),
    .ID_dest            (ID_dest            ),
    //.ID_irp_signal      (ID_irp_signal      ), ???   //外部传来的硬件中断信号interrupt signal
	.ID_ERET            (ID_ERET            ),
	.ID_MTC0            (ID_MTC0            ),
	.ID_MTLO            (ID_MTLO            ),
	.ID_MTHI            (ID_MTHI            ),
	.ID_no_inst         (ID_no_inst         ),
	.ID_syscall         (ID_syscall         ),
	.ID_break           (ID_break           ),
	.ID_arithmetic_unimm(ID_arithmetic_unimm), //下面这些信号，后面的级似乎没用到
    .ID_arithmetic_imm  (ID_arithmetic_imm  ),
    .ID_arithmetic      (ID_arithmetic      ),
    .ID_logic_unimm     (ID_logic_unimm     ),
    .ID_logic_imm       (ID_logic_imm       ),
    .ID_logic           (ID_logic           ),
    .ID_shift           (ID_shift           ),
    .ID_branch_1        (ID_branch_1        ),
    .ID_branch_2        (ID_branch_2        ),
    .ID_move            (ID_move            ),
    .ID_src1            (ID_src1            ),
    .ID_src2            (ID_src2            ),
    .ID_vsrc1_op        (ID_vsrc1_op        ),
    .ID_vsrc2_op        (ID_vsrc2_op        ),
    .ID_vsrc1_temp      (ID_vsrc1_temp      ),
    .ID_vsrc2_temp      (ID_vsrc2_temp      ),

	.ID_pc              (ID_pc              ),
	.ID_inst            (ID_inst            ),
	.ID_delay_slot      (ID_delay_slot      )
);
////////////?????????????????????????????????????????????????
module EXE_stage(
    .clk				(clk			   	),
	.resetn				(resetn				),
	.EXE_stall			(EXE_stall			),
	.EXE_clear			(EXE_flush			),

    .fwd_vsrc1			(),//////////??????????????????????????????从哪来
    .fwd_vsrc2			(),
    .fwd_vsrc1_valid	(),
    .fwd_vsrc2_valid	(),

    .ID_vsrc1       	(ID_vsrc1       	), //**** EXE级使用 ****
    .ID_vsrc2       	(ID_vsrc2       	),
    .ID_ALUop       	(ID_ALUop       	),
    .ID_MULT        	(ID_MULT        	),
    .ID_DIV         	(ID_DIV         	),
    .ID_unsigned    	(ID_unsigned    	),
    .ID_store       	(ID_store       	),
    .ID_SB          	(ID_SB          	),
    .ID_SH          	(ID_SH          	),
    .ID_SW          	(ID_SW          	),
    .ID_SWL         	(ID_SWL         	),
    .ID_SWR         	(ID_SWR         	),
    .ID_load        	(ID_load        	),
    .ID_LB          	(ID_LB          	),
    .ID_LBU         	(ID_LBU         	),
    .ID_LH          	(ID_LH          	),
    .ID_LHU         	(ID_LHU         	),
    .ID_LW          	(ID_LW          	),
    .ID_LWL         	(ID_LWL         	),
    .ID_LWR         	(ID_LWR         	),
    .ID_jump        	(ID_jump        	),
    .ID_jump_reg    	(ID_jump_reg    	),
    .ID_b           	(ID_b           	),
    .ID_bne         	(ID_bne         	),
    .ID_beq         	(ID_beq         	),
    .ID_bgz         	(ID_bgz         	),
    .ID_bez         	(ID_bez         	),
    .ID_blz         	(ID_blz         	),
    .ID_syscall     	(ID_syscall     	),
    .ID_break       	(ID_break       	),
    .ID_no_inst     	(ID_no_inst     	),
    .ID_b_predict   	(ID_b_predict   	), //**** 后续使用 ****
    .ID_pc          	(ID_pc          	),
    .ID_inst        	(ID_inst        	),
    .ID_goto_CP0    	(ID_goto_CP0    	),
    .ID_goto_MEM    	(ID_goto_MEM    	),
    .ID_goto_WB     	(ID_goto_WB     	),
    .ID_dest        	(ID_dest        	),
    .ID_irp_signal  	(ID_irp_signal  	),   //外部传来的硬件中断信号interrupt signal
	.ID_delay_slot  	(ID_delay_slot  	),
	.ID_ERET        	(ID_ERET        	),
	.ID_MTC0        	(ID_MTC0        	),
	.ID_MTLO        	(ID_MTLO        	),
	.ID_MTHI        	(ID_MTHI        	),

    .EXE_alu_result 	(EXE_alu_result 	),
    .EXE_mul_result 	(EXE_mul_result 	),
    .EXE_mul_finish 	(EXE_mul_finish 	),
    .EXE_div_result 	(EXE_div_result 	), //高32位：余数 低32位：商
    .EXE_div_finish 	(EXE_div_finish 	),
    .EXE_mem_wen    	(EXE_mem_wen    	),
    .EXE_mem_wdata  	(EXE_mem_wdata  	), 

    .EXE_exc_overflow  	(EXE_exc_overflow  	),
    .EXE_exc_addr_load 	(EXE_exc_addr_load 	), //取指或读数据错误 //取值地址错我咋判断
    .EXE_exc_addr_store	(EXE_exc_addr_store	), //写数据地址错误
    .EXE_exc_addr_inst 	(EXE_exc_addr_inst 	),
    .EXE_exc_syscall   	(EXE_exc_syscall   	),
    .EXE_exc_break     	(EXE_exc_break     	),
    .EXE_exc_no_inst   	(EXE_exc_no_inst   	),
    .EXE_b_taken       	(EXE_b_taken       	),
    .EXE_bad_addr      	(EXE_bad_addr      	), //出错的地址	
	.EXE_cp0_wdata     	(EXE_cp0_wdata     	), //写到CP0寄存器的数值

    .EXE_vsrc1       	(EXE_vsrc1       	), //EXE级使用
    .EXE_vsrc2       	(EXE_vsrc2       	),
    .EXE_ALUop       	(EXE_ALUop       	),
    .EXE_MULT        	(EXE_MULT        	),
    .EXE_DIV         	(EXE_DIV         	),
    .EXE_unsigned    	(EXE_unsigned    	),
    .EXE_store       	(EXE_store       	),
    .EXE_SB          	(EXE_SB          	),
    .EXE_SH          	(EXE_SH          	),
    .EXE_SW          	(EXE_SW          	),
    .EXE_SWL         	(EXE_SWL         	),
    .EXE_SWR         	(EXE_SWR         	),
    .EXE_load        	(EXE_load        	),
    .EXE_LB          	(EXE_LB          	),
    .EXE_LBU         	(EXE_LBU         	),
    .EXE_LH          	(EXE_LH          	),
    .EXE_LHU         	(EXE_LHU         	),
    .EXE_LW          	(EXE_LW          	),
    .EXE_LWL         	(EXE_LWL         	),
    .EXE_LWR         	(EXE_LWR         	),
    .EXE_jump        	(EXE_jump        	),
    .EXE_jump_reg    	(EXE_jump_reg    	),
    .EXE_b           	(EXE_b           	),
    .EXE_bne         	(EXE_bne         	),
    .EXE_beq         	(EXE_beq         	),
    .EXE_bgz         	(EXE_bgz         	),
    .EXE_bez         	(EXE_bez         	),
    .EXE_blz         	(EXE_blz         	),
    .EXE_syscall     	(EXE_syscall     	),
    .EXE_break       	(EXE_break       	),
    .EXE_no_inst     	(EXE_no_inst     	),
    .EXE_b_predict   	(EXE_b_predict   	), //CP0/MM/WB级使用
    .EXE_pc          	(EXE_pc          	),
    .EXE_inst        	(EXE_inst        	),
    .EXE_goto_CP0    	(EXE_goto_CP0    	),
    .EXE_goto_MEM    	(EXE_goto_MEM    	),
    .EXE_goto_WB     	(EXE_goto_WB     	),
    .EXE_dest        	(EXE_dest        	),
    .EXE_irp_signal  	(int[7:2]  			),   //外部传来的硬件中断信号interrupt signal
	.EXE_delay_slot  	(EXE_delay_slot  	),
	.EXE_ERET        	(EXE_ERET        	),
	.EXE_MTC0        	(EXE_MTC0        	),
	.EXE_MTLO        	(EXE_MTLO        	),
	.EXE_MTHI           (EXE_MTHI           )
);

module MEM_stage(
    .clk						(clk						),
	.resetn						(resetn						),
	.MEM_stall					(MEM_stall					),
    .EXE_stall					(EXE_stall					),
    .Cache_data_Mem_req_ack		(Cache_data_Mem_req_ack		),
    .Cache_data_Read_data  		(Cache_data_Read_data  		),
    .Cache_data_Read_data_valid	(Cache_data_Read_data_valid	),

    .EXE_alu_result  			(EXE_alu_result  			), //MEM级用
    .EXE_mem_wdata   			(EXE_mem_wdata   			),
    .EXE_mem_wen     			(EXE_mem_wen     			),
    .EXE_load        			(EXE_load        			),
    .EXE_store       			(EXE_store       			),
    .EXE_jump        			(EXE_jump        			),
    .EXE_jump_reg    			(EXE_jump_reg    			),
    .EXE_b           			(EXE_b           			),
    .EXE_b_taken     			(EXE_b_taken     			),
    .EXE_b_predict   			(EXE_b_predict   			),
    .EXE_pc          			(EXE_pc          			), //后面级用
    .EXE_inst        			(EXE_inst        			),
    .EXE_goto_MEM    			(EXE_goto_MEM    			),
    .EXE_goto_WB     			(EXE_goto_WB     			),
    .EXE_dest        			(EXE_dest        			),
    .EXE_LB          			(EXE_LB          			),
    .EXE_LBU         			(EXE_LBU         			),
    .EXE_LH          			(EXE_LH          			),
    .EXE_LHU         			(EXE_LHU         			),
    .EXE_LW          			(EXE_LW          			),
    .EXE_LWL         			(EXE_LWL         			),
    .EXE_LWR         			(EXE_LWR         			),

    .Cache_data_Address			(Cache_data_Address			),
    .Cache_data_MemWrite		(Cache_data_MemWrite		),
    .Cache_data_Write_data		(Cache_data_Write_data		),
    .Cache_data_Write_strb		(Cache_data_Write_strb		),
    .Cache_data_MemRead			(Cache_data_MemRead			),
    .Cache_data_Read_data_Ack	(Cache_data_Read_data_Ack	),
    .MEM_predict_error			(MEM_predict_error			),
    .MEM_correct_branch_pc		(MEM_correct_branch_pc		),
    .MEM_mem_rdata   			(MEM_mem_rdata   			),

    .MEM_alu_result  			(MEM_alu_result  			),//MEM级用
    .MEM_mem_wdata   			(MEM_mem_wdata   			),
    .MEM_mem_wen     			(MEM_mem_wen     			),
    .MEM_load        			(MEM_load        			),
    .MEM_store       			(MEM_store       			),
    .MEM_b           			(MEM_b           			),
    .MEM_b_taken     			(MEM_b_taken     			),
    .MEM_b_predict   			(MEM_b_predict   			),
    .MEM_pc          			(MEM_pc          			),//后面级用
    .MEM_inst        			(MEM_inst        			),
    .MEM_goto_MEM    			(MEM_goto_MEM    			),
    .MEM_goto_WB     			(MEM_goto_WB     			),
    .MEM_dest        			(MEM_dest        			),
    .MEM_LB          			(MEM_LB          			),
    .MEM_LBU         			(MEM_LBU         			),
    .MEM_LH          			(MEM_LH          			),
    .MEM_LHU         			(MEM_LHU         			),
    .MEM_LW          			(MEM_LW          			),
    .MEM_LWL         			(MEM_LWL         			),
    .MEM_LWR         			(MEM_LWR         			)
);

module WB_stage(
    .clk          (clk          ),
    .resetn       (resetn       ),

	.EXE_result   (EXE_result   ), // EXE级计算结果
	.MEM_pc       (MEM_pc       ),
	.MEM_inst     (MEM_inst     ),
	.MEM_reg_we   (MEM_reg_we   ), // 访存地址最后两位
	.MEM_dest     (MEM_dest     ),
	.MEM_goto_MEM (MEM_goto_MEM ), // 是否经过MEM级
	.MEM_mem_rdata(MEM_mem_rdata),
	.MEM_reg_rt   (MEM_reg_rt   ), // 从MEM传来的当前指令的 rt寄存器值
    .MEM_LB       (MEM_LB       ), //load的各种one hot
    .MEM_LBU      (MEM_LBU      ),
    .MEM_LH       (MEM_LH       ),
    .MEM_LHU      (MEM_LHU      ),
    .MEM_LW       (MEM_LW       ),
    .MEM_LWL      (MEM_LWL      ),
    .MEM_LWR      (MEM_LWR      ) 

    .WB_reg_wdata (WB_reg_wdata ), 
	.WB_reg_addr  (WB_reg_addr  ),
    .WB_pc        (WB_pc        ) 
);


module CP0_stage(
    .clk				(clk				),
    .resetn				(resetn				),

	.EXE_exc_overflow  	(EXE_exc_overflow  	),   //溢出
	.EXE_exc_addr_load 	(EXE_exc_addr_load 	),   //取数地址错
	.EXE_exc_addr_store	(EXE_exc_addr_store	),   //存数地址错
	.EXE_exc_addr_inst 	(EXE_exc_addr_inst 	),   //取指令地址错
	.EXE_exc_syscall   	(EXE_exc_syscall   	),   //
	.EXE_exc_break     	(EXE_exc_break     	),   //
	.EXE_exc_no_inst   	(EXE_exc_no_inst   	),   //保留指令例外

	.EXE_irp_signal   	(EXE_irp_signal   	),    //外部传来的硬件中断信号interrupt signal
	.EXE_inst         	(EXE_inst         	),    //指令的15:11位，来判断MTC0时写到哪个寄存器中
	.EXE_bad_addr     	(EXE_bad_addr     	),    //出错的地址	
	.EXE_wdata        	(EXE_wdata        	),    //写到CP0寄存器的数值
	.EXE_pc           	(EXE_pc           	),    //发生中断例外时指令对应的PC
	.EXE_delay_slot   	(EXE_delay_slot   	),    //例外延迟槽信号，表示例外是否在延迟槽中

	.EXE_ERET         	(EXE_ERET         	),	//ERET指令
	.EXE_MTC0         	(EXE_MTC0         	),    //MTC0指令

	.EXE_mul_finish 	(EXE_mul_finish 	),	//乘法器结果是否有效   (MULT和MULTU指令)	
	.EXE_div_finish 	(EXE_div_finish 	),	//除法器结果是否有效
	.EXE_MTLO          	(EXE_MTLO          	),	//MTLO指令
	.EXE_MTHI          	(EXE_MTHI          	),	//MTHI指令
	.EXE_mul_result    	(EXE_mul_result    	),	//乘法器结果
	.EXE_div_result    	(EXE_div_result    	),	//除法器结果

	.CP0_CAUSE			(CP0_CAUSE			),
	.CP0_STATUS			(CP0_STATUS			),
	.CP0_EPC			(CP0_EPC			),
	.CP0_BADVADDR		(CP0_BADVADDR		),
	.CP0_COUNT			(CP0_COUNT			),
	.CP0_COMPARE		(CP0_COMPARE		),

	.CP0_LO				(CP0_LO				),
	.CP0_HI				(CP0_HI				),

	.Exception			(Exception			),
	.Interrupt          (Interrupt          )
);

////////////?????????????????????????????????????????????????
module stall(
	.EXE_mul_div_validout(),
	.ID_j_type			 (),
	.ID_br_type			 (),
	.ID_jr_type			 (),
	.MEM_l_type			 (),
	.MEM_s_type			 (),
	.EXE_l_type			 (),
	.EXE_s_type			 (),
	.EXE_mul_div_type	 (),

	.inst_data_ok		 (),
	.data_data_ok		 (),
	.data_addr_ok		 (),
	.inst_addr_ok		 (),

	.IF_stall 			 (IF_stall 			  ),
	.ID_stall 			 (ID_stall 			  ),
	.EXE_stall			 (EXE_stall			  ),
	.MEM_stall			 (MEM_stall			  ),

	.EXE_srcA_for		 (EXE_srcA_for		  ),    // 1表示前递数据已经准备好，0表示未准备好
	.EXE_srcB_for		 (EXE_srcB_for		  ),

	.EXE_src1_forward	 (EXE_src1_forward	  ),   // EXE的源寄存器1是否需要拿前递值
	.EXE_src2_forward	 (EXE_src2_forward	  ),   // EXE的源寄存器2是否需要拿前递值

	.sec_reg_rdata1_valid(),
	.sec_reg_rdata2_valid(),   // 从sec_regfile 中获得，表示前递值已有效
	.ID_vsrc1_valid		 (ID_vsrc1_valid	  ),
	.ID_vsrc2_valid		 (ID_vsrc2_valid	  )
);


module regfile(
    .clk		 (clk		  	),

    .raddr1		 (ID_reg_raddr1	),
    .rdata1		 (rdata1		),
	.rdata1_valid(rdata1_valid	),

    .raddr2		 (ID_reg_raddr2	),
    .rdata2		 (rdata2		),
	.rdata2_valid(rdata2_valid	),

	.flush		 (),					///////////////////?????????????????????????从哪来

	.waddr		 (waddr		 	),
    .wdata		 (wdata		 	),
	.ID_dest	 (ID_dest	 	),	//只有ID级不被阻塞，正常向前传递时才将ID_dest的V位清0
	.ID_stall    (ID_stall      )
);

 module sec_regfile(
    .clk		 (clk		  	),

    .raddr1		 (ID_reg_raddr1	),
    .rdata1		 (rdata1	  	),
	.rdata1_valid(rdata1_valid	),

    .raddr2		 (ID_reg_raddr2	),
    .rdata2	 	 (rdata2	 	),
	.rdata2_valid(rdata2_valid	),

    .waddr		 (waddr		 	),
    .wdata		 (wdata		 	),
	.flush		 (),					///////////////////?????????????????????????从哪来
	.ID_dest	 (ID_dest	 	),
	.EXE_forward (EXE_forward	),
	.EXE_addr	 (EXE_addr	 	),
	.EXE_data	 (EXE_data	 	),
	.MEM_forward (MEM_forward	),
	.MEM_addr	 (MEM_addr	 	),
	.MEM_addr    (MEM_addr      )
);

module flush(
    .Exception		  (Exception		 ),
    .Interrupt		  (Interrupt		 ),
    .MEM_predict_error(MEM_predict_error ),

    .IF_delay_slot	  (IF_delay_slot	 ),
    .ID_delay_slot	  (ID_delay_slot	 ),
    .EX_delay_slot	  (EX_delay_slot	 ),

	.Cache_inst_valid (Cache_inst_valid  ),
	.Inst_Req_Vaild   (Inst_Req_Vaild    ),  	

    .IF_flush 		  (IF_flush 		 ),
    .ID_flush 		  (ID_flush 		 ),
    .EXE_flush		  (EXE_flush		 ),    
    .Cache_flush	  (Cache_flush		 )	    
);


