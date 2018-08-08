`include "head.h"

module flush(
    input  wire Exception		 ,
    input  wire Interrupt		 ,
    input  wire MEM_predict_error,
 
    input  wire IF_delay_slot	 ,
    input  wire ID_delay_slot	 ,
    input  wire EX_delay_slot	 ,
   
	input  wire Cache_inst_valid ,
	input  wire Inst_Req_Vaild   ,  	

    output wire IF_flush 		 ,
    output wire ID_flush 		 ,
    output wire EXE_flush		 ,    
    output wire Cache_flush		    
);

    assign IF_flush  = (Exception || Interrupt || MEM_predict_error && !IF_delay_slot); 
    assign ID_flush  = (Exception || Interrupt || MEM_predict_error && !ID_delay_slot) & Cache_inst_valid;
    assign EXE_flush = (Exception || Interrupt || MEM_predict_error && !EXE_delay_slot)& Cache_inst_valid;
	assign Cache_flush = Cache_inst_valid ? IF_flush:
						 Inst_Req_Vaild ? IF_flush:
						 1'b0;
endmodule // flush