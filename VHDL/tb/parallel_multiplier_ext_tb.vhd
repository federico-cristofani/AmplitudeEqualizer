library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity parallel_multiplier_ext_tb is
end parallel_multiplier_ext_tb;

architecture pm_e_tb of parallel_multiplier_ext_tb is 

    constant N_BITS     : positive := 4;
    constant CLK_PERIOD : time := 100 ns;

    component parallel_multiplier_ext is
        generic (
            PM_E_N_BITS : positive
        );
        port ( 
            pm_e_a 		: in  std_logic_vector (PM_E_N_BITS-1 downto 0);
            pm_e_b 		: in  std_logic_vector (PM_E_N_BITS-1 downto 0);
            pm_e_prod	: out std_logic_vector (PM_E_N_BITS*2 - 1 downto 0)
        );
    end component;

    signal a_tb     : std_logic_vector(N_BITS-1 downto 0) := std_logic_vector(to_signed(0, N_BITS));
    signal b_tb     : std_logic_vector(N_BITS-1 downto 0) := std_logic_vector(to_signed(0, N_BITS));
    signal prod_tb  : std_logic_vector(N_BITS*2-1 downto 0);
    signal clk_tb   : std_logic := '0';

    -- Testing only
    signal testing  : boolean := true;

begin         

    clk_tb <= not clk_tb after CLK_PERIOD/2 when testing else '0';
    
    DUT: parallel_multiplier_ext
        generic map(
            PM_E_N_BITS  => N_BITS
        )
        port map (
            pm_e_a 		=> a_tb,
            pm_e_b 		=> b_tb,
            pm_e_prod   => prod_tb
        );

    STIMULI : process(clk_tb)
        variable t : integer := 0;
    begin
        if rising_edge(clk_tb) then
            case(t) is  
                when 0 => 
                    report("Start simulation");
                    a_tb <= std_logic_vector(to_unsigned(10, N_BITS));
                    b_tb <= std_logic_vector(to_unsigned(15, N_BITS));
                when 1 =>
                    a_tb <= std_logic_vector(to_unsigned(15, N_BITS));
                    b_tb <= std_logic_vector(to_unsigned(10, N_BITS));
                when 2 => 
                    a_tb <= std_logic_vector(to_unsigned(15, N_BITS));
                    b_tb <= std_logic_vector(to_unsigned(15, N_BITS));
                when 3 => 
                    a_tb <= std_logic_vector(to_unsigned(0, N_BITS));
                    b_tb <= std_logic_vector(to_unsigned(15, N_BITS));
                when others => 
                    report("End simulation"); 
                    testing <= false;
            end case;
            t := t + 1;
        end if;
    end process;
end architecture;