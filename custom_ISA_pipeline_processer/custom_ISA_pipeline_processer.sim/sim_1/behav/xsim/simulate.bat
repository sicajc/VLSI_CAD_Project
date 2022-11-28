@echo off
REM ****************************************************************************
REM Vivado (TM) v2022.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Mon Nov 28 16:45:10 +0800 2022
REM SW Build 3526262 on Mon Apr 18 15:48:16 MDT 2022
REM
REM IP Build 3524634 on Mon Apr 18 20:55:01 MDT 2022
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim pipeline_test_behav -key {Behavioral:sim_1:Functional:pipeline_test} -tclbatch pipeline_test.tcl -view C:/Users/User/Desktop/cad_project/custom_ISA_pipeline_processer/pipeline_test_behav_Partitioned.wcfg -log simulate.log"
call xsim  pipeline_test_behav -key {Behavioral:sim_1:Functional:pipeline_test} -tclbatch pipeline_test.tcl -view C:/Users/User/Desktop/cad_project/custom_ISA_pipeline_processer/pipeline_test_behav_Partitioned.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
