//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.1 (win64) Build 1538259 Fri Apr  8 15:45:27 MDT 2016
//Date        : Tue Oct 25 21:44:36 2016
//Host        : chenqiang running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target AXI_Lite_test_wrapper.bd
//Design      : AXI_Lite_test_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module AXI_Lite_test_wrapper
   (ACLK,
    ARESETN);
  input ACLK;
  input ARESETN;

  wire ACLK;
  wire ARESETN;

  AXI_Lite_test AXI_Lite_test_i
       (.ACLK(ACLK),
        .ARESETN(ARESETN));
endmodule
