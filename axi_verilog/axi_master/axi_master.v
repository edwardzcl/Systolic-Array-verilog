//------------------------------------------------------------------
//-- File generated by RobustVerilog parser
//-- RobustVerilog version 1.5g (limited free version) Jul 5 2011
//-- Invoked Wed Mar 28 12:55:29 2012
//-- Source file: axi_master.v
//-- Parent file: None
//-- Project directory: C:/Users/MARIOS/Desktop/VLSI/RobustVerilog_free1.5_win/RobustVerilog_free1.5_win/examples/axi_master/trunk/run/
//-- Target directory: out/
//-- Command flags: ..\..\..\..\robust.exe ../robust_axi_master.pro -gui 
//-- www.provartec.com/edatools ... info@provartec.com
//------------------------------------------------------------------




//////////////////////////////////////
//
// General:
//   The AXI master has an internal master per ID. 
//   These internal masters work simultaniously and an interconnect matrix connets them. 
// 
//
// I/F :
//   idle - all internal masters emptied their command FIFOs
//   scrbrd_empty - all scoreboard checks have been completed (for random testing)
//
//
// Tasks:
//
// enable(input master_num)
//   Description: Enables master
//   Parameters: master_num - number of internal master
//
// enable_all()  
//   Description: Enables all masters
//
// write_single(input master_num, input addr, input wdata)
//   Description: write a single AXI burst (1 data cycle)
//   Parameters: master_num - number of internal master
//           addr  - address
//           wdata - write data
// 
// read_single(input master_num, input addr, output rdata)
//   Description: read a single AXI burst (1 data cycle)
//   Parameters: master_num - number of internal master
//               addr  - address
//               rdata - return read data
//
// check_single(input master_num, input addr, input expected)
//   Description: read a single AXI burst and gives an error if the data read does not match expected
//   Parameters: master_num - number of internal master
//               addr  - address
//               expected - expected read data
//
// write_and_check_single(input master_num, input addr, input data)
//   Description: write a single AXI burst read it back and compare the write and read data
//   Parameters: master_num - number of internal master
//               addr  - address
//               data - data to write and expect on read
//
// insert_wr_cmd(input master_num, input addr, input len, input size)
//   Description: add an AXI write burst to command FIFO
//   Parameters: master_num - number of internal master
//               addr - address
//               len - AXI LEN (data strobe number)
//               size - AXI SIZE (data width)
//  
// insert_rd_cmd(input master_num, input addr, input len, input size)
//   Description: add an AXI read burst to command FIFO
//   Parameters: master_num - number of internal master
//               addr - address
//               len - AXI LEN (data strobe number)
//               size - AXI SIZE (data width)
//  
// insert_wr_data(input master_num, input wdata)
//   Description: add a single data to data FIFO (to be used in write bursts)
//   Parameters: master_num - number of internal master
//               wdata - write data
//  
// insert_wr_incr_data(input master_num, input addr, input len, input size)
//   Description: add an AXI write burst to command FIFO will use incremental data (no need to use insert_wr_data)
//   Parameters: master_num - number of internal master
//               addr - address
//               len - AXI LEN (data strobe number)
//               size - AXI SIZE (data width)
//  
// insert_rand_chk(input master_num, input burst_num)
//   Description: add multiple commands to command FIFO. Each command writes incremental data to a random address, reads the data back and checks the data. Useful for random testing.
//   Parameters: master_num - number of internal master
//               burst_num - total number of bursts to check
//  
// insert_rand(input burst_num)
//   Description: disperces burst_num between internal masters and calls insert_rand_chk for each master
//   Parameters:  burst_num - total number of bursts to check (combined)
//
//  
//  Parameters:
//  
//    For random testing: (changing these values automatically update interanl masters)
//      ahb_bursts - if set, bursts will only be of length 1, 4, 8 or 16.
//      len_min  - minimum burst AXI LEN (length)
//      len_max  - maximum burst AXI LEN (length)
//      size_min - minimum burst AXI SIZE (width)
//      size_max - maximum burst AXI SIZE (width)
//      addr_min - minimum address (in bytes)
//      addr_max - maximum address (in bytes)
//  
//////////////////////////////////////



