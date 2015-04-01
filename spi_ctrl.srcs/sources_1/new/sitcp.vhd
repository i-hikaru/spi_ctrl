----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/03/11 22:46:33
-- Design Name: 
-- Module Name: sitcp - Behavioral
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
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity sitcp is
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
end sitcp;

architecture Behavioral of sitcp is

  component WRAP_SiTCP_GMII_XC7K_32K is
    port (
      clk            : in  std_logic;
      rst            : in  std_logic;
      -- Configuration parameters
      force_defaultn : in  std_logic;
      ext_ip_addr    : in  std_logic_vector(31 downto 0);
      ext_tcp_port   : in  std_logic_vector(15 downto 0);
      ext_rbcp_port  : in  std_logic_vector(15 downto 0);
      phy_addr       : in  std_logic_vector(4 downto 0);
      eeprom_cs      : out std_logic;
      eeprom_sk      : out std_logic;
      eeprom_di      : out std_logic;
      eeprom_do      : in  std_logic;
      -- user data, intialial values are stored in the EEPROM, 0xFFFF_FC3C-3F
      usr_reg_x3c    : out std_logic_vector(7 downto 0);  -- 0xFFFF_FF3C
      usr_reg_x3d    : out std_logic_vector(7 downto 0);  -- 0xFFFF_FF3D
      usr_reg_x3e    : out std_logic_vector(7 downto 0);  -- 0xFFFF_FF3E
      usr_reg_x3f    : out std_logic_vector(7 downto 0);  -- 0xFFFF_FF3F
      -- MII I/F
      gmii_rstn      : out std_logic;   -- PHY reset
      gmii_1000m     : in  std_logic;   -- GMII mode (0:MII, 1:GMII)
      -- TX
      gmii_tx_clk    : in  std_logic;
      gmii_tx_en     : out std_logic;
      gmii_txd       : out std_logic_vector(7 downto 0);
      gmii_tx_er     : out std_logic;
      -- RX
      gmii_rx_clk    : in  std_logic;
      gmii_rx_dv     : in  std_logic;
      gmii_rxd       : in  std_logic_vector(7 downto 0);
      gmii_rx_er     : in  std_logic;
      gmii_crs       : in  std_logic;
      gmii_col       : in  std_logic;
      -- Management I/F
      gmii_mdc       : out std_logic;
      gmii_mdio_in   : in  std_logic;
      gmii_mdio_out  : out std_logic;
      gmii_mdio_oe   : out std_logic;
      -- User I/F
      sitcp_rst      : out std_logic;
      -- TCP connection control
      tcp_open_req   : in  std_logic;
      tcp_open_ack   : out std_logic;
      tcp_error      : out std_logic;
      tcp_close_req  : out std_logic;
      tcp_close_ack  : in  std_logic;
      -- FIFO I/F
      tcp_rx_wc      : in  std_logic_vector(15 downto 0);
      tcp_rx_wr      : out std_logic;
      tcp_rx_data    : out std_logic_vector(7 downto 0);
      tcp_tx_full    : out std_logic;
      tcp_tx_wr      : in  std_logic;
      tcp_tx_data    : in  std_logic_vector(7 downto 0);
      -- RBCP
      rbcp_act       : out std_logic;
      rbcp_addr      : out std_logic_vector(31 downto 0);
      rbcp_wd        : out std_logic_vector(7 downto 0);
      rbcp_we        : out std_logic;
      rbcp_re        : out std_logic;
      rbcp_ack       : in  std_logic;
      rbcp_rd        : in  std_logic_vector(7 downto 0));
  end component WRAP_SiTCP_GMII_XC7K_32K;

  signal gmii_tx_clk : std_logic;
  signal mdio_out    : std_logic;
  signal mdio_in     : std_logic;
  signal mdio_oe     : std_logic;
  signal tcp_close   : std_logic;
  
begin

  Wrapper_SiTCP : WRAP_SiTCP_GMII_XC7K_32K
    port map (
      clk            => clk_200,
      rst            => rst,
      force_defaultn => '0',
      ext_ip_addr    => (others => '0'),
      ext_tcp_port   => (others => '0'),
      ext_rbcp_port  => (others => '0'),
      phy_addr       => "00111",        -- GMII mode
      eeprom_cs      => open,
      eeprom_sk      => open,
      eeprom_di      => open,
      eeprom_do      => '0',
      usr_reg_x3c    => open,
      usr_reg_x3d    => open,
      usr_reg_x3e    => open,
      usr_reg_x3f    => open,
      gmii_1000m     => gmii_1000m,
      gmii_rstn      => phy_rstn,
      gmii_tx_clk    => gmii_tx_clk,
      gmii_tx_en     => phy_txctl_txen,
      gmii_txd       => phy_txd,
      gmii_tx_er     => phy_txer,
      gmii_rx_clk    => phy_rxclk,
      gmii_rx_dv     => phy_rxctl_rxdv,
      gmii_rxd       => phy_rxd,
      gmii_rx_er     => phy_rxer,
      gmii_crs       => phy_crs,
      gmii_col       => phy_col,
      gmii_mdc       => phy_mdc,
      gmii_mdio_in   => phy_mdio,
      gmii_mdio_out  => mdio_out,
      gmii_mdio_oe   => mdio_oe,
      sitcp_rst      => sitcp_rst,
      tcp_open_req   => '0',
      tcp_open_ack   => tcp_open_ack,
      tcp_error      => open,
      tcp_close_req  => tcp_close,
      tcp_close_ack  => tcp_close,
      tcp_rx_wc      => (others => '0'),
      tcp_rx_wr      => open,
      tcp_rx_data    => open,
      tcp_tx_full    => tcp_tx_full,
      tcp_tx_wr      => tcp_tx_wr,
      tcp_tx_data    => tcp_txd,
      rbcp_act       => rbcp_act,
      rbcp_addr      => rbcp_addr,
      rbcp_wd        => rbcp_wd,
      rbcp_we        => rbcp_we,
      rbcp_re        => rbcp_re,
      rbcp_ack       => rbcp_ack,
      rbcp_rd        => rbcp_rd);

  ODDR_phy_txc_gtxclk : ODDR
    generic map (
      DDR_CLK_EDGE => "OPPOSITE_EDGE",
      INIT         => '0',
      SRTYPE       => "SYNC")
    port map (
      Q  => phy_txc_gtxclk,
      C  => clk_125,
      CE => '1',
      D1 => '1',
      D2 => '0',
      R  => '0',
      S  => '0');

  BUFGMUX_gmii_tx_clk : BUFGMUX
    port map (
      O  => gmii_tx_clk,
      I0 => phy_txclk,
      I1 => clk_125,
      S  => gmii_1000m);

  phy_mdio <= mdio_out when mdio_oe = '1' else 'Z';

end Behavioral;
