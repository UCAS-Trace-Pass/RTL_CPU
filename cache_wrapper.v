`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/21 10:12:50
// Design Name: 
// Module Name: cache_wrapper
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

module cache_wrapper(
// System Signals
  input wire M_AXI_ACLK,
  input wire M_AXI_ARESETN,
  ////////////////////////////////////////////////////////////////////////////
  // Master Interface Write Address
  output wire [31:0]      M_AXI_AWADDR,
  output wire [2:0] M_AXI_AWSIZE,
  output wire M_AXI_AWVALID,
  input  wire M_AXI_AWREADY,
  ////////////////////////////////////////////////////////////////////////////
  // Master Interface Write Data
  output wire [31:0]      M_AXI_WDATA,
  output wire [3:0]    M_AXI_WSTRB,
  output wire M_AXI_WVALID,
  input  wire M_AXI_WREADY,
  ////////////////////////////////////////////////////////////////////////////
  // Master Interface Write Response
  input  wire M_AXI_BVALID,
  output wire M_AXI_BREADY,
  ////////////////////////////////////////////////////////////////////////////
  // Master Interface Read Address
  output wire [3:0] M_AXI_ARID,
  output wire [31:0]      M_AXI_ARADDR,
  output wire [2:0] M_AXI_ARSIZE,
  output wire M_AXI_ARVALID,
  output wire [3:0] M_AXI_ARLEN,
  input  wire M_AXI_ARREADY,
  ////////////////////////////////////////////////////////////////////////////
  // Master Interface Read Data
  input wire [3:0] M_AXI_RID,
  input  wire [31:0]      M_AXI_RDATA,
  input  wire M_AXI_RVALID,
  input  wire M_AXI_RLAST,
  output wire M_AXI_RREADY,
  ////////////////////////////////////////////////////////////////////////////
  // Master Interface with IF stage
  input  wire [31:0] PC,
  input  wire        Inst_Req_Valid,
  output wire        Inst_Req_Ack,
  
  input  wire        Inst_Ack,
  output wire [31:0] instruction,
  output wire  [31:0] pc_req,  
  output wire        Inst_Valid,
  ////////////////////////////////////////////////////////////////////////////
  // Master Interface with ID stage
  input wire        Flush,
  ////////////////////////////////////////////////////////////////////////////
  // Master Interface with MEM stage
  input  wire   [31:0]  Address,
  input wire            MemWrite,
  input wire    [31:0]  Write_data,
  input wire    [3:0]   Write_strb,
  input wire            MemRead,
  output wire           Mem_Req_Ack,
  output wire [31:0]    Read_data,
  output wire           Read_data_Valid,
  input wire            Read_data_Ack
    );
    
    assign          M_AXI_ARID[3:1] = 3'd0;
    wire            pc_rvalid;
    wire            pc_rready;
    wire    [31:0]  pc_rdata;
    wire            pc_rlast;
    wire            pc_arvalid;
    wire            pc_arready;
    wire    [31:0]  pc_araddr;
    wire    [3:0]   pc_arlen;
    wire            pc_wready;
    wire            pc_awready;
    wire            pc_bvalid;
    
    wire            mem_rvalid;
    wire            mem_rready;
    wire    [31:0]  mem_rdata;
    wire            mem_rlast;
    wire            mem_arvalid;
    wire            mem_arready;
    wire    [31:0]  mem_araddr;
    reg            mem_wvalid;
    wire    [31:0]  mem_wdata;
    wire            mem_wready;
    wire    [3:0]   mem_wstrb;
    reg            mem_awvalid;
    wire            mem_awready;
    wire    [31:0]  mem_awaddr;
    wire            mem_bvalid;
    
    wire            wdata_fifo_is_empty;
    wire            wdata_fifo_is_full;
    wire            wdata_fifo_ready;
    
    wire            waddr_fifo_is_empty;
    wire            waddr_fifo_is_full;
    wire            waddr_fifo_ready;
    
    wire            pc_req_fifo_full;
    wire            pc_req_fifo_empty;
    
    wire    [31:0]      D_mem_araddr;
    wire                D_mem_arvalid;
    wire                D_mem_arready;
    wire    [31:0]      D_mem_rdata;
    wire                D_mem_rvalid;
    wire                D_mem_rready;
    wire                D_mem_rlast;
    
    reg             flush_state;
    reg             wait_inst_state;
    reg             wait_mem_state;
    reg             pc_rvalid_slot;
    reg     [31:0]  inst_slot;
    
    assign          Inst_Req_Ack = pc_arvalid & pc_arready | Flush;
    assign          instruction = {(pc_rdata & {32{wait_inst_state}})} ;//| (inst_slot & {32{wait_mem_state}})};
    assign          Inst_Valid = (pc_rvalid & wait_inst_state & ~Flush) ;//| (pc_rvalid_slot);
    
    assign          Mem_Req_Ack = (MemRead & mem_arvalid & mem_arready) | (MemWrite & wdata_fifo_ready & waddr_fifo_ready);
    assign          Read_data = mem_rdata;
    assign          Read_data_Valid = mem_rvalid;
    
    assign          pc_rready = (Inst_Ack & wait_inst_state) | flush_state ;//| wait_mem_state;
    assign          pc_arvalid = Inst_Req_Valid;
    assign          pc_araddr = PC;
    assign          pc_rlast = pc_rvalid;
    assign          pc_arlen = 'd0;
    
    assign          mem_rready = Read_data_Ack;
    assign          mem_arvalid = MemRead;
    assign          mem_araddr = {Address[31:2], 2'b00};
    assign          mem_rlast = mem_rvalid;

    always @(posedge M_AXI_ACLK)
    begin
            if(~M_AXI_ARESETN)
                    mem_wvalid <= 1'b0;
            else if(~wdata_fifo_is_empty && ~mem_wvalid)
                    mem_wvalid <= 1'b1;
            else if(mem_wready && mem_wvalid)
                    mem_wvalid <= 1'b0;
            else
                    mem_wvalid <= mem_wvalid;
    end
    
    always @(posedge M_AXI_ACLK)
    begin
            if(~M_AXI_ARESETN)
                    mem_awvalid <= 1'b0;
            else if(~waddr_fifo_is_empty && ~mem_awvalid)
                    mem_awvalid <= 1'b1;
            else if(mem_awvalid && mem_awready)
                    mem_awvalid <= 1'b0;
            else
                    mem_awvalid <= mem_awvalid;
    end

    always @(posedge M_AXI_ACLK)
    begin
            if(~M_AXI_ARESETN)
                    pc_rvalid_slot <= 1'b0;
            else if(wait_mem_state && pc_rvalid)
                    pc_rvalid_slot <= pc_rvalid;
            else if(pc_rvalid_slot && Inst_Ack)
                    pc_rvalid_slot <= 1'b0;
            else
                    pc_rvalid_slot <= pc_rvalid_slot;
    end
    
    always @(posedge M_AXI_ACLK)
    begin
            if(~M_AXI_ARESETN)
                    wait_mem_state <=1'b0;
            else if(D_mem_arvalid && ~wait_mem_state && wait_inst_state && ~flush_state)
                    wait_mem_state <= 1'b1;
            else if(wait_mem_state && mem_rvalid && mem_rready)
                    wait_mem_state <=1'b0;
            else
                    wait_mem_state <= wait_mem_state;
    end
    
    always @(posedge M_AXI_ACLK)
    begin
            if(~M_AXI_ARESETN)
                    flush_state <= 1'b0;
            else if(((pc_arvalid && pc_arready) || wait_inst_state) && ~flush_state && Flush && ~(pc_rready && pc_rvalid))
                    flush_state <= 1'b1;
            else if(pc_rready && pc_rvalid && flush_state && ~wait_inst_state)
                    flush_state <= 1'b0;
            else
                    flush_state <= flush_state;
    end

    always @(posedge M_AXI_ACLK)
    begin
            if(~M_AXI_ARESETN)
                    wait_inst_state <= 1'b0;
            else if(pc_arvalid && pc_arready  && ~Flush)
                    wait_inst_state <= 1'b1;
            else if((wait_inst_state && Flush && ~flush_state) || (pc_rready && pc_rvalid && wait_inst_state && ~flush_state) )//|| (wait_inst_state && D_mem_arvalid && ~wait_mem_state))
                    wait_inst_state <= 1'b0;
            else
                    wait_inst_state <= wait_inst_state;
    end
    
     FIFO #(
            .QUEUE_LENGTH('d2),
            .DATA_WEDTH('d32)
    )pc_req_fifo(
            .resetn (M_AXI_ARESETN),
            .clk    (M_AXI_ACLK),
    
            .complete   ((Inst_Valid & Inst_Ack) | (pc_rvalid & pc_rready & (flush_state | Flush))),
            .wdata_pack (PC),
            .valid      (pc_arvalid && pc_arready),
    
            .ready      (),
            .rdata_pack (pc_req),
            .is_empty   (pc_req_fifo_empty),
            .is_full    (pc_req_fifo_full)
    );
    
    FIFO #(
            .QUEUE_LENGTH('d2),
            .DATA_WEDTH('d36)
    )wdata_fifo(
            .resetn (M_AXI_ARESETN),
            .clk    (M_AXI_ACLK),
            
            .complete   (mem_wvalid & mem_wready),
            .wdata_pack ({Write_strb, Write_data}),
            .valid      (MemWrite & Mem_Req_Ack),
            
            .ready      (wdata_fifo_ready),
            .rdata_pack ({mem_wstrb, mem_wdata}),
            .is_empty   (wdata_fifo_is_empty),
            .is_full    (wdata_fifo_is_full)
    );
    
    FIFO #(
            .QUEUE_LENGTH('d2),
            .DATA_WEDTH('d32)
    )waddr_fifo(
            .resetn (M_AXI_ARESETN),
            .clk    (M_AXI_ACLK),
    
            .complete   (mem_awvalid & mem_awready),
            .wdata_pack (Address),
            .valid      (MemWrite & Mem_Req_Ack),
    
            .ready      (waddr_fifo_ready),
            .rdata_pack (mem_awaddr),
            .is_empty   (waddr_fifo_is_empty),
            .is_full    (waddr_fifo_is_full)
    
    );
    
    Dcache_wrapper #(
    )Dcache(
            .clk                (M_AXI_ACLK),
            .resetn             (M_AXI_ARESETN),
    
            .s_araddr           (mem_araddr),
            .s_arvalid          (mem_arvalid),
            .s_arready          (mem_arready),
    
            .s_awaddr           ({Address[31:2],2'b00}),
            .s_awvalid          (MemWrite),
            .s_wdata            (Write_data),
            .s_wvalid           (MemWrite),
            .s_wstrb            (Write_strb),
            
            .s_rdata            (mem_rdata),
            .s_rvalid           (mem_rvalid),
            .s_rready           (mem_rready),
    
            .m_araddr           (D_mem_araddr),
            .m_arvalid          (D_mem_arvalid),
            .m_arready          (D_mem_arready),
    
            .m_rdata            (D_mem_rdata),
            .m_rvalid           (D_mem_rvalid),
            .m_rready            (D_mem_rready)
    );
    wire        [31 : 0]        I_mem_araddr;
    wire                        I_mem_arvalid;
    wire        [7 : 0]         I_mem_arlen;
    wire                        I_mem_arready;
    wire        [31 : 0]        I_mem_rdata;
    wire                        I_mem_rvalid;
    wire                        I_mem_rlast;
    wire                        I_mem_rready;
    Icache_wrapper #(
    )Icache(
            .clk                (M_AXI_ACLK),
            .resetn             (M_AXI_ARESETN),

            .s_araddr           (pc_araddr),
            .s_arvalid          (pc_arvalid),
            .s_arready          (pc_arready),

            .s_rdata            (pc_rdata),
            .s_rvalid           (pc_rvalid),
            .s_rready           (pc_rready),

            .m_araddr           (I_mem_araddr),
            .m_arvalid          (I_mem_arvalid),
            .m_arlen            (I_mem_arlen),
            .m_arready          (I_mem_arready),

            .m_rdata            (I_mem_rdata),
            .m_rvalid           (I_mem_rvalid),
            .m_rlast            (I_mem_rlast),
            .m_rready           (I_mem_rready)
    );

    axi_crossbar mem_inst_axi_crossbar(
        .aclk             (    M_AXI_ACLK      ), // i, 1                 
        .aresetn          (    M_AXI_ARESETN   ), // i, 1                 
    
        .s_axi_arid       (    8'd0     ),
        .s_axi_araddr     (    {I_mem_araddr, D_mem_araddr}   ),
        .s_axi_arlen      (    {I_mem_arlen, 4'd0}),
        .s_axi_arsize     (    {3'd2,3'd2}   ),
        .s_axi_arvalid    (    {I_mem_arvalid, D_mem_arvalid}  ),
        .s_axi_arready    (    {I_mem_arready, D_mem_arready}  ),
        .s_axi_rdata      (    {I_mem_rdata, D_mem_rdata}    ),
        .s_axi_rlast      (    {I_mem_rlast, D_mem_rlast}    ),
        .s_axi_rvalid     (    {I_mem_rvalid, D_mem_rvalid}   ),
        .s_axi_rready     (    {I_mem_rready, D_mem_rready}   ),
        .s_axi_awid       (    'd0     ),
        .s_axi_awaddr     (    {32'd0,mem_awaddr}   ),
        .s_axi_awsize     (    {3'd2,3'd2}   ),
        .s_axi_awvalid    (    {1'b0,mem_awvalid}  ),
        .s_axi_awready    (    {pc_awready, mem_awready}  ),
        .s_axi_wid        (    'd0      ),
        .s_axi_wdata      (    {32'd0, mem_wdata}    ),
        .s_axi_wstrb      (    {4'd0, mem_wstrb}    ),
        .s_axi_wlast      (    {1'b0, mem_wvalid}    ),
        .s_axi_wvalid     (    {1'b0, mem_wvalid}   ),
        .s_axi_wready     (     {pc_wready, mem_wready}  ),
        .s_axi_bvalid     (     {pc_bvalid, mem_bvalid}  ),
        .s_axi_bready     (    2'b11   ),
    
        .m_axi_arid       ( M_AXI_ARID[0] ),
        .m_axi_araddr     ( M_AXI_ARADDR ),
        .m_axi_arlen      ( M_AXI_ARLEN ),
        .m_axi_arsize     ( M_AXI_ARSIZE ),
        .m_axi_arvalid    ( M_AXI_ARVALID ),
        .m_axi_arready    ( M_AXI_ARREADY ),
        .m_axi_rid        ( M_AXI_RID[0] ),
        .m_axi_rdata      ( M_AXI_RDATA ),
        .m_axi_rlast      ( M_AXI_RLAST ),
        .m_axi_rvalid     ( M_AXI_RVALID ),
        .m_axi_rready     ( M_AXI_RREADY ),
        .m_axi_awaddr     ( M_AXI_AWADDR ),
        .m_axi_awsize     ( M_AXI_AWSIZE ),
        .m_axi_awvalid    ( M_AXI_AWVALID ),
        .m_axi_awready    ( M_AXI_AWREADY ),
        .m_axi_wdata      ( M_AXI_WDATA ),
        .m_axi_wstrb      ( M_AXI_WSTRB ),
        .m_axi_wvalid     ( M_AXI_WVALID ),
        .m_axi_wready     ( M_AXI_WREADY ),
        .m_axi_bvalid     ( M_AXI_BVALID ),
        .m_axi_bready     ( M_AXI_BREADY )
        );
endmodule
