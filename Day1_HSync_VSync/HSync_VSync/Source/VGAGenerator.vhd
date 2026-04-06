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
		VGAHSync			: out	std_logic;
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
				rHSyncCnt(10 downto 0) <= (others=>'0');
			else
				-- coding here
				if (rHSyncCnt (10 downto 0 ) = x"53F") then 
					rHSyncCnt (10 downto 0 ) <= (others=>'0');
				else
					rHSyncCnt (10 downto 0 ) <= rHSyncCnt (10 downto 0 ) + 1;
				-- behaviour
			end if;
			end if;
		end if;
	End Process u_rHSyncCnt;
	
	u_rHSync : Process (VGAClk) Is
	Begin
		if ( rising_edge(VGAClk) ) then
			if ( VGARstB='0' ) then
				rHSync <= '1';
			else	
                if (rHSyncCnt (10 downto 0 ) =  x"87") then
                    rHSync <= '1';
                 elsif (rHSyncCnt (10 downto 0 ) =  x"53F") then
                    rHSync <= '0';
                    else
                        rHSync <= rHSync;
                end if ;
			end if;
		end if;
	End Process u_rHSync;
----------------------------------------------------------------------------------
---- [[ LBA 2 : CODING VSYNC(1) ]]
	
	u_rVSyncCnt : Process (VGAClk) Is
	Begin
		if ( rising_edge(VGAClk) ) then
			if ( VGARstB='0' ) then
               rVSyncCnt (9 downto 0) <= (others=>'0');
			else
                if (rHSyncCnt (10 downto 0 ) = x"53F") then
                    rVSyncCnt(9 downto 0) <= rVSyncCnt (9 downto 0) + 1;
                elsif (rVSyncCnt(9 downto 0) = x"324") then
                    rVSyncCnt (9 downto 0) <= (others=>'0');
				else
					rVSyncCnt (9 downto 0)  <=  rVSyncCnt (9 downto 0) ;
            	end if ;
			end if;
		end if;
	End Process u_rVSyncCnt;
	
	u_rVSync : Process (VGAClk) Is
	Begin
		if ( rising_edge(VGAClk) ) then
			if ( VGARstB='0' ) then
            rVSync <= '1';
			else
                if (rVSyncCnt (9 downto 0) = 0) then
                    rVsync <= '0';
                elsif (rVSyncCnt (9 downto 0) = 5) then
                    rVsync <= '1';
				else 
					rVsync <= rVsync;	
                end if ;
			end if;
		end if;
	End Process u_rVSync;
	
------------------------------------------------------------------------------------
---- [[ Challenge Exercise : CODING TEST PATTERN ]]
	 
	u_rDe : Process (VGAClk) Is
	Begin
		if ( rising_edge(VGAClk) ) then
			if ( VGARstB='0' ) then
				rDe <= '0';
			else
				if(rVsync = '1' and rHSync = '1' and rVSyncCnt (9 downto 0) = 34) then
					rDe <= '1';
				elsif (rVsync = '1' and rHSync = '1' and rVSyncCnt (9 downto 0) = 804) then
					rDe <= '0';
				else
					rDe <= rDe;
				end if ;
			end if;
		end if;
	End Process u_rDe;
	
	u_rVGAData : Process (VGAClk) Is
	Begin
		if ( rising_edge(VGAClk) ) then
			if (rDe = '0') then
				rVGAData (23 downto 0) <= (others=>'0');
			else
			if (rDe = '1' and  rVSyncCnt (9 downto 0) = 34 and  rVSyncCnt (9 downto 0) < 91) then -- white
				rVGAData (7 downto 0 ) <= x"FF";
				rVGAData (15 downto 8 ) <= x"FF";
				rVGAData (23 downto 16 ) <= x"FF";
			elsif (rDe = '1' and rVSyncCnt (9 downto 0) = 91 and rVSyncCnt (9 downto 0) < 182) then -- Yellow
				rVGAData (7 downto 0 ) <= x"FF";
				rVGAData (15 downto 8 ) <= x"FF";
				rVGAData (23 downto 16 ) <= x"00";
			elsif (rDe = '1' and rVSyncCnt (9 downto 0) = 182 and rVSyncCnt (9 downto 0) < 273) then -- Sky blue
				rVGAData (7 downto 0 ) <= x"00";
				rVGAData (15 downto 8 ) <= x"FF";
				rVGAData (23 downto 16 ) <= x"FF";
			elsif (rDe = '1' and rVSyncCnt (9 downto 0) = 273 and rVSyncCnt (9 downto 0) < 364) then -- Green
				rVGAData (7 downto 0 ) <= x"00";
				rVGAData (15 downto 8 ) <= x"FF";
				rVGAData (23 downto 16 ) <= x"00";
			elsif (rDe = '1' and rVSyncCnt (9 downto 0) = 364 and rVSyncCnt (9 downto 0) < 455) then -- Pink
				rVGAData (7 downto 0 ) <= x"FF";
				rVGAData (15 downto 8 ) <= x"00";
				rVGAData (23 downto 16 ) <= x"FF";
			elsif (rDe = '1' and rVSyncCnt (9 downto 0) = 455 and rVSyncCnt (9 downto 0) < 546) then -- Red
				rVGAData (7 downto 0 ) <= x"FF";
				rVGAData (15 downto 8 ) <= x"00";
				rVGAData (23 downto 16 ) <= x"00";			
			elsif (rDe = '1' and rVSyncCnt (9 downto 0) = 546 and rVSyncCnt (9 downto 0) < 637) then -- Blue
				rVGAData (7 downto 0 ) <= x"00";
				rVGAData (15 downto 8 ) <= x"00";
				rVGAData (23 downto 16 ) <= x"FF";			
			elsif (rDe = '1' and rVSyncCnt (9 downto 0) = 637 and rVSyncCnt (9 downto 0) < 728) then -- Black
				rVGAData (7 downto 0 ) <= x"00";
				rVGAData (15 downto 8 ) <= x"00";
				rVGAData (23 downto 16 ) <= x"00";
			else
				rVGAData (23 downto 0) <= (others=>'0');
			end if ;
		end if ;	
	end if ;
	End Process u_rVGAData;
	
End Architecture rtl;