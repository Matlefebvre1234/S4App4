@echo off
REM ****************************************************************************
REM Vivado (TM) v2020.2 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Fri Mar 11 15:42:55 -0500 2022
REM SW Build 3064766 on Wed Nov 18 09:12:45 MST 2020
REM
REM Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim mips_unicycle_tb_behav -key {Behavioral:sim_1:Functional:mips_unicycle_tb} -tclbatch mips_unicycle_tb.tcl -view C:/Users/mathg/OneDrive/Bureau/Tout/Bacc UdeS/S4APP4/git/S4App4/mips32_unicycle_reference/mips_unicycle_tb_behav.wcfg -log simulate.log"
call xsim  mips_unicycle_tb_behav -key {Behavioral:sim_1:Functional:mips_unicycle_tb} -tclbatch mips_unicycle_tb.tcl -view C:/Users/mathg/OneDrive/Bureau/Tout/Bacc UdeS/S4APP4/git/S4App4/mips32_unicycle_reference/mips_unicycle_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
