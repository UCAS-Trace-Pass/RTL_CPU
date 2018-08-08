module Wallace (
    input wire[16:0] P,
    input wire[14:0] ci,

    output wire[14:0] co,
    output wire s,
    output wire c
);

    wire[14:0] st; //s inside tree

    full_add a0  ( .a(P[0 ] ), .b(P[1 ] ), .ci(P[2 ]), .co(co[0 ]), .s(st[0]) );
    full_add a1  ( .a(P[3 ] ), .b(P[4 ] ), .ci(P[5 ]), .co(co[1 ]), .s(st[1]) );
    full_add a2  ( .a(P[6 ] ), .b(P[7 ] ), .ci(P[8 ]), .co(co[2 ]), .s(st[2]) );
    full_add a3  ( .a(P[9 ] ), .b(P[10] ), .ci(P[11]), .co(co[3 ]), .s(st[3]) );
    full_add a4  ( .a(P[12] ), .b(P[13] ), .ci(P[14]), .co(co[4 ]), .s(st[4]) );
    half_add a5  ( .a(P[15] ), .b(P[16] ),             .co(co[5 ]), .s(st[5]) ); //half add
  
    full_add a6  ( .a(st[0 ]), .b(st[1] ), .ci(st[2]), .co(co[6 ]), .s(st[6 ]) );
    full_add a7  ( .a(st[3 ]), .b(st[4] ), .ci(st[5]), .co(co[7 ]), .s(st[7 ]) );
    full_add a8  ( .a(ci[0 ]), .b(ci[1] ), .ci(ci[2]), .co(co[8 ]), .s(st[8 ]) );
    full_add a9  ( .a(ci[3 ]), .b(ci[4] ), .ci(ci[5]), .co(co[9 ]), .s(st[9 ]) );
  
    full_add a10 ( .a(st[6 ]), .b(st[7] ), .ci(st[8]), .co(co[10]), .s(st[10]) );
    full_add a11 ( .a(st[9 ]), .b(ci[6] ), .ci(ci[7]), .co(co[11]), .s(st[11]) );

    full_add a12 ( .a(st[10]), .b(st[11]), .ci(ci[8 ]), .co(co[12]), .s(st[12]) );
    full_add a13 ( .a(ci[9 ]), .b(ci[10]), .ci(ci[11]), .co(co[13]), .s(st[13]) );

    full_add a14 ( .a(st[12]), .b(st[13]), .ci(ci[12]), .co(co[14]), .s(st[14]) );
    
    full_add a15 ( .a(st[14]), .b(ci[13]), .ci(ci[14]), .co(c)     , .s(s)      );

/*
    full_add a0  ( .a(P[14] ), .b(P[15] ), .ci(P[16]), .co(co[0 ]), .s(st[0]) );
    full_add a1  ( .a(P[11] ), .b(P[12] ), .ci(P[13]), .co(co[1 ]), .s(st[1]) );
    full_add a2  ( .a(P[8 ] ), .b(P[9 ] ), .ci(P[10]), .co(co[2 ]), .s(st[2]) );
    full_add a3  ( .a(P[5 ] ), .b(P[6 ] ), .ci(P[7 ]), .co(co[3 ]), .s(st[3]) );
    full_add a4  ( .a(P[2 ] ), .b(P[3 ] ), .ci(P[4 ]), .co(co[4 ]), .s(st[4]) );
    half_add a5  ( .a(P[0 ] ), .b(P[1 ] ),             .co(co[5 ]), .s(st[5]) ); //half add
  
    full_add a6  ( .a(st[3 ]), .b(st[4] ), .ci(st[5]), .co(co[6 ]), .s(st[6 ]) );
    full_add a7  ( .a(st[0 ]), .b(st[1] ), .ci(st[2]), .co(co[7 ]), .s(st[7 ]) );
    full_add a8  ( .a(ci[3 ]), .b(ci[4] ), .ci(ci[5]), .co(co[8 ]), .s(st[8 ]) );
    full_add a9  ( .a(ci[0 ]), .b(ci[1] ), .ci(ci[2]), .co(co[9 ]), .s(st[9 ]) );
    
    full_add a10 ( .a(st[7 ]), .b(st[8] ), .ci(st[9]), .co(co[10]), .s(st[10]) );
    full_add a11 ( .a(st[6 ]), .b(ci[6] ), .ci(ci[7]), .co(co[11]), .s(st[11]) );

    full_add a12 ( .a(st[10]), .b(st[11]), .ci(ci[8 ]), .co(co[12]), .s(st[12]) );
    full_add a13 ( .a(ci[9 ]), .b(ci[10]), .ci(ci[11]), .co(co[13]), .s(st[13]) );

    full_add a14 ( .a(st[12]), .b(st[13]), .ci(ci[12]), .co(co[14]), .s(st[14]) );
    
    full_add a15 ( .a(st[14]), .b(ci[13]), .ci(ci[14]), .co(c)     , .s(s)      );
   */     
endmodule // 