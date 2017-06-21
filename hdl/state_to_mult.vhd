-- Dispatcher block 
-- This block goes to from state holders to multiplier chains.
-- It is used in order to reinject points in the overlap section to perform
-- overlap-add computation of the filter.
-- Author : C. Ferry
-- Date : May 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity state_to_mult is

generic(
  RESULT_WIDTH : positive := 64; 
  NUM_PIPELINES : positive := 8; -- number of fifos thus number of pipelines
  NUM_CHANNELS : positive := 48;
  CHANNEL_COUNTER_WIDTH : positive := 6 -- 6 bits => up to 64 channels @ once
);

port(
  -- No need for clocks here; everything is asynchronous, this is just wiring
  signal sel : in std_logic_vector(CHANNEL_COUNTER_WIDTH - 1 downto 0); 
  signal input : in std_logic_vector((RESULT_WIDTH * NUM_CHANNELS) - 1 downto 0);
  signal output  : out std_logic_vector((RESULT_WIDTH * NUM_PIPELINES) -1 downto 0)
);

end entity state_to_mult;

architecture master of state_to_mult is
begin

-- This avoids using a multiplier and generates as much output logic as would
-- be required by an ordinary demux
gen:
for i in 0 to NUM_PIPELINES-1 generate
  -- TODO check
  output((i + 1) * RESULT_WIDTH - 1 downto i * RESULT_WIDTH) <= 
    input(((to_integer(unsigned(sel)) * NUM_CHANNELS + i) * RESULT_WIDTH) mod NUM_PIPELINES -1 
    downto ((to_integer(unsigned(sel)) * NUM_CHANNELS + i) * RESULT_WIDTH mod NUM_PIPELINES) - RESULT_WIDTH);
end generate gen;

end architecture master;
