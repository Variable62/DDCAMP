library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity TxSerial Is
Port(
	RstB		: in	std_logic;
	Clk			: in	std_logic;
	
	TxFfEmpty	: in	std_logic;
	TxFfRdData	: in	std_logic_vector( 7 downto 0 );
	TxFfRdEn	: out	std_logic;
	
	SerDataOut	: out	std_logic
);
End Entity TxSerial;

Architecture rtl Of TxSerial Is

----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------
constant cbuadCnt   :   integer := 434;

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
type    SerStateType  is
			(
				stIdle,
				stRdReq ,
				stWtData ,
				stWtEnd
			);
		signal 	rState     	: 	SerStateType;

		signal 	rTxFtRdEn 	: 	std_logic_vector(1 downto 0);
		signal  rSerData   	: 	std_logic_vector(9 downto 0);
		signal	rBuadCnt 	:	std_logic_vector(9 downto 0);
		signal	rBuadEnd	:	std_logic;
		signal	rDataCnt	: 	std_logic_vector(3 downto 0);

Begin
----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
		TxFfRdEn 	<= 			rTxFtRdEn(0);
		SerDataOut		<= 		rSerData(0);

----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
	u_rTxFtRdEn	: Process (Clk) Is
	Begin
		if(rising_edge(Clk))	then
			if(RstB = '0') then 
				rTxFtRdEn <=  "00";
			else
				rTxFtRdEn(1) 	<=		rTxFtRdEn(0);
				if (rState = stRdReq) then
					rTxFtRdEn(0) <= '1';
				else
					rTxFtRdEn(0) <= '0';
				end if ;
			end if;
		end if;
	End Process	u_rTxFtRdEn;

	u_rSerData : Process (Clk) Is
	Begin
	if (rising_edge(Clk)) then
		if (RstB = '0') then
			rSerData	<= 	(others => '1');
		else
			if (rTxFtRdEn(1) =  '1') then
				rSerData(9) <=	'1';
				rSerData(8 downto 1) <= TxFfRdData;
				rSerData(0)	<= 	'0';
			elsif (rBuadEnd = '1') then
				rSerData	<= '1' & rSerData(9 downto 1);
			else
				rSerData	<= 	rSerData;
			end if ;
		end if ;
	end if;
	End Process	u_rSerData;

	u_rState : Process (Clk) Is
	Begin
		if (rising_edge(Clk)) then
			if (RstB = '0') then
				rState <=	stIdle;
			else
				case (rState) is
					when stIdle =>
						if (TxFfEmpty = '0') then
							rState 	<=	stRdReq; 
						else
							rState	<=	stIdle;
						end if ;

					when stRdReq =>
						rState <= 	stWtData;

					when  stWtData =>
						if (rTxFtRdEn(1) = '1') then
							rState <= stWtEnd;
						else
							rState <= stWtData;
						end if ;

					when stWtEnd =>
						if (rDataCnt (3 downto 0) = 9 and rBuadEnd = '1') then
							rState <= stIdle;
						else
							rState <= stWtEnd;
					end if ;
					when others => rState <= stIdle;	
				end case;
			end if ;
		end if ;
		
	End Process	u_rState;
	
	u_rDataCnt : Process(Clk) Is
	Begin
		if(rising_edge(Clk))	then
			if (RstB = '0') then
				rDataCnt <= (others => '0');
			else
				if(rBuadEnd = '1') then
					if (rDataCnt = 9) then
						rDataCnt <= (others => '0');
					else
						rDataCnt (3 downto 0) <= rDataCnt (3 downto 0) + 1;
					end if;
				end if;
			end if;
		end if;
	End Process	u_rDataCnt;
	
	u_rBuadCnt : Process(Clk) Is
	Begin
		if (rising_edge(Clk))	then
			if (RstB = '0') then
				rBuadCnt(9 downto 0) <= conv_std_logic_vector(cbuadCnt,10);
			else
				if (rState = stWtEnd) then
					if (rBuadCnt(9 downto 0) = 1) then
						rBuadCnt(9 downto 0) <= conv_std_logic_vector(cbuadCnt,10);
					else
						rBuadCnt(9 downto 0) <= 	rBuadCnt(9 downto 0) - 1;
					end if;
				end if;
			end if ;
		end if;
	End Process	u_rBuadCnt;

	u_rBuadEnd : Process(Clk) Is
	Begin
		if (rising_edge(Clk)) then
			if (rBuadCnt(9 downto 0) /= 1) then
				rBuadEnd <= '0';
			else
				rBuadEnd <= '1';
			end if ;
		end if ;
	End Process	u_rBuadEnd;
	

End Architecture rtl;