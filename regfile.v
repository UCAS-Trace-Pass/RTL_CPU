module regfile(
    input         clk,

    input  [4:0]  raddr1,
    output [31:0] rdata1,
	output        rdata1_valid,

    input  [4:0]  raddr2,
    output [31:0] rdata2,
	output        rdata2_valid,

	
	input  		  flush,
    
	input  [4:0]  waddr,
    input  [31:0] wdata,
	input  [4:0]  ID_dest,	//只有ID级不被阻塞，正常向前传递时才将ID_dest的V位清0
	input         ID_stall
);

	reg  [31:0] r [32:0];

	assign rdata1 = r[raddr1][31:0];
	assign rdata2 = r[raddr2][31:0];
	assign rdata1_valid = r[raddr1][32];
	assign rdata2_valid = r[raddr2][32];

	always @(posedge clk)
	begin
		r[0] <= {1'b1, 32'b0};
		if (flush)
			r[31:0][32] <= 1'b1;
		else begin
			if (!ID_stall)
				r[ID_dest][32] = 1'b0;
			
			if (|waddr) begin
				r[waddr] <= {1'b1, wdata};
			end
		end
	end

endmodule
