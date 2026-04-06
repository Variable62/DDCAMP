----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Filename     UserRdDdr.vhd
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

Entity UserRdDdr Is
	Port
	(
		RstB			: in	std_logic;							-- use push button Key0 (active low)
		Clk				: in	std_logic;							-- clock input 100 MHz
		
		DipSwitch		: in 	std_logic_vector( 1 downto 0 );
		
		-- HDMICtrl I/F
		HDMIReq			: out	std_logic;
		HDMIBusy		: in	std_logic;
		
		-- RdCtrl I/F
		MemInitDone		: in	std_logic;
		MtDdrRdReq		: out	std_logic;
		MtDdrRdBusy		: in	std_logic;
		MtDdrRdAddr		: out	std_logic_vector( 28 downto 7 );
		
		-- D2URdFf I/F
		D2URdFfWrEn		: in	std_logic;
		D2URdFfWrData	: in	std_logic_vector( 63 downto 0 );
		D2URdFfWrCnt	: out	std_logic_vector( 15 downto 0 );
		
		-- URd2HFf I/F
		URd2HFfWrEn		: out	std_logic;
		URd2HFfWrData	: out	std_logic_vector( 63 downto 0 );
		URd2HFfWrCnt	: in	std_logic_vector( 15 downto 0 )
	);
End Entity UserRdDdr;

architecture rtl of UserRdDdr is

    ------------------------------------------------------------------------------
    -- Signal Declaration
    ------------------------------------------------------------------------------
    signal rMemInitDone   : std_logic_vector(1 downto 0);
    signal rHDMIReq       : std_logic;
    signal rMtDdrRdReq    : std_logic;
    signal rMtDdrRdAddr   : std_logic_vector(28 downto 7);
    -- signal rRdDone        : std_logic;   -- flag for end of memory
begin

    ------------------------------------------------------------------------------
    -- Output Mapping
    ------------------------------------------------------------------------------
    HDMIReq        <= rHDMIReq;
    MtDdrRdReq     <= rMtDdrRdReq;
    MtDdrRdAddr    <= rMtDdrRdAddr;

    URd2HFfWrEn    <= D2URdFfWrEn;
    URd2HFfWrData  <= D2URdFfWrData;
    D2URdFfWrCnt   <= URd2HFfWrCnt;

    -- Synchronize MemInitDone
    u_rMemInitDone : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rMemInitDone <= "00";
            else
                rMemInitDone <= rMemInitDone(0) & MemInitDone;
            end if;
        end if;
    end process u_rMemInitDone;

    u_rHDMIReq : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rHDMIReq <= '0';
            elsif HDMIBusy = '0' and rMemInitDone(1) = '1' then
                rHDMIReq <= '1';
            elsif HDMIBusy = '1' then
                rHDMIReq <= '0';
            end if;
        end if;
    end process u_rHDMIReq;

    ------------------------------------------------------------------------------
    --DDR Read Request Control
    ------------------------------------------------------------------------------
    u_rMtDdrRdReq : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rMtDdrRdReq <= '0';
            elsif rMemInitDone(1) = '0' then
                rMtDdrRdReq <= '0';
            -- elsif rRdDone = '1' then
            --     rMtDdrRdReq <= '0';
            elsif MtDdrRdBusy = '1' then
                rMtDdrRdReq <= '0';
            elsif URd2HFfWrCnt >= 32 then
                rMtDdrRdReq <= '1';
            else
                rMtDdrRdReq <= '0';
            end if;
        end if;
    end process u_rMtDdrRdReq;

    ------------------------------------------------------------------------------
    -- DDR Read Address Counter
    ------------------------------------------------------------------------------
    u_rMtDdrRdAddr : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rMtDdrRdAddr <= (others => '0');
            elsif rMemInitDone(1) = '1' then
                if (rMtDdrRdReq = '1' and MtDdrRdBusy = '1') then
                    if (rMtDdrRdAddr(26 downto 7) = 24575) then
                        rMtDdrRdAddr(26 downto 7) <= (others => '0');
                        rMtDdrRdAddr(28 downto 27) <= DipSwitch(1 downto 0);
                    else
                        rMtDdrRdAddr(26 downto 7) <= rMtDdrRdAddr(26 downto 7) + 1;
                    end if;
                end if;
            end if;
        end if;
    end process u_rMtDdrRdAddr;

End Architecture rtl;
