-- #############################################################################
-- DE1_SoC_top_level.vhd
--
-- BOARD         : DE1-SoC from Terasic
-- Author        : Sahand Kashani-Akhavan from Terasic documentation
-- Revision      : 1.5
-- Creation date : 04/02/2015
--
-- Syntax Rule : GROUP_NAME_N[bit]
--
-- GROUP  : specify a particular interface (ex: SDR_)
-- NAME   : signal name (ex: CONFIG, D, ...)
-- bit    : signal index
-- _N     : to specify an active-low signal
-- #############################################################################

library ieee;
use ieee.std_logic_1164.all;

entity DE1_SoC_top_level is
    port(
        -- ADC
     -- ADC_CS_n : out std_logic;
     -- ADC_DIN  : out std_logic;
     -- ADC_DOUT : in  std_logic;
     -- ADC_SCLK : out std_logic;

        -- Audio
        AUD_ADCDAT  : in    std_logic;
        AUD_ADCLRCK : inout std_logic;
        AUD_BCLK    : inout std_logic;
        AUD_DACDAT  : out   std_logic;
        AUD_DACLRCK : inout std_logic;
        AUD_XCK     : out   std_logic;

        -- CLOCK
        CLOCK_50 : in std_logic;
     -- CLOCK2_50        : in    std_logic;
     -- CLOCK3_50        : in    std_logic;
     -- CLOCK4_50        : in    std_logic;

        -- SDRAM
     -- DRAM_ADDR        : out   std_logic_vector(12 downto 0);
     -- DRAM_BA          : out   std_logic_vector(1 downto 0);
     -- DRAM_CAS_N       : out   std_logic;
     -- DRAM_CKE         : out   std_logic;
     -- DRAM_CLK         : out   std_logic;
     -- DRAM_CS_N        : out   std_logic;
     -- DRAM_DQ          : inout std_logic_vector(15 downto 0);
     -- DRAM_LDQM        : out   std_logic;
     -- DRAM_RAS_N       : out   std_logic;
     -- DRAM_UDQM        : out   std_logic;
     -- DRAM_WE_N        : out   std_logic;

        -- I2C for Audio and Video-In
        FPGA_I2C_SCLK : out   std_logic;
        FPGA_I2C_SDAT : inout std_logic;

        -- SEG7
     -- HEX0_N           : out   std_logic_vector(6 downto 0);
     -- HEX1_N           : out   std_logic_vector(6 downto 0);
     -- HEX2_N           : out   std_logic_vector(6 downto 0);
     -- HEX3_N           : out   std_logic_vector(6 downto 0);
     -- HEX4_N           : out   std_logic_vector(6 downto 0);
     -- HEX5_N           : out   std_logic_vector(6 downto 0);

        -- IR
     -- IRDA_RXD         : in    std_logic;
     -- IRDA_TXD         : out   std_logic;

        -- KEY_N
        KEY_N : in std_logic_vector(3 downto 0);

        -- LED
     -- LEDR : out std_logic_vector(9 downto 0);

        -- PS2
     -- PS2_CLK          : inout std_logic;
     -- PS2_CLK2         : inout std_logic;
     -- PS2_DAT          : inout std_logic;
     -- PS2_DAT2         : inout std_logic;

        -- SW
     -- SW : in std_logic_vector(9 downto 0);

        -- Video-In
     -- TD_CLK27         : inout std_logic;
     -- TD_DATA          : out   std_logic_vector(7 downto 0);
     -- TD_HS            : out   std_logic;
     -- TD_RESET_N       : out   std_logic;
     -- TD_VS            : out   std_logic;

        -- VGA
     -- VGA_B            : out   std_logic_vector(7 downto 0);
     -- VGA_BLANK_N      : out   std_logic;
     -- VGA_CLK          : out   std_logic;
     -- VGA_G            : out   std_logic_vector(7 downto 0);
     -- VGA_HS           : out   std_logic;
     -- VGA_R            : out   std_logic_vector(7 downto 0);
     -- VGA_SYNC_N       : out   std_logic;
     -- VGA_VS           : out   std_logic;

        -- GPIO_0
     -- GPIO_0 : inout std_logic_vector(35 downto 0);

        -- GPIO_1
     -- GPIO_1           : inout std_logic_vector(35 downto 0);

        -- HPS
        HPS_CONV_USB_N   : inout std_logic;
        HPS_DDR3_ADDR    : out   std_logic_vector(14 downto 0);
        HPS_DDR3_BA      : out   std_logic_vector(2 downto 0);
        HPS_DDR3_CAS_N   : out   std_logic;
        HPS_DDR3_CK_N    : out   std_logic;
        HPS_DDR3_CK_P    : out   std_logic;
        HPS_DDR3_CKE     : out   std_logic;
        HPS_DDR3_CS_N    : out   std_logic;
        HPS_DDR3_DM      : out   std_logic_vector(3 downto 0);
        HPS_DDR3_DQ      : inout std_logic_vector(31 downto 0);
        HPS_DDR3_DQS_N   : inout std_logic_vector(3 downto 0);
        HPS_DDR3_DQS_P   : inout std_logic_vector(3 downto 0);
        HPS_DDR3_ODT     : out   std_logic;
        HPS_DDR3_RAS_N   : out   std_logic;
        HPS_DDR3_RESET_N : out   std_logic;
        HPS_DDR3_RZQ     : in    std_logic;
        HPS_DDR3_WE_N    : out   std_logic;
        HPS_ENET_GTX_CLK : out   std_logic;
        HPS_ENET_INT_N   : inout std_logic;
        HPS_ENET_MDC     : out   std_logic;
        HPS_ENET_MDIO    : inout std_logic;
        HPS_ENET_RX_CLK  : in    std_logic;
        HPS_ENET_RX_DATA : in    std_logic_vector(3 downto 0);
        HPS_ENET_RX_DV   : in    std_logic;
        HPS_ENET_TX_DATA : out   std_logic_vector(3 downto 0);
        HPS_ENET_TX_EN   : out   std_logic;
        HPS_FLASH_DATA   : inout std_logic_vector(3 downto 0);
        HPS_FLASH_DCLK   : out   std_logic;
        HPS_FLASH_NCSO   : out   std_logic;
        HPS_GSENSOR_INT  : inout std_logic;
        HPS_I2C_CONTROL  : inout std_logic;
        HPS_I2C1_SCLK    : inout std_logic;
        HPS_I2C1_SDAT    : inout std_logic;
        HPS_I2C2_SCLK    : inout std_logic;
        HPS_I2C2_SDAT    : inout std_logic;
        HPS_KEY_N        : inout std_logic;
        HPS_LED          : inout std_logic;
        HPS_LTC_GPIO     : inout std_logic;
        HPS_SD_CLK       : out   std_logic;
        HPS_SD_CMD       : inout std_logic;
        HPS_SD_DATA      : inout std_logic_vector(3 downto 0);
        HPS_SPIM_CLK     : out   std_logic;
        HPS_SPIM_MISO    : in    std_logic;
        HPS_SPIM_MOSI    : out   std_logic;
        HPS_SPIM_SS      : inout std_logic;
        HPS_UART_RX      : in    std_logic;
        HPS_UART_TX      : out   std_logic;
        HPS_USB_CLKOUT   : in    std_logic;
        HPS_USB_DATA     : inout std_logic_vector(7 downto 0);
        HPS_USB_DIR      : in    std_logic;
        HPS_USB_NXT      : in    std_logic;
        HPS_USB_STP      : out   std_logic
    );
