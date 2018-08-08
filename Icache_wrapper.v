`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/22 00:35:42
// Design Name: 
// Module Name: Icache_wrapper
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
//basic configuration : two ways, line size is 16KB or 32KB, total size is 1024KB, three pipline.
//31----------------9|  8----4 |  32    |10
//       tag         |  index  | offset |
//-----------------------------------------
//optimal : multiple banks and critical word first (maybe stream buffer)

module Icache_wrapper 
#(
        parameter   integer Line_Size = 16,
        parameter   integer Line_Size_in_Bits = $clog2(Line_Size),
        parameter   integer Index_Num = 512 / Line_Size,
        parameter   integer Index_Num_in_Bits = $clog2(Index_Num)
)(
        input   wire            clk,
        input   wire            resetn,

        input   wire    [31:0]  s_araddr,
        input   wire            s_arvalid,
        output  wire            s_arready,

        output  wire    [31:0]  s_rdata,
        output  wire            s_rvalid,
        input   wire            s_rready,

        output  wire    [31:0]  m_araddr,
        output  wire            m_arvalid,
        output  wire    [7:0]   m_arlen,
        input   wire            m_arready,

        input   wire    [31:0]  m_rdata,
        input   wire            m_rvalid,
        input   wire            m_rlast,
        output  wire            m_rready
    );
        wire    [1 :0]                          hit;
        wire                                    miss;
        wire    [5:0]                           stage;
        wire    [Index_Num_in_Bits - 1 : 0]     index;
        wire    [Line_Size_in_Bits /2 - 1 : 0]  offset;
        wire    [32 - Line_Size_in_Bits - Index_Num_in_Bits -1 : 0]     tag;
        wire    [1 : 0]                         bank_replaced;
        
        reg         wait_stage;
        reg         accesstag_stage;
        reg         compare_stage;
        reg         accessmem_stage;
        reg         waitkeyword_stage;
        reg         waitdata_stage;
        reg     [31 : 0]                                                addr;
        reg     [31 : 0]                                                rdata;
        reg                                                             rvalid;
        reg     [32 - Line_Size_in_Bits - Index_Num_in_Bits -1 : 0]     way1_tag;
        reg     [31:0]                                                  way1_rdata;
        reg                                                             way1_valid;
        reg     [32 - Line_Size_in_Bits - Index_Num_in_Bits -1 : 0]     way2_tag;
        reg     [31:0]                                                  way2_rdata;
        reg                                                             way2_valid;
        reg     [1 :0]                                                  bank_replaced_reg;
        reg     [1 : 0]                                                 used_record;
        reg     [Line_Size_in_Bits /2 : 0]                          rindex;
        reg     [Line_Size * 8 - 1: 0]                                bank1   [512 / Line_Size - 1:0];
        reg     [32 - Line_Size_in_Bits - Index_Num_in_Bits -1 : 0]   tag1    [512 / Line_Size - 1:0];
        reg     [Line_Size / 4 - 1 : 0]                               valid_array1  [512 / Line_Size - 1:0];
        reg     [Line_Size * 8 - 1: 0]                                bank2   [512 / Line_Size - 1:0];
        reg     [32 - Line_Size_in_Bits - Index_Num_in_Bits -1 : 0]   tag2    [512 / Line_Size - 1:0];
        reg     [Line_Size / 4 - 1 : 0]                               valid_array2  [512 / Line_Size - 1:0];
        reg     [1 : 0]                                               used_record_array     [512 / Line_Size - 1:0];
  
        assign      stage = {wait_stage, accesstag_stage, compare_stage, accessmem_stage, waitkeyword_stage,waitdata_stage};
        assign      index = addr[Index_Num_in_Bits + 2 + Line_Size_in_Bits /2 -1 : 2 + Line_Size_in_Bits /2];
        assign      offset = addr[1+Line_Size_in_Bits /2 : 2];
        assign      tag = addr[31 : Index_Num_in_Bits + 2 + Line_Size_in_Bits /2];
        assign      s_arready =  wait_stage ;
        assign      s_rvalid = (rvalid) | (compare_stage & (hit[0] & way1_valid | hit[1] & way2_valid));
        assign      s_rdata = {{32{rvalid}} & rdata} | {{32{compare_stage & hit[0]}} & way1_rdata} | {{32{compare_stage & hit[1]}} & way2_rdata};
        assign      m_araddr = addr;
        assign      m_arvalid = accessmem_stage;
        assign      m_arlen = Line_Size / 4 - offset - 'd1;
        assign      m_rready = waitkeyword_stage | waitdata_stage;
        assign      miss = ~|hit;
        assign      hit[0] = ~|(tag ^ way1_tag) & way1_valid;
        assign      hit[1] = ~|(tag ^ way2_tag) & way2_valid;
        
        always @(posedge clk)
        begin
                if(~resetn)
                        wait_stage <= 1'b1;
                else if(s_arvalid && stage == 6'b100000)
                        wait_stage <= 1'b0;
                else if((stage == 6'b001000 && (|hit) && s_rready) || (stage == 6'b000001 && m_rlast && m_rvalid && (~rvalid || rvalid && s_rready)) 
                         || (stage == 6'b000010 && m_rlast && m_rvalid && (~rvalid || rvalid && s_rready)) || (stage == 6'b000000 && rvalid && s_rready))
                        wait_stage <= 1'b1;
                else
                        wait_stage <= wait_stage;
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                        accesstag_stage <= 1'b0;
                else if(stage == 6'b100000 && s_arvalid)
                        accesstag_stage <= 1'b1;
                else
                        accesstag_stage <= 1'b0;           
        end
        
         always @(posedge clk)
        begin
                if(~resetn)
                        compare_stage <= 1'b0;
                else if(stage == 6'b010000)
                        compare_stage <= 1'b1;
                else if((stage == 6'b001000 && (|hit) && s_rready) || (stage == 6'b001000 && miss))
                        compare_stage <= 1'b0;
                else
                        compare_stage <= compare_stage;
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                        accessmem_stage <= 1'b0;
                else if(stage == 6'b001000 && miss )
                        accessmem_stage <= 1'b1;
                else if(stage == 6'b000100 && m_arready)
                        accessmem_stage <= 1'b0;
                else
                        accessmem_stage <= accessmem_stage;
        end
    
        always @(posedge clk)
        begin
                if(~resetn)
                        waitkeyword_stage <= 1'b0;
                else if(stage == 6'b000100 && m_arready)
                        waitkeyword_stage <= 1'b1;
                else if(stage == 6'b000010 && m_rvalid)
                        waitkeyword_stage <= 1'b0;
                else 
                        waitkeyword_stage <= waitkeyword_stage;
        end
       
        always @(posedge clk)
        begin
                if(~resetn)
                        waitdata_stage <= 1'b0;
                else if(stage == 6'b000010 && m_rvalid && ~m_rlast)
                        waitdata_stage <= 1'b1;
                else if(stage == 6'b000001 && m_rlast && m_rvalid)
                        waitdata_stage <= 1'b0;
                else
                        waitdata_stage <= waitdata_stage;
        end
        
         always @(posedge clk)
        begin
                if(~resetn)
                        addr <= 32'd0;
                else if(wait_stage && s_arvalid)
                        addr <= s_araddr;
                else
                        addr <= addr;
        end
      
        always @(posedge clk)
        begin
                if(~resetn)
                        rdata <= 32'd0;
                else if(waitkeyword_stage && m_rvalid)
                        rdata <= m_rdata;
                else
                        rdata <= rdata;
        end
       
        always @(posedge clk)
        begin
                if(~resetn)
                        rvalid <= 1'b0;
                else if(waitkeyword_stage && m_rvalid)
                        rvalid <= 1'b1;
                else if(rvalid && s_rready)
                        rvalid <= 1'b0;
                else
                        rvalid <= rvalid;
        end

        always @(posedge clk)
        begin
                if(~resetn)
                        way1_tag <= 'd0;
                else if(accesstag_stage)
                        way1_tag <= tag1[index];
                else
                        way1_tag <= way1_tag;
        end
      
        always @(posedge clk)
        begin
                if(~resetn)
                        way1_rdata <= 32'd0;
                else if(accesstag_stage)
                        way1_rdata <= offset == 2'b00 ? bank1[index][31 : 0]
                                                        : (offset == 2'b01 ? bank1[index][63 : 32]
                                                        : (offset == 2'b10 ? bank1[index][95 : 64]
                                                        : bank1[index][127 : 96]));
                else
                        way1_rdata <= way1_rdata;
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                        way1_valid <= 1'b0;
                else if(accesstag_stage)
                        way1_valid <= offset == 2'b00 ? valid_array1[index][0]
                                                        : (offset == 2'b01 ? valid_array1[index][1]
                                                        : (offset == 2'b10 ? valid_array1[index][2]
                                                        : valid_array1[index][3]));
                else if(compare_stage && hit[0] && way1_valid && s_rready)
                        way1_valid <= 1'b0;
                else
                        way1_valid <= way1_valid;
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                        way2_tag <= 'd0;
                else if(accesstag_stage)
                        way2_tag <= tag2[index];
                else
                        way2_tag <= way2_tag;
        end
      
        always @(posedge clk)
        begin
                if(~resetn)
                        way2_rdata <= 32'd0;
                else if(accesstag_stage)
                        way2_rdata <= offset == 2'b00 ? bank2[index][31 : 0]
                                                        : (offset == 2'b01 ? bank2[index][63 : 32]
                                                        : (offset == 2'b10 ? bank2[index][95 : 64]
                                                        : bank2[index][127 : 96]));
                else
                        way2_rdata <= way2_rdata;
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                        way2_valid <= 1'b0;
                else if(accesstag_stage)
                        way2_valid <= offset == 2'b00 ? valid_array2[index][0]
                                                        : (offset == 2'b01 ? valid_array2[index][1]
                                                        : (offset == 2'b10 ? valid_array2[index][2]
                                                        : valid_array2[index][3]));
                else if(compare_stage && hit[0] && way2_valid && s_rready)
                        way2_valid <= 1'b0;
                else
                        way2_valid <= way2_valid;
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                        rindex <= 'd0;
                else if(accessmem_stage && m_arready)
                        rindex <= offset;
                else if(m_rvalid && m_rready)
                        rindex <= rindex + 'd1;
                else
                        rindex <= rindex;
        end
        
        integer i;
        always @(posedge clk)
        begin
                if(~resetn)
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                bank1[i] <= 'd0;
                        end
                end
                else if(m_rvalid && m_rready && bank_replaced_reg[0])
                begin
                        for(i = 0;i < 512 / Line_Size; i = i+1)
                        begin
                                bank1[i] <= (i == index) ? (rindex == 'd0 ? {bank1[i][127:32],m_rdata}
                                                           :(rindex == 'd1 ? {bank1[i][127:64],m_rdata,bank1[i][31:0]}
                                                           :(rindex == 'd2 ? {bank1[i][127:96],m_rdata,bank1[i][63:0]}
                                                           :{m_rdata,bank1[i][95:0]})))
                                            :   bank1[i];
                        end
                end
                else
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                bank1[i] <= bank1[i];
                        end
                end
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                tag1[i] <= 'd0;
                        end
                end
                else if(accessmem_stage && m_arready && bank_replaced_reg[0])
                begin
                         for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                tag1[i] <= i == index ? tag : tag1[i];
                        end
                end
                else
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                tag1[i] <= tag1[i];
                        end
                end
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                valid_array1[i] <= 'd0;
                        end
                end
                else if(accessmem_stage && m_arready && bank_replaced_reg[0])
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                valid_array1[i] <= i == index ? 'd0 : valid_array1[i];
                        end
                end
                else if(m_rvalid && m_rready && bank_replaced_reg[0])
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                valid_array1[i] <= i == index ? (rindex == 'd0 ? {valid_array1[i][3:1],1'b1}
                                                                :(rindex == 'd1 ? {valid_array1[i][3:2],1'b1,valid_array1[i][0]}
                                                                :(rindex == 'd2 ? {valid_array1[i][3],1'b1,valid_array1[i][1:0]}
                                                                :{1'b1,valid_array1[i][2:0]}))) 
                                                   : valid_array1[i];
                        end 
                end
                else
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                valid_array1[i] <= valid_array1[i];
                        end
                end
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                bank2[i] <= 'd0;
                        end
                end
                else if(m_rvalid && m_rready && bank_replaced_reg[1])
                begin
                        for(i = 0;i < 512 / Line_Size; i = i+1)
                        begin
                                bank2[i] <= (i == index) ? (rindex == 'd0 ? {bank2[i][127:32],m_rdata}
                                                           :(rindex == 'd1 ? {bank2[i][127:64],m_rdata,bank2[i][31:0]}
                                                           :(rindex == 'd2 ? {bank2[i][127:96],m_rdata,bank2[i][63:0]}
                                                           :{m_rdata,bank2[i][95:0]})))
                                            :   bank2[i];
                        end
                end
                else
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                bank2[i] <= bank2[i];
                        end
                end
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                tag2[i] <= 'd0;
                        end
                end
                else if(accessmem_stage && m_arready && bank_replaced_reg[1])
                begin
                         for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                tag2[i] <= i == index ? tag : tag2[i];
                        end
                end
                else
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                tag2[i] <= tag2[i];
                        end
                end
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                valid_array2[i] <= 'd0;
                        end
                end
                else if(accessmem_stage && m_arready && bank_replaced_reg[1])
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                valid_array2[i] <= i == index ? 'd0 : valid_array2[i];
                        end
                end
                else if(m_rvalid && m_rready && bank_replaced_reg[1])
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                valid_array2[i] <= i == index ? (rindex == 'd0 ? {valid_array2[i][3:1],1'b1}
                                                                :(rindex == 'd1 ? {valid_array2[i][3:2],1'b1,valid_array2[i][0]}
                                                                :(rindex == 'd2 ? {valid_array2[i][3],1'b1,valid_array2[i][1:0]}
                                                                :{1'b1,valid_array2[i][2:0]}))) 
                                                   : valid_array2[i];
                        end 
                end
                else
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                valid_array2[i] <= valid_array2[i];
                        end
                end
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                used_record_array[i] <= 2'b00;
                        end
                end
                else if(compare_stage && hit[0] && s_rready || bank_replaced_reg[0] && accessmem_stage)
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                used_record_array[i] <= i == index ? 2'b01 : used_record_array[i];
                        end
                end
                else if(compare_stage && hit[1] && s_rready || bank_replaced_reg[1] && accessmem_stage)
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                used_record_array[i] <= i == index ? 2'b10 : used_record_array[i];
                        end
                end
                else
                begin
                        for(i = 0; i<512 / Line_Size;i = i+1)
                        begin
                                used_record_array[i] <= used_record_array[i];
                        end
                end
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                        used_record <= 2'b00;
                else if(accesstag_stage)
                        used_record <= used_record_array[index];
                else
                        used_record <= used_record;
        end
        
        always @(posedge clk)
        begin
                if(~resetn)
                        bank_replaced_reg <= 2'b00;
                else if(compare_stage && miss)
                        bank_replaced_reg <= bank_replaced;
                else
                        bank_replaced_reg <= bank_replaced_reg; 
        end
        
        replace_police u_replace_police(
                .used_record            (used_record),
                .valid_array            ({way1_valid,way2_valid}),
                
                .bank_replaced          (bank_replaced)
        );
endmodule
