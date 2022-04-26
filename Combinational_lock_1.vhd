----------------------------------------------------------------------------------
-- Generic top level design file
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity top_level is
    Port ( CLK100MHZ: in std_logic;
	       BTNL, BTNR, BTNU, BTND, BTNC: in std_logic;        --Push buttons
	       SWITCHES:  in STD_LOGIC_VECTOR (15 downto 0);       --Slider switches
           LEDS:      out STD_LOGIC_VECTOR (7 downto 0);      --LEDs
		   DIGITS:    out STD_LOGIC_VECTOR (7 downto 0);      --Digits of 7-segment display
           SEGMENTS:  out STD_LOGIC_VECTOR (7 downto 0)   );  --Segments of 7-segment display 
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
    signal state_temp1: my_states:=Idle;  
    signal start_btnc_prev, accept_btnl_prev, debounced_btnc, debounced_btnu, debounced_btnl: std_logic :='0';

    begin
        --IKHz clock process
        process (enable) 
            begin 
                if (rising_edge(enable)) then  
                   start_btnc_prev <= BTNC; --Assign button previous state
                   accept_btnl_prev <= BTNL; --Assign button previous state
               
                --Check if the first button is pressed and compare the recent button value with the previous value
               if BTNC = '1' and start_btnc_prev = '0'then
                   case state_temp1 is
                        when Idle => if debounced_btnc = '1' then state_temp1 <= s0;
                                   else state_temp1 <= Idle; end if;
                        when others => state_temp1 <= idle; 
                     end case;
               elsif  BTNL = '1' and accept_btnl_prev = '0'  then
                  case state_temp1 is
                        when s0 => if debounced_btnl = '1' then state_temp1 <= s1;  
                                  else state_temp1 <= s0; end if;
                        when s1 => if debounced_btnl = '1' then state_temp1 <= s2; 
                                  else state_temp1 <= s1; end if;
                        when s2 => if debounced_btnl ='1' then state_temp1 <= s3; 
                                  else state_temp1 <= s2; end if;
                        when s3 => if debounced_btnl = '1' then state_temp1 <= s4; 
                                  else state_temp1 <= s3; end if;
                        when s4 => if debounced_btnl = '1' then state_temp1 <= s0; 
                                  else state_temp1 <= s4; end if;
                        when others => state_temp1 <= idle;
                   end case;
                end if;
             end if; 
          end process; 
          state <= state_temp1;
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
                             passcode_input(3 downto 0) <= SWITCHES(3 downto 0);
                        else enable <= '0' ; end if ;
                     elsif state = s1 then
                        if count = MAX_COUNT then enable <= '1' ; 
                             count <= (others => '0') ;
                             passcode_input(7 downto 4) <= SWITCHES(7 downto 4);
                        else enable <= '0' ; end if ;
                     elsif state = s2 then
                        if count = MAX_COUNT then enable <= '1' ; 
                             count <= (others => '0') ; 
                             passcode_input(11 downto 8) <= SWITCHES(11 downto 8);
                        else enable <= '0' ; end if ;
                     elsif state = s3 then
                        if count = MAX_COUNT then enable <= '1' ; 
                           count <= (others => '0') ;
                           passcode_input(15 downto 12) <= SWITCHES(15 downto 12);
                        else enable <= '0' ; end if ;
                     elsif state = s4 then
                        if count = MAX_COUNT then enable <= '1' ; 
                           count <= (others => '0') ; 
                           if passcode = passcode_input then LEDS(7 downto 0) <= "11111111"; 
                           else LEDS(7 downto 0) <= "00000000"; end if ;
                        else enable <= '0' ;end if ;
                     else  
                     end if ;
                  end if ;
               end process ; 
         
          start_btn_debouncer: ENTITY work.Debouncer(Behavioral) port map(clk=>enable, btn=>start_btnc_prev, btn_clr=>debounced_btnc);
          accept_btn_debouncer: ENTITY work.Debounce(Behavioral) PORT MAP(clk=>enable, btc=>accept_btnl_prev, btn_clr=>debounced_btnl);
          
          -- We're not using these signals, but we have to give some value to
           -- all declared outputs so that the code will compile
           --LEDS(7 downto 0) <= "00000000"; -- Turn off unused LEDs
          --DIGITS <= "11111111"; -- Turn off digit of display
          SEGMENTS <= "11111111";
           
         end Behavioral;    