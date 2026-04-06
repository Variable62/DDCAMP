-------------------------------------------------------------------------------------------------------
-- Copyright (c) 2017, Design Gateway Co., Ltd.
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
-- 1. Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- 2. Redistributions in binary form must reproduce the above copyright notice,
-- this list of conditions and the following disclaimer in the documentation
-- and/or other materials provided with the distribution.
--
-- 3. Neither the name of the copyright holder nor the names of its contributors
-- may be used to endorse or promote products derived from this software
-- without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
-- IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
-- EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Filename     UARTFIFO.vhd
-- Title        Top
--
-- Company      Design Gateway Co., Ltd.
-- Project      RxTx
-- PJ No.       
-- Syntax       VHDL
-- Note         

-- Version      1.00
-- Author       
-- Date         
-- Remark       New Creation
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.all;
use IEEE.std_logic_UNSIGNED.all;

Entity UARTFIFO Is
	Port
	(
		RstB		: in	std_logic;			-- use push button Key0 (active low)
		Button		: in	std_logic;			-- use push button Key1 (active low)
		Clk50		: in	std_logic;
		
		TxSerData	: out	std_logic;
		RxSerData	: in	std_logic;
		RESERVED	: in	std_logic_vector( 1 downto 0 )
	);
End Entity UARTFIFO;

Architecture rtl Of UARTFIFO Is

	
	Component RxSerial Is
	Port
	(
		RstB		: in	std_logic;
		Clk			: in	std_logic;

		Fail		: out	std_logic;		
		SerDataIn	: in	std_logic;
		
		RxFfFull	: in	std_logic;
		RxFfWrData	: out	std_logic_vector( 7 downto 0 );
		RxFfWrEn	: out	std_logic
	);
	End Component RxSerial;
	
----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------

	
Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------

	
	
----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
	

-----------------------------------------------------
-- RxSerial -> FIFO -> TxSerial
	
	u_RxSerial : RxSerial
	Port map
	(
		RstB		=> rSysRstB		,
		Clk			=> UserClk		,
		
		Fail		=> open			,
		SerDataIn	=> RxSerData	,
		
		RxFfFull	=> RxFfFull		,	
		RxFfWrData	=> RxFfWrData	,
		RxFfWrEn	=> RxFfWrEn	
	);
		
End Architecture RTL;