 module sec_regfile(
    input         clk,

    input  [4:0]  raddr1,
    output [31:0] rdata1,
	output        rdata1_valid,
	
    input  [4:0]  raddr2,
    output [31:0] rdata2,
	output        rdata2_valid,
	
    input  [4:0]  waddr,
    input  [31:0] wdata,
	input  		  flush,
	input  [4:0]  ID_dest,
	input         EXE_forward,
	input  [4:0]  EXE_addr,
	input  [31:0] EXE_data,
	input         MEM_forward,
	input  [4:0]  MEM_addr,
	input  [31:0] MEM_addr,
);

	reg  [31:0] r [32:0];   // 1'b1 valid + 32'b data

	assign rdata1 = r[raddr1][31:0];
	assign rdata2 = r[raddr2][31:0];
	assign rdata1_valid = r[raddr1][32];
	assign rdata2_valid = r[raddr2][32];
	
	
	
	always @(posedge clk)
	begin
		if (flush)
			r[0:31][32] <= 1'b1; 
		else if (EXE_forward && MEM_forward && EXE_addr == MEM_addr)
			r[EXE_addr] <= {1'b1, EXE_data};
		else if (EXE_forward)
			r[EXE_addr] <= {1'b1, EXE_data};
		else if (MEM_forward)
			r[MEM_addr] <= {1'b1, MEM_data};
		else if (|ID_dest)
			r[ID_dest][31] <= 1'b0; 
	end
	
	

endmodule
