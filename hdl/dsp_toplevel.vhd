-- Toplevel entity for DSP
-- Constants are set here

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity dsp_toplevel is

-- set generics here
generic (
  NUM_MULTIPLIERS : integer := 128;
  FIFO_LENGTH : integer := 100
);

port (
  signal clock : in std_logic;
  signal reset_n : in std_logic;
  
  -- Connected to the exterior : Avalon master & slave interfaces

  -- avalon mm master
  signal ma_address        : out std_logic_vector(31 downto 0);
  signal ma_read           : out std_logic;
  signal ma_write          : out std_logic;
  signal ma_burstcount     : out std_logic_vector(15 downto 0);
  signal ma_writedata      : out std_logic_vector(31 downto 0);
  signal ma_waitrequest    : in std_logic;
  signal ma_readdata       : in std_logic_vector(31 downto 0);
  signal ma_readdatavalid  : in std_logic;

  -- Avalon slave
  
  signal sl_address : in std_logic_vector(7 downto 0);
  signal sl_data_in : in std_logic_vector(31 downto 0);
  signal sl_data_out : out std_logic_vector(31 downto 0);
  
  signal sl_waitrequest : out std_logic;
  
  signal sl_read : in std_logic;
  signal sl_write : in std_logic
  
);

end entity dsp_toplevel;

architecture master of dsp_toplevel is
component dma is 
port(
  signal clock               : in std_logic;
  signal reset_n           : in std_logic;

  -- avalon mm master
  signal ma_address        : out std_logic_vector(31 downto 0);
  signal ma_read           : out std_logic;
  signal ma_write          : out std_logic;
  signal ma_burstcount     : out std_logic_vector(15 downto 0);
  signal ma_writedata      : out std_logic_vector(31 downto 0);
  signal ma_waitrequest    : in std_logic;
  signal ma_readdata       : in std_logic_vector(31 downto 0);
  signal ma_readdatavalid  : in std_logic;

  signal coef_out          : out std_logic_vector(17 downto 0);
  signal coef_valid        : out std_logic;
  signal sig_out           : out std_logic_vector(15 downto 0);
  signal sig_valid         : out std_logic;
  signal sig_written       : out std_logic;
  signal data_in           : in unsigned(31 downto 0); -- from data path
  
  -- These count how many bytes the client module wants to see transferred
  -- from/to it
  signal coef_out_count    : in unsigned(15 downto 0); -- counts coef_out
  signal sig_out_count    : in unsigned(15 downto 0); -- counts sig_out
  signal data_in_count     : in unsigned(15 downto 0); -- counts data_in
  
  signal coef_query        : in std_logic;
  signal sig_query         : in std_logic;
  signal write_query       : in std_logic;
  
  signal baseCoefAddress   : in unsigned(31 downto 0);
  signal baseSignalAddress : in unsigned(31 downto 0);
  signal baseOutputAddress : in unsigned(31 downto 0)
     
);
end component dma;

component avalon_slave is 

port(
  signal clock : in std_logic;
  signal reset_n : in std_logic;
  
  signal sl_address : in std_logic_vector(7 downto 0);
  signal sl_data_in : in std_logic_vector(31 downto 0);
  signal sl_data_out : out std_logic_vector(31 downto 0);
  signal sl_waitrequest : out std_logic;
  signal sl_read : in std_logic;
  signal sl_write : in std_logic;
  
  -- Registers fanout

  signal reg_dataInAddr : out std_logic_vector(31 downto 0);
  signal reg_coefsInAddr : out std_logic_vector(31 downto 0);
  signal reg_dataOutAddr : out std_logic_vector(31 downto 0);
  
  signal reg_dataLength : out std_logic_vector(31 downto 0);
  signal reg_coefsLength : out std_logic_vector(31 downto 0)
  
);

-- Insert here DSP core

end component avalon_slave;

