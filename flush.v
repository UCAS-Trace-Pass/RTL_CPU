`include "head.h"

module flush(
    input wire Exception,
    input wire Interrupt,
    input wire MEM_predict_error,

    input wire IF_delay_slot,
    input wire ID_delay_slot,
    input wire EX_delay_slot,
    
    input wire pc_vaid, ??? 没见过这个信号

    output wire IF_flush,
    output wire ID_flush,
    output wire EXE_flush,    
);

    assign IF_flush  = Exception || Interrupt || MEM_predict_error && !IF_delay_slot; ???
    assign ID_flush  = Exception || Interrupt || MEM_predict_error && !ID_delay_slot;
    assign EXE_flush = Exception || Interrupt || MEM_predict_error && !EXE_delay_slot;

endmodule // flush