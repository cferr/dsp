library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package dsp_utils is

-- Component-wide constants : do not replace them by hand elsewhere in the package !

constant INPUT_SIGNAL_WIDTH : positive := 16;
constant RESULT_WIDTH : positive := 64;
constant NUM_PIPELINES : positive := 8;
constant FILTER_BLOCK_LENGTH : positive := 10;
constant OVERLAP_LENGTH : positive := 5;
constant NUM_CHANNELS : positive := 48;
constant CHANNEL_COUNTER_WIDTH : positive := 6;

-- Fifos that will contain the input coefs 
constant GCOEF_FIFO_NUM_WORDS : positive := 8;
constant GCOEF_FIFO_NUM_WORDS_LOG2 : positive := 4; -- = log2(GCOEF_FIFO_NUM_WORDS)

-- Fifos that will contain the coefficients (one in each multiplier block)
constant COEF_FIFO_NUM_WORDS : positive := 10;
constant COEF_FIFO_NUM_WORDS_LOG2 : positive := 4; -- = log2(COEF_FIFO_NUM_WORDS)

constant COEF_WIDTH : positive := 16;
constant CHANNELS_PER_PIPELINE : positive := 3;

---------------------------------- COMPONENTS ----------------------------------

component mult_block is

port (
  signal clock        : in std_logic;
  signal reset_n      : in std_logic;
  
  signal inputVal     : in signed(15 downto 0);
  signal coefficient  : in signed(17 downto 0);
  -- 17 + 15 = 32 bit for one result
  signal accumulator  : in signed(RESULT_WIDTH - 1 downto 0); -- 64-bit accumulator thus allowing up to packets of 32
  
  signal outputVal    : out signed(RESULT_WIDTH - 1 downto 0);
  signal inputRepet   : out signed(15 downto 0)
);

end component mult_block;

component state_holder is
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
  data_out_return   : out signed(SAMPLE_LENGTH - 1 downto 0) := to_signed(0, SAMPLE_LENGTH);
  
  -- Towards DMA
  data_out_finished : out signed(SAMPLE_LENGTH - 1 downto 0) := to_signed(0, SAMPLE_LENGTH);
  dma_request       : out std_logic; -- when we need to write the samples back
  dma_written       : in std_logic -- when a sample has been written back (whether it is in a fifo or elsewhere)
);
end component state_holder;

component fifo is
generic
(
    FIFO_WIDTH : natural; -- FIFO_WIDTH = sample width + enough bits for pass index
    NUM_WORDS_LOG2 : natural;
    NUM_WORDS : natural
);
PORT
(
    clock           : in std_logic ;
    data            : in std_logic_vector (FIFO_WIDTH-1 downto 0);
    rdreq           : in std_logic ;
    sclr            : in std_logic ;
    wrreq           : in std_logic ;
    empty           : out std_logic ;
    full            : out std_logic ;
    q               : out std_logic_vector (FIFO_WIDTH-1 downto 0);
    usedw           : out std_logic_vector (NUM_WORDS_LOG2-1 downto 0)
);
end component fifo;

component mult_to_state is

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
  signal output : out std_logic_vector((RESULT_WIDTH * NUM_CHANNELS) - 1 downto 0);
  signal output_valid : out std_logic_vector(NUM_CHANNELS - 1 downto 0)
);

end component mult_to_state;

component channel_counter is

generic (
  NUM_CHANNELS : positive -- TODO see if this takes default values
);

port(
  signal clock : in std_logic;
  signal reset_n : in std_logic;
  signal inhibit : in std_logic;
  signal output : out integer range 0 to NUM_CHANNELS - 1
);

end component channel_counter;

component state_to_mult is

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

end component state_to_mult;


------------------------------------- TYPES ------------------------------------

-- Type for input data
type fifo_to_mult_dataT is array(NUM_PIPELINES-1 downto 0) of std_logic_vector(INPUT_SIGNAL_WIDTH - 1 downto 0);

-- These type defines wiring for the inter-multiplicator connections
type mult_samplesT is array((NUM_PIPELINES * FILTER_BLOCK_LENGTH) - 1 downto 0) of signed(INPUT_SIGNAL_WIDTH - 1 downto 0);
type mult_accumT is array((NUM_PIPELINES * FILTER_BLOCK_LENGTH) - 1 downto 0) of signed(RESULT_WIDTH - 1 downto 0);

-- Repartitor to state holder register type 
type mux_to_state_holderT is array(NUM_CHANNELS - 1 downto 0) of signed(RESULT_WIDTH - 1 downto 0);

-- Repartitor to state holder register type - Valid signals
type mux_to_state_holder_validT is array(NUM_CHANNELS - 1 downto 0) of std_logic;

-- Multiplier to repartitor register type
type mult_to_muxT is array(NUM_PIPELINES - 1 downto 0) of signed(RESULT_WIDTH - 1 downto 0);


function to_std_logic_vector(v : mult_to_muxT) return std_logic_vector;
function to_std_logic_vector(v : mux_to_state_holderT) return std_logic_vector;
function to_mux_to_state_holderT(v : std_logic_vector((RESULT_WIDTH * NUM_CHANNELS) -1 downto 0)) return mux_to_state_holderT;
function to_mult_to_muxT(v : std_logic_vector((RESULT_WIDTH * NUM_PIPELINES) -1 downto 0)) return mult_to_muxT;

end dsp_utils;

package body dsp_utils is

--------------------------- TYPE CONVERTER FUNCTIONS ---------------------------

function to_std_logic_vector(v : mult_to_muxT) return std_logic_vector is
  variable output : std_logic_vector((RESULT_WIDTH * NUM_PIPELINES) -1 downto 0);
begin
  gen: for i in 0 to NUM_PIPELINES - 1 loop
    output(RESULT_WIDTH * (i+1) - 1 downto RESULT_WIDTH * i) := std_logic_vector(v(i));
  end loop gen;
  return output;
end function to_std_logic_vector;


function to_std_logic_vector(v : mux_to_state_holderT) return std_logic_vector is
  variable output : std_logic_vector((RESULT_WIDTH * NUM_CHANNELS) -1 downto 0);
begin
  gen: for i in 0 to NUM_CHANNELS - 1 loop
    output(RESULT_WIDTH * (i+1) - 1 downto RESULT_WIDTH * i) := std_logic_vector(v(i));
  end loop gen;
  return output;
end function to_std_logic_vector;


function to_mux_to_state_holderT(v : std_logic_vector((RESULT_WIDTH * NUM_CHANNELS) -1 downto 0)) return mux_to_state_holderT is
  variable output : mux_to_state_holderT;
begin
  gen: for i in 0 to NUM_CHANNELS - 1 loop
    output(i) := signed(v((i + 1) * RESULT_WIDTH - 1 downto i * RESULT_WIDTH));
  end loop gen;
end function to_mux_to_state_holderT;


function to_mult_to_muxT(v : std_logic_vector((RESULT_WIDTH * NUM_PIPELINES) -1 downto 0)) return mult_to_muxT is
  variable output : mult_to_muxT;
begin
  gen: for i in 0 to NUM_PIPELINES - 1 loop
    output(i) := signed(v((i + 1) * RESULT_WIDTH - 1 downto i * RESULT_WIDTH));
  end loop gen;
end function to_mult_to_muxT;

end dsp_utils;