signal reg_dataInAddr : std_logic_vector(31 downto 0);
signal reg_coefsInAddr : std_logic_vector(31 downto 0);
signal reg_dataOutAddr : std_logic_vector(31 downto 0);

-- DMA / Core communication
signal coef_dma2core     : std_logic_vector(17 downto 0);
signal coef_valid        : std_logic;
signal sig_dma2core      : std_logic_vector(15 downto 0);
signal sig_valid         : std_logic;
signal sig_written       : std_logic;
signal data_core2dma     : unsigned(31 downto 0); -- from data path

signal coef_count    :  unsigned(15 downto 0) := to_unsigned(0, 16); -- counts coef_out
signal data_dma2core_count    :  unsigned(15 downto 0) := to_unsigned(0, 16); -- counts data_out
signal data_core2dma_count    :  unsigned(15 downto 0) := to_unsigned(0, 16); -- counts data_in

component dspcore is
port(
  signal clock : in std_logic;
  signal reset_n : in std_logic;
  
  signal coef_in          : in std_logic_vector(17 downto 0);
  signal coef_valid        : in std_logic;
  signal sig_in           : in std_logic_vector(15 downto 0);
  signal sig_valid         : in std_logic;
  signal sig_written       : in std_logic;
  signal data_out           : out unsigned(31 downto 0); -- from data path
  
  signal coef_in_count    : in unsigned(15 downto 0); -- counts coef_out
  signal data_in_count    : in unsigned(15 downto 0); -- counts data_out
  signal data_out_count     : out unsigned(15 downto 0) -- counts data_in
  
);

end component dspcore;

begin

amaster : dma port map (
  clock             => clock, 
  reset_n           => reset_n, 

  -- avalon mm master
  ma_address        => ma_address, 
  ma_read           => ma_read, 
  ma_write          => ma_write, 
  ma_burstcount     => ma_burstcount, 
  ma_writedata      => ma_writedata, 
  ma_waitrequest    => ma_waitrequest, 
  ma_readdata       => ma_readdata, 
  ma_readdatavalid  => ma_readdatavalid, 

  -- Registers set at the slave
  baseCoefAddress   => unsigned(reg_coefsInAddr), 
  baseSignalAddress => unsigned(reg_dataInAddr), 
  baseOutputAddress => unsigned(reg_dataOutAddr), 

  -- Interface with the DSP core
  coef_out          => coef_dma2core, 
  coef_valid        => coef_valid, 
  sig_out           => sig_dma2core, 
  sig_valid         => sig_valid, 
  sig_written       => sig_written, 
  data_in           => data_core2dma, 
  
  -- These count how many bytes the client module wants to see transferred
  -- from/to it
  coef_out_count    => coef_count, 
  sig_out_count     => data_core2dma_count, 
  data_in_count     => data_dma2core_count,

  coef_query        => '0',
  sig_query         => '0',
  write_query       => '0'
);

-- Avalon slave

avslave : avalon_slave port map (
  clock             => clock, 
  reset_n           => reset_n, 
  
  -- avalon slave signals
  sl_address           => sl_address, 
  sl_data_in           => sl_data_in, 
  sl_data_out          => sl_data_out, 
  sl_waitrequest       => sl_waitrequest, 
  sl_read              => sl_read, 
  sl_write             => sl_write, 
  
  -- Registers fanout

  reg_dataInAddr => reg_dataInAddr, 
  reg_coefsInAddr => reg_coefsInAddr, 
  reg_dataOutAddr => reg_dataOutAddr
);


-- DSP block core

core : dspcore port map (
  clock => clock,
  reset_n => reset_n,
  
  coef_in => coef_dma2core,
  coef_valid => coef_valid,
  sig_in => sig_dma2core,
  sig_valid => sig_valid,
  sig_written => sig_written,
  data_out => data_core2dma,
  
  coef_in_count => coef_count,
  data_in_count => data_core2dma_count,
  data_out_count => data_dma2core_count
  
);


end architecture master;
