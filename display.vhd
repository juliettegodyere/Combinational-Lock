library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display is
  Port ( number: in std_logic_vector(3 downto 0);
         segs: out std_logic_vector(7 downto 0));
end display;

architecture Behavioral of display is

begin
    segs(7) <= '1';
    with number select
      segs(6 downto 0)<= 
        "1111001" when "0001",  --1
         "0100100" when "0010",   --2
         "0110000" when "0011",   --3
         "0011001" when "0100",   --4
         "0010010" when "0101",   --5
         "0000010" when "0110",   --6
         "1111000" when "0111",   --7
         "0000000" when "1000",   --8
         "0010000" when "1001",   --9
         "1001000" when "1010",   --A now N
         "0001001" when "1011",   --b now H
         "0101111" when "1100",   --C now r                                              
         "0100001" when "1101",   --d
         "0000110" when "1110",   --E
         "0111111" when "1111",   --F now -
         "1000000" when others;   --0
end Behavioral;

