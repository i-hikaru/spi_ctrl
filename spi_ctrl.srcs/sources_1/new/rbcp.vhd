----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/03/11 17:58:52
-- Design Name: 
-- Module Name: rbcp - Behavioral
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
use IEEE.STD_LOGIC_ARITH.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.rhea_pkg.all;

entity rbcp is
  port (
    clk        : in     std_logic;
    rst        : in     std_logic;
    -- RBCP
    rbcp_act   : in     std_logic;
    rbcp_addr  : in     std_logic_vector(31 downto 0);
    rbcp_we    : in     std_logic;
    rbcp_wd    : in     std_logic_vector(7 downto 0);
    rbcp_re    : in     std_logic;
    rbcp_rd    : out    std_logic_vector(7 downto 0);
    rbcp_ack   : out    std_logic;
    -- ADC register
    regd_adc   : inout  reg_data_adc;
    rbcp_debug : buffer std_logic_vector(7 downto 0));
end rbcp;

architecture Behavioral of rbcp is

  type rbcp_state is (init, idle, wr, rd, fini);
  signal s_rbcp : rbcp_state;

begin

  rbcp_sm_proc : process(clk)
  begin
    if (clk'event and clk = '1') then
      if rst = '1' then
        s_rbcp   <= init;
        rbcp_ack <= '0';
      else
        case s_rbcp is
          when init =>
            rbcp_ack <= '0';
            if rbcp_act = '1' then
              s_rbcp <= idle;
            else
              null;
            end if;
          when idle =>
            if rbcp_we = '1' then
              s_rbcp <= wr;
            elsif rbcp_re = '1' then
              s_rbcp <= rd;
            else
              null;
            end if;
          when wr => s_rbcp <= fini;
          when rd => s_rbcp <= fini;
          when fini =>
            rbcp_ack <= '1';
            s_rbcp   <= init;
          when others => s_rbcp <= init;
        end case;
      end if;
    end if;
  end process;

--  process(clk)
--  begin
--    if (clk'event and clk = '1') then
--      if rst = '1' then
--        rbcp_rd    <= (others => '0');
--        rbcp_debug <= (others => '0');
--      else
--        case rbcp_addr is
--          -- test write/read
--          when x"10000000" =>
--            if s_rbcp = wr then
--              rbcp_debug <= rbcp_wd;
--            elsif s_rbcp = rd then
--              rbcp_rd <= rbcp_debug;
--            else
--              null;
--            end if;

--          -- ADC register
--          -- e.g., x"0000f0__", __ = register address
--          when x"0000f000" =>
--            if s_rbcp = wr then
--              reg_addr_adc_00 <= rbcp_wd;
--            elsif s_rbcp = rd then
--              rbcp_rd <= reg_addr_adc_00;
--            else
--              null;
--            end if;

--          when x"0000f001" =>
--            if s_rbcp = wr then
--              reg_addr_adc_01 <= rbcp_wd;
--            elsif s_rbcp = rd then
--              rbcp_rd <= reg_addr_adc_01;
--            else
--              null;
--            end if;

--          when x"0000f002" =>
--            if s_rbcp = wr then
--              reg_addr_adc_03 <= rbcp_wd;
--            elsif s_rbcp = rd then
--              rbcp_rd <= x"03";
--            else
--              null;
--            end if;

--            for i in 0 to 23 loop
--              when x"0000f0" & conv_std_logic_vector(i, 8) =>
--              if s_rbcp = wr then
--                reg_addr_adc(i) <= rbcp_wd;
--              elsif s_rbcp = rd then
--                rbcp_rd <= reg_addr_adc(i);
--              else
--                null;
--              end if;
--            end loop;  -- i

--          when others => null;
--        end case;
--      end if;
--    end if;
--  end process;

  process(clk)
  begin
    if (clk'event and clk = '1') then
      if rst = '1' then
        rbcp_rd    <= (others => '0');
        rbcp_debug <= (others => '0');

      -- test write/read
      elsif rbcp_addr = x"00000000" then
        if s_rbcp = wr then
          rbcp_debug <= rbcp_wd;
        elsif s_rbcp = rd then
          rbcp_rd <= rbcp_debug;
        else
          null;
        end if;

      -- ADC register control
      elsif rbcp_addr(31 downto 28) = x"1" then
        for i in 0 to 23 loop
          case rbcp_addr(7 downto 0) is
            when conv_std_logic_vector(i, 8) =>
              if s_rbcp = wr then
                regd_adc(i) <= rbcp_wd;
              elsif s_rbcp = rd then
                rbcp_rd <= regd_adc(i);
              else
                null;
              end if;
            when others => null;
          end case;
        end loop;  -- i

      -- DAC register control
      elsif rbcp_addr(31 downto 28) = x"2" then
        null;
      else
        null;
      end if;
    end if;
  end process;

end Behavioral;
