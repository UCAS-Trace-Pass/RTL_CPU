module hbits(
    input wire clk,
    input wire resetn,
    input wire taken,
    input wire enable,
    
    output wire bo
);
    reg[1:0] bits;
    always@(posedge clk) begin
        if(!resetn)
            bits <= 0;
        else if(enable) begin
            case({bits,taken})
                3'b00_0: bits<= 2'b00;
                3'b00_1: bits<= 2'b01;

                3'b01_0: bits<= 2'b00;
                3'b01_1: bits<= 2'b10;
                
                3'b10_0: bits<= 2'b01;
                3'b10_1: bits<= 2'b11;

                3'b11_0: bits<= 2'b10;
                3'b11_1: bits<= 2'b11;
            endcase
        end
        else
            ;
    end

    assign bo = bits[1];

endmodule // hbits history bits


//todo
module hash #(parameter hash_width=24)(
    input wire[hash_width-1:0] A,
    input wire[hash_width-1:0] B,

    output wire[hash_width-1:0] hash
);
    assign hash = A ^ B;

endmodule



module bpu(
    input wire       clk,
    input wire       resetn,

    input wire       id_j, //id级是否是j型指令
    input wire       mm_b, //mm级是否是b型指令
    input wire       mm_b_taken, //mm级b型指令是否发生跳转
    
    input wire[31:0] id_PC, //id级处理的pc
    input wire       id_b,
    
    output wire      predict_taken
);

    //GBT
    parameter GBT_width = 32;
    reg[GBT_width-1:0] reg_GBT;
    always@(posedge clk) begin
        if(!resetn)
            reg_GBT <= 0;
        else if(mm_b | id_j)
            reg_GBT <= {reg_GBT[GBT_width-2:0],mm_b_taken|id_j};
        else
            ;
    end

    //keep_PC
    reg[31:0] keep_PC;
    always@(posedge clk) begin
        if(id_b)
            keep_PC <= id_PC;
        else
            ;
    end

    //hash
    parameter hash_width = 24; //todo
    parameter bits_num = 1<<hash_width;

    wire[hash_width-1:0] hash_id;
    wire[hash_width-1:0] hash_keep;

    wire[bits_num-1:0] bits_enable;
    wire[bits_num-1:0] bit_out    ;

    //hash hash_r #(.hash_width(hash_width)) (.A(reg_GBT), .B(id_PC  [hash_width-1:0]), .hash(hash_id));
    //hash hash_w #(.hash_width(hash_width)) (.A(reg_GBT), .B(keep_PC[hash_width-1:0]), .hash(hash_keep));
    hash hash_r  (.A(reg_GBT), .B(id_PC  [hash_width-1:0]), .hash(hash_id));
    hash hash_w  (.A(reg_GBT), .B(keep_PC[hash_width-1:0]), .hash(hash_keep));

    
    //update bits
    /*
    assign bits_enable = {(bits_num-1)'b0, mm_b} << hash_keep;
    generate
        genvar i;
        for(i=0; i<(1<<hash_width); i=i+1) begin
            hbits hbi(.clk(clk), .resetn(resetn), .taken(mm_b_taken), .enable(bits_enable[i]), .bo(bit_out[i]));
        end
    endgenerate
    //prediction result
    assign predict_taken = bit_out[hash_id];
    */
    reg[1:0] H_bits[bits_num-1:0];
    integer i;
    always@(posedge clk) begin
        if(!resetn) begin
            for(i=0; i<bits_num ; i=i+1)
                H_bits[i] <= 0;
        end
        else if(mm_b) begin
            case({H_bits[hash_keep],mm_b_taken})
                3'b00_0: H_bits[hash_keep]<= 2'b00;
                3'b00_1: H_bits[hash_keep]<= 2'b01;

                3'b01_0: H_bits[hash_keep]<= 2'b00;
                3'b01_1: H_bits[hash_keep]<= 2'b10;
                
                3'b10_0: H_bits[hash_keep]<= 2'b01;
                3'b10_1: H_bits[hash_keep]<= 2'b11;

                3'b11_0: H_bits[hash_keep]<= 2'b10;
                3'b11_1: H_bits[hash_keep]<= 2'b11;
            endcase
        end
        else
            ;
    end
    //prediction result
    assign predict_taken = H_bits[hash_id][1];

    //performance counter:
    reg[63:0] counter_cycles;
    reg[63:0] counter_branch_instr;
    reg[63:0] counter_branch_taken;
    reg[63:0] counter_branch_right;
    always@(posedge clk) begin
        if(!resetn)
            counter_cycles <= 0;
        else
            counter_cycles <= counter_cycles +1;
    end
    always@(posedge clk) begin
        if(!resetn)
            counter_branch_instr <= 0;
        else if(mm_b)
            counter_branch_instr <= counter_branch_instr +1;
        else
            ;
    end
    always@(posedge clk) begin
        if(!resetn)
            counter_branch_taken <= 0;
        else if(mm_b && mm_b_taken)
            counter_branch_taken <= counter_branch_taken +1;
        else
            ;
    end
    always@(posedge clk) begin
        if(!resetn)
            counter_branch_right <= 0;
        else if(mm_b && H_bits[hash_keep][1]==mm_b_taken )
            counter_branch_right <= counter_branch_right + 1;
        else
            ;
    end
    


endmodule // bpu