@echo off
set xv_path=D:\\Xilinx\\Vivado\\2016.1\\bin
call %xv_path%/xsim lite_system_wrapper_tb_behav -key {Behavioral:sim_1:Functional:lite_system_wrapper_tb} -tclbatch lite_system_wrapper_tb.tcl -view D:/IMSLAB/VivadoProject/AXI_Total/AXI_Lite/tb/AXI_Lite_test/lite_system_wrapper_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
