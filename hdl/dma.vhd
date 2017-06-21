-- Shared DMA module (all channels, all coeffs => one common module to avoid
-- memory cross-traffic on bursts)
-- Author : C. Ferry
-- Date : May 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity dma is

-- Convention : IN = towards THIS MODULE (DMA)
--              OUT = towards the EXTERIOR

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

end entity dma;

architecture master of dma is

signal currentCoefAddress   : unsigned(31 downto 0);
signal currentSignalAddress : unsigned(31 downto 0);
signal currentOutputAddress : unsigned(31 downto 0);

type dma_stateT is (
  idle, initDmaRead, performDmaRead, initDmaWrite, performDmaWrite);

signal dma_state : dma_stateT;
  
type signal_dma_control_stateT is (
  idle, computeAddresses, fetch, transfer1, transfer2);

signal signal_state : signal_dma_control_stateT;
signal coefs_state : signal_dma_control_stateT;

type signal_dma_write_stateT is (
  idle, computeAddresses, write, transfer
);
signal writeback_state : signal_dma_write_stateT;

signal coefs_dma_request  : std_logic;
signal input_dma_request  : std_logic;
signal output_dma_request : std_logic;

signal priv_burstcount : unsigned(15 downto 0);
signal priv_data : std_logic_vector(31 downto 0);

signal priv_data_write : std_logic_vector(31 downto 0);

begin

dma : process(clock, reset_n)
begin
  if reset_n = '0' then
    -- 
    currentSignalAddress <= baseSignalAddress;
    priv_burstcount <= (others => '0');
    
  elsif rising_edge(clock) then
    case dma_state is
      when idle =>
        -- If one of these is up, then we will take its input burst count
        -- as the main burst counter. Thus, we should only trigger this
        -- when everything else is set
        if coefs_dma_request = '1' or input_dma_request = '1' then
          dma_state <= initDmaRead;
          priv_burstcount <= sig_out_count + coef_out_count;
        elsif output_dma_request = '1' then
          dma_state <= initDmaWrite;
          priv_burstcount <= data_in_count;
        end if;
        
      when initDmaRead =>
        -- set read only once
        ma_read <= '1';
        ma_burstcount <= std_logic_vector(priv_burstcount);
        dma_state <= performDmaRead;
        
      when performDmaRead =>
        if ma_readdatavalid = '1' then
          -- we have data; let's route it to the proper output
          priv_data <= ma_readdata;
          priv_burstcount <= priv_burstcount - 1;
          if priv_burstcount = 0 then
            dma_state <= idle;
          end if;
        end if;
      
      when initDmaWrite =>
        ma_write <= '1';
        ma_burstcount <= std_logic_vector(priv_burstcount);
        dma_state <= performDmaWrite;
        
      when performDmaWrite =>
        if ma_waitrequest = '0' then
          ma_writedata <= priv_data_write;
          priv_burstcount <= priv_burstcount - 1;
          if priv_burstcount = 0 then
            dma_state <= idle;
          end if;
        end if;
      
    end case;
    
  end if;

end process;

------ COMBINATORIAL (ASYNCHRONOUS) PROCESSES TO DRIVE THE DATA TRANSFERS ------

-- Priorities : Signal > Coefs > Writeback


fetchSignal:process(reset_n)
begin
  if reset_n = '0' then
  
  else
    case signal_state is
      when idle =>
        input_dma_request <= '0';
        if sig_query = '1' then
          input_dma_request <= '1';
          signal_state <= computeAddresses;
        end if;
        
      when computeAddresses =>
        -- Compute the address for fetching the data, i.e. it is an increment here
        if dma_state = idle then
          signal_state <= fetch;
        end if;
        
      when fetch =>
        signal_state <= transfer1;
        
      -- 32 bits = 2 * 16 bits => 2 samples !
      when transfer1 =>
        if ma_readdatavalid = '1' then
          sig_out <= priv_data(31 downto 16);
          sig_valid <= '1';
        end if;
        signal_state <= transfer2;
      
      when transfer2 =>
        if ma_readdatavalid = '1' then
          sig_out <= priv_data(15 downto 0);
          sig_valid <= '1';
        end if;
      
        signal_state <= idle;
    end case;
  end if;

end process;

fetchCoefs : process(reset_n)
begin

  if reset_n = '0' then
    
  else
    case coefs_state is
      when idle =>
        coefs_dma_request <= '0';
        if coef_query = '1' then
            coefs_dma_request <= '1';
            coefs_state <= computeAddresses;
        end if;
        
      when computeAddresses =>
        -- We can compute the addresses here and wait for the other r/w process
        -- to be completed
        
        if dma_state = idle and input_dma_request = '0' then -- our flag will be read and in the next cycle we're in coef fetch
          coefs_state <= transfer1;
        end if;
        
      when fetch =>
        
      when transfer1 =>
        if ma_readdatavalid = '1' then
          coef_out <= priv_data(17 downto 0); -- coefs are 18-bit wide !!
          coefs_state <= idle;
        end if;
        
      when transfer2 => null;
      
    end case;
  end if;

end process;

writeOutput : process(reset_n)
begin

  if reset_n = '0' then
    
  else
    case writeback_state is
      when idle =>
        output_dma_request <= '0';
        if write_query = '1' then
          writeback_state <= computeAddresses;
          output_dma_request <= '1';
        end if;
        
      when computeAddresses =>
      
      if dma_state = idle and (coefs_dma_request or input_dma_request) = '1' then
        writeback_state <= write;
      end if;
        
      when write =>
        writeback_state <= transfer;
        
      when transfer =>
        if priv_burstcount > 0 then
          priv_data_write <= std_logic_vector(data_in);
        else
          writeback_state <= idle;
        end if;
        
    end case;
  end if;

end process;

end architecture master;
