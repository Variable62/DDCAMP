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
-------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Filename     TestPatt.vhd
-- Title        Top
--
-- Company      Design Gateway Co., Ltd.
-- Project      DDCamp DDR-IP
-- PJ No.       
-- Syntax       VHDL
-- Note         

-- Version      1.00
-- Author       B.Attapon
-- Date         2017/11/17
-- Remark       New Creation
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity TestPatt Is
	Port 
	(
		RstB			: in	std_logic;
		Clk				: in	std_logic;
		
		-- TestPatt Command I/F
		PattSel			: in	std_logic;	-- '0':Inc  , '1':Dec
		PattCmd			: in	std_logic;	-- '0':write, '1':Read
		PattReq			: in	std_logic;
		PattBusy		: out	std_logic;
		PattFail		: out	std_logic;
		
		-- MtDdr Interface
		-- Command Write I/F
		MtDdrWrReq		: out	std_logic;
		MtDdrWrBusy		: in	std_logic;
		MtDdrWrAddr		: out	std_logic_vector( 28 downto 7 );
		-- Write Fifo interface
		WrFfWrCnt		: in	std_logic_vector( 15 downto 0 );	-- Fifo write counter
		WrFfWrEn		: out	std_logic;							-- Fifo write enable
		WrFfWrData		: out	std_logic_vector( 31 downto 0 );	-- Fifo write data
		
		-- Command Read I/F
		MtDdrRdReq		: out	std_logic;
		MtDdrRdBusy		: in	std_logic;
		MtDdrRdAddr		: out	std_logic_vector( 28 downto 7 );
		-- Read Fifo interface
		RdFfRdCnt		: in	std_logic_vector( 15 downto 0 );	-- Fifo read counter
		RdFfRdData		: in	std_logic_vector( 31 downto 0 );	-- Fifo read data
		RdFfRdEn		: out	std_logic							-- Fifo read enable
	);
End Entity TestPatt;

Architecture rtl Of TestPatt Is
	
	-- Transfer size (Byte), align 1024						   (512 in MB)
	constant	c512MB		: integer						:= (512 / 4) * 1024 * 1024;	-- Maximum Transfer
	-- Calculate Parameter
	constant	cEndPattReq	: std_logic_vector(22 downto 0)	:= conv_std_logic_vector((c512MB/32), 23);

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------

	type	StateType is
						(
							stIdle,
							stWaitFf,
							stGenReq,
							stWtRdFf,
							stTrans
						);
	signal	rState	: StateType;
	
	signal	rPattSel		: std_logic;
	signal	rCmd			: std_logic;
	signal	rPattBusy		: std_logic;
	signal	rBurstCnt		: std_logic_vector( 4 downto 0 );
	
	signal	rPattCnt		: std_logic_vector( 27 downto 0 );	-- Pattern counter (Count-up)
	signal	wPattData		: std_logic_vector( 31 downto 0 );	-- Real pattern data
	
	signal	rMtDdrWrReq		: std_logic;
	signal	rMtDdrRdReq		: std_logic;
	signal	rMtDdrAddr		: std_logic_vector( 28 downto 7 );

	signal	rWrFfWrEn		: std_logic;						-- Fifo write enable
	signal	rRdFfRdEn		: std_logic_vector( 1 downto 0 );	-- Fifo read enable
	signal	rFail			: std_logic;

Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
	
	PattBusy					<= rPattBusy;
	PattFail					<= rFail;
	
	-- MtDdr Interface
	MtDdrWrReq					<= rMtDdrWrReq;
	MtDdrWrAddr(28 downto 7)	<= rMtDdrAddr(28 downto 7);
	MtDdrRdReq					<= rMtDdrRdReq;
	MtDdrRdAddr(28 downto 7)	<= rMtDdrAddr(28 downto 7);
	
	-- Fifo interface
	WrFfWrEn					<= rWrFfWrEn;
	WrFfWrData(31 downto 0)		<= wPattData(31 downto 0);
	RdFfRdEn					<= rRdFfRdEn(0);

