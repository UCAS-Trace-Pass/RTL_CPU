module full_add(
    input wire a,
    input wire b,
    input wire ci,

    output wire co,
    output wire s
);
    assign s = ~a & ~b &  ci |
                ~a &  b & ~ci |
                a & ~b & ~ci |
                a &  b &  ci ;

    assign co= ~a &  b &  ci |
                a & ~b &  ci |
                a &  b & ~ci |
                a &  b &  ci ;
                
endmodule // full_add
/*
 a b ci|co s
 0 0 0 |0  0
 0 0 1 |0  1
 0 1 0 |0  1
 0 1 1 |1  0
 1 0 0 |0  1
 1 0 1 |1  0
 1 1 0 |1  0
 1 1 1 |1  1
*/

//////////////////////////////////////////////////
//////////////////////////////////////////////////

module half_add(
    input wire a,
    input wire b,
    
    output wire co,
    output wire s
);
    assign s  = a & ~b | ~a & b;
    assign co = a & b ;

endmodule // half_add

/*
 a b|co s
 0 0|0  0
 0 1|0  1
 1 0|0  1
 1 1|1  0
*/