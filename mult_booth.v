module booth(
    input wire[2:0] y,
    input wire[67:0] X,

    output wire[67:0] P,
    output wire c
);

	wire [3:0]	s;
    assign s[0] = (y[2] & y[1] & ~y[0]) | (y[2] & ~y[1] & y[0]);	//-x
	assign s[1] = (~y[2] & y[1] & ~y[0])| (~y[2] & ~y[1] & y[0]); 	//+x
	assign s[2] = y[2] & ~y[1] & ~y[0];								//-2x
	assign s[3] = ~y[2] & y[1] & y[0];								//+2x

	assign c = s[0] | s[2];
	assign P[0] = (s[0] & ~X[0]) | (s[1] & X[0]) | s[2] ;
	generate
	   genvar i;
	   for (i = 1; i < 68; i = i + 1)
	   begin
		  assign P[i] = s[0] & ~X[i] | s[1] & X[i] | s[2] & ~X[i-1] | s[3] & X[i-1];
	   end
	endgenerate

endmodule // booth