--Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, the Altera Quartus Prime License Agreement,
--the Altera MegaCore Function License Agreement, or other 
--applicable license agreement, including, without limitation, 
--that your use is for the sole purpose of programming logic 
--devices manufactured by Altera and sold by Altera or its 
--authorized distributors.  Please refer to the applicable 
--agreement for further details.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

entity fifo is
  generic
  (
    FIFO_WIDTH : natural;
    NUM_WORDS_LOG2 : natural;
    NUM_WORDS : natural
  );
  PORT
  (
    clock    : IN std_logic ;
    data    : IN std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    rdreq    : IN std_logic ;
    sclr    : IN std_logic ;
    wrreq    : IN std_logic ;
    empty    : OUT std_logic ;
    full    : OUT std_logic ;
    q    : OUT std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    usedw    : OUT std_logic_vector (NUM_WORDS_LOG2-1 DOWNTO 0)
  );
end fifo;


architecture syn of fifo is

signal sub_wire0  : std_logic ;
signal sub_wire1  : std_logic ;
signal sub_wire2  : std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
signal sub_wire3  : std_logic_vector (NUM_WORDS_LOG2-1 DOWNTO 0);

component scfifo
generic (
  add_ram_output_register    : string;
  intended_device_family    : string;
  lpm_numwords    : natural;
  lpm_showahead    : string;
  lpm_type    : string;
  lpm_width    : natural;
  lpm_widthu    : natural;
  overflow_checking    : string;
  underflow_checking    : string;
  use_eab    : string
);
port (
    clock  : IN std_logic ;
    data  : IN std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    rdreq  : IN std_logic ;
    sclr  : IN std_logic ;
    wrreq  : IN std_logic ;
    empty  : OUT std_logic ;
    full  : OUT std_logic ;
    q  : OUT std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    usedw  : OUT std_logic_vector (NUM_WORDS_LOG2-1 DOWNTO 0)
);
end component;

begin
  empty    <= sub_wire0;
  full    <= sub_wire1;
  q    <= sub_wire2(FIFO_WIDTH-1 DOWNTO 0);
  usedw    <= sub_wire3(NUM_WORDS_LOG2-1 DOWNTO 0);

  scfifo_component : scfifo
  generic map(
    add_ram_output_register => "OFF",
    intended_device_family => "Cyclone V",
    lpm_numwords => NUM_WORDS,
    lpm_showahead => "OFF",
    lpm_type => "scfifo",
    lpm_width => FIFO_WIDTH,
    lpm_widthu => NUM_WORDS_LOG2,
    overflow_checking => "ON",
    underflow_checking => "ON",
    use_eab => "ON"
  )
  port map (
    clock => clock,
    data => data,
    rdreq => rdreq,
    sclr => sclr,
    wrreq => wrreq,
    empty => sub_wire0,
    full => sub_wire1,
    q => sub_wire2,
    usedw => sub_wire3
  );
end syn;
