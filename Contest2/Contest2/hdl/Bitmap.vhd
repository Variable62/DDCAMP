library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity Bitmap Is

    port
    (
        RstB            : in    std_logic;
        Clk             : in    std_logic;
        
        RxFfWrEn        : in   std_logic;

        RxFfWrData      : in    std_logic_vector(7 downto 0);
        DataOutToFf     : out   std_logic_vector(31 downto 0);
    );

End Entity Bitmap;

Architecture rtl Of Bitmap Is
----------------------------------------------------------------------------------
-- Component declaration
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------

    signal  rRxFfWrData     :   std_logic_vector(7 downto 0); -- input data
    signal  rDataOutToFf    :   std_logic_vector(31 downto 0);  -- output data
    signal  rRxFfWrEn       :   std_logic;  -- enable input
    signal  rCntData        :   std_logic_vector(5 downto 0);

Begin
----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
    DataOutToFf <= rDataOutToFf;
----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
    u_rDataOutToFf : Process(Clk) Is
    Begin
    if (rising_edge(Clk)) then
        if (RstB = '0') then
            rDataOutToFf <= (others=>'0');
        else
            if (rCntData = 53) then
                rDataOutToFf <= rRxFfWrData(7 downto 0);
            else
                rDataOutToFf <= (others=>'0');
            end if ;
        end if ;
    end if ;
    End Process u_rDataOutToFf;

    u_rRxFfWrEn : Process(Clk) Is
    Begin
    if (rising_edge(Clk)) then
        if (RstB = '0') then
            rRxFfWrEn <= '0';
        else
            if (rRxFfWrData(0) = '0') then
                rRxFfWrEn <= '1';
            else
                 rRxFfWrEn <= rRxFfWrEn;
            end if ;
        end if ;
    end if ;
    End Process u_rRxFfWrEn;
    
    u_rCntData : Process(Clk) Is
    Begin
    if (rising_edge(Clk)) then
        if (RstB = '0') then
            rCntData <= (others=>'0');
        else
            if (rRxFfWrData(0) = '0' and rRxFfWrEn = '1') then
                if (rCntData = 53) then
                     rCntData <= (others=>'0');
                else
                    if (rCntData <= 786431) then
                        rCntData <= rCntData + 1;
                    else
                        rCntData <= rCntData;
                    end if ;
            else
                rCntData <= (others=>'0');
            end if ;
        end if ;
    end if ;
    end if;
    End Process u_rCntData;

    
End Architecture rtl;