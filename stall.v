`include "head.h"
module stall(
	input  wire        EXE_mul_div_validout,
	input  wire        ID_j_type,
	input  wire        ID_br_type,
	input  wire        ID_jr_type,
	input  wire        MEM_l_type,
	input  wire        MEM_s_type,
	input  wire        EXE_l_type,
	input  wire        EXE_s_type,
	input  wire        EXE_mul_div_type,
	
	input  wire        inst_data_ok,
	input  wire        data_data_ok,
	input  wire        data_addr_ok,
	input  wire        inst_addr_ok,
	
	output wire        IF_stall,
	output wire        ID_stall,
	output wire        EXE_stall,
	output wire        MEM_stall,

	output wire        EXE_srcA_for,    // 1表示前递数据已经准备好，0表示未准备好
	output wire        EXE_srcB_for,
	
	
	input EXE_src1_forward,   // EXE的源寄存器1是否需要拿前递值
	input EXE_src2_forward,   // EXE的源寄存器2是否需要拿前递值
	
	input sec_reg_rdata1_valid,
	input sec_reg_rdata2_valid,   // 从sec_regfile 中获得，表示前递值已有效
	input ID_vsrc1_valid,
	input ID_vsrc2_valid,
);

    // 如果IF级指令没有取回来，需要阻塞
	// 如果ID级是BR指令，并且需要计算的两个操作数没有准备好，需要阻塞
	// 如果MEM级取的数没有回来，需要阻塞
	// 如果EXE级的乘除法没有算完，需要阻塞
	// 如果EXE级在等待前递数据，但是副寄存器中对应V位为0，需要阻塞
	
	assign IF_stall  = ((!inst_data_ok) ||
					   (ID_br_type && !(ID_vsrc1_valid && ID_vsrc2_valid)) ||  
					   (EXE_mul_div_type && !EXE_mul_div_validout) ||
					   (EXE_src1_forward && !sec_reg_rdata1_valid) ||
					   ((MEM_l_type || MEM_s_type) && !data_data_ok);
	
	
	assign ID_stall  = (ID_br_type && !(ID_vsrc1_valid && ID_vsrc2_valid)) ||  
					   (EXE_mul_div_type && !EXE_mul_div_validout) ||
					   (EXE_src1_forward && !sec_reg_rdata1_valid) ||
					   ((MEM_l_type || MEM_s_type) && !data_data_ok);
	
	
	assign EXE_stall = (EXE_mul_div_type && !EXE_mul_div_validout) ||
					   (EXE_src1_forward && !sec_reg_rdata1_valid) ||
					   ((MEM_l_type || MEM_s_type) && !data_data_ok);
	
	assign MEM_stall = ((MEM_l_type || MEM_s_type) && !data_data_ok);
	

	

	
	assign EXE_srcA_for = (EXE_src1_forward && sec_reg_rdata1_valid) ? 2'b01 :
						  2'b00;

	
	
	assign EXE_srcB_for = (EXE_src2_forward && sec_reg_rdata2_valid) ? 2'b01 :
						  2'b00;
						
							 


endmodule