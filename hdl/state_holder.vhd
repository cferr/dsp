-- State holders for DSP block
-- This block holds the current filter state, namely, L output samples where
-- L is the filter length. If we call M the overlap length, then the last M
-- samples will be reinjected in the path at the next iteration.
-- The other samples will be sent to DMA for writeback, and are held here 
-- while waiting.
-- Author: C. Ferry
-- Date: May 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.dsp_utils.all;

entity state_holder is

generic(
  FILTER_BLOCK_LENGTH : positive := 25;
  OVERLAP_LENGTH      : positive := 5; -- the last coefficients that will be added to the next part
  SAMPLE_LENGTH       : positive := 64
);

port (
  clock             : in std_logic;
  reset_n           : in std_logic;
  
  -- Entering data
  data_in           : in signed(SAMPLE_LENGTH - 1 downto 0); 
  data_in_valid     : in std_logic;  -- inhibit signal
  
  -- Towards overlap-add
  data_out_return   : out signed(SAMPLE_LENGTH - 1 downto 0);
  
  -- Towards DMA
  data_out_finished : out signed(SAMPLE_LENGTH - 1 downto 0);
  dma_request       : out std_logic; -- when we need to write the samples back
  dma_written       : in std_logic -- when a sample has been written back (whether it is in a fifo or elsewhere)
);
end entity state_holder;

architecture master of state_holder is

type filterStateT is array(OVERLAP_LENGTH - 1 downto 0) of signed(SAMPLE_LENGTH - 1 downto 0);
signal filterState : filterStateT; -- comprises Ovlap part + computed part

signal counter : integer range 0 to FILTER_BLOCK_LENGTH - 1; 


-- The coefficients that have been done wait in a FIFO. As soon as there is one
-- word in the FIFO, we want to push it back to DMA - we thus raise a flag and
-- peacefully wait for our turn to come.

-- DMA wants to push words to memory in a RIFF fashion. Thus, it does a round
-- robin over all the states, taking one sample at each round.

signal dmaGetFromFifo : std_logic;
signal dmaPushToFifo  : std_logic;
signal fifoEmpty : std_logic;

signal dataToFifo : signed(SAMPLE_LENGTH - 1 downto 0);

signal dmaWaitWrite : std_logic;
signal fifo_data_out_q : std_logic_vector(SAMPLE_LENGTH - 1 downto 0);

begin

pushbackFifo : fifo generic map (
    FIFO_WIDTH => SAMPLE_LENGTH,
    NUM_WORDS_LOG2 => 7,
    NUM_WORDS => 128
) port map (
    clock => clock,
    data => std_logic_vector(dataToFifo),
    rdreq => dmaGetFromFifo,
    sclr => not reset_n,
    wrreq => dmaPushToFifo,
    empty => fifoEmpty,
    full => open,
    q => fifo_data_out_q,
    usedw => open
);

data_out_finished <= signed(fifo_data_out_q);

writeToState : process(clock, reset_n)
begin
  -- When receiving some data through data_in, write it to the state.
  -- Increase the counter at the same time (this one indicates which value we
  -- are writing to, and at the same time which value we are passing back to the
  -- pipeline
  if reset_n = '0' then
    dmaPushToFifo <= '0';
    dataToFifo <= (others => '0');
    filterState <= (others => to_signed(0, SAMPLE_LENGTH));
  elsif rising_edge(clock) then
    dmaPushToFifo <= '0';
    if data_in_valid = '1' then
      if counter < FILTER_BLOCK_LENGTH - OVERLAP_LENGTH then
        dataToFifo <= data_in;
        dmaPushToFifo <= '1';
      else
        filterState(counter - FILTER_BLOCK_LENGTH) <= data_in; -- TODO fix the counter here
      end if;
      counter <= counter + 1;
    end if;
  end if;
end process writeToState;

dmaWriteBack : process(clock, reset_n)
begin
  if reset_n = '0' then
    dmaGetFromFifo <= '0';
    dmaWaitWrite <= '0';
  elsif rising_edge(clock) then
    if dmaWaitWrite = '0' and fifoEmpty = '0' then
      dmaGetFromFifo <= '1';
      dma_request <= '1';
      dmaWaitWrite <= '1';
    end if;
    if dma_written = '1' then
      dmaWaitWrite <= '0';
    end if;
  end if;
end process dmaWriteBack;


sendCurrentOverlap : process(reset_n)
begin
  -- Combinatorial circuit to send the current value of the overlap part back
  -- to the pipeline (first OVERLAP_LENGTH samples)
  if counter < OVERLAP_LENGTH then
    data_out_return <= filterState(counter);
  else
    data_out_return <= (others => '0'); -- no need to overlap in such cases
  end if;
end process sendCurrentOverlap;

end architecture master;