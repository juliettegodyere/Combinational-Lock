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
   signal passcode_input: std_logic_vector (15 downto 0):=X"2222"; --The four digit student ID inputed by the user. 22222 is the default value.
   signal display_value: std_logic_vector (3 downto 0); --The value to be displayed on the 7-segment display
   signal enable: std_logic; --The derived 1KHz enable signal
   signal count: std_logic_vector(15 downto 0):=(OTHERS=>'0') ; --The counter for the 1KHz clock
   signal dig_count: Integer:=0; -- Used as multiplexer for diplaying of multiple displays
   constant MAX_COUNT: std_logic_vector(15 downto 0) := "1100001101010000";  -- 100,000: use this for synthesis  --  "1010"; 
   ------States: Idle, Ready, s0: input 1, s1: input 2, s2: input 3, s3: input 4, Result------------ 
   type my_states IS (Idle, Ready, s0, s1, s2, s3,result);
   signal state: my_states:=Idle; 
   signal accept_btnl_prev, start_btnc_prev, debounced_btnc, debounced_btnu, debounced_btnl: std_logic :='0';

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
                  when Idle => 
                     if debounced_btnc = '1' then
                         state <= Ready;
                      else
                        state <= Idle;
                    when others => state <= Idle;
                     end if;
                end case;
            --Check if the second button is pressed and compare the recent button value with the previous value
            elsif BTNL = '1' and accept_btnl_prev = '0
                case state is
                    when Ready => 
                        if debounced_btnl = '1' then
                            state <= s0;
                        else
                            state <= Ready;
                        end if;
                    when s0 => 
                        if debounced_btnl = '1' then
                            state <= s1;  
                            else
                            state <= s0;
                        end if;
                    when s1 => 
                        if debounced_btnl = '1' then
                                state <= s2; 
                        else
                            state <= s1; 
                            end if;
                    when s2 => 
                        if debounced_btnl = '1' then 
                                state <= s3;  
                        else
                            state <= s2;
                        end if;
                    when s3 => 
                        if debounced_btnl = '1' then
                                state <= result 
                        else
                                state <= s3;
                        end if;
                    when result => 
                        if debounced_btnl = '1' then
                            state <= ready;
                        else
                            state <= result;
                        end if;
                    when others => state <= ready;
               end case;
            end if;
         end if; 
      end process; 
       
      process (clk100MHz) 
         begin 
         if rising_edge (clk100MHz) then 
            if state = Idle then
               if count = MAX_COUNT THEN  -- Count to 100,000 which is the maximum value for the counter
                  enable <= '1' ; 
                  count <= (others => '0') ;
                  LEDS <= "00000000"; -- Turn off unused LEDs
                  DIGITS <= "11111111"; -- Turn off all display digits
               else  
                  enable <= '0' ; 
                  count <= count + 1 ;  -- Increment the counter
               end if ;
            elsif state = Ready then
               if count = MAX_COUNT THEN 
                    enable <= '1' ; 
                    count <= (others => '0') ;
                    LEDS(7 downto 0) <= "00000001"; -- Turn on a single led to indicate that the system is ready to accept input
                    passcode_input(3 DOWNTO 0) <= SWITCHES(3 DOWNTO 0); --Get the first user input
                    -----Multiplexer: Display multiple values on the segment display-----
                    if dig_count = 0 then
                        --Display "N" on first digit of segment display
                        display_value <= "1010"; 
                        DIGITS <= "11111110";
                    elsif dig_count = 1 then
                        --Display "0" on second digit of segment display
                        display_value <= "0000";
                        DIGITS <= "11111101"; -- Displays "0" on the second digit
                    end if;

                    --Count checker for the multiplexer
                    if dig_count > 1 then
                        dig_count <= 0;
                    else 
                        dig_count <= dig_count+1;
                    end if;
                    ------END Multiplexer-----
               else  
                  enable <= '0' ; 
                  count <= count + 1 ;  
               end if ;
            elsif state = s0 then
               if count = MAX_COUNT then 
                    enable <= '1' ; 
                    count <= (others => '0') ;
                    --Display "-" on first digit of segment display
                    display_value <= SWITCHES(3 DOWNTO 0); 
                    DIGITS <= "11111110";  --Select the first digit
                    --Get the second user input
                    passcode_input(7 DOWNTO 4) <= SWITCHES(7 DOWNTO 4); 
               else  
                  enable <= '0' ; 
                  count <= count + 1 ;  
               end if ;
            elsif state = s1 then
               if count = MAX_COUNT then  -- Count to MAX_COUNT 
                    enable <= '1' ; 
                    count <= (others => '0') ;
                    -----Multiplexer: Display multiple values on the segment display-----
                    if dig_count = 0 then
                        --Display "-" on first digit of segment display
                        display_value <= SWITCHES(3 DOWNTO 0);
                        DIGITS <= "11111110"; 
                    elsif dig_count = 1 then
                        --Display "-" on second digit of segment display
                        display_value <= SWITCHES(7 DOWNTO 4);
                        DIGITS <= "11111101"; 
                    end if;

                    --Count checker for the multiplexer
                    if dig_count > 1 then
                        dig_count <= 0;
                    else 
                        dig_count <= dig_count+1;
                    end if;
                    ------END Multiplexer-----
                    passcode_input(11 DOWNTO 8) <= SWITCHES(11 DOWNTO 8); 
               else  
                  enable <= '0' ; 
               end if ;
                  count <= count + 1 ;    
            elsif state = s2 then
               if count = MAX_COUNT then  -- Count to MAX_COUNT 
                  enable <= '1' ; 
                  count <= (others => '0') ;
                  -----Multiplexer: Display multiple values on the segment display-----
                if dig_count = 0 then
                    --Display "-" on first digit of segment display
                    display_value <= SWITCHES(3 DOWNTO 0);
                    DIGITS <= "11111110"; 
                elsif dig_count = 1 then
                    --Display "-" on second digit of segment display
                    display_value <= SWITCHES(7 DOWNTO 4);
                    DIGITS <= "11111101"; 
                elsif dif_count = 2 then
                    --Display "-" on third digit of segment display
                    display_value <= SWITCHES(11 DOWNTO 8); 
                    DIGITS <= "11111011"; 
                 end if;

                 --Count checker for the multiplexer
                 if dig_count > 2 then
                    dig_count <= 0;
                 else 
                    dig_count <= dig_count+1;
                 end if;
                 ------END Multiplexer-----
                  passcode_input(15 DOWNTO 12) <= SWITCHES(15 DOWNTO 12);
               else  
                  enable <= '0' ;
                  count <= count + 1 ;   
               end if ;
            elsif state = s3 then
                if count = MAX_COUNT then  -- Count to MAX_COUNT 
                  enable <= '1' ; 
                  count <= (others => '0') ;
                  -----Multiplexer: Display multiple values on the segment display-----
                if dig_count = 0 then
                    --Display "-" on first digit of segment display
                    display_value <= SWITCHES(3 DOWNTO 0);
                    DIGITS <= "11111110"; 
                elsif dig_count = 1 then
                    --Display "-" on second digit of segment display
                    display_value <= SWITCHES(7 DOWNTO 4);
                    DIGITS <= "11111101"; 
                elsif dif_count = 2 then
                    --Display "-" on third digit of segment display
                    display_value <= SWITCHES(11 DOWNTO 8); 
                    DIGITS <= "11111011"; 
                elsif dif_count = 3 then
                        --Display "-" on four digit of segment display
                        display_value <= SWITCHES(15 DOWNTO 12); 
                        DIGITS <= "11111011"; 
                 end if;

                 --Count checker for the multiplexer
                 if dig_count > 3 then
                    dig_count <= 0;
                 else 
                    dig_count <= dig_count+1;
                 end if;
                 ------END Multiplexer-----
               else  
                  enable <= '0' ; 
                  count <= count + 1 ;  
               end if ;
            elsif state = result then
               if count = MAX_COUNT then  -- Count to MAX_COUNT 
                  enable <= '1' ; 
                  count <= (others => '0') ; 
                  if passcode = passcode_input then
                     LEDS(7 downto 0) <= "11111111";
                     DIGITS <= "11111110"; 
                        if dig_count = 0 then
                           display_value <= "1011";
                           DIGITS <= "11111110"; --Displays "H" on the third digit
                        elsif dig_count = 1 then
                           display_value <= "0000";
                           DIGITS <= "11111101"; --Displays "O" on the third digit
                        end if;
                        if dig_count > 1 then
                           dig_count <= 0;
                        else 
                           dig_count <= dig_count+1;
                        end if;
                  else
                     LEDS(7 downto 0) <= "00000000";
                     if dig_count = 0 then
                        display_value <= "1100";
                        DIGITS <= "11111110";--Displays "r" on the third digit
                     elsif dig_count = 1 then
                        display_value <= "1100";
                        DIGITS <= "11111101";--Displays "r" on the third digit
                     elsif dig_count = 2 then
                        display_value <= "1110";
                        DIGITS <= "11111011";--Displays "E" on the third digit
                     end if;
                     if dig_count > 2 then
                        dig_count <= 0;
                     else 
                        dig_count <= dig_count+1;
                     end if;
                  end if ;
               else  
                  enable <= '0' ; 
               end if ;
               count <= count + 1 ;  
            else  
               enable <= '0' ; 
            end if ;
            count <= count + 1 ;  
         end if ;
      end process ; 


start_btn_debouncer: ENTITY work.Debouncer(Behavioral) PORT MAP(clk=>enable, D_BTNC=>start_btnc_prev, btnc_clr=>debounced_btnc);
accept_btn_debouncer: ENTITY work.Debounce(Behavioral) PORT MAP(clk=>enable, D_BTNL=>accept_btnl_prev, btnl_clr=>debounced_btnl);
display: ENTITY work.display(Behavioral) PORT MAP(number=> display_value, segs=> SEGMENTS);

end Behavioral;	
