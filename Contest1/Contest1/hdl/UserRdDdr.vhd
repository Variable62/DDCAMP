----------------------------------------------------------------------------------
-- Filename     : UserRdDdr.vhd
-- Title        : DDR Read Controller 
-- Company      : Design Gateway Co., Ltd.
-- Project      : DDCamp
-- Version      : 1.0
-- Date         : 2025/11/07
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity UserRdDdr is
    port (
        RstB            : in  std_logic;                          -- active low reset
        Clk             : in  std_logic;                          -- 100 MHz clock
        DipSwitch       : in  std_logic_vector(1 downto 0);

        -- HDMI Control I/F
        HDMIReq         : out std_logic;
        HDMIBusy        : in  std_logic;

        -- DDR Read Controller I/F
        MemInitDone     : in  std_logic;
        MtDdrRdReq      : out std_logic;
        MtDdrRdBusy     : in  std_logic;
        MtDdrRdAddr     : out std_logic_vector(28 downto 7);

        -- DDR Read FIFO (from DDR to User)
        D2URdFfWrEn     : in  std_logic;
        D2URdFfWrData   : in  std_logic_vector(63 downto 0);
        D2URdFfWrCnt    : out std_logic_vector(15 downto 0);

        -- HDMI FIFO (to HDMI from User)
        URd2HFfWrEn     : out std_logic;
        URd2HFfWrData   : out std_logic_vector(63 downto 0);
        URd2HFfWrCnt    : in  std_logic_vector(15 downto 0)
    );
end entity;

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

    ------------------------------------------------------------------------------
    -- Detect End of Address Range
    ------------------------------------------------------------------------------
    -- u_rRdDone : process(Clk)
    -- begin
    --     if rising_edge(Clk) then
    --         if RstB = '0' then
    --             rRdDone <= '0';
    --         elsif (rMtDdrRdAddr(26 downto 7) = 24575 and
    --                rMtDdrRdAddr(28 downto 27) = "11" and
    --                MtDdrRdBusy = '1') then
    --             rRdDone <= '1';
    --         end if;
    --     end if;
    -- end process u_rRdDone;

End Architecture rtl;
