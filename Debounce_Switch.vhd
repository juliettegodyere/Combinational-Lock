----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.04.2022 14:58:30
-- Design Name: 
-- Module Name: Debounce - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Debouncer is
    Port ( 
           clk : in STD_LOGIC;
           D_BTNL, D_BTNR, D_BTNU, D_BTND, D_BTNC: IN STD_LOGIC;        --Push buttons
           btnc_clr , btnu_clr, btnl_clr: out STD_LOGIC);
end Debouncer;

architecture Behavioral of Debouncer is

constant DELAY: integer:=10000;
    signal count: integer:=0;
    signal btn_enable:std_logic:='0';
    
    signal btnc_prev: std_logic;
    signal btnc_prev_prev: std_logic;
    signal btnu_prev: std_logic;
    signal btnu_prev_prev: std_logic;
    signal btnl_prev: std_logic;
    signal btnl_prev_prev: std_logic;

begin

    CLK_DOMAIN_CROSS:
        process(clk)
            begin
                if rising_edge(clk) then
                    btnc_prev <= BTNC;
                    btnc_prev_prev <= btnc_prev;

                    btnu_prev <= BTNU;
                    btnu_prev_prev <= btnc_prev;

                    btnl_prev <= BTNL;
                    btnl_prev_prev <= btnc_prev;
                 end if;
          end process;
          
          
    BTNC_DEBOUNCE_COUNTER:
        process(clk)
            begin
                if rising_edge(clk) then
                    btnc_clr<='1';
                    if btnc_prev_prev = '0' then
                        count <= 0;
                     elsif count < DELAY then
                        count <= count+1;
                     end if;
                     if count = DELAY - 1 then
                        btnc_clr <= '0';
                     end if;
             end if;
         end process;

    BTNU_DEBOUNCE_COUNTER:
        process(clk)
            begin
                if rising_edge(clk) then
                    btnu_clr<='1';
                    if btnu_prev_prev = '0' then
                        count <= 0;
                     elsif count < DELAY then
                        count <= count+1;
                     end if;
                     if count = DELAY - 1 then
                        btnu_clr <= '0';
                     end if;
             end if;
         end process;
    BTNL_DEBOUNCE_COUNTER:
         process(clk)
             begin
                 if rising_edge(clk) then
                     btnl_clr<='1';
                     if btnl_prev_prev = '0' then
                         count <= 0;
                      elsif count < DELAY then
                         count <= count+1;
                      end if;
                      if count = DELAY - 1 then
                         btnl_clr <= '0';
                      end if;
              end if;
          end process;
                    
end Behavioral;
