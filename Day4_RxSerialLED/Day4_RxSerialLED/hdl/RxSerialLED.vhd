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
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Filename     RxSerialLED.vhd
-- Title        Top
--
-- Company      Design Gateway Co., Ltd.
-- Project      DD-Camp
-- PJ No.       
-- Syntax       VHDL
-- Note         

-- Version      1.00
-- Author       B.Attapon
-- Date         2017/11/16
-- Remark       New Creation
----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity RxSerialLED Is
	Port
	(
		RstB		: in	std_logic;							-- use push button Key0 (active low)
		Clk50		: in	std_logic;							-- clock input 50 MHz
		
		RxSerData	: in	std_logic;							-- Tx serial data out
		RESERVED	: in	std_logic_vector( 1 downto 0 );
		LED			: out	std_logic_vector( 7 downto 0 )		-- active low LED
	);
End Entity RxSerialLED;

Architecture rtl Of RxSerialLED Is

----------------------------------------------------------------------------------
-- Component declaration
----------------------------------------------------------------------------------

	Component PLL50 Is
	Port
	(
		areset		: in 	std_logic;
		inclk0		: in 	std_logic;
		c0			: out 	std_logic;
		locked		: out 	std_logic 
	);
	End Component;
	
	Component RxSerial Is
	Port
	(
		RstB		: in	std_logic;
		Clk			: in	std_logic;
		
		SerDataIn	: in	std_logic;
		
		RxFfFull	: in	std_logic;
		RxFfWrData	: out	std_logic_vector( 7 downto 0 );
		RxFfWrEn	: out	std_logic
	);
	End Component RxSerial;

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	
	-- Reset System
	-- Clk50
	signal	rPLL50RstBCnt	: std_logic_vector( 3 downto 0 ) := "0000";
	signal	PLL50Rst		: std_logic;
	signal	PLLLock			: std_logic;
	
	-- Clk100
	signal	UserClk			: std_logic;
	signal	rPLLLockUser	: std_logic_vector( 1 downto 0 );
	signal	rRstBUser		: std_logic;
	signal	rSysRstB		: std_logic;
	signal	SysRst			: std_logic;
	signal	rRstBCnt		: std_logic_vector( 22 downto 0 ) := (others=>'0');	

	-- RxSerial
	signal	RxFfWrEn		: std_logic;
	signal	RxFfWrData		: std_logic_vector( 7 downto 0 );
	signal	rLED			: std_logic_vector( 7 downto 0 );
	
Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
	
	LED(7 downto 0)		<= not rLED(7 downto 0);	-- for active low LED
	
----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------

-----------------------------------------------------
-- Power on Reset


	u_rPLL50RstBCnt : Process (Clk50) Is
	Begin
		if ( rising_edge(Clk50) ) then
			rPLL50RstBCnt	<= rPLL50RstBCnt(2 downto 0) & '1';
		end if;
	End Process u_rPLL50RstBCnt;
	
	PLL50Rst	<= not rPLL50RstBCnt(3);

	u_PLL50 : PLL50
	Port map
	(
		areset		=> PLL50Rst			,
		inclk0		=> Clk50			,
		c0			=> UserClk			, -- UserClk: 100 MHz	
		locked		=> PLLLock
	);

	u_rRstBCnt : Process (Clk50) Is
	Begin
		if ( rising_edge(Clk50) ) then
			if ( RstB='0' ) then
				rRstBCnt	<= (others=>'0');
			else
				if ( rRstBCnt(22)='1' ) then
					rRstBCnt	<= rRstBCnt;
				else
					rRstBCnt	<= rRstBCnt + 1;
				end if;
			end if;
		end if;
	End Process u_rRstBCnt;
	
	u_rSysRstB : Process (UserClk) Is
	Begin
		if ( rising_edge(UserClk) ) then
			rPLLLockUser	<= rPLLLockUser(0) & PLLLock;
			rRstBUser		<= rRstBCnt(22);	
			rSysRstB		<= rPLLLockUser(1) and rRstBUser;
		end if;
	End Process u_rSysRstB;
	
	SysRst		<= not rSysRstB;

-----------------------------------------------------
-- RxSerial
	
	u_RxSerial : RxSerial
	Port map
	(
		RstB		=> rSysRstB		,
		Clk			=> UserClk		,
		
		SerDataIn	=> RxSerData	,
		
		RxFfFull	=> '0'			, -- always not full
		RxFfWrData	=> RxFfWrData	,
		RxFfWrEn	=> RxFfWrEn
	);
	
	u_rLED : Process (UserClk) Is
	Begin
		if ( rising_edge(UserClk) ) then
			if ( rSysRstB='0' ) then
				rLED	<= x"00";
			else
				if ( RxFfWrEn='1' ) then
					rLED	<= RxFfWrData;
				else
					rLED	<= rLED;
				end if;
			end if;
		end if;
	End Process u_rLED;

End Architecture rtl;