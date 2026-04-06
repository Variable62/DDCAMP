library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity RxSerial Is
Port(
    RstB        : in    std_logic;
    Clk         : in    std_logic;
    
    SerDataIn   : in    std_logic;

    RxFfFull    : in    std_logic;
    RxFfWrData  : out   std_logic_vector(7 downto 0);
    RxFfWrEn    : out   std_logic
);
End Entity RxSerial;

Architecture rtl Of RxSerial Is
----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------
constant cBuadrate : integer := 868;

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
type    SerStateType  is
            (
                stIdle,
                stWrReq ,
                stWtEnd
            );

signal  rState        :   SerStateType    ;
        
signal rSerDataIn   : std_logic_vector(9 downto 0);
signal rRxFfWrEn    : std_logic;
signal rRxFfWrData  : std_logic_vector(7 downto 0);
signal rBuadCnt     : std_logic_vector(9 downto 0);
signal rRxFfFull    : std_logic;  -- This local signal is driven by u_rRxFfFull
signal rDataCnt     : std_logic_vector(3 downto 0);

Begin
----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
    RxFfWrEn   <= rRxFfWrEn;
    RxFfWrData <= rRxFfWrData;

    u_rState : Process(Clk) Is
    begin
        if (rising_edge(Clk)) then
            if (RstB = '0' ) then
                rState <= stIdle;
            else
                case (rState) is
                    when stIdle =>
                        if (SerDataIn = '0') then
                            rState <= stWrReq;
                        else
                            rState <= stIdle;
                        end if ;
                    
                    when stWrReq =>
                        -- Wait for 10 bits and check if FIFO is not full
                        -- This now reads the CORRECTED local rRxFfFull signal
                        if (rRxFfFull = '0' and rDataCnt = 10) then
                            rState <= stWtEnd;
                        else
                            rState <= stWrReq;
                        end if ;

                    when stWtEnd =>
                        -- Wait for the write enable to pulse
                        if (rRxFfWrEn = '1' and rDataCnt = 10) then
                            rState <= stIdle;
                        else
                            rState <= stWtEnd;
                        end if ;

                    when others => rState <= stIdle;
                end case;
            end if ;
        end if ;
    End Process u_rState;

    u_rBuadCnt : Process(Clk) Is
    begin
        if (rising_edge(Clk)) then
            if (RstB = '0') then
                rBuadCnt <= conv_std_logic_vector(cBuadrate,10);
            else
                -- **FIXED**: Reset counter when idle
                if (rState = stIdle) then
                    rBuadCnt <= conv_std_logic_vector(cBuadrate,10);
                
                -- **FIXED**: Keep counting in stWtEnd to prevent deadlock
                elsif (rState = stWrReq or rState = stWtEnd) then
                    if (rBuadCnt /= 1) then
                        rBuadCnt <= rBuadCnt - 1;
                    else
                        rBuadCnt <= conv_std_logic_vector(cBuadrate,10);
                    end if;
                end if ;
            end if ;
        end if ;
    End Process u_rBuadCnt;

    u_rDataCnt : Process(Clk) Is
        begin
            if (rising_edge(Clk)) then
                if (RstB = '0') then
                    rDataCnt <= (others=>'0');
                else
                    if (rState = stIdle) then
                        rDataCnt <= (others=>'0');
                    -- Only count when in the receiving state
                    elsif (rState = stWrReq) then
                        -- Increment on the tick *before* baud counter reload
                        if (rBuadCnt = 2 and rDataCnt < 10) then
                            rDataCnt <= rDataCnt + 1;
                        end if ;
                    end if ;
                end if ;
            end if ;
        End Process u_rDataCnt;

    u_rSerDataIn : Process (Clk)
    Begin
        if ( rising_edge(Clk) ) then
            if (RstB = '0') then
                rSerDataIn(9 downto 0) <= (others => '0');
            else
                if (rState = stWrReq) then
                    -- Sample at bit midpoint (cBuadrate / 2)
                    if (rBuadCnt = 434) then
                        rSerDataIn(8 downto 0) <= rSerDataIn(9 downto 1);
                        rSerDataIn(9)          <= SerDataIn;
                    end if;
                elsif (rState = stIdle) then
                    rSerDataIn(9 downto 0) <= (others => '0');
                end if;
            end if;
        end if;
    End Process u_rSerDataIn;

    u_rRxFfWrEn : Process(Clk) IS
        begin
            if (rising_edge(Clk)) then
                if (RstB = '0') then
                    rRxFfWrEn <= '0';
                else
                    -- This logic is correct
                    if (rBuadCnt = 1 and rDataCnt = 10) then
                        rRxFfWrEn <= '1';
                    else
                        rRxFfWrEn <= '0';
                    end if;
                end if ;
            end if;
        End Process u_rRxFfWrEn;

    u_rRxFfWrData : Process(Clk) Is
        begin
            if (rising_edge(Clk)) then
                if (RstB = '0') then
                    rRxFfWrData <= (others=>'0');
                else
                    -- This logic is correct
                    if (rBuadCnt = 1 and rDataCnt = 10) then
                        rRxFfWrData <= rSerDataIn(8 downto 1);
                    else
                        rRxFfWrData <= (others=>'0');
                    end if ;
                end if ;
            end if ;
        End Process u_rRxFfWrData;

    u_rRxFfFull : Process(Clk) Is
        begin
            if (rising_edge(Clk)) then
                if (RstB = '0') then
                    rRxFfFull <= '1';
                else
                    -- **FIXED**: This process now correctly registers
                    -- the RxFfFull INPUT PORT into the local rRxFfFull signal.
                    rRxFfFull <= RxFfFull;
                end if ;
            end if ;
        End Process u_rRxFfFull;

End Architecture rtl;