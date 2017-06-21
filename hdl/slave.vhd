-- Avalon slave for DSP

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity avalon_slave is

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

end entity avalon_slave;

architecture master of avalon_slave is

-- Architectural registers
signal dataInAddr : std_logic_vector(31 downto 0);
signal coefsInAddr : std_logic_vector(31 downto 0);
signal dataOutAddr : std_logic_vector(31 downto 0);

signal dataLength : std_logic_vector(31 downto 0); -- in == out
signal coefsLength : std_logic_vector(31 downto 0);

-- Status bit mapping:
-- 0 => global enable / disable
-- others => not assigned
signal status : std_logic_vector(31 downto 0);

begin

asyncRead : process(sl_address)
begin
  sl_data_out <= (others => '0');
  case to_integer(unsigned(sl_address)) is 
    when 0 => 
      sl_data_out <= status;
    when 1 => 
      sl_data_out <= dataInAddr;
    when 2 =>
      sl_data_out <= dataOutAddr;
    when 3 =>
      sl_data_out <= coefsInAddr;
    when 4 => 
      sl_data_out <= dataLength;
    when 5 => 
      sl_data_out <= coefsLength;
    when others => 
      null;
  end case;
end process asyncRead;


syncWrite : process(clock, reset_n)
begin
  if reset_n = '0' then
    status <= (others => '0');
    dataInAddr <= (others => '0');
    dataOutAddr <= (others => '0');
    coefsInAddr <= (others => '0');
    dataLength <= (others => '0');
    coefsLength <= (others => '0');
  elsif rising_edge(clock) then
    case to_integer(unsigned(sl_address)) is 
      when 0 => 
        status <= sl_data_in;
      when 1 => 
        dataInAddr <= sl_data_in;
      when 2 =>
        dataOutAddr <= sl_data_in;
      when 3 =>
        coefsInAddr <= sl_data_in;
      when 4 => 
        dataLength <= sl_data_in;
      when 5 => 
        coefsLength <= sl_data_in;
      when others => 
        null;
    end case;  
  end if;
end process;

reg_coefsInAddr <= coefsInAddr;
reg_dataOutAddr <= dataOutAddr;
reg_dataInAddr <= dataInAddr;
reg_dataLength <= dataLength;
reg_coefsLength <= coefsLength;

end architecture master;