----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Filename     VGAGenerator.vhd
-- Title        Top
--
-- Company      Design Gateway Co., Ltd.
-- Project      DDCamp HDMI-IP
-- PJ No.       
-- Syntax       VHDL
-- Note         

-- Version      1.00
-- Author       B.Attapon
-- Date         2017/11/14
-- Remark       New Creation
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity VGAGenerator Is
	Port (
        VGAClk			: in	std_logic;
		VGARstB			: in	std_logic;
		
		-- VGA Output Interface
		VGAClkB			: out	std_logic;
		VGADe			: out	std_logic;
		VGAHSync		: out	std_logic;
		VGAVSync		: out	std_logic;
		VGAData			: out	std_logic_vector( 23 downto 0 )
    );
End Entity VGAGenerator;

Architecture rtl Of VGAGenerator Is

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------

	signal	rHSyncCnt	: std_logic_vector( 10 downto 0 );
	signal	rHSync		: std_logic;
	
	signal	rVSyncCnt	: std_logic_vector( 9 downto 0 );
	signal	rVSync		: std_logic;
	
	signal	rDe			: std_logic;
	signal	rVGAData	: std_logic_vector( 23 downto 0 );
	
Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------

	VGAClkB		<= not VGAClk;
	
	VGAHSync	<= rHSync;
	VGAVSync	<= rVSync;
	
	VGADe		<= rDe;
	VGAData		<= rVGAData;

----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
	
----------------------------------------------------------------------------------
-- [[ LBA 1 : CODING HSYNC(1) ]]
	
	u_rHSyncCnt : Process (VGAClk) Is
	Begin
		if ( rising_edge(VGAClk) ) then
			if ( VGARstB='0' ) then
				-- coding here
				-- initial value
			else
				-- coding here
				-- behaviour
			end if;
		end if;
	End Process u_rHSyncCnt;
	
	u_rHSync : Process (VGAClk) Is
	Begin
		if ( rising_edge(VGAClk) ) then
			if ( VGARstB='0' ) then
				-- coding here
				-- initial value
			else
				-- coding here
				-- behaviour
			end if;
		end if;
	End Process u_rHSync;
	
----------------------------------------------------------------------------------
-- [[ LBA 2 : CODING VSYNC(1) ]]
	
	u_rVSyncCnt : Process (VGAClk) Is
	Begin
		if ( rising_edge(VGAClk) ) then
			if ( VGARstB='0' ) then
				-- coding here
				-- initial value
			else
				-- coding here
				-- behaviour
			end if;
		end if;
	End Process u_rVSyncCnt;
	
	u_rVSync : Process (VGAClk) Is
	Begin
		if ( rising_edge(VGAClk) ) then
			if ( VGARstB='0' ) then
				-- coding here
				-- initial value
			else
				-- coding here
				-- behaviour
			end if;
		end if;
	End Process u_rVSync;
	
----------------------------------------------------------------------------------
-- [[ Challenge Exercise : CODING TEST PATTERN ]]
	 
	u_rDe : Process (VGAClk) Is
	Begin
		if ( rising_edge(VGAClk) ) then
			if ( VGARstB='0' ) then
				-- coding here
				-- initial value
			else
				-- coding here
				-- behaviour
			end if;
		end if;
	End Process u_rDe;
	
	u_rVGAData : Process (VGAClk) Is
	Begin
		if ( rising_edge(VGAClk) ) then
			-- coding here
			-- behaviour
		end if;
	End Process u_rVGAData;
	
End Architecture rtl;
