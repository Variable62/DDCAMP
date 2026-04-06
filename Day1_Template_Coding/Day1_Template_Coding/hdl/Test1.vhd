----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Filename     Test1.vhd
-- Title        Top
--
-- Company      Design Gateway Co., Ltd.
-- Project      DDCamp
-- PJ No.       
-- Syntax       VHDL
-- Note         

-- Version      
-- Author       
-- Date         
-- Remark       
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity Test1 Is
	Port (
        Clk					: in	std_logic;
		RstB				: in	std_logic;
		
		HdDataIn			: in	std_logic_vector( 7 downto 0 );
		HdDataValid			: in	std_logic;
		
		HdDataOut			: out	std_logic_vector( 7 downto 0 );
		HdDataOutValid		: out	std_logic
    );
End Entity Test1;

Architecture rtl Of Test1 Is

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
signal rHdDataInValid0 : std_logic;
signal rCnt8     : std_logic_vector(2 downto 0);
signal rHdDataIn0 : std_logic_vector(7 downto 0);
signal rHdDataIn1 : std_logic_vector(7 downto 0);
signal rHdDataOutValid : std_logic;
	
Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
	HdDataOut <= rHdDataIn1;
	HdDataOutValid <= rHdDataOutValid;

----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
	
	--Delay data
	u_rHdDataIn0 : Process(Clk) Is
	Begin 
		if(rising_edge(Clk)) then
				rHdDataIn1 <= rHdDataIn0;
				rHdDataIn0 <= rHdDataIn;
		end if;
	End Process u_rHdDataIn0;
	
	--Delay Valid
	u_rHdDataInValid0 : Process(Clk) IS
	Begin 
		if(rising_edge(Clk)) then
				if(Rst = '0') then
					rHdDataInValid0 <= '0' ;
				else 
					rHdDataInValid0 <= rHdDataInValid;
				else if;
			end if;
		End Process u_rHdDataInValid0;
		
	u_rCnt8 : Process(Clk) Is
	Begin	
		if( rising_edge(Clk)) then
				if(rHdDataInValid0 = '1' ) then
					rCnt8(2 downto 0) <= rCnt8(2 downto 0) + 1;
				else
					rCnt8(2 downto 0) <= "000";
				end if;
			end if;
		End Process u_rCnt8;
		
	u_rHdDataOutValid : Process(Clk) IS
	Begin 
		if(rising_edge(Clk)) then
			if(RstB = '0') then
				rHdDataOutValid <= '0';
			else
			
			--Start of Valid data streaming
			
				if(rHdDataInValid0 = '1' and rCnt8(2 downto 0) = 0 and HdDataIn(7 downto 0) = x"AA" and rHdDataIn0 = x"55") then
					rHdDataOutValid <= '1';
			-- End of data streaming		
					
				elsif(rHdDataInValid0 = '0') then
					rHdDataOutValid <= '0';
				else
					rHdDataOutValid <= rHdDataOutValid;
				end if;
			end if;
		end if;
	End Process u_rHdDataOutValid;
	
End Architecture rtl;
