-- Multiplier block with accumulator
-- Author: C. Ferry
-- Date: May 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.dsp_utils.all;

entity mult_block is

port (
  signal clock        : in std_logic;
  signal reset_n      : in std_logic;
  
  signal inputVal     : in signed(INPUT_SIGNAL_WIDTH-1 downto 0);
  signal coefficient  : in signed(COEF_WIDTH-1 downto 0);
  -- 17 + 15 = 32 bit for one result
  signal accumulator  : in signed(RESULT_WIDTH-1 downto 0); -- 64-bit accumulator thus allowing up to packets of 32
  
  signal outputVal    : out signed(RESULT_WIDTH-1 downto 0);
  signal inputRepet   : out signed(INPUT_SIGNAL_WIDTH-1 downto 0)
);

end entity mult_block;


architecture master of mult_block is

signal currentCoef : signed(17 downto 0);
signal dmaGetFromFifo : std_logic;
signal dmaPushToFifo : std_logic;
signal fifoEmpty : std_logic;

signal currentCoef_v : std_logic_vector(17 downto 0);
type wait_regs is array(NUM_PIPELINES-1 downto 0) of signed(RESULT_WIDTH-1 downto 0);
signal wr : wait_regs;

begin


coef_fifo : fifo generic map (
    FIFO_WIDTH => COEF_WIDTH,
    NUM_WORDS_LOG2 => COEF_FIFO_NUM_WORDS_LOG2,
    NUM_WORDS => COEF_FIFO_NUM_WORDS
) port map (
    clock => clock,
    data => std_logic_vector(coefficient),
    rdreq => dmaGetFromFifo,
    sclr => not reset_n,
    wrreq => dmaPushToFifo,
    empty => fifoEmpty,
    full => open,
    q => currentCoef_v,
    usedw => open
);

-- Type conversion is kinf od shit but we have to do this
currentCoef <= signed(currentCoef_v);


-- This is sequential ! One cycle = one multiplication cycle. If we're even
-- more unlucky, we'll have to wait for more.
-- But to keep synchronous, everybody starts at the same cycle and the
-- computation rate is the same for everyone -given by this clock.
control: process(clock, reset_n)
begin
    if reset_n = '0' then
        outputVal <= to_signed(0, RESULT_WIDTH);
        inputRepet <= to_signed(0, INPUT_SIGNAL_WIDTH);
    elsif rising_edge(clock) then
      -- if pop then
      -- end if
      -- if top then
        inputRepet <= inputVal;
        wr(0) <= accumulator + (coefficient * inputVal);
        gen_acc: for i in 0 to RESULT_WIDTH-2 generate
          wr(i+1) <= wr(i);
        end generate gen_acc;
        -- Pull the next value from the FIFO right now
      -- end if;
    end if;
end process;

outputVal <= wr(RESULT_WIDTH-1);

end architecture master;
