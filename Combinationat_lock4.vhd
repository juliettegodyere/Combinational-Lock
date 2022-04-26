--On clock rise, start counting at a very hign speed

entity CombinationLock is
    CLK100MHZ: in std_logic;
    BTNL, BTNR, BTNU, BTND, BTNC: in std_logic;        --Push buttons
    SWITCHES:  in std_logic_vector (15 downto 0);       --Slider switches
    LEDS:      out std_logic_vector (7 downto 0);      --LEDs
    DIGITS:    out std_logic_vector (7 downto 0);      --Digits of 7-segment display
    SEGMENTS:  out std_logic_vector (7 downto 0)   );  --Segments of 7-segment display 
end CombinationLock;

architecture Behavioral of CombinationLock is
    signal passcode: std_logic_vector (15 downto 0):=X"0240"; --The four digit student ID
    signal random1: std_logic_vector(3 downto 0):=X"0";
    signal random2: std_logic_vector(3 downto 0):=X"0";
    signal val: std_logic_vector(3 downto 0):=X"0";
    signal dig_count: Integer:=0;
    signal enable: std_logic; --Enable signal for the RAM
    signal freq_count: STD_LOGIC_VECTOR(15 downto 0):=(OTHERS=>'0') ; --Random number counter
    signal count: STD_LOGIC_VECTOR(15 downto 0):=(OTHERS=>'0') ; --The counter for the 1KHz clock
    signal dig_count: Integer:=0; -- Used as multiplexer for diplaying of multiple displays
    constant MAX_COUNT: std_logic_vector(15 downto 0) := "1100001101010000";  -- 100,000: use this for synthesis  --  "1010";  
    signal start_btnc_prev, accept_btnl_prev, debounced_btnr, debounced_btnl: std_logic :='0';
    type my_states IS (idle,s0, s1, s2, s3); -- id: idle, st:start, s0: input 1, s1: input 2, s2: input 3, s3: input 4, re: reset
    signal state: my_states:=idle; 

     -- Get the inputted value using the position
     function getVal(rand : integer := 0) return integer is
        variable val : integer;
        begin
            if rand = 0 then val := 0;
            elsif rand = 1 then val := 4;
            elsif rand = 2 then val := 2;
            elsif rand = 3 then val := 0;
            end if;
            return val;
    end function;


    begin
        process (enable)
        begin
            if rising_edge(enable) then
                start_btnr_prev = BTNR; -- assign BTNR value to start_btnr_prev
                accept_btnl_prev = BTNL; -- assign BTNL value to accept_btnl_prev
                --Check if the first button is pressed and compare the recent button value with the previous value
                if (BTNR = '1' and start_btnr_prev = '0')' then
                    case state is
                        when Idle => if debounced_btnc = '1' then state <= s0; 
                                    else state <= Idle; end if;
                        when s2 => if debounced_btnc = '1' then state <= idle; 
                                    else state <= s2; end if;
                        when others => state <= Idle;
                    end case;
                --Check if the second button is pressed and compare the recent button value with the previous value
                elsif BTNL = '1' and accept_btnl_prev = '0
                    case state is
                        when s0 => if debounced_btnl = '1' then state <= s1;  
                                    else state <= s0; end if;
                        when s1 => if debounced_btnl = '1' then state <= s2; 
                                    else state <= s1; end if;
                        when s2 => if debounced_btnl = '1' then state <= s0;  
                                    else state <= s2; end if;
                        when others => state <= Idle;
                    end case;
                else
                    state <= Idle;
                end if;
            end if;
        end process;

        process(clk500MHz)
        begin
            if rising_edge(CLK100MHZ) then
                start_btnr_prev = BTNR;
                accept_btnl_prev = BTNL;

                count <= count + 1 ; 
                freq_count <= freq_count + "0000000000000001"; --Random number generator
              
               if state = Idle then
                    if count = MAX_COUNT THEN  -- Count to 100,000 which is the maximum value for the counter
                        enable <= '1' ; 
                        count <= (others => '0') ;
                        LEDS <= "00000000"; -- Turn off unused LEDs
                        DIGITS <= "11111111"; -- Turn off all display digits
                    else enable <= '0' ; end if ;
               elsif state = s0 then
                    --Check if the random number is within the range of 3-0 or not eaqual to the second random number
                    if (freq_count(3 downto 0) = "0001" OR freq_count(3 downto 0) = "0010" OR freq_count(3 downto 0) = "0011" OR freq_count(3 downto 0) = "0100") AND freq_count(3 downto 0) /= freq_count(11 downto 8) then
                        random1 <= freq_count(3 downto 0);
                    else freq_count <= (others => '0');
                        state <= s0; end if;
                    if count = MAX_COUNT then enable <= '1' ; 
                        count <= (others => '0') ;
                        --Display the first random number
                        display_value <= random1; 
                        DIGITS <= "11111110";
                        --get the first user input
                        user_ram_input(3 downto 0) <= SWITCHES(3 downto 0);
                    else enable <= '0' ; end if;
                elsif state = s1 then
                    random2 <= freq_count(11 downto 8);
                    --Check if the random number is within the range of 3-0 or not eaqual to the second random number
                    if (freq_count(11 downto 8) = "0001" OR freq_count(11 downto 8) = "0010" OR freq_count(11 downto 8) = "0011" OR freq_count(11 downto 8 = "0100") AND freq_count(11 downto 8) /= random1 then
                       random2 <= freq_count(11 downto 8);
                    else
                        freq_count <= (others => '0');
                        state <= s1; end if;
                    if count = MAX_COUNT then enable <= '1' ; 
                        count <= (others => '0') ;
                        --Display the first random number
                        display_value <= random2; 
                        DIGITS <= "11111110";
                        user_ram_input(7 downto 4) <= SWITCHES(3 downto 0);
                    else enable <= '0' ; end if;
                elsif state = s2 then
                    if count = MAX_COUNT then enable <= '1' ; 
                        count <= (others => '0') ;
                        --Display the first random number
                        display_value <= random2; 
                        DIGITS <= "11111110";
                        if getVal(random1) = user_ram_input(3 downto 0) && getVal(random2) = user_ram_input(7 downto 4) then
                            LEDS(7 downto 0) <= "11111111";
                            DIGITS <= "11111110"; 
                            if dig_count = 0 then display_value <= "1111";
                                DIGITS <= "11111110"; --Displays "H" on the third digit
                            elsif dig_count = 1 then display_value <= "0000";
                                DIGITS <= "11111101"; --Displays "O" on the third digit
                            end if;
                            if dig_count > 1 then dig_count <= 0;
                            else dig_count <= dig_count+1;
                            end if;
                        else
                            LEDS(7 downto 0) <= "00000000"; display_value <= "1100";
                                DIGITS <= "11111110";--Displays "r" on the third digit
                            elsif dig_count = 1 then display_value <= "1100";
                                DIGITS <= "11111101";--Displays "r" on the third digit
                            elsif dig_count = 2 then display_value <= "1110";
                                DIGITS <= "11111011";--Displays "E" on the third digit
                            end if;
                            if dig_count > 2 then dig_count <= 0;
                            else  dig_count <= dig_count+1; end if;
                        end if;

                    else enable <= '0' ;
                    end if;
                end if;
            end if;
        end process;

start_btn_debouncer: ENTITY work.Debouncer(Behavioral) PORT MAP(clk=>enable, D_BTNR=>start_btnr_prev, btnc_clr=>debounced_btnr);
accept_btn_debouncer: ENTITY work.Debounce(Behavioral) PORT MAP(clk=>enable, D_BTNL=>accept_btnl_prev, btnl_clr=>debounced_btnl);
display: ENTITY work.display(Behavioral) PORT MAP(number=> display_value, segs=> SEGMENTS);