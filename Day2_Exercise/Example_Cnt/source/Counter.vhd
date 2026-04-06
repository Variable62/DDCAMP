----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Filename     Counter.vhd
-- Title        Top
--
-- Company      Design Gateway Co., Ltd.
-- Project      DDCamp Simulation
-- PJ No.       
-- Syntax       VHDL
-- Note         

-- Version      1.00
-- Author       S.Chaiwat
-- Date         2018/12/16
-- Remark       New Creation
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity Counter Is
Port 
(
	RstB		: in	std_logic;
	Clk			: in	std_logic;	
	
	CntOut		: out	std_logic_vector( 7 downto 0 )
);
End Entity Counter;

Architecture rtl Of Counter Is

----------------------------------------------------------------------------------
-- Constant Declaration
----------------------------------------------------------------------------------
	
-------------------------------------------------------------------------
-- Component Declaration
-------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	
	signal	rCnt	: std_logic_vector( 7 downto 0 );

Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------

	CntOut	<= rCnt;

----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------

	u_rCnt : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rCnt(7 downto 0)	<= (others=>'0');
			else
				rCnt(7 downto 0)	<= rCnt(7 downto 0) + 1;
			end if;
		end if;
	End Process u_rCnt;	

End Architecture rtl;
