----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Filename     UserWrDdr.vhd
-- Title        Top
--
-- Company      Design Gateway Co., Ltd.
-- Project      DDCamp
-- PJ No.       
-- Syntax       VHDL
-- Note         

-- Version      1.00
-- Author       B.Attapon
-- Date         2017/12/20
-- Remark       New Creation
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity UserWrDdr Is
	Port
	(
		RstB			: in	std_logic;							-- use push button Key0 (active low)
		Clk				: in	std_logic;							-- clock input 100 MHz
		
		-- WrCtrl I/F
		MemInitDone		: in	std_logic;
		MtDdrWrReq		: out	std_logic;
		MtDdrWrBusy		: in	std_logic;
		MtDdrWrAddr		: out	std_logic_vector( 28 downto 7 );
		
		-- T2UWrFf I/F
		T2UWrFfRdEn		: out	std_logic;
		T2UWrFfRdData	: in	std_logic_vector( 63 downto 0 );
		T2UWrFfRdCnt	: in	std_logic_vector( 15 downto 0 );
		
		-- UWr2DFf I/F
		UWr2DFfRdEn		: in	std_logic;
		UWr2DFfRdData	: out	std_logic_vector( 63 downto 0 );
		UWr2DFfRdCnt	: out	std_logic_vector( 15 downto 0 )
	);
End Entity UserWrDdr;

Architecture rtl of UserWrDdr is

    signal rMemInitDone  : std_logic_vector(1 downto 0);
    signal rMtDdrWrReq   : std_logic;
    signal rMtDdrWrAddr  : std_logic_vector(28 downto 7);

begin
----------------------------------------------------------------------------------
-- Output Mapping
----------------------------------------------------------------------------------
    MtDdrWrReq   <= rMtDdrWrReq;
    MtDdrWrAddr  <= rMtDdrWrAddr;


    T2UWrFfRdEn  <= UWr2DFfRdEn;
    UWr2DFfRdData <= T2UWrFfRdData;
    UWr2DFfRdCnt  <= T2UWrFfRdCnt;

----------------------------------------------------------------------------------
-- Process 1 : Synchronize MemInitDone
----------------------------------------------------------------------------------
    process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rMemInitDone <= "00";
            else
                rMemInitDone <= rMemInitDone(0) & MemInitDone;
            end if;
        end if;
    end process;

----------------------------------------------------------------------------------
-- Generate Write Request
    u_rMtDdrWrReq : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rMtDdrWrReq <= '0';
            elsif rMemInitDone(1) = '0' then
                rMtDdrWrReq <= '0';
            elsif MtDdrWrBusy = '1' then
                rMtDdrWrReq <= '0';
            elsif T2UWrFfRdCnt < 65536 - 32 then
                rMtDdrWrReq <= '1';
            else
                rMtDdrWrReq <= '0';
            end if;
        end if;
    end process u_rMtDdrWrReq;

-- Address Counter
    u_rMtDdrWrAddr : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rMtDdrWrAddr <= (others => '0');
            elsif rMemInitDone(1) = '1' then
                if (rMtDdrWrReq = '1' and MtDdrWrBusy = '1') then
                    if (rMtDdrWrAddr(26 downto 7) = 24575) then 
                        rMtDdrWrAddr(26 downto 7) <= (others => '0');
                        rMtDdrWrAddr(28 downto 27) <= rMtDdrWrAddr(28 downto 27) + 1;
                    else
                        rMtDdrWrAddr(26 downto 7) <= rMtDdrWrAddr(26 downto 7) + 1;
                    end if;
                end if;
            end if;
        end if;
    end process u_rMtDdrWrAddr;

End Architecture rtl;