module axi_master(clk,reset,AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWCACHE,AWPROT,AWLOCK,AWVALID,AWREADY,WID,WDATA,WSTRB,WLAST,WVALID,WREADY,BID,BRESP,BVALID,BREADY,ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARCACHE,ARPROT,ARLOCK,ARVALID,ARREADY,RID,RDATA,RRESP,RLAST,RVALID,RREADY,idle,scrbrd_empty);

`include "prgen_rand.v"
   
   input                    clk;
   input                               reset;
   
   output [3:0]                     AWID;
   output [31:0]                    AWADDR;
   output [3:0]                     AWLEN;
   output [1:0]                     AWSIZE;
   output [1:0]                     AWBURST;
   output [3:0]                     AWCACHE;
   output [2:0]                     AWPROT;
   output [1:0]                     AWLOCK;
   output                           AWVALID;
   input                            AWREADY;
   output [3:0]                     WID;
   output [31:0]                    WDATA;
   output [32/8-1:0]                WSTRB;
   output                           WLAST;
   output                           WVALID;
   input                            WREADY;
   input [3:0]                      BID;
   input [1:0]                      BRESP;
   input                            BVALID;
   output                           BREADY;
   output [3:0]                     ARID;
   output [31:0]                    ARADDR;
   output [3:0]                     ARLEN;
   output [1:0]                     ARSIZE;
   output [1:0]                     ARBURST;
   output [3:0]                     ARCACHE;
   output [2:0]                     ARPROT;
   output [1:0]                     ARLOCK;
   output                           ARVALID;
   input                            ARREADY;
   input [3:0]                      RID;
   input [31:0]                     RDATA;
   input [1:0]                      RRESP;
   input                            RLAST;
   input                            RVALID;
   output                           RREADY;

   output                              idle;
   output                              scrbrd_empty;
   
   
   //random parameters
   integer                             ahb_bursts = 0;
   integer                             use_addr_base = 0;
   integer                             len_min = 0;
   integer                             len_max = 15;
   integer                             size_min = 0;
   integer                             size_max = 3;
   integer                             addr_min = 0;
   integer                             addr_max = {32{1'b1}};
   
   wire [3:0]                          AWID_0;
   wire [31:0]                         AWADDR_0;
   wire [3:0]                          AWLEN_0;
   wire [1:0]                          AWSIZE_0;
   wire [1:0]                          AWBURST_0;
   wire [3:0]                          AWCACHE_0;
   wire [2:0]                          AWPROT_0;
   wire [1:0]                          AWLOCK_0;
   wire                                AWVALID_0;
   wire                                AWREADY_0;
   wire [3:0]                          WID_0;
   wire [31:0]                         WDATA_0;
   wire [32/8-1:0]                     WSTRB_0;
   wire                                WLAST_0;
   wire                                WVALID_0;
   wire                                WREADY_0;
   wire [3:0]                          BID_0;
   wire [1:0]                          BRESP_0;
   wire                                BVALID_0;
   wire                                BREADY_0;
   wire [3:0]                          ARID_0;
   wire [31:0]                         ARADDR_0;
   wire [3:0]                          ARLEN_0;
   wire [1:0]                          ARSIZE_0;
   wire [1:0]                          ARBURST_0;
   wire [3:0]                          ARCACHE_0;
   wire [2:0]                          ARPROT_0;
   wire [1:0]                          ARLOCK_0;
   wire                                ARVALID_0;
   wire                                ARREADY_0;
   wire [3:0]                          RID_0;
   wire [31:0]                         RDATA_0;
   wire [1:0]                          RRESP_0;
   wire                                RLAST_0;
   wire                                RVALID_0;
   wire                                RREADY_0;
   wire [3:0]                          AWID_1;
   wire [31:0]                         AWADDR_1;
   wire [3:0]                          AWLEN_1;
   wire [1:0]                          AWSIZE_1;
   wire [1:0]                          AWBURST_1;
   wire [3:0]                          AWCACHE_1;
   wire [2:0]                          AWPROT_1;
   wire [1:0]                          AWLOCK_1;
   wire                                AWVALID_1;
   wire                                AWREADY_1;
   wire [3:0]                          WID_1;
   wire [31:0]                         WDATA_1;
   wire [32/8-1:0]                     WSTRB_1;
   wire                                WLAST_1;
   wire                                WVALID_1;
   wire                                WREADY_1;
   wire [3:0]                          BID_1;
   wire [1:0]                          BRESP_1;
   wire                                BVALID_1;
   wire                                BREADY_1;
   wire [3:0]                          ARID_1;
   wire [31:0]                         ARADDR_1;
   wire [3:0]                          ARLEN_1;
   wire [1:0]                          ARSIZE_1;
   wire [1:0]                          ARBURST_1;
   wire [3:0]                          ARCACHE_1;
   wire [2:0]                          ARPROT_1;
   wire [1:0]                          ARLOCK_1;
   wire                                ARVALID_1;
   wire                                ARREADY_1;
   wire [3:0]                          RID_1;
   wire [31:0]                         RDATA_1;
   wire [1:0]                          RRESP_1;
   wire                                RLAST_1;
   wire                                RVALID_1;
   wire                                RREADY_1;
   wire [3:0]                          AWID_2;
   wire [31:0]                         AWADDR_2;
   wire [3:0]                          AWLEN_2;
   wire [1:0]                          AWSIZE_2;
   wire [1:0]                          AWBURST_2;
   wire [3:0]                          AWCACHE_2;
   wire [2:0]                          AWPROT_2;
   wire [1:0]                          AWLOCK_2;
   wire                                AWVALID_2;
   wire                                AWREADY_2;
   wire [3:0]                          WID_2;
   wire [31:0]                         WDATA_2;
   wire [32/8-1:0]                     WSTRB_2;
   wire                                WLAST_2;
   wire                                WVALID_2;
   wire                                WREADY_2;
   wire [3:0]                          BID_2;
   wire [1:0]                          BRESP_2;
   wire                                BVALID_2;
   wire                                BREADY_2;
   wire [3:0]                          ARID_2;
   wire [31:0]                         ARADDR_2;
   wire [3:0]                          ARLEN_2;
   wire [1:0]                          ARSIZE_2;
   wire [1:0]                          ARBURST_2;
   wire [3:0]                          ARCACHE_2;
   wire [2:0]                          ARPROT_2;
   wire [1:0]                          ARLOCK_2;
   wire                                ARVALID_2;
   wire                                ARREADY_2;
   wire [3:0]                          RID_2;
   wire [31:0]                         RDATA_2;
   wire [1:0]                          RRESP_2;
   wire                                RLAST_2;
   wire                                RVALID_2;
   wire                                RREADY_2;
   wire                                idle_0;
   wire                                idle_1;
   wire                                idle_2;
   wire                                scrbrd_empty_0;
   wire                                scrbrd_empty_1;
   wire                                scrbrd_empty_2;


   always @(*)
     begin
        #1;
        axi_master_single0.ahb_bursts = ahb_bursts;
        axi_master_single0.use_addr_base = use_addr_base;
        axi_master_single0.len_min = len_min;
        axi_master_single0.len_max = len_max;
        axi_master_single0.size_min = size_min;
        axi_master_single0.size_max = size_max;
        axi_master_single0.addr_min = addr_min;
        axi_master_single0.addr_max = addr_max;
        axi_master_single1.ahb_bursts = ahb_bursts;
        axi_master_single1.use_addr_base = use_addr_base;
        axi_master_single1.len_min = len_min;
        axi_master_single1.len_max = len_max;
        axi_master_single1.size_min = size_min;
        axi_master_single1.size_max = size_max;
        axi_master_single1.addr_min = addr_min;
        axi_master_single1.addr_max = addr_max;
        axi_master_single2.ahb_bursts = ahb_bursts;
        axi_master_single2.use_addr_base = use_addr_base;
        axi_master_single2.len_min = len_min;
        axi_master_single2.len_max = len_max;
        axi_master_single2.size_min = size_min;
        axi_master_single2.size_max = size_max;
        axi_master_single2.addr_min = addr_min;
        axi_master_single2.addr_max = addr_max;
     end
   
   assign                              idle = idle_2  & idle_1  & idle_0 ;
   assign                              scrbrd_empty = scrbrd_empty_2  & scrbrd_empty_1  & scrbrd_empty_0 ;
   
   

   axi_master_single #(0, 4'b0011, 4)
   axi_master_single0(
                   .clk(clk),
                   .reset(reset),
                   .AWID(AWID_0),
                   .AWADDR(AWADDR_0),
                   .AWLEN(AWLEN_0),
                   .AWSIZE(AWSIZE_0),
                   .AWBURST(AWBURST_0),
                   .AWCACHE(AWCACHE_0),
                   .AWPROT(AWPROT_0),
                   .AWLOCK(AWLOCK_0),
                   .AWVALID(AWVALID_0),
                   .AWREADY(AWREADY_0),
                   .WID(WID_0),
                   .WDATA(WDATA_0),
                   .WSTRB(WSTRB_0),
                   .WLAST(WLAST_0),
                   .WVALID(WVALID_0),
                   .WREADY(WREADY_0),
                   .BID(BID_0),
                   .BRESP(BRESP_0),
                   .BVALID(BVALID_0),
                   .BREADY(BREADY_0),
                   .ARID(ARID_0),
                   .ARADDR(ARADDR_0),
                   .ARLEN(ARLEN_0),
                   .ARSIZE(ARSIZE_0),
                   .ARBURST(ARBURST_0),
                   .ARCACHE(ARCACHE_0),
                   .ARPROT(ARPROT_0),
                   .ARLOCK(ARLOCK_0),
                   .ARVALID(ARVALID_0),
                   .ARREADY(ARREADY_0),
                   .RID(RID_0),
                   .RDATA(RDATA_0),
                   .RRESP(RRESP_0),
                   .RLAST(RLAST_0),
                   .RVALID(RVALID_0),
                   .RREADY(RREADY_0),
                   .idle(idle_0),
                   .scrbrd_empty(scrbrd_empty_0)
                   );
   
   axi_master_single #(1, 4'b0010, 4)
   axi_master_single1(
                   .clk(clk),
                   .reset(reset),
                   .AWID(AWID_1),
                   .AWADDR(AWADDR_1),
                   .AWLEN(AWLEN_1),
                   .AWSIZE(AWSIZE_1),
                   .AWBURST(AWBURST_1),
                   .AWCACHE(AWCACHE_1),
                   .AWPROT(AWPROT_1),
                   .AWLOCK(AWLOCK_1),
                   .AWVALID(AWVALID_1),
                   .AWREADY(AWREADY_1),
                   .WID(WID_1),
                   .WDATA(WDATA_1),
                   .WSTRB(WSTRB_1),
                   .WLAST(WLAST_1),
                   .WVALID(WVALID_1),
                   .WREADY(WREADY_1),
                   .BID(BID_1),
                   .BRESP(BRESP_1),
                   .BVALID(BVALID_1),
                   .BREADY(BREADY_1),
                   .ARID(ARID_1),
                   .ARADDR(ARADDR_1),
                   .ARLEN(ARLEN_1),
                   .ARSIZE(ARSIZE_1),
                   .ARBURST(ARBURST_1),
                   .ARCACHE(ARCACHE_1),
                   .ARPROT(ARPROT_1),
                   .ARLOCK(ARLOCK_1),
                   .ARVALID(ARVALID_1),
                   .ARREADY(ARREADY_1),
                   .RID(RID_1),
                   .RDATA(RDATA_1),
                   .RRESP(RRESP_1),
                   .RLAST(RLAST_1),
                   .RVALID(RVALID_1),
                   .RREADY(RREADY_1),
                   .idle(idle_1),
                   .scrbrd_empty(scrbrd_empty_1)
                   );
   
   axi_master_single #(2, 4'b1010, 4)
   axi_master_single2(
                   .clk(clk),
                   .reset(reset),
                   .AWID(AWID_2),
                   .AWADDR(AWADDR_2),
                   .AWLEN(AWLEN_2),
                   .AWSIZE(AWSIZE_2),
                   .AWBURST(AWBURST_2),
                   .AWCACHE(AWCACHE_2),
                   .AWPROT(AWPROT_2),
                   .AWLOCK(AWLOCK_2),
                   .AWVALID(AWVALID_2),
                   .AWREADY(AWREADY_2),
                   .WID(WID_2),
                   .WDATA(WDATA_2),
                   .WSTRB(WSTRB_2),
                   .WLAST(WLAST_2),
                   .WVALID(WVALID_2),
                   .WREADY(WREADY_2),
                   .BID(BID_2),
                   .BRESP(BRESP_2),
                   .BVALID(BVALID_2),
                   .BREADY(BREADY_2),
                   .ARID(ARID_2),
                   .ARADDR(ARADDR_2),
                   .ARLEN(ARLEN_2),
                   .ARSIZE(ARSIZE_2),
                   .ARBURST(ARBURST_2),
                   .ARCACHE(ARCACHE_2),
                   .ARPROT(ARPROT_2),
                   .ARLOCK(ARLOCK_2),
                   .ARVALID(ARVALID_2),
                   .ARREADY(ARREADY_2),
                   .RID(RID_2),
                   .RDATA(RDATA_2),
                   .RRESP(RRESP_2),
                   .RLAST(RLAST_2),
                   .RVALID(RVALID_2),
                   .RREADY(RREADY_2),
                   .idle(idle_2),
                   .scrbrd_empty(scrbrd_empty_2)
                   );
   



  
    axi_master_ic axi_master_ic(
                       .clk(clk),
                       .reset(reset),
                       .M0_AWID(AWID_0),
                       .M0_AWADDR(AWADDR_0),
                       .M0_AWLEN(AWLEN_0),
                       .M0_AWSIZE(AWSIZE_0),
                       .M0_AWBURST(AWBURST_0),
                       .M0_AWCACHE(AWCACHE_0),
                       .M0_AWPROT(AWPROT_0),
                       .M0_AWLOCK(AWLOCK_0),
                       .M0_AWVALID(AWVALID_0),
                       .M0_AWREADY(AWREADY_0),
                       .M0_WID(WID_0),
                       .M0_WDATA(WDATA_0),
                       .M0_WSTRB(WSTRB_0),
                       .M0_WLAST(WLAST_0),
                       .M0_WVALID(WVALID_0),
                       .M0_WREADY(WREADY_0),
                       .M0_BID(BID_0),
                       .M0_BRESP(BRESP_0),
                       .M0_BVALID(BVALID_0),
                       .M0_BREADY(BREADY_0),
                       .M0_ARID(ARID_0),
                       .M0_ARADDR(ARADDR_0),
                       .M0_ARLEN(ARLEN_0),
                       .M0_ARSIZE(ARSIZE_0),
                       .M0_ARBURST(ARBURST_0),
                       .M0_ARCACHE(ARCACHE_0),
                       .M0_ARPROT(ARPROT_0),
                       .M0_ARLOCK(ARLOCK_0),
                       .M0_ARVALID(ARVALID_0),
                       .M0_ARREADY(ARREADY_0),
                       .M0_RID(RID_0),
                       .M0_RDATA(RDATA_0),
                       .M0_RRESP(RRESP_0),
                       .M0_RLAST(RLAST_0),
                       .M0_RVALID(RVALID_0),
                       .M0_RREADY(RREADY_0),
                       .M1_AWID(AWID_1),
                       .M1_AWADDR(AWADDR_1),
                       .M1_AWLEN(AWLEN_1),
                       .M1_AWSIZE(AWSIZE_1),
                       .M1_AWBURST(AWBURST_1),
                       .M1_AWCACHE(AWCACHE_1),
                       .M1_AWPROT(AWPROT_1),
                       .M1_AWLOCK(AWLOCK_1),
                       .M1_AWVALID(AWVALID_1),
                       .M1_AWREADY(AWREADY_1),
                       .M1_WID(WID_1),
                       .M1_WDATA(WDATA_1),
                       .M1_WSTRB(WSTRB_1),
                       .M1_WLAST(WLAST_1),
                       .M1_WVALID(WVALID_1),
                       .M1_WREADY(WREADY_1),
                       .M1_BID(BID_1),
                       .M1_BRESP(BRESP_1),
                       .M1_BVALID(BVALID_1),
                       .M1_BREADY(BREADY_1),
                       .M1_ARID(ARID_1),
                       .M1_ARADDR(ARADDR_1),
                       .M1_ARLEN(ARLEN_1),
                       .M1_ARSIZE(ARSIZE_1),
                       .M1_ARBURST(ARBURST_1),
                       .M1_ARCACHE(ARCACHE_1),
                       .M1_ARPROT(ARPROT_1),
                       .M1_ARLOCK(ARLOCK_1),
                       .M1_ARVALID(ARVALID_1),
                       .M1_ARREADY(ARREADY_1),
                       .M1_RID(RID_1),
                       .M1_RDATA(RDATA_1),
                       .M1_RRESP(RRESP_1),
                       .M1_RLAST(RLAST_1),
                       .M1_RVALID(RVALID_1),
                       .M1_RREADY(RREADY_1),
                       .M2_AWID(AWID_2),
                       .M2_AWADDR(AWADDR_2),
                       .M2_AWLEN(AWLEN_2),
                       .M2_AWSIZE(AWSIZE_2),
                       .M2_AWBURST(AWBURST_2),
                       .M2_AWCACHE(AWCACHE_2),
                       .M2_AWPROT(AWPROT_2),
                       .M2_AWLOCK(AWLOCK_2),
                       .M2_AWVALID(AWVALID_2),
                       .M2_AWREADY(AWREADY_2),
                       .M2_WID(WID_2),
                       .M2_WDATA(WDATA_2),
                       .M2_WSTRB(WSTRB_2),
                       .M2_WLAST(WLAST_2),
                       .M2_WVALID(WVALID_2),
                       .M2_WREADY(WREADY_2),
                       .M2_BID(BID_2),
                       .M2_BRESP(BRESP_2),
                       .M2_BVALID(BVALID_2),
                       .M2_BREADY(BREADY_2),
                       .M2_ARID(ARID_2),
                       .M2_ARADDR(ARADDR_2),
                       .M2_ARLEN(ARLEN_2),
                       .M2_ARSIZE(ARSIZE_2),
                       .M2_ARBURST(ARBURST_2),
                       .M2_ARCACHE(ARCACHE_2),
                       .M2_ARPROT(ARPROT_2),
                       .M2_ARLOCK(ARLOCK_2),
                       .M2_ARVALID(ARVALID_2),
                       .M2_ARREADY(ARREADY_2),
                       .M2_RID(RID_2),
                       .M2_RDATA(RDATA_2),
                       .M2_RRESP(RRESP_2),
                       .M2_RLAST(RLAST_2),
                       .M2_RVALID(RVALID_2),
                       .M2_RREADY(RREADY_2),
                       .S0_AWID(AWID),
                       .S0_AWADDR(AWADDR),
                       .S0_AWLEN(AWLEN),
                       .S0_AWSIZE(AWSIZE),
                       .S0_AWBURST(AWBURST),
                       .S0_AWCACHE(AWCACHE),
                       .S0_AWPROT(AWPROT),
                       .S0_AWLOCK(AWLOCK),
                       .S0_AWVALID(AWVALID),
                       .S0_AWREADY(AWREADY),
                       .S0_WID(WID),
                       .S0_WDATA(WDATA),
                       .S0_WSTRB(WSTRB),
                       .S0_WLAST(WLAST),
                       .S0_WVALID(WVALID),
                       .S0_WREADY(WREADY),
                       .S0_BID(BID),
                       .S0_BRESP(BRESP),
                       .S0_BVALID(BVALID),
                       .S0_BREADY(BREADY),
                       .S0_ARID(ARID),
                       .S0_ARADDR(ARADDR),
                       .S0_ARLEN(ARLEN),
                       .S0_ARSIZE(ARSIZE),
                       .S0_ARBURST(ARBURST),
                       .S0_ARCACHE(ARCACHE),
                       .S0_ARPROT(ARPROT),
                       .S0_ARLOCK(ARLOCK),
                       .S0_ARVALID(ARVALID),
                       .S0_ARREADY(ARREADY),
                       .S0_RID(RID),
                       .S0_RDATA(RDATA),
                       .S0_RRESP(RRESP),
                       .S0_RLAST(RLAST),
                       .S0_RVALID(RVALID),
                       .S0_RREADY(RREADY)
      
      );



   
   task check_master_num;
      input [24*8-1:0] task_name;
      input [31:0] master_num;
      begin
         if (master_num >= 3)
           begin
              $display("FATAL ERROR: task %0s called for master %0d that does not exist.\tTime: %0d ns.", task_name, master_num, $time);
           end
      end
   endtask
   
   task enable;
      input [31:0] master_num;
      begin
         check_master_num("enable", master_num);
         case (master_num)
           0 : axi_master_single0.enable = 1;
           1 : axi_master_single1.enable = 1;
           2 : axi_master_single2.enable = 1;
         endcase
      end
   endtask

   task enable_all;
      begin
         axi_master_single0.enable = 1;
         axi_master_single1.enable = 1;
         axi_master_single2.enable = 1;
      end
   endtask
   
   task write_single;
      input [31:0] master_num;
      input [32-1:0]  addr;
      input [32-1:0]  wdata;
      begin
         check_master_num("write_single", master_num);
         case (master_num)
           0 : axi_master_single0.write_single(addr, wdata);
           1 : axi_master_single1.write_single(addr, wdata);
           2 : axi_master_single2.write_single(addr, wdata);
         endcase
      end
   endtask

   task read_single;
      input [31:0] master_num;
      input [32-1:0]  addr;
      output [32-1:0]  rdata;
      begin
         check_master_num("read_single", master_num);
         case (master_num)
           0 : axi_master_single0.read_single(addr, rdata);
           1 : axi_master_single1.read_single(addr, rdata);
           2 : axi_master_single2.read_single(addr, rdata);
         endcase
      end
   endtask

   task check_single;
      input [31:0] master_num;
      input [32-1:0]  addr;
      input [32-1:0]  expected;
      begin
         check_master_num("check_single", master_num);
         case (master_num)
           0 : axi_master_single0.check_single(addr, expected);
           1 : axi_master_single1.check_single(addr, expected);
           2 : axi_master_single2.check_single(addr, expected);
         endcase
      end
   endtask

   task write_and_check_single;
      input [31:0] master_num;
      input [32-1:0]  addr;
      input [32-1:0]  data;
      begin
         check_master_num("write_and_check_single", master_num);
         case (master_num)
           0 : axi_master_single0.write_and_check_single(addr, data);
           1 : axi_master_single1.write_and_check_single(addr, data);
           2 : axi_master_single2.write_and_check_single(addr, data);
         endcase
      end
   endtask

   task insert_wr_cmd;
      input [31:0] master_num;
      input [32-1:0]  addr;
      input [4-1:0]   len;
      input [2-1:0]  size;
      begin
         check_master_num("insert_wr_cmd", master_num);
         case (master_num)
           0 : axi_master_single0.insert_wr_cmd(addr, len, size);
           1 : axi_master_single1.insert_wr_cmd(addr, len, size);
           2 : axi_master_single2.insert_wr_cmd(addr, len, size);
         endcase
      end
   endtask

   task insert_rd_cmd;
      input [31:0] master_num;
      input [32-1:0]  addr;
      input [4-1:0]   len;
      input [2-1:0]  size;
      begin
         check_master_num("insert_rd_cmd", master_num);
         case (master_num)
           0 : axi_master_single0.insert_rd_cmd(addr, len, size);
           1 : axi_master_single1.insert_rd_cmd(addr, len, size);
           2 : axi_master_single2.insert_rd_cmd(addr, len, size);
         endcase
      end
   endtask

   task insert_wr_data;
      input [31:0] master_num;
      input [32-1:0]  wdata;
      begin
         check_master_num("insert_wr_data", master_num);
         case (master_num)
           0 : axi_master_single0.insert_wr_data(wdata);
           1 : axi_master_single1.insert_wr_data(wdata);
           2 : axi_master_single2.insert_wr_data(wdata);
         endcase
      end
   endtask

   task insert_wr_incr_data;
      input [31:0] master_num;
      input [32-1:0]  addr;
      input [4-1:0]   len;
      input [2-1:0]  size;
      begin
         check_master_num("insert_wr_incr_data", master_num);
         case (master_num)
           0 : axi_master_single0.insert_wr_incr_data(addr, len, size);
           1 : axi_master_single1.insert_wr_incr_data(addr, len, size);
           2 : axi_master_single2.insert_wr_incr_data(addr, len, size);
         endcase
      end
   endtask

   task insert_rand_chk;
      input [31:0] master_num;
      input [31:0] burst_num;
      begin
         check_master_num("insert_rand_chk", master_num);
         case (master_num)
           0 : axi_master_single0.insert_rand_chk(burst_num);
           1 : axi_master_single1.insert_rand_chk(burst_num);
           2 : axi_master_single2.insert_rand_chk(burst_num);
         endcase
      end
   endtask

   task insert_rand;
      input [31:0] burst_num;
      
      reg [31:0] burst_num0;
      reg [31:0] burst_num1;
      reg [31:0] burst_num2;
      integer remain;
      begin
         remain = burst_num;
         if (remain > 0)
           begin
              burst_num0 = rand(1, remain);
              remain = remain - burst_num0;
              insert_rand_chk(0, burst_num0);              
           end
         if (remain > 0)
           begin
              burst_num1 = rand(1, remain);
              remain = remain - burst_num1;
              insert_rand_chk(1, burst_num1);              
           end
         if (remain > 0)
           begin
              burst_num2 = rand(1, remain);
              remain = remain - burst_num2;
              insert_rand_chk(2, burst_num2);              
           end
      end
   endtask
   

endmodule




