library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity RxSerial Is
Port(
	RstB		: in	std_logic;
	Clk			: in	std_logic;
	
	Fail		: out	std_logic;
	SerDataIn	: in	std_logic;
	
	RxFfFull	: in	std_logic;
	RxFfWrData	: out	std_logic_vector( 7 downto 0 );
	RxFfWrEn	: out	std_logic
);
End Entity RxSerial;

Architecture rtl Of RxSerial Is

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------

	signal	rExpData		: std_logic_vector( 7 downto 0 );
	signal	rFail			: std_logic;

Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------

	RxFfWrData		<= rSerData(8 downto 1);
	RxFfWrEn		<= rRxFfWrEn;
	
	Fail			<= rFail;

----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------

	u_rExpData : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rExpData	<= x"00";
			else
				if ( rRxFfWrEn='1' ) then
					rExpData	<= rExpData + 1;
				else
					rExpData	<= rExpData;
				end if;
			end if;
		end if;
	End Process u_rExpData;

	u_rFail : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rFail	<= '0';
			else
				if ( rRxFfWrEn='1' ) then
					if ( rExpData=rSerData(8 downto 1) ) then
						rFail	<= '0';
					else
						rFail	<= '1';
					end if;
				else
					rFail	<= '0';
				end if;
			end if;
		end if;
	End Process u_rFail;

End Architecture rtl;