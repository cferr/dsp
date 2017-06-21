-- Toplevel for computational part (core)
-- Author: C. Ferry
-- Date: May 2017

-- Combinatorial calcualtion part + Synchronous pipeline management
-- Input 1 : Samples (go to FIFOs then to multipliers)
-- Input 2 : Coefficients (from DMA; add a fifo if necessary or some buffer)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.dsp_utils.all;

entity dspcore is
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

end entity dspcore;

architecture master of dspcore is


signal fifo_to_mult_data : fifo_to_mult_dataT := (others => (others => '0'));

signal mult_samples : mult_samplesT := (others => to_signed(0, INPUT_SIGNAL_WIDTH));
signal mult_accum : mult_accumT := (others => to_signed(0, RESULT_WIDTH));

signal mux_to_state_holder : mux_to_state_holderT := (others => to_signed(0, RESULT_WIDTH));
signal state_holder_to_mux : mux_to_state_holderT := (others => to_signed(0, RESULT_WIDTH)); -- communication is bidirectional, samples are reinjected

signal mux_to_state_holder_valid : mux_to_state_holder_validT := (others => '0');

signal mult_to_mux : mult_to_muxT := (others => to_signed(0, RESULT_WIDTH));
signal mux_to_mult : mult_to_muxT := (others => to_signed(0, RESULT_WIDTH)); -- bidirectional communication again

signal fifo_pullreq : std_logic_vector(NUM_PIPELINES-1 downto 0) := (others => '0');
signal fifo_wrreq : std_logic_vector(NUM_PIPELINES-1 downto 0) := (others => '0'); -- we push samples one by one

signal count : integer range 0 to NUM_CHANNELS - 1 := 0;
signal count_fifo : integer range 0 to NUM_PIPELINES - 1 := 0;

signal wayback_output : mult_accumT := (others => to_signed(0, RESULT_WIDTH));

begin

-- Generate the channel counter here

channel_cpt : channel_counter generic map (
  NUM_CHANNELS => NUM_CHANNELS
) port map (
  clock => clock,
  reset_n => reset_n,
  
  inhibit => '0', -- todo
  
  output => count
  
);

gen_state_holders : for i in 0 to NUM_CHANNELS - 1 generate
  
  state_holder_i : state_holder generic map (
    FILTER_BLOCK_LENGTH => FILTER_BLOCK_LENGTH,
    OVERLAP_LENGTH      => OVERLAP_LENGTH -- the last coefficients that will be added to the next part
  ) port map (
    clock => clock,
    reset_n => reset_n,
    data_in => mux_to_state_holder(i),
    data_in_valid => mux_to_state_holder_valid(i),
    data_out_return => state_holder_to_mux(i),
    data_out_finished => open, --TODO connect to DMA
    dma_request => open,-- when we need to write the samples back
    dma_written => '0' -- when a sample has been written back (whether it is in a fifo or elsewhere)
  );
end generate gen_state_holders;

