library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity subtractor_signed_ext_tb is
end subtractor_signed_ext_tb;

architecture sub_ext_tb of subtractor_signed_ext_tb is 

    constant N_BITS     : positive := 8;
    constant CLK_PERIOD : time := 100 ns;

    component subtractor_signed_ext is 
    generic (
        SUB_SE_N_BITS  : positive
    );
    port(
        sub_se_a       : in std_logic_vector(SUB_SE_N_BITS-1 downto 0);
        sub_se_b       : in std_logic_vector(SUB_SE_N_BITS-1 downto 0);
        sub_se_diff    : out std_logic_vector(SUB_SE_N_BITS downto 0)
    );
    end component;

    signal a_tb     : std_logic_vector(N_BITS-1 downto 0) := std_logic_vector(to_signed(0, N_BITS));
    signal b_tb     : std_logic_vector(N_BITS-1 downto 0) := std_logic_vector(to_signed(0, N_BITS));
    signal diff_tb  : std_logic_vector(N_BITS downto 0);
    signal clk_tb   : std_logic := '0';

    -- Testing only
    signal testing  : boolean := true;

begin         

    clk_tb <= not clk_tb after CLK_PERIOD/2 when testing else '0';
    
    DUT: subtractor_signed_ext
        generic map(
            SUB_SE_N_BITS  => N_BITS
        )
        port map (
            sub_se_a    => a_tb,
            sub_se_b    => b_tb,
            sub_se_diff => diff_tb
        );

    STIMULI : process(clk_tb)
        variable t : integer := 0;
    begin
        if rising_edge(clk_tb) then
            case(t) is  
                when 0 => -- Test A-B => 5
                    report("Start simulation");
                    a_tb <= std_logic_vector(to_signed(10, N_BITS));
                    b_tb <= std_logic_vector(to_unsigned(5, N_BITS));
                when 1 => -- Test B-A => -5
                    a_tb <= std_logic_vector(to_signed(5, N_BITS));
                    b_tb <= std_logic_vector(to_signed(10, N_BITS));
                when 2 => -- Test MaxPositive - 0 => 127
                    a_tb <= std_logic_vector(to_signed(127, N_BITS));
                    b_tb <= std_logic_vector(to_signed(0, N_BITS));
                when 3 => -- Test MinNegative - 1 => -129
                    a_tb <= std_logic_vector(to_signed(-128, N_BITS));
                    b_tb <= std_logic_vector(to_signed(1, N_BITS));
                when 4 => -- Test A-(-B) => +15
                    a_tb <= std_logic_vector(to_signed(10, N_BITS));
                    b_tb <= std_logic_vector(to_signed(-5, N_BITS));
                when 5 => -- Test -A-B => -15
                    a_tb <= std_logic_vector(to_signed(-10, N_BITS));
                    b_tb <= std_logic_vector(to_signed(5, N_BITS));
                when 6 => -- Test MinNegative - MaxPositive (Min) => -255
                    a_tb <= std_logic_vector(to_signed(-128, N_BITS));
                    b_tb <= std_logic_vector(to_signed(127, N_BITS));
                when 7 => -- Test MinNegative - MinNegative (Min) => 0
                    a_tb <= std_logic_vector(to_signed(-128, N_BITS));
                    b_tb <= std_logic_vector(to_signed(-128, N_BITS));
                when 8 => -- Test Bin => -1
                    a_tb <= std_logic_vector(to_signed(1, N_BITS));
                    b_tb <= std_logic_vector(to_signed(1, N_BITS));
                when 9 => -- Test Bin => -1
                    a_tb <= std_logic_vector(to_signed(-1, N_BITS));
                    b_tb <= std_logic_vector(to_signed(-1, N_BITS));
                when others => 
                    report("End simulation"); 
                    testing <= false;
            end case;
            t := t + 1;
        end if;
    end process;
end architecture;