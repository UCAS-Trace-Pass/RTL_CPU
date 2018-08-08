`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/02 19:51:38
// Design Name: 
// Module Name: axi_crossbar
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

//2-->1 crossbar channel 0's priority is greater than channel 1's.
module axi_crossbar(
        input  wire        aclk,
        input  wire        aresetn,
        
        input  wire     [7:0]       s_axi_awid,
        input  wire     [63:0]      s_axi_awaddr,
        input   wire    [5:0]       s_axi_awsize,
        input   wire    [1:0]       s_axi_awvalid,
        output  wire    [1:0]       s_axi_awready,
    
        input   wire    [7:0]       s_axi_wid,
        input   wire    [63:0]      s_axi_wdata,
        input   wire    [7:0]       s_axi_wstrb,
        input   wire    [1:0]       s_axi_wlast,
        input   wire    [1:0]       s_axi_wvalid,
        output  wire    [1:0]       s_axi_wready,
    
        output   wire   [1:0]       s_axi_bvalid,
        input   wire    [1:0]       s_axi_bready,
    
        input   wire    [7:0]       s_axi_arid,
        input   wire    [63:0]      s_axi_araddr,
        input   wire    [7:0]       s_axi_arlen,
        input   wire    [5:0]       s_axi_arsize,
        input   wire    [1:0]       s_axi_arvalid,
        output  wire    [1:0]       s_axi_arready,
    
        output  wire    [63:0]      s_axi_rdata,
        output   wire   [1:0]       s_axi_rlast,
        output  wire    [1:0]       s_axi_rvalid,
        input   wire    [1:0]       s_axi_rready,
                
        output wire    [3:0]        m_axi_awid,
        output wire     [31:0]      m_axi_awaddr,
        output wire     [2:0]       m_axi_awsize,
        output wire                 m_axi_awvalid,
        input  wire                 m_axi_awready,

        output wire    [3:0]        m_axi_wid,
        output wire     [31:0]      m_axi_wdata,
        output wire     [3:0]       m_axi_wstrb,
        output  wire                m_axi_wlast,
        output wire                 m_axi_wvalid,
        input  wire                 m_axi_wready,

        input  wire                 m_axi_bvalid,
        output wire                 m_axi_bready,

        output wire     [3:0]       m_axi_arid,
        output wire     [31:0]      m_axi_araddr,
        output  wire    [3:0]       m_axi_arlen,
        output wire     [2:0]       m_axi_arsize,
        output wire                 m_axi_arvalid,
        input  wire                 m_axi_arready,

        input wire                  m_axi_rid,
        input  wire     [31:0]      m_axi_rdata,
        input   wire                m_axi_rlast,
        input  wire                 m_axi_rvalid,
        output wire                 m_axi_rready
    );
    
    reg         wait_state;
    reg         channel0_read_state;
    reg         channel1_read_state;
    
    wire    [2:0]   state;
    
    assign      state = {wait_state, channel0_read_state, channel1_read_state};
    //read channel
    assign      s_axi_rdata = {{32{m_axi_rid}} & m_axi_rdata, {32{~m_axi_rid}} & m_axi_rdata};
    assign      s_axi_rlast = {m_axi_rlast, m_axi_rlast};
    assign      s_axi_rvalid = {m_axi_rid & m_axi_rvalid, ~m_axi_rid & m_axi_rvalid};
    assign      m_axi_rready = m_axi_rid ? s_axi_rready[1] : s_axi_rready[0];
    //read address channel
    assign      m_axi_arsize = s_axi_arsize[2:0];
    assign      m_axi_arid = channel1_read_state;
    assign      m_axi_araddr = {{32{channel1_read_state}} & s_axi_araddr[63:32]} | {{32{channel0_read_state}} & s_axi_araddr[31:0]};
    assign      m_axi_arlen = {{4{channel1_read_state}} & s_axi_arlen[7:4]};
    assign      m_axi_arvalid = channel1_read_state | channel0_read_state;
    assign      s_axi_arready = {channel1_read_state & m_axi_arready, channel0_read_state & m_axi_arready};
    
    always @(posedge aclk)
    begin
            if(~aresetn)
                    wait_state <= 1'b1;
            else if(state == 3'b100 && (|s_axi_arvalid))
                    wait_state <= 1'b0;
            else if((state == 3'b010 || state == 3'b001) && m_axi_arvalid && m_axi_arready)
                    wait_state <= 1'b1;
            else
                    wait_state <= wait_state;
    end
    
    always @(posedge aclk)
    begin
            if(~aresetn)
                    channel0_read_state <= 1'b0;
            else if(state == 3'b100 && s_axi_arvalid[0])
                    channel0_read_state <= 1'b1;
            else if(state == 3'b010 && m_axi_arvalid && m_axi_arready)
                    channel0_read_state <= 1'b0;
            else
                    channel0_read_state <= channel0_read_state;
    end
    
    always @(posedge aclk)
    begin
            if(~aresetn)
                    channel1_read_state <= 1'b0;
            else if((state == 3'b100) && s_axi_arvalid[1] && ~s_axi_arvalid[0])
                    channel1_read_state <= 1'b1;
            else if(state == 3'b001 && m_axi_arvalid && m_axi_arready)
                    channel1_read_state <= 1'b0;
            else
                    channel1_read_state <= channel1_read_state;
    end
    
    //write channel
    assign      m_axi_wid = s_axi_wid[3:0];
    assign      m_axi_wdata = s_axi_wdata[31:0];
    assign      m_axi_wstrb = s_axi_wstrb[3:0];
    assign      m_axi_wlast = s_axi_wlast[0];
    assign      m_axi_wvalid = s_axi_wvalid[0];
    assign      s_axi_wready = {1'b0, m_axi_wready};
    //write adress channel
    assign      m_axi_awid = s_axi_awid[3:0];
    assign      m_axi_awaddr = s_axi_awaddr[31:0];
    assign      m_axi_awsize = s_axi_awsize[2:0];
    assign      m_axi_awvalid = s_axi_awvalid[0];
    assign      s_axi_awready = {1'b0, m_axi_awready};
    //write response channel
    assign      m_axi_bready = s_axi_bready[0];
    assign      s_axi_bvalid = {1'b0, m_axi_bvalid};
    
endmodule
