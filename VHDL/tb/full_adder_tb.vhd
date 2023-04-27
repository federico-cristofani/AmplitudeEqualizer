library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder_tb is
end full_adder_tb;

architecture fa_tb of full_adder_tb is 
    constant CLK_PERIOD : time := 100 ns;
   
    component full_adder is port(
        fa_a    :   in std_logic;
        fa_b    :   in std_logic;
        fa_cin  :   in std_logic;
        fa_sum  :   out std_logic;
        fa_cout :   out std_logic
    );
    end component;

    signal a_tb             : std_logic := '0';
    signal b_tb             : std_logic := '0';
    signal cin_tb           : std_logic := '0';
    signal sum_tb, cout_tb  : std_logic;
    signal clk_tb           : std_logic := '0';
    signal testing          : boolean := true;
    
begin         
    DUT: full_adder
    port map(
        fa_a => a_tb,
        fa_b => b_tb,
        fa_sum => sum_tb,
        fa_cin => cin_tb,
        fa_cout => cout_tb
    );

    clk_tb <= not clk_tb after CLK_PERIOD/2 when testing else '1';

    STIMULI : process(clk_tb)
    variable t : integer := 0;
    begin
        if rising_edge(clk_tb) then
            case(t) is  
                when 0 =>
                    report("Start simulation");
                    a_tb <= '0';
                    b_tb <= '0';
                    cin_tb <= '0';
                when 1 =>
                    a_tb <= '0';
                    b_tb <= '0';
                    cin_tb <= '1';
                when 2 =>
                    a_tb <= '0';
                    b_tb <= '1';
                    cin_tb <= '0';
                when 3 =>
                    a_tb <= '0';
                    b_tb <= '1';
                    cin_tb <= '1';
                when 4 =>
                    a_tb <= '1';
                    b_tb <= '0';
                    cin_tb <= '0';               
                when 5 =>
                    a_tb <= '1';
                    b_tb <= '0';
                    cin_tb <= '1';
                when 6 =>
                    a_tb <= '1';
                    b_tb <= '1';
                    cin_tb <= '0';
                when 7 =>
                    a_tb <= '1';
                    b_tb <= '1';
                    cin_tb <= '1';
                when others => 
                    report("End simulation"); 
                    testing <= false;
            end case;
            t := t + 1;
        end if;
    end process;

end architecture;