gen1: for i in 0 to NUM_PIPELINES - 1 generate
  -- generate one fifo here

  fifo_i : fifo generic map (
    FIFO_WIDTH => INPUT_SIGNAL_WIDTH,
    NUM_WORDS_LOG2 => INPUT_FIFO_NUM_WORDS_LOG2,
    NUM_WORDS => INPUT_FIFO_NUM_WORDS
  ) port map (
    clock => clock,
    data => sig_in,
    rdreq => fifo_pullreq(i),
    sclr => not reset_n,
    wrreq => fifo_wrreq(i),
    empty => open,
    full => open,
    q => fifo_to_mult_data(i),
    usedw => open -- TODO see if we use this
  );
  
  -- Wayback from state
  
  state_wayback_i : state_to_mult generic map (
    RESULT_WIDTH => RESULT_WIDTH,
    NUM_PIPELINES => NUM_PIPELINES, -- number of fifos thus number of pipelines
    NUM_CHANNELS => NUM_CHANNELS,
    CHANNEL_COUNTER_WIDTH => CHANNEL_COUNTER_WIDTH -- 6 bits => up to 64 channels @ once
  ) port map (
    -- No need for clocks here; everything is asynchronous, this is just wiring
    sel => std_logic_vector(to_unsigned(count, CHANNEL_COUNTER_WIDTH)), 
    input => to_std_logic_vector(state_holder_to_mux),
    output => mult_accum(i)
  );
  
  -- Begin pipeline

  multadd_i0 : mult_block port map (
    clock => clock,
    reset_n => reset_n,
    
    inputVal => signed(fifo_to_mult_data(i)),
    accumulator => mux_to_mult(i), -- overlap-add
    coefficient => signed(coef_in), -- TODO connect to dma or fifo
    -- todo add an input enable signal
    inputRepet => mult_samples(i + NUM_PIPELINES +j),
    outputVal => mult_accum(i + NUM_PIPELINES +j)
  );

  gen2:  for j in 1 to FILTER_BLOCK_LENGTH -2 generate
      -- Generate multiplier/adder
      -- Connect it to :
      --  - its predecessor in the pipeline (1 cycle before, we have no choice)
      --    (whether it be the state holder or 
      --  - a coefficient input (the big inverse mux in link with the channel counter)
      --  - if it's the last one in the chain, to the appropriate state holder
      --    (through an inverse mux)
    multadd_ij : mult_block port map (
      clock => clock,
      reset_n => reset_n,
      
      inputVal => mult_samples(i + NUM_PIPELINES * j),
      accumulator => mult_accum(i + NUM_PIPELINES * j),
      coefficient => signed(coef_in), -- TODO connect to dma or fifo
      -- add an input enable signal
      inputRepet => mult_samples(i + NUM_PIPELINES * (j + 1)),
      outputVal => mult_accum(i + NUM_PIPELINES * (j + 1))
    );
  end generate gen2;

  -- Last multiplier : connected to some inv mux
  multadd_iN : mult_block port map (
    clock => clock,
    reset_n => reset_n,
    
    inputVal => mult_samples(i * NUM_PIPELINES + FILTER_BLOCK_LENGTH - 1), -- fixme
    accumulator => mult_accum(i * NUM_PIPELINES + FILTER_BLOCK_LENGTH - 1),
    coefficient => signed(coef_in), -- TODO connect to dma or fifo
    -- add an input enable signal
    inputRepet => open, -- OK, we don't need the sample anymore
    outputVal => mult_to_mux(i) -- for the moment no return path
  );

  mult_to_state_i : mult_to_state generic map (
      RESULT_WIDTH => RESULT_WIDTH,
      NUM_PIPELINES => NUM_PIPELINES, -- number of fifos thus number of pipelines
      NUM_CHANNELS => NUM_CHANNELS,
      CHANNEL_COUNTER_WIDTH => CHANNEL_COUNTER_WIDTH, -- 6 bits => up to 64 channels @ once
      FILTER_BLOCK_LENGTH => FILTER_BLOCK_LENGTH
    ) port map (
      -- No need for clocks here; everything is asynchronous, this is just wiring
      sel => std_logic_vector(to_unsigned(count, CHANNEL_COUNTER_WIDTH)), -- TODO add channel counter
      input => to_std_logic_vector(mult_to_mux),
      output => open -- TODO convert the output using an extra signal and the converter function
    );
  
end generate gen1;

dispatch_dma : process(clock, reset_n)
begin
  if reset_n = '0' then
    fifo_wrreq <= (others => '0');
  elsif rising_edge(clock) then
    if sig_valid = '1' then
      fifo_wrreq <= (others => '0');
      fifo_wrreq(count_fifo) <= '1';
      
      count_fifo <= count_fifo + 1;
    else
      fifo_wrreq <= (others => '0');
    end if;
  end if;
end process;

end architecture master;
