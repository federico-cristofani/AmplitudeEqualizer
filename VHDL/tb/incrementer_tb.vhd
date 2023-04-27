library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity incrementer_tb is
end incrementer_tb;

architecture fa_tb of incrementer_tb is 
    constant CLK_PERIOD : time := 100 ns;
    constant N_BITS : positive := 8;

    component incrementer is 
    generic (
        INC_N_BITS : positive
    );
    port(
        inc_a   : in std_logic_vector(INC_N_BITS-1 downto 0);
        inc_sum : out std_logic_vector(INC_N_BITS-1 downto 0);
        inc_ow  : out std_logic
    );
    end component;

    signal a_tb     : std_logic_vector(N_BITS-1 downto 0) := std_logic_vector(to_signed(0, N_BITS));
    signal sum_tb   : std_logic_vector(N_BITS-1 downto 0);
    signal ow_tb    : std_logic;
    signal clk_tb   : std_logic := '0';

    -- Testing
    signal testing  : boolean := true;
    
begin         
    DUT: incrementer
    generic map(INC_N_BITS => N_BITS)
    port map(
        inc_a   => a_tb,
        inc_sum => sum_tb,
        inc_ow  => ow_tb
    );

    clk_tb <= not clk_tb after CLK_PERIOD/2 when testing else '1';

    STIMULI : process(clk_tb)
    variable t : integer := 0;
    begin
        if rising_edge(clk_tb) then
            case(t) is  
                when 0 =>
                    report("Start simulation");
                    a_tb <= std_logic_vector(to_signed(0, N_BITS));
                when 1 =>
                    a_tb <= std_logic_vector(to_signed(1, N_BITS));
                when 2 =>
                    a_tb <= std_logic_vector(to_signed(-1, N_BITS));
                when 3 =>
                    a_tb <= std_logic_vector(to_signed(-128, N_BITS));
                when 4 =>
                    a_tb <= std_logic_vector(to_signed(127, N_BITS));
                when others => 
                    report("End simulation"); 
                    testing <= false;
            end case;
            t := t + 1;
        end if;
    end process;

end architecture;