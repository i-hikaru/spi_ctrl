-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/03/11 19:34:13
-- Design Name: 
-- Module Name: spi_ctrl - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
-----------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.rhea_pkg.all;

entity spi_ctrl is
  port (
    -- KC705 resources
    sysclk_p       : in    std_logic;   -- 200 MHz
    sysclk_n       : in    std_logic;
    cpu_rst        : in    std_logic;
    gpio_led       : out   std_logic_vector(7 downto 0);
    gpio_dip_sw    : in    std_logic_vector(3 downto 0);
    -- PHY I/F
    phy_mdio       : inout std_logic;
    phy_mdc        : out   std_logic;
    phy_rstn       : out   std_logic;
    phy_crs        : in    std_logic;
    phy_col        : in    std_logic;
    phy_rxclk      : in    std_logic;
    phy_rxer       : in    std_logic;
    phy_rxctl_rxdv : in    std_logic;
    phy_rxd        : in    std_logic_vector(7 downto 0);
    phy_txc_gtxclk : out   std_logic;
    phy_txclk      : in    std_logic;
    phy_txer       : out   std_logic;
    phy_txctl_txen : out   std_logic;
    phy_txd        : out   std_logic_vector(7 downto 0));
end spi_ctrl;

architecture Behavioral of spi_ctrl is

  component clk_wiz_0 is
    port (
      clk_in1_p : in  std_logic;        -- sysclk_p
      clk_in1_n : in  std_logic;        -- sysclk_n
      -- Clock out ports
      clk_out1  : out std_logic;        -- 200 MHz
      clk_out2  : out std_logic;        -- 125 MHz
      -- Status and control signals
      reset     : in  std_logic;        -- cpu_rst
      locked    : out std_logic);
  end component clk_wiz_0;

  signal clk_200 : std_logic;
  signal clk_125 : std_logic;
  signal sys_rst : std_logic;
  signal clk_loc : std_logic;

  component sitcp is
    port (
      -- System I/F
      clk_200        : in    std_logic;
      clk_125        : in    std_logic;
      rst            : in    std_logic;
      sitcp_rst      : out   std_logic;
      -- MII/GMII I/F signal
      gmii_1000m     : in    std_logic;
      -- PHY I/F
      phy_mdio       : inout std_logic;
--    phy_intn       : in  std_logic;     -- open drain output from PHY
      phy_mdc        : out   std_logic;
      phy_rstn       : out   std_logic;
      phy_crs        : in    std_logic;
      phy_col        : in    std_logic;
      phy_rxclk      : in    std_logic;
      phy_rxer       : in    std_logic;
      phy_rxctl_rxdv : in    std_logic;
      phy_rxd        : in    std_logic_vector(7 downto 0);
      phy_txc_gtxclk : out   std_logic;
      phy_txclk      : in    std_logic;
      phy_txer       : out   std_logic;
      phy_txctl_txen : out   std_logic;
      phy_txd        : out   std_logic_vector(7 downto 0);
--    sgmii_tx_p     : out std_logic;     -- SGMII transmit data
--    sgmii_tx_n     : out std_logic;
--    sgmii_rx_p     : in  std_logic;     -- SGMII receive data
--    sgmii_rx_n     : in  std_logic;
      -- TCP
      tcp_open_req   : in    std_logic;
      tcp_open_ack   : out   std_logic;
      tcp_error      : out   std_logic;
      tcp_close_req  : out   std_logic;
      tcp_close_ack  : in    std_logic;
      tcp_rxd        : out   std_logic_vector(7 downto 0);
      tcp_tx_full    : out   std_logic;
      tcp_tx_wr      : in    std_logic;
      tcp_txd        : in    std_logic_vector(7 downto 0);
      -- UDP (RBCP)
      rbcp_act       : out   std_logic;
      rbcp_addr      : out   std_logic_vector(31 downto 0);
      rbcp_wd        : out   std_logic_vector(7 downto 0);
      rbcp_we        : out   std_logic;
      rbcp_re        : out   std_logic;
      rbcp_ack       : in    std_logic;
      rbcp_rd        : in    std_logic_vector(7 downto 0));
  end component sitcp;

  signal sitcp_rst     : std_logic;
  signal gmii_1000m    : std_logic;
  signal tcp_open_req  : std_logic;
  signal tcp_open_ack  : std_logic;
  signal tcp_error     : std_logic;
  signal tcp_close_req : std_logic;
  signal tcp_close_ack : std_logic;
  signal tcp_rxd       : std_logic_vector(7 downto 0);
  signal tcp_tx_full   : std_logic;
  signal tcp_tx_wr     : std_logic;
  signal tcp_txd       : std_logic_vector(7 downto 0);
  signal rbcp_act      : std_logic;
  signal rbcp_addr     : std_logic_vector(31 downto 0);
  signal rbcp_wd       : std_logic_vector(7 downto 0);
  signal rbcp_we       : std_logic;
  signal rbcp_re       : std_logic;
  signal rbcp_ack      : std_logic;
  signal rbcp_rd       : std_logic_vector(7 downto 0);

  component rbcp is
    port (
      clk        : in     std_logic;
      rst        : in     std_logic;
      rbcp_act   : in     std_logic;
      rbcp_addr  : in     std_logic_vector(31 downto 0);
      rbcp_we    : in     std_logic;
      rbcp_wd    : in     std_logic_vector(7 downto 0);
      rbcp_re    : in     std_logic;
      rbcp_rd    : out    std_logic_vector(7 downto 0);
      rbcp_ack   : out    std_logic;
      regd_adc   : inout  reg_data_adc;
      regd_dac   : inout  reg_data_dac;
      rbcp_debug : buffer std_logic_vector(7 downto 0));
  end component rbcp;

  signal regd_adc   : reg_data_adc;
  signal regd_dac   : reg_data_dac;
  signal rbcp_debug : std_logic_vector(7 downto 0);

