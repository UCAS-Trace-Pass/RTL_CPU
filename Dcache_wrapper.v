`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/22 00:35:42
// Design Name: 
// Module Name: Dcache_wrapper
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


module Dcache_wrapper
#(
        parameter   integer TABLE_NUM = 8,
        parameter   integer TABLE_NUM_bits = $clog2(TABLE_NUM),
        parameter   integer ENTRY_SIZE = 32
)(
        input   wire            clk,
        input   wire            resetn,
        
        input   wire    [31:0]  s_araddr,
        input   wire            s_arvalid,
        output  wire            s_arready,
        
        output  wire    [31:0]  s_rdata,
        output  wire            s_rvalid,
        input   wire            s_rready,
        
        input   wire    [31:0]  s_awaddr,
        input   wire            s_awvalid,
        input   wire    [3:0]   s_wstrb,
        input   wire    [31:0]  s_wdata,
        input   wire            s_wvalid,
        
        output  wire    [31:0]  m_araddr,
        output  wire            m_arvalid,
        input   wire            m_arready,
        
        input   wire    [31:0]  m_rdata,
        input   wire            m_rvalid,
        output  wire            m_rready
    );
        wire            miss;
        wire            hit;
        wire            cacheable;
        wire    [TABLE_NUM * ENTRY_SIZE-1 : 0]  data_pack;
        wire    [TABLE_NUM * ENTRY_SIZE-1 : 0]  addr_pack;
        wire    [TABLE_NUM-1 : 0]   tag;
        wire    [TABLE_NUM-1 : 0]   wptr_tag;
        wire    [31:0]  data_found;
        wire    [TABLE_NUM_bits-1 :0]   wptr;
        wire                            wptr_valid;
        reg             wait_stage;
        reg             lookup_stage;
        reg             accessmem_stage;
        reg             waitdata_stage;
        wire   [3:0]    stage;
        reg    [31:0]   addr;
        
        assign  stage = {wait_stage, lookup_stage, accessmem_stage, waitdata_stage};
        assign  cacheable = ~(&s_awaddr[31:16]) & s_awvalid & (wptr_valid | (&s_wstrb));
        assign  miss = lookup_stage & (~|tag);
        assign  hit = lookup_stage & (|tag);
        assign  m_arvalid = accessmem_stage;
        assign  s_rvalid = waitdata_stage & m_rvalid | lookup_stage & hit;
        assign  m_rready = waitdata_stage & s_rready;
        assign  s_arready = wait_stage;
        assign  s_rdata = {{32{lookup_stage & hit}} & data_found} | {{32{waitdata_stage}} & m_rdata};
        assign  m_araddr = addr;
        assign  data_found = {{32{tag[0]}} & data_pack[31:0]} | {{32{tag[1]}} & data_pack[2*32 - 1:1*32]} | {{32{tag[2]}} & data_pack[3*32 - 1:2*32]} | {{32{tag[3]}} & data_pack[4*32 - 1:3*32]}
                           | {{32{tag[4]}} & data_pack[5*32 - 1:4*32]} | {{32{tag[5]}} & data_pack[6*32 - 1:5*32]} | {{32{tag[6]}} & data_pack[7*32 - 1:6*32]} | {{32{tag[7]}} & data_pack[8*32 - 1:7*32]};
        assign  wptr = ({(TABLE_NUM_bits){wptr_tag[0]}} & 'd0) | ({(TABLE_NUM_bits){wptr_tag[1]}} & 'd1) | ({(TABLE_NUM_bits){wptr_tag[2]}} & 'd2) | ({(TABLE_NUM_bits){wptr_tag[3]}} & 'd3)
                     | ({(TABLE_NUM_bits){wptr_tag[4]}} & 'd4) | ({(TABLE_NUM_bits){wptr_tag[5]}} & 'd5) | ({(TABLE_NUM_bits){wptr_tag[6]}} & 'd6) | ({(TABLE_NUM_bits){wptr_tag[7]}} & 'd7);
        assign  wptr_valid = |wptr_tag;
        
        genvar j;
        generate
        for( j =0; j < TABLE_NUM; j = j+1)
        begin
                assign  wptr_tag[j] = (~|(s_awaddr ^ addr_pack[ENTRY_SIZE * (j+1) -1 : ENTRY_SIZE * j])) & s_awvalid;
                assign tag[j] = ~|(addr ^ addr_pack[ENTRY_SIZE * (j+1) -1 : ENTRY_SIZE * j]);
        end
        endgenerate
        
        always @(posedge clk)
        begin
                if(~resetn)
                        wait_stage <= 1'b1;
                else if(stage == 4'b1000 && s_arvalid)
                        wait_stage <= 1'b0;
                else if((stage == 4'b0100 || stage == 4'b0001) && s_rvalid && s_rready)
                        wait_stage <= 1'b1;
                else
                        wait_stage <= wait_stage;
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                        addr <= 32'd0;
                else if(stage == 4'b1000 && s_arvalid)
                        addr <= s_araddr;
                else
                        addr <= addr;
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                        lookup_stage <= 1'b0;
                else if(stage == 4'b1000 && s_arvalid)
                        lookup_stage <= 1'b1;
                else if(stage == 4'b0100 && (miss || (hit && s_rready)))
                        lookup_stage <= 1'b0;
                else
                        lookup_stage <= lookup_stage;
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                        accessmem_stage <= 1'b0;
                else if(stage == 4'b0100 && miss)
                        accessmem_stage <= 1'b1;
                else if(stage == 4'b0010 && m_arready)
                        accessmem_stage <= 1'b0;
                else
                        accessmem_stage <= accessmem_stage;
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                        waitdata_stage <= 1'b0;
                else if(stage == 4'b0010 && m_arready)
                        waitdata_stage <= 1'b1;
                else if(stage == 4'b0001 && s_rvalid && s_rready)
                        waitdata_stage <= 1'b0;
                else
                        waitdata_stage <= waitdata_stage;
        end
        
        Ring_buf     #(
            .buf_length     (TABLE_NUM),
            .DATA_WEDTH     (ENTRY_SIZE)
        )addr_buffer(
            .clk            (clk),
            .resetn         (resetn),
        
            .data           (s_awaddr),
            .wptr           (wptr),
            .wptr_valid     (wptr_valid),
            .wtrb           (s_wstrb),
            .valid          (s_awvalid & cacheable),
        
            .data_pack      (addr_pack)
        );
        
        Ring_buf     #(
            .buf_length     (TABLE_NUM),
            .DATA_WEDTH     (ENTRY_SIZE)
        )data_buffer(
            .clk            (clk),
            .resetn         (resetn),
    
            .data           (s_wdata),
            .wptr           (wptr),
            .wptr_valid     (wptr_valid),
            .wtrb           (s_wstrb),
            .valid          (s_wvalid & cacheable),
    
            .data_pack      (data_pack)
        );
endmodule