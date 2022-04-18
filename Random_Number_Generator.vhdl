--On clock rise, start counting at a very hign speed

entity Random is
    RESET : in std_logic;
    clk100MHz : in std_logic;
    BTND, BTNC, BTNB : in std_logic;
end Random;

architecture Behavioral of Random is
    signal random1: std_logic_vector(3 downto 0):= "0001";
    signal random2: std_logic_vector(3 downto 0):= "0010";
    signal freq_count: STD_LOGIC_VECTOR(15 downto 0):=(OTHERS=>'0') ; 
    signal rand_no: std_logic_vector(7 downto 0):=X"02";

    begin

        process(clk100MHz)
        begin
            if rising_edge(clk100MHz) then
                start_btnb_prev = BTNB;
                accept_btnl_prev = BTNL;
               freq_count <= freq_count + "0000000000000001";
               --if button is pressed, stop the count and generate a random number
               if BTNB = '1' and start_btnb_prev = '0' then
                   random1 <= freq_count(3 downto 0);
                   random2 <= freq_count(7 downto 4);
                   if (random1 = "0001" OR random1 = "0010" OR random1 = "0011" OR random1 = "0100") AND random1 /= random2 then
                        rand_no(7 downto 4) <= random1;
                    elsif (random2 = "0001" OR random2 = "0010" OR random2 = "0011" OR random2 = "0100") AND rand /= random1 then
                        rand_no(3 downto 0) <= random2;
                    end if;
                    if rand_no(3 downto 0) > rand_no(7 downto 4) then
                        rand_no(7 downto 4) <= random2;
                        rand_no(3 downto 0) <= random1;
                    end if;
                
                end if;

            end if;
        end process;