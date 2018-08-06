// resetn and counter are both responsible for resetting
// abandon always block dealing with resetn
// 2017.10.23, 00:17, counter and resetn messed up......
// never use resetn...

// 2017.10.23, 01:20, finally this module worked. 
//                    I was so foolish that used a wrong 
//                    signal to control the shift of 
//                    variable tempReulst. Just now I 
//                    used a nother signal zeroCounter
//                    to replaced it. Now it worked. 
//                    That's really a good birthday gift .
module divider(
	      input wire 	 clk,
	      input wire 	 resetn,
	      input wire 	 div,
	      input wire 	 isSigned,
	      input wire [31:0]  A,
	      input wire [31:0]  B,
	      output wire [31:0] Q,
	      output wire [31:0] R,
	      output wire 	 complete
	      );
   
    wire [31:0] 			 absoluteA;
    wire [31:0] 			 absoluteB;
    wire [32:0] 			 extendedA;
    wire [32:0] 			 extendedB;
    wire                  zeroCounter;

    reg [63:0] 			 tempResult;
    reg [6:0] 			 counter;
    reg [31:0] 			 regQ;
    reg [63:0] 			 regA;
    reg [32:0] 			 regB;

    wire 			 Less;
    wire [31:0] 			 remainder;
    

    assign absoluteA = (isSigned && A[31]) ? ~A+1 : A;
    assign absoluteB = (isSigned && B[31]) ? ~B+1 : B;
    assign extendedA = {32'b0, absoluteA[31:0]};
    assign extendedB = {1'b0, absoluteB[31:0]};
    assign Less = (tempResult[63:31] <= extendedB);
    assign complete = (counter == 7'd33);
    assign zeroCounter = (counter == 7'b0);
    
    /*
    always@(posedge clk) begin
        counter <= (~resetn || complete) ? 7'b0 :
	            (div) ? counter + 1 : counter;

        tempResult <= (~resetn) ? 64'b0 :
	     	    (zeroCounter) ? extendedA : 
	     	    (Less) ? tempResult << 1 : {tempResult[63:31] - extendedB, tempResult[30:0]} << 1;

        regQ <= (~resetn || zeroCounter) ? 32'b0 :
	           (Less) ? regQ << 1 : (regQ << 1) | 32'b1 ;
    end
     */
    always@(posedge clk) begin
        counter <=  (!resetn )?         7'b0 :
	                (div && !complete)? counter + 1 : 
                                        counter;
        
        tempResult  <=  (!resetn) ?     64'b0 :
                        (complete)?     tempResult : 
	     	            (zeroCounter)?  extendedA : 
	     	            (Less) ?        tempResult << 1 :
                                        {tempResult[63:31] - extendedB, tempResult[30:0]} << 1;
        
        regQ <= (~resetn || zeroCounter) ? 32'b0 :
                (complete)? regQ :
	            (Less) ?    regQ << 1 : 
                            (regQ << 1) | 32'b1 ;
    end
    
    assign Q = (complete && (~isSigned)) ? regQ :
	          (complete && (A[31] ^ B[31])) ? ~regQ+1 : regQ;

    assign R = (complete && (~isSigned)) ? tempResult[63:32] :
	          (complete && A[31]) ? ~tempResult[63:32]+1 : tempResult[63:32];
endmodule
