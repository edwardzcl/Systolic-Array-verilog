//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.1 (win64) Build 1538259 Fri Apr  8 15:45:27 MDT 2016
//Date        : Tue Oct 25 21:44:36 2016
//Host        : chenqiang running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target AXI_Lite_test.bd
//Design      : AXI_Lite_test
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "AXI_Lite_test,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=AXI_Lite_test,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=2,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "AXI_Lite_test.hwdef" *) 
module AXI_Lite_test
   (ACLK,
    ARESETN);
  input ACLK;
  input ARESETN;

  wire ACLK_1;
  wire ARESETN_1;
  wire [31:0]axi_lite_master_0_M_AXI_ARADDR;
  wire axi_lite_master_0_M_AXI_ARREADY;
  wire axi_lite_master_0_M_AXI_ARVALID;
  wire [31:0]axi_lite_master_0_M_AXI_AWADDR;
  wire axi_lite_master_0_M_AXI_AWREADY;
  wire axi_lite_master_0_M_AXI_AWVALID;
  wire axi_lite_master_0_M_AXI_BREADY;
  wire [1:0]axi_lite_master_0_M_AXI_BRESP;
  wire axi_lite_master_0_M_AXI_BVALID;
  wire [31:0]axi_lite_master_0_M_AXI_RDATA;
  wire axi_lite_master_0_M_AXI_RREADY;
  wire [1:0]axi_lite_master_0_M_AXI_RRESP;
  wire axi_lite_master_0_M_AXI_RVALID;
  wire [31:0]axi_lite_master_0_M_AXI_WDATA;
  wire axi_lite_master_0_M_AXI_WREADY;
  wire [3:0]axi_lite_master_0_M_AXI_WSTRB;
  wire axi_lite_master_0_M_AXI_WVALID;

  assign ACLK_1 = ACLK;
  assign ARESETN_1 = ARESETN;
  AXI_Lite_test_axi_lite_master_0_0 axi_lite_master_0
       (.M_AXI_ACLK(ACLK_1),
        .M_AXI_ARADDR(axi_lite_master_0_M_AXI_ARADDR),
        .M_AXI_ARESETN(ARESETN_1),
        .M_AXI_ARREADY(axi_lite_master_0_M_AXI_ARREADY),
        .M_AXI_ARVALID(axi_lite_master_0_M_AXI_ARVALID),
        .M_AXI_AWADDR(axi_lite_master_0_M_AXI_AWADDR),
        .M_AXI_AWREADY(axi_lite_master_0_M_AXI_AWREADY),
        .M_AXI_AWVALID(axi_lite_master_0_M_AXI_AWVALID),
        .M_AXI_BREADY(axi_lite_master_0_M_AXI_BREADY),
        .M_AXI_BRESP(axi_lite_master_0_M_AXI_BRESP),
        .M_AXI_BVALID(axi_lite_master_0_M_AXI_BVALID),
        .M_AXI_RDATA(axi_lite_master_0_M_AXI_RDATA),
        .M_AXI_RREADY(axi_lite_master_0_M_AXI_RREADY),
        .M_AXI_RRESP(axi_lite_master_0_M_AXI_RRESP),
        .M_AXI_RVALID(axi_lite_master_0_M_AXI_RVALID),
        .M_AXI_WDATA(axi_lite_master_0_M_AXI_WDATA),
        .M_AXI_WREADY(axi_lite_master_0_M_AXI_WREADY),
        .M_AXI_WSTRB(axi_lite_master_0_M_AXI_WSTRB),
        .M_AXI_WVALID(axi_lite_master_0_M_AXI_WVALID));
  AXI_Lite_test_axi_lite_slave_0_0 axi_lite_slave_0
       (.S_AXI_ACLK(ACLK_1),
        .S_AXI_ARADDR(axi_lite_master_0_M_AXI_ARADDR[4:0]),
        .S_AXI_ARESETN(ARESETN_1),
        .S_AXI_ARREADY(axi_lite_master_0_M_AXI_ARREADY),
        .S_AXI_ARVALID(axi_lite_master_0_M_AXI_ARVALID),
        .S_AXI_AWADDR(axi_lite_master_0_M_AXI_AWADDR[4:0]),
        .S_AXI_AWREADY(axi_lite_master_0_M_AXI_AWREADY),
        .S_AXI_AWVALID(axi_lite_master_0_M_AXI_AWVALID),
        .S_AXI_BREADY(axi_lite_master_0_M_AXI_BREADY),
        .S_AXI_BRESP(axi_lite_master_0_M_AXI_BRESP),
        .S_AXI_BVALID(axi_lite_master_0_M_AXI_BVALID),
        .S_AXI_RDATA(axi_lite_master_0_M_AXI_RDATA),
        .S_AXI_RREADY(axi_lite_master_0_M_AXI_RREADY),
        .S_AXI_RRESP(axi_lite_master_0_M_AXI_RRESP),
        .S_AXI_RVALID(axi_lite_master_0_M_AXI_RVALID),
        .S_AXI_WDATA(axi_lite_master_0_M_AXI_WDATA),
        .S_AXI_WREADY(axi_lite_master_0_M_AXI_WREADY),
        .S_AXI_WSTRB(axi_lite_master_0_M_AXI_WSTRB),
        .S_AXI_WVALID(axi_lite_master_0_M_AXI_WVALID));
endmodule
