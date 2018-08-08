module multiply(
    input wire clk,
    input wire resetn,

    input wire[31:0] A,
    input wire[31:0] B,
    
    input wire sign,

    output wire[63:0] result
    /*
    output wire doing,
    output reg finish
    */
);

    //state machine
    /*
    assign doing = (mult|multu) & ~finish;
    always@(posedge clk) begin
        if(!resetn)
            finish <= 0;
        else
            finish <= (mult|multu) & doing;
    end
    */
    
    //computing progress:
    //32b*32b -> 34b*34b -> 17*68b -> 68*17b -> 68b+68b -> 68b -> 64b
    
    ///////////////////////////////////////////////////////////////
    //  first stage: booth, switch, wallace
    ///////////////////////////////////////////////////////////////

    //widen:  32b*32b -> 34b*34b
    wire[67:0] op_a,op_b;
    assign op_a={{36{A[31] & sign}},A};
    assign op_b={{36{B[31] & sign}},B};
    

    //booth:  34b*34b -> 17*68b
    wire[67:0] P[16:0];
    wire[16:0] cb; //c booth
            booth boo_0( .y({op_b[1:0],1'b0}),  .X(op_a), .P(P[0]), .c(cb[0]) );
    generate
        genvar i;
        for(i=1 ; i<17 ; i=i+1) begin
            booth boo_i( .y(op_b[i*2+1:i*2-1]), .X({op_a[67-2*i:0],{i{2'b00}}}), .P(P[i]), .c(cb[i]) );
        end
    endgenerate


    //switch and register:  17*68b -> 68*17b
    //p trans:
    wire[16:0] PP[67:0];
    reg[16:0] reg_PP[67:0];
    generate
        genvar j,k;
        for(j=0; j<17 ; j=j+1) begin
            for(k=0; k<68 ; k=k+1) begin
                assign PP[k][j] = P[j][k];
            end
        end
    endgenerate
    
    //wallace:  68*17b -> 68b+68b
    wire[67:0] sout,cout;
    wire[14:0] ct[67:0]; //c tree
            Wallace wal_0(.P(PP[0]), .ci(cb[14:0]), .co(ct[0]), .s(sout[0]), .c(cout[0]) );
    generate
        genvar y;
        for(y=1; y<68; y=y+1) begin
            Wallace wal_y(.P(PP[y]), .ci(ct[y-1]),  .co(ct[y]), .s(sout[y]), .c(cout[y]) );
        end
    endgenerate

    ///////////////////////////////////////////////////////////////
    //  second stage: add
    ///////////////////////////////////////////////////////////////
    reg[67:0] reg_sout,reg_cout;
    always@(posedge clk) begin
        reg_sout <= sout;
        reg_cout <= cout;
    end

    reg[16:0] reg_cb;
    always@(posedge clk) begin
        reg_cb <= cb;
    end

    //final add:  68b+68b -> 68b -> 64b
    /*
    wire[67:0] sum;
    assign sum = reg_sout + {reg_cout[66:0], reg_cb[15]} + reg_cb[16];
    assign result = sum[63:0];
    */
    assign result = reg_sout[63:0] + {reg_cout[62:0], reg_cb[15]} + reg_cb[16];
endmodule // multiply