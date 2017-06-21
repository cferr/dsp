-- Channel counter
-- Author : C. Ferry
-- Date : May 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity channel_counter is

generic (
  NUM_CHANNELS : positive -- TODO see if this takes default values
);

port(
  signal clock : in std_logic;
  signal reset_n : in std_logic;
  
  signal inhibit : in std_logic;
  
  signal output : out integer range 0 to NUM_CHANNELS - 1
  
);

end entity channel_counter;

architecture master of channel_counter is

signal currentChannel : integer range 0 to NUM_CHANNELS-1;

begin

roundRobin : process(clock, reset_n)
begin
  if reset_n = '0' then
    currentChannel <= 0;
  elsif rising_edge(clock) then
    currentChannel <= (currentChannel + 1) mod NUM_CHANNELS;
  end if;
end process;

end architecture master;