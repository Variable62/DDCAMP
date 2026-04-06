-------------------------------------------------------------------------------------------------------
-- Filename     TbVGAGenerator.vhd
-- Title        Test VGAGenerator
--
-- Company      Design Gateway Co., Ltd.
-- Project      
-- Syntax       VHDL
-- Note         Testbench for VGA Signal Generator
--
-- Version      1.00
-- Author       ChatGPT (Design style from S.Chaiwat)
-- Date         2025/11/02
-- Remark       Compatible style with TbCntUpDwn.vhd
-------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use STD.TEXTIO.all;

entity TbVGAGenerator is
end entity TbVGAGenerator;

architecture HTWTestBench of TbVGAGenerator is

--------------------------------------------------------------------------------------------
-- Constant Declaration
--------------------------------------------------------------------------------------------

	constant	tClk : time := 10 ns; -- 100 MHz

--------------------------------------------------------------------------------------------
-- Component Declaration
--------------------------------------------------------------------------------------------

	component VGAGenerator is
		port (
			VGAClk      : in  std_logic;
			VGARstB     : in  std_logic;

			VGAClkB     : out std_logic;
			VGADe       : out std_logic;
			VGAHSync    : out std_logic;
			VGAVSync    : out std_logic;
			VGAData     : out std_logic_vector(23 downto 0)
		);
	end component;

--------------------------------------------------------------------------------------------
-- Signal Declaration
--------------------------------------------------------------------------------------------

	signal VGAClk		: std_logic := '0';
	signal VGARstB		: std_logic := '0';
	signal VGAClkB		: std_logic;
	signal VGADe		: std_logic;
	signal VGAHSync		: std_logic;
	signal VGAVSync		: std_logic;
	signal VGAData		: std_logic_vector(23 downto 0);

	signal TM, TT		: integer range 0 to 65535 := 0;
	signal FrameCnt		: integer := 0;

begin

--------------------------------------------------------------------------------------------
-- Clock Generator
--------------------------------------------------------------------------------------------

	u_VGAClk : process
	begin
		VGAClk <= '0';
		wait for tClk/2;
		VGAClk <= '1';
		wait for tClk/2;
	end process;

--------------------------------------------------------------------------------------------
-- DUT (Device Under Test)
--------------------------------------------------------------------------------------------

	u_VGAGen : VGAGenerator
		port map (
			VGAClk   => VGAClk,
			VGARstB  => VGARstB,
			VGAClkB  => VGAClkB,
			VGADe    => VGADe,
			VGAHSync => VGAHSync,
			VGAVSync => VGAVSync,
			VGAData  => VGAData
		);

--------------------------------------------------------------------------------------------
-- Test Process
--------------------------------------------------------------------------------------------

	u_Test : process
		variable line_cnt : integer := 0;
	begin
		--------------------------------------------------------------------------------
		-- TM=0 : Reset
		--------------------------------------------------------------------------------
		TM <= 0; TT <= 0; wait for 1 ns;
		report "TM=" & integer'image(TM) & " TT=" & integer'image(TT) & " : Assert Reset";

		VGARstB <= '0';
		wait for 20 * tClk;
		VGARstB <= '1';
		wait for 10 * tClk;

		--------------------------------------------------------------------------------
		-- TM=1 : Observe HSync & VSync activity
		--------------------------------------------------------------------------------
		TM <= 1; TT <= 0; wait for 1 ns;
		report "TM=" & integer'image(TM) & " TT=" & integer'image(TT) & " : Observe HSync/VSync transitions";

		for i in 0 to 5000 loop
			wait until rising_edge(VGAClk);
			if (i mod 500 = 0) then
				report "t=" & integer'image(i) &
				       " HSync=" & std_logic'image(VGAHSync) &
				       " VSync=" & std_logic'image(VGAVSync) &
				       " DE=" & std_logic'image(VGADe);
			end if;
		end loop;

		--------------------------------------------------------------------------------
		-- TM=2 : Count visible frame area (DE active)
		--------------------------------------------------------------------------------
		TM <= 2; TT <= 0; wait for 1 ns;
		report "TM=" & integer'image(TM) & " TT=" & integer'image(TT) & " : Measure DE active region";

		line_cnt := 0;
		for i in 0 to 100000 loop
			wait until rising_edge(VGAClk);
			if VGADe = '1' then
				line_cnt := line_cnt + 1;
			end if;
		end loop;
		report "Total DE Active Pixels = " & integer'image(line_cnt);

		--------------------------------------------------------------------------------
		-- TM=3 : Detect Color Change Pattern
		--------------------------------------------------------------------------------
		TM <= 3; TT <= 0; wait for 1 ns;
		report "TM=" & integer'image(TM) & " TT=" & integer'image(TT) & " : Detect RGB pattern by VGAData";

		for i in 0 to 30000 loop
			wait until rising_edge(VGAClk);
			if VGADe = '1' then
				if (VGAData = x"FFFFFF") then
					report "White line detected";
				elsif (VGAData = x"FFFF00") then
					report "Yellow line detected";
				elsif (VGAData = x"00FFFF") then
					report "Cyan line detected";
				elsif (VGAData = x"00FF00") then
					report "Green line detected";
				elsif (VGAData = x"FF00FF") then
					report "Pink line detected";
				elsif (VGAData = x"FF0000") then
					report "Red line detected";
				elsif (VGAData = x"0000FF") then
					report "Blue line detected";
				elsif (VGAData = x"000000") then
					report "Black line detected";
				end if;
			end if;
		end loop;

		--------------------------------------------------------------------------------
		-- TM=255 : End of Simulation
		--------------------------------------------------------------------------------
		TM <= 255; wait for 1 ns;
		report "##### End Simulation #####" severity failure;
		wait;

	end process;

end architecture HTWTestBench;
