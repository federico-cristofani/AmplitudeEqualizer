library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity half_adder_tb is
end half_adder_tb;

architecture ha_tb of half_adder_tb is 
    constant CLK_PERIOD : time := 100 ns;
   
    component half_adder is port(
        ha_a    :   in std_logic;
        ha_b    :   in std_logic;
        ha_sum  :   out std_logic;
        ha_cout :   out std_logic
    );
    end component;

    signal a_tb     : std_logic := '0';
    signal b_tb     : std_logic := '0';
    signal sum_tb   : std_logic;
    signal cout_tb  : std_logic;
       
    -- Testing
    signal clk_tb   : std_logic := '0';
    signal testing  : boolean := true;
    
begin         
    DUT: half_adder
    port map(
        ha_a => a_tb,
        ha_b => b_tb,
        ha_sum => sum_tb,
        ha_cout => cout_tb
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
                when 1 =>
                    a_tb <= '0';
                    b_tb <= '1';
                when 2 =>
                    a_tb <= '1';
                    b_tb <= '0';
                when 3 =>
                    a_tb <= '1';
                    b_tb <= '1';
                when others => 
                    report("End simulation"); 
                    testing <= false;
            end case;
            t := t + 1;
        end if;
    end process;

end architecture;