-- Dispatcher block
-- This block goes from multiplicators to state holders. The path taken by a
-- sample being independent from the channel it corresponds to, this block
-- restores the mapping.
-- Author : C. Ferry
-- Date : May 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult_to_state is
generic (
  RESULT_WIDTH : positive; 
  NUM_PIPELINES : positive; -- number of fifos thus number of pipelines
  NUM_CHANNELS : positive; -- number of channels
  CHANNEL_COUNTER_WIDTH : positive; -- 6 bits => up to 64 channels @ once
  FILTER_BLOCK_LENGTH : positive -- explicit, right ?
);
port (
  -- No need for clocks here; everything is asynchronous, this is just wiring
  signal sel : in std_logic_vector(CHANNEL_COUNTER_WIDTH - 1 downto 0); 
  signal input  : in std_logic_vector((RESULT_WIDTH * NUM_PIPELINES) -1 downto 0);
  signal output : out std_logic_vector((RESULT_WIDTH * NUM_CHANNELS) - 1 downto 0) := (others => '0');
  signal output_valid : out std_logic_vector(NUM_CHANNELS - 1 downto 0) := (others => '0')
);
end entity mult_to_state;

architecture master of mult_to_state is

type fifo_index is array(NUM_PIPELINES-1 downto 0) of integer range 0 to NUM_CHANNELS - 1;
signal ci : fifo_index;

begin

-- This avoids using a multiplier and generates as much output logic as would
-- be required by an ordinary demux
gen:
for i in 0 to NUM_PIPELINES-1 generate
  -- TODO compute inverses !!
  ci(i) <= (i + 1 + to_integer(unsigned(sel)) * FILTER_BLOCK_LENGTH) mod NUM_CHANNELS;
  --output((ci(i) * RESULT_WIDTH - 1) downto (ci(i) - 1) * RESULT_WIDTH) <= (others => '0'); --input((i+1) * RESULT_WIDTH - 1 downto i * RESULT_WIDTH);
--  output_valid(ci(i)) <= '1';
end generate gen;

output_valid <= ( (to_integer(unsigned(sel)) * FILTER_BLOCK_LENGTH + NUM_PIPELINES) mod NUM_CHANNELS downto 
    (to_integer(unsigned(sel)) * FILTER_BLOCK_LENGTH) mod NUM_CHANNELS => '1', others => '0');

end architecture master;