end entity DE1_SoC_top_level;

architecture rtl of DE1_SoC_top_level is


component system is
        port (
                clk_clk            : in    std_logic                     := '0';             --    clk.clk
                memory_mem_a       : out   std_logic_vector(12 downto 0);                    -- memory.mem_a
                memory_mem_ba      : out   std_logic_vector(2 downto 0);                     --       .mem_ba
                memory_mem_ck      : out   std_logic;                                        --       .mem_ck
                memory_mem_ck_n    : out   std_logic;                                        --       .mem_ck_n
                memory_mem_cke     : out   std_logic;                                        --       .mem_cke
                memory_mem_cs_n    : out   std_logic;                                        --       .mem_cs_n
                memory_mem_ras_n   : out   std_logic;                                        --       .mem_ras_n
                memory_mem_cas_n   : out   std_logic;                                        --       .mem_cas_n
                memory_mem_we_n    : out   std_logic;                                        --       .mem_we_n
                memory_mem_reset_n : out   std_logic;                                        --       .mem_reset_n
                memory_mem_dq      : inout std_logic_vector(7 downto 0)  := (others => '0'); --       .mem_dq
                memory_mem_dqs     : inout std_logic                     := '0';             --       .mem_dqs
                memory_mem_dqs_n   : inout std_logic                     := '0';             --       .mem_dqs_n
                memory_mem_odt     : out   std_logic;                                        --       .mem_odt
                memory_mem_dm      : out   std_logic;                                        --       .mem_dm
                memory_oct_rzqin   : in    std_logic                     := '0';             --       .oct_rzqin
                reset_reset_n      : in    std_logic                     := '0'              --  reset.reset_n
        );
end component system;

begin

-- TODO why are these here ?
HPS_DDR3_ADDR(14 downto 13) <= (others => '0');
HPS_DDR3_DQ(31 downto 8)  <= (others => '0');

sys: system port map (
                clk_clk            => CLOCK_50,
                memory_mem_a       => HPS_DDR3_ADDR(12 downto 0),
                memory_mem_ba      => HPS_DDR3_BA,
                memory_mem_ck      => open,
                memory_mem_ck_n    => HPS_DDR3_CK_N,
                memory_mem_cke     => HPS_DDR3_CKE,
                memory_mem_cs_n    => HPS_DDR3_CS_N,
                memory_mem_ras_n   => HPS_DDR3_RAS_N,
                memory_mem_cas_n   => HPS_DDR3_CAS_N,
                memory_mem_we_n    => HPS_DDR3_WE_N,
                memory_mem_reset_n => HPS_DDR3_RESET_N,
                memory_mem_dq      => HPS_DDR3_DQ(7 downto 0),
                memory_mem_dqs     => HPS_DDR3_DQS_P(0),
                memory_mem_dqs_n   => HPS_DDR3_DQS_N(0),
                memory_mem_odt     => HPS_DDR3_ODT,
                memory_mem_dm      => HPS_DDR3_DM(0),
                memory_oct_rzqin   => HPS_DDR3_RZQ,
                reset_reset_n      => KEY_N(0)
        );

    GPIO_0(0)  <= '0';
    GPIO_0(1)  <= '0';
    GPIO_0(2)  <= '0';
    GPIO_0(3)  <= '0';
    GPIO_0(4)  <= '0';
    GPIO_0(5)  <= '0';
    GPIO_0(6)  <= '0';
    GPIO_0(7)  <= '0';
    GPIO_0(9)  <= '0';
    GPIO_0(30) <= '0';
    GPIO_0(31) <= '0';
    GPIO_0(32) <= '0';
    GPIO_0(33) <= '0';
    GPIO_0(34) <= '0';
    GPIO_0(35) <= '0';

end;