----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
	
	------------------------------------------------------------------------------
	-- State Machine
	u_rState : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rState		<= stIdle;
			else
				case ( rState ) is				
					-- Wait start pulse
					when stIdle		=>
						-- Receive request from user
						if ( PattReq='1' ) then
							rState	<= stWaitFf;							
						else
							rState	<= stIdle;
						end if;
					
					-- Wait until FIFO is ready
					when stWaitFf	=>
						-- Ddr is not busy
						-- Free space is more than 32 words
						if ( (rCmd='0' and MtDdrWrBusy='0' and WrFfWrCnt(15 downto 6)/=("11"&x"FF"))
						-- Ddr is not busy
						  or (rCmd='1' and MtDdrRdBusy='0') ) then
							rState	<= stGenReq;
						else
							rState	<= stWaitFf;
						end if;
					
					-- Generate request to DDR
					when stGenReq	=>
						-- Write Command is received
						if ( rCmd='0' and MtDdrWrBusy='1' ) then
							rState	<= stTrans;
						-- Read Command is received
						elsif ( rCmd='1' and MtDdrRdBusy='1' ) then
							rState	<= stWtRdFf;
						else
							rState	<= stGenReq;
						end if;

					-- Wait 32 words available
					when stWtRdFf	=>
						if ( RdFfRdCnt(15 downto 5)/=0 ) then
							rState	<= stTrans;
						else
							rState	<= stWtRdFf;
						end if;
					
					-- Transfer data to/from DDR
					when stTrans	=>
						-- End of burst transfer
						if ( rBurstCnt(4 downto 0)=31 ) then
							-- End transfer when next address is end address
							if ( rMtDdrAddr(28 downto 7)=cEndPattReq(21 downto 0) ) then
								rState	<= stIdle;
							-- Continue for next burst transfer
							else
								rState	<= stWaitFf;
							end if;
						-- Still not complete current burst transfer
						else
							rState	<= stTrans;
						end if;
				end case;
			end if;
		end if;
	End Process u_rState;
	
	u_rBurstCnt : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rBurstCnt	<= (others=>'0');
			else
				if ( rState=stTrans ) then
					rBurstCnt	<= rBurstCnt + 1;
				else
					rBurstCnt	<= (others=>'0');
				end if;
			end if;
		end if;
	End Process u_rBurstCnt;
	
	------------------------------------------------------------------------------
	-- Pattern

	u_rPattSel : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			rPattSel		<= PattSel;
		end if;
	End Process u_rPattSel;

	u_rCmd : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( PattReq='1' and rPattBusy='0' ) then
				rCmd	<= PattCmd;
			else
				rCmd	<= rCmd;
			end if;
		end if;
	End Process u_rCmd;
	
	u_rPattBusy : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rPattBusy	<= '0';
			else
				-- Idle state and no request from user
				if ( rState=stIdle and PattReq='0' ) then
					rPattBusy	<= '0';
				else
					rPattBusy	<= '1';
				end if;
			end if;
		end if;
	End Process u_rPattBusy;
	
	u_rPattCnt : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			-- Transfer test data
			if ( rWrFfWrEn='1' or rRdFfRdEn(1)='1' ) then
				rPattCnt(27 downto 0)	<= rPattCnt(27 downto 0) + 1;
			-- Reset pattern 
			-- (rWrFfWrEn/rRdFfRdEn is asserted to '1' in stIdle 
			-- for short time when end of transfer)
			elsif ( rState=stIdle ) then
				rPattCnt(27 downto 0)	<= (others=>'0');
			else
				rPattCnt(27 downto 0)	<= rPattCnt(27 downto 0);
			end if;
		end if;
	End Process u_rPattCnt;
	
	-- '0': Increment, '1': Decrement
	wPattData(31 downto 0)	<= x"0"&rPattCnt(27 downto 0) when rPattSel='0'
						else not(x"0"&rPattCnt(27 downto 0));
	
	------------------------------------------------------------------------------
	-- MtDdr
	
	u_rMtDdrWrReq : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rMtDdrWrReq		<= '0';
			else
				-- Write command and DDR still not receives command
				if ( rCmd='0' and rState=stGenReq and MtDdrWrBusy='0' ) then
					rMtDdrWrReq	<= '1';
				else
					rMtDdrWrReq	<= '0';
				end if;
			end if;
		end if;
	End Process u_rMtDdrWrReq;
	
	u_rMtDdrRdReq : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rMtDdrRdReq		<= '0';
			else
				-- Read command and DDR still not receives command
				if ( rCmd='1' and rState=stGenReq and MtDdrRdBusy='0' ) then
					rMtDdrRdReq	<= '1';
				else
					rMtDdrRdReq	<= '0';
				end if;
			end if;
		end if;
	End Process u_rMtDdrRdReq;
	
	u_rMtDdrAddr : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( rState=stIdle ) then
				rMtDdrAddr(28 downto 7)	<= (others=>'0');
			-- Command is received (stGenReq->stTrans)
			elsif ( (rState=stGenReq and rCmd='0' and MtDdrWrBusy='1')
				 or (rState=stGenReq and rCmd='1' and MtDdrRdBusy='1') ) then
			-- Increase to next address
				rMtDdrAddr(28 downto 7)	<= rMtDdrAddr(28 downto 7) + 1;
			else
				rMtDdrAddr(28 downto 7)	<= rMtDdrAddr(28 downto 7);
			end if;
		end if;
	End Process u_rMtDdrAddr;
	
	------------------------------------------------------------------------------
	-- Write Data
	
	u_rWrFfWrEn : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rWrFfWrEn	<= '0';
			else
				if ( rCmd='0' and rState=stTrans ) then
					rWrFfWrEn	<= '1';
				else
					rWrFfWrEn	<= '0';
				end if;
			end if;
		end if;
	End Process u_rWrFfWrEn;
	
	------------------------------------------------------------------------------
	-- Read and Verify Data
	
	u_rRdFfRdEn : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rRdFfRdEn		<= "00";
			else
				rRdFfRdEn(1)	<= rRdFfRdEn(0);
				if ( rCmd='1' and rState=stTrans ) then
					rRdFfRdEn(0)	<= '1';
				else
					rRdFfRdEn(0)	<= '0';
				end if;
			end if;
		end if;
	End Process u_rRdFfRdEn;
	
	u_rFail : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rFail	<= '0';
			else				
				-- Clear after receiving new request
				if ( rState=stIdle and PattReq='1' ) then
					rFail	<= '0';
				-- Use bit 1 to wait data from FIFO
				elsif ( rRdFfRdEn(1)='1' ) then
					if ( RdFfRdData/=wPattData ) then
						rFail	<= '1';
					else
						rFail	<= rFail;
					end if;
				else
					rFail		<= rFail;
				end if;
			end if;
		end if;
	End Process u_rFail;
	
End Architecture rtl;
