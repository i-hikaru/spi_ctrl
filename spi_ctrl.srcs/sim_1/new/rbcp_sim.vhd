----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/03/16 14:09:16
-- Design Name: 
-- Module Name: rbcp_sim - Behavioral
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity rbcp_sim is
end rbcp_sim;

architecture Behavioral of rbcp_sim is

  constant clk_period : time := 5 ns;   -- 200 MHz

  component rbcp is
    port (
      clk           : in     std_logic;
      rst           : in     std_logic;
      rbcp_act      : in     std_logic;
      rbcp_addr     : in     std_logic_vector(31 downto 0);
      rbcp_we       : in     std_logic;
      rbcp_wd       : in     std_logic_vector(7 downto 0);
      rbcp_re       : in     std_logic;
      rbcp_rd       : out    std_logic_vector(7 downto 0);
      rbcp_ack      : out    std_logic;
      rbcp_wd_debug : buffer std_logic_vector(7 downto 0));
  end component rbcp;

  signal clk           : std_logic;
  signal rst           : std_logic;
  signal rbcp_act      : std_logic;
  signal rbcp_addr     : std_logic_vector(31 downto 0);
  signal rbcp_we       : std_logic;
  signal rbcp_wd       : std_logic_vector(7 downto 0);
  signal rbcp_re       : std_logic;
  signal rbcp_rd       : std_logic_vector(7 downto 0);
  signal rbcp_ack      : std_logic;
  signal rbcp_wd_debug : std_logic_vector(7 downto 0);

begin

  rbcp_inst : rbcp
    port map (
      clk           => clk,
      rst           => rst,
      rbcp_act      => rbcp_act,
      rbcp_addr     => rbcp_addr,
      rbcp_we       => rbcp_we,
      rbcp_wd       => rbcp_wd,
      rbcp_re       => rbcp_re,
      rbcp_rd       => rbcp_rd,
      rbcp_ack      => rbcp_ack,
      rbcp_wd_debug => rbcp_wd_debug);

  -- clock process definitions
  clk_process : process
  begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
  end process;

  -- stimulus process
  stim_proc : process
  begin
    -- initialize
    rst     <= '1';
    rbcp_we <= '0';
    rbcp_re <= '0';
    wait for clk_period*4;
    rst     <= '0';

    -- write
    rbcp_act  <= '1';
    rbcp_addr <= x"00000000";
    rbcp_wd   <= x"01";
    wait for clk_period*4;
    rbcp_we   <= '1';
    wait for clk_period;
    rbcp_we   <= '0';
--    rbcp_act  <= '0';
    wait for clk_period*20;

    -- read
    rbcp_act  <= '1';
    rbcp_addr <= x"00000000";
    wait for clk_period*4;
    rbcp_re   <= '1';
    wait for clk_period;
    rbcp_re   <= '0';
--    rbcp_act  <= '0';
    wait for clk_period*20;

    -- read
    rbcp_act  <= '1';
    rbcp_addr <= x"00000001";
    wait for clk_period*4;
    rbcp_re   <= '1';
    wait for clk_period;
    rbcp_re   <= '0';
--    rbcp_act  <= '0';

    wait;
  end process;

end Behavioral;
