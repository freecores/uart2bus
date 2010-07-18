-----------------------------------------------------------------------------------------
-- uart top level module  
--
-----------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uartTop is
  port ( -- global signals
         clr       : in  std_logic;                     -- global reset input
         clk       : in  std_logic;                     -- global clock input
         -- uart serial signals
         serIn     : in  std_logic;                     -- serial data input
         serOut    : out std_logic;                     -- serial data output
         -- transmit and receive internal interface signals
         txData    : in  std_logic_vector(7 downto 0);  -- data byte to transmit
         newTxData : in  std_logic;                     -- asserted to indicate that there is a new data byte for transmission
         txBusy    : out std_logic;                     -- signs that transmitter is busy
         rxData    : out std_logic_vector(7 downto 0);  -- data byte received
         newRxData : out std_logic;                     -- signs that a new byte was received
         -- baud rate configuration register - see baudGen.vhd for details
         baudFreq  : in  std_logic_vector(11 downto 0); -- baud rate setting registers - see header description
         baudLimit : in  std_logic_vector(15 downto 0); -- baud rate setting registers - see header description
         baudClk   : out std_logic);                    -- 
end uartTop;

architecture Behavioral of uartTop is

  component baudGen
    port (
      clr       : in  std_logic;
      clk       : in  std_logic;
      baudFreq  : in  std_logic_vector(11 downto 0);
      baudLimit : in  std_logic_vector(15 downto 0);
      ce16      : out std_logic);
  end component;

  component uartTx
    port (
      clr : in  std_logic;
      clk : in  std_logic;
      ce16 : in  std_logic;
      txData : in  std_logic_vector(7 downto 0);
      newTxData : in  std_logic;
      serOut : out  std_logic;
      txBusy : out  std_logic);
  end component;

  component uartRx
    port (
      clr       : in  std_logic;
      clk       : in  std_logic;
      ce16      : in  std_logic;
      serIn     : in  std_logic;
      rxData    : out std_logic_vector(7 downto 0);
      newRxData : out std_logic);
  end component;

  signal ce16 : std_logic; -- clock enable at bit rate

  begin
    -- baud rate generator module
    bg : baudGen
      port map (
        clr => clr,
        clk => clk,
        baudFreq => baudFreq,
        baudLimit => baudLimit,
        ce16 => ce16);
    -- uart receiver
    ut : uartTx
      port map (
        clr => clr,
        clk => clk,
        ce16 => ce16,
        txData => txData,
        newTxData => newTxData,
        serOut => serOut,
        txBusy => txBusy);
    -- uart transmitter
    ur : uartRx
      port map (
        clr => clr,
        clk => clk,
        ce16 => ce16,
        serIn => serIn,
        rxData => rxData,
        newRxData => newRxData);
    baudClk <= ce16;
  end Behavioral;
