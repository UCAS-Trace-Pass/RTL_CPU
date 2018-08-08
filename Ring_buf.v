`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/25 09:17:00
// Design Name: 
// Module Name: Ring_buf
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Ring_buf #(
        parameter integer buf_length = 8,
        parameter integer buf_length_bits = $clog2(buf_length),
        parameter integer DATA_WEDTH = 32,
        parameter integer DATA_SELECT = 32/8
)(
        input   wire    clk,
        input   wire    resetn,
        
        input   wire    [DATA_WEDTH -1:0]  data,
        input   wire    [buf_length_bits-1 :0]  wptr,
        input   wire            wptr_valid,
        input   wire    [DATA_SELECT - 1:0]   wtrb,
        input   wire            valid,
        
        output  wire    [DATA_WEDTH*buf_length - 1 : 0]        data_pack
    );
        wire    [DATA_WEDTH - 1:0]  wdata;
        reg     [DATA_WEDTH - 1 :0]  buffer  [buf_length-1 : 0];
        reg     [buf_length_bits -1 : 0]      buf_ptr;
        
        genvar gen;
        generate
        for(gen = 0;gen < DATA_SELECT; gen = gen + 1)
        begin
                assign wdata[8*(gen + 1) - 1: gen * 8] = wtrb[gen] ? data[8*(gen + 1) - 1: gen * 8] : buffer[wptr][8*(gen + 1) - 1: gen * 8];
        end
        endgenerate
        
        generate
        for(gen = 0; gen < buf_length; gen = gen + 1)
        begin
                assign data_pack[(gen+1) * DATA_WEDTH - 1 : gen * DATA_WEDTH] = buffer[gen];
        end
        endgenerate
        
        always @(posedge clk)
        begin
                if(~resetn)
                        buf_ptr <= 'd0;
                else if(valid && ~wptr_valid)
                        buf_ptr <= (buf_ptr == buf_length-1) ? {(buf_length_bits){1'b0}} : buf_ptr + 'd1;
                else
                        buf_ptr <= buf_ptr;
        end
        
        integer i;
        always @(posedge clk)
        begin
                if(~resetn)
                begin
                        for(i = 0;i < buf_length; i = i+1)
                            buffer[i] = {(DATA_WEDTH){1'b0}};
                end
                else if(wptr_valid && valid)
                begin
                        for(i = 0;i < buf_length; i = i+1)
                            buffer[i] = (i == wptr) ? wdata : buffer[i];
                end
                else if(valid)
                begin
                        for(i = 0;i < buf_length; i = i+1)
                            buffer[i] = (i == buf_ptr) ? data : buffer[i];
                end
                else
                begin
                        for(i = 0;i < buf_length; i = i+1)
                            buffer[i] = buffer[i];
                end
        end
endmodule
