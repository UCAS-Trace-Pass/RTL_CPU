module nextpc(
    input  wire [31:0] IF_pc,
 
    input  wire        ID_br_type,     //1: target is PC+offset
    input  wire        ID_j_type,      //1: target is PC||offset
    input  wire        ID_jr_type,     //1: target is GR value
    input  wire [25:0] ID_j_index,     //instr_index for type "j"
    input  wire [31:0] ID_jr_index,    //target for type "jr"
    output wire [31:0] next_pc,
    input  wire [31:0] CP0_EPC,
    input  wire        ID_eret
);


	
	assign next_pc = (ID_eret) ? CP0_EPC : 
	                 (ID_j_type) ? {IF_pc[31:28],ID_j_index,2'b00} :
					 (ID_jr_type) ? ID_jr_index :
					 (ID_br_type) ? xxx(BPU传来的信号) :
					 IF_pc + 4;
endmodule