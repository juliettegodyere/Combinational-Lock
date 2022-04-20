----------------------------------------------------------------------------------
-- Generic top level design file
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity top_level is
    Port ( 
        CLK100MHZ: in std_logic;
        BTNL, BTNR, BTNU, BTND, BTNC: in std_logic;        --Push buttons
        SWITCHES:  in std_logic_vector (15 downto 0);       --Slider switches
        LEDS:      out std_logic_vector (7 downto 0);      --LEDs
        DIGITS:    out std_logic_vector (7 downto 0);      --Digits of 7-segment display
        SEGMENTS:  out std_logic_vector (7 downto 0)   );  --Segments of 7-segment display 
end top_level;

architecture Behavioral of top_level is
   --Local declarations go here
   signal passcode: std_logic_vector (15 downto 0):=X"0240"; --The four digit student ID
   signal passcode_input: std_logic_vector (15 downto 0):=X"2222"; --User imput 
   signal display_value: std_logic_vector (3 downto 0); --The value to be displayed on the 7-segment display
   signal enable: std_logic; --The derived 1KHz enable signal
   signal count: std_logic_vector(15 downto 0):=(OTHERS=>'0') ; --The counter for the 1KHz clock
   signal dig_count: Integer:=0; -- Used as multiplexer for diplaying of multiple displays
   constant MAX_COUNT: std_logic_vector(15 downto 0) := "1100001101010000";  -- 100,000: use this for synthesis  --  "1010"; 
   type my_states IS (Idle, s0, s1, s2, s3, s4);
   signal state: my_states:=Idle; 
   signal accept_btnc_prev, start_btnl_prev, debounced_btnc, debounced_btnu, debounced_btnl: std_logic :='0';

   begin
    --IKHz clock process
    process (enable) 
        begin 
            if (rising_edge(enable)) then  
               start_btnc_prev <= BTNC; --Assign button previous state
               accept_btnl_prev <= BTNL; --Assign button previous state
           
            --Check if the first button is pressed and compare the recent button value with the previous value
           if (BTNC = '1' and start_btnc_prev = '0')' then
               case state is
                    when Idle => if debounced_btnc = '1' then state <= s0;
                                 else state <= Idle;
                    when others => state <= Idle; end if;
                end case;
            --Check if the second button is pressed and compare the recent button value with the previous value
            elsif BTNL = '1' and accept_btnl_prev = '0
                case state is
                  when s0 => if debounced_btnl = '1' then state <= s1;  
                              else state <= s0; end if;
                  when s1 => if debounced_btnl = '1' then state <= s2; 
                              else state <= s1; end if;
                  when s2 => if debounced_btnl;end if;
                  when s3 => if debounced_btnl = '1' then state <= s4; 
                              else state <= s3; end if;
                  when s4 => if debounced_btnl = '1' then state <= s0; 
                              else state <= s4; end if;
                  when others => state <= ready;
               end case;
            end if;
         end if; 
      end process; 
       
      process (clk100MHz) 
         begin 
         if rising_edge (clk100MHz) then 
            count <= count + 1 ;
            enable <= '0' ;
            if state = Idle then
               if count = MAX_COUNT then enable <= '1' ; 
                  count <= (others => '0') ;
                  LEDS <= "00000000"; -- Turn off unused LEDs
                  DIGITS <= "11111111"; -- Turn off all display digits
               else enable <= '0' ;  end if ;
            elsif state = s0 then
               if count = MAX_COUNT then enable <= '1' ; 
                    count <= (others => '0') ;
                    LEDS(7 downto 0) <= "00000001"; 
                    passcode_input(3 DOWNTO 0) <= SWITCHES(3 DOWNTO 0);
               else enable <= '0' ; end if ;
            elsif state = s1 then
               if count = MAX_COUNT then enable <= '1' ; 
                    count <= (others => '0') ;
                    passcode_input(7 DOWNTO 4) <= SWITCHES(7 DOWNTO 4);
               else enable <= '0' ; end if ;
            elsif state = s2 then
               if count = MAX_COUNT then enable <= '1' ; 
                    count <= (others => '0') ; 
                    passcode_input(11 DOWNTO 8) <= SWITCHES(11 DOWNTO 8);
               else enable <= '0' ; end if ;
            elsif state = s3 then
               if count = MAX_COUNT then enable <= '1' ; 
                  count <= (others => '0') ;
                  passcode_input(15 DOWNTO 12) <= SWITCHES(15 DOWNTO 12);
               else enable <= '0' ; end if ;
            elsif state = s4 then
               if count = MAX_COUNT then enable <= '1' ; 
                  count <= (others => '0') ; 
                  if passcode = passcode_input then LEDS(7 downto 0) <= "11111111"; 
                  else LEDS(7 downto 0) <= "00000000"; end if ;
               else enable <= '0' ;end if ;
            else  
               state <= Idle;  
            end if ;
         end if ;
      end process ; 

 start_btn_debouncer: ENTITY work.Debouncer(Behavioral) PORT MAP(clk=>enable, D_BTNC=>start_btnc_prev, btnc_clr=>debounced_btnc);
 accept_btn_debouncer: ENTITY work.Debounce(Behavioral) PORT MAP(clk=>enable, D_BTNL=>accept_btnl_prev, btnl_clr=>debounced_btnl);
  
end Behavioral;	
