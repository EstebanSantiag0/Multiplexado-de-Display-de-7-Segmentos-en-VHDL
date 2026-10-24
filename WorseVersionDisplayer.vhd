----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:14:59 03/19/2026 
-- Design Name: 
-- Module Name:    WorseVersionDisplayer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity WorseVersionDisplayer is
   Port (
      clk : in std_logic;
      disp : out  STD_LOGIC_vector(3 downto 0);
      seg : out  STD_LOGIC_vector(7 downto 0)
);
end WorseVersionDisplayer;

architecture Behavioral of WorseVersionDisplayer is
begin
   process(clk)
      variable df: integer range 0 to 50000;
      variable cnt: std_logic_vector(1 downto 0);
      variable tmux: std_logic_vector(3 downto 0);
   begin
      if falling_edge(clk) then
         if df = 50000 then
            df := 0;
            cnt := cnt + 1;
            case cnt is
               when "00" =>
                  disp <= "1110";
                  tmux := "0001";
               when "01" =>
                  disp <= "1101";
                  tmux := "0010";
               when "10" =>
                  disp <= "1011";
                  tmux := "0100";
               when "11" =>
                  disp <= "0111";
                  tmux := "1000";
               when others => null;
            end case;
 
            case tmux is
               when "0001" =>
                  seg <= "11000000";
               when "0010" =>
                  seg <= "10000000";
               when "0100" =>
                  seg <= "10010010";
               when "1000" =>
                  seg <= "10100100";
               when others => null;
            end case;
         else
            df := df + 1;
         end if;
      end if;
   end process;
end Behavioral;