begin

  System_Clock : clk_wiz_0
    port map (
      clk_in1_p => sysclk_p,
      clk_in1_n => sysclk_n,
      clk_out1  => clk_200,
      clk_out2  => clk_125,
      reset     => cpu_rst,
      locked    => clk_loc);

  System_Reset : process(clk_200)
  begin
    if (clk_200'event and clk_200 = '1') then
      sys_rst <= not clk_loc;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- SiTCP
  ---------------------------------------------------------------------------
  gmii_1000m <= gpio_dip_sw(0);         -- (0: 100MbE, 1: GbE)

  SiTCP_inst : sitcp
    port map (
      clk_200        => clk_200,
      clk_125        => clk_125,
      rst            => sys_rst,
      sitcp_rst      => sitcp_rst,
      gmii_1000m     => gmii_1000m,
      phy_mdio       => phy_mdio,
      phy_mdc        => phy_mdc,
      phy_rstn       => phy_rstn,
      phy_crs        => phy_crs,
      phy_col        => phy_col,
      phy_rxclk      => phy_rxclk,
      phy_rxer       => phy_rxer,
      phy_rxctl_rxdv => phy_rxctl_rxdv,
      phy_rxd        => phy_rxd,
      phy_txc_gtxclk => phy_txc_gtxclk,
      phy_txclk      => phy_txclk,
      phy_txer       => phy_txer,
      phy_txctl_txen => phy_txctl_txen,
      phy_txd        => phy_txd,
      tcp_open_req   => tcp_open_req,
      tcp_open_ack   => tcp_open_ack,
      tcp_error      => tcp_error,
      tcp_close_req  => tcp_close_req,
      tcp_close_ack  => tcp_close_ack,
      tcp_rxd        => tcp_rxd,
      tcp_tx_full    => tcp_tx_full,
      tcp_tx_wr      => tcp_tx_wr,
      tcp_txd        => tcp_txd,
      rbcp_act       => rbcp_act,
      rbcp_addr      => rbcp_addr,
      rbcp_wd        => rbcp_wd,
      rbcp_we        => rbcp_we,
      rbcp_re        => rbcp_re,
      rbcp_ack       => rbcp_ack,
      rbcp_rd        => rbcp_rd);

  ---------------------------------------------------------------------------
  -- RBCP
  ---------------------------------------------------------------------------
  RBCP_inst : rbcp
    port map (
      clk        => clk_200,
      rst        => sitcp_rst,
      rbcp_act   => rbcp_act,
      rbcp_addr  => rbcp_addr,
      rbcp_we    => rbcp_we,
      rbcp_wd    => rbcp_wd,
      rbcp_re    => rbcp_re,
      rbcp_rd    => rbcp_rd,
      rbcp_ack   => rbcp_ack,
      regd_adc   => regd_adc,
      regd_dac   => regd_dac,
      rbcp_debug => rbcp_debug);

  ---------------------------------------------------------------------------
  -- GPIO LED
  ---------------------------------------------------------------------------
--  gpio_led <= rbcp_debug;
  gpio_led <= regd_adc(0) when gpio_dip_sw(3 downto 1) = "000" else
              regd_adc(1) when gpio_dip_sw(3 downto 1) = "001" else
              regd_adc(2) when gpio_dip_sw(3 downto 1) = "010" else
              regd_adc(3) when gpio_dip_sw(3 downto 1) = "011" else
              regd_adc(4) when gpio_dip_sw(3 downto 1) = "100" else
              regd_adc(5) when gpio_dip_sw(3 downto 1) = "101" else
              regd_adc(6) when gpio_dip_sw(3 downto 1) = "110" else
              regd_adc(7) when gpio_dip_sw(3 downto 1) = "111";

end Behavioral;
