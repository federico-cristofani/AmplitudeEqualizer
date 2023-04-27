library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity ripple_carry_adder_unsigned_tb is
end ripple_carry_adder_unsigned_tb;

architecture rca_u_tb of ripple_carry_adder_unsigned_tb is 

    constant N_BITS     : positive := 8;
    constant CLK_PERIOD : time := 100 ns;

    component ripple_carry_adder_unsigned is 
    generic (
       RCA_U_N_BITS : positive := 8
    );
    port(
        rca_u_a    : in std_logic_vector(RCA_U_N_BITS-1 downto 0);
        rca_u_b    : in std_logic_vector(RCA_U_N_BITS-1 downto 0);
        rca_u_sum  : out std_logic_vector(RCA_U_N_BITS-1 downto 0);
        rca_u_cout : out std_logic
    );
    end component;

    signal a_tb     : std_logic_vector(N_BITS-1 downto 0) := std_logic_vector(to_unsigned(0, N_BITS));
    signal b_tb     : std_logic_vector(N_BITS-1 downto 0) := std_logic_vector(to_unsigned(0, N_BITS));
    signal sum_tb   : std_logic_vector(N_BITS-1 downto 0);
    signal cout_tb  : std_logic;
    signal clk_tb   : std_logic := '0';

    -- Simulation only
    signal testing  : boolean := true;
begin         

    clk_tb <= not clk_tb after CLK_PERIOD/2 when testing else '0';
    
    DUT: ripple_carry_adder_unsigned
        generic map(
           RCA_U_N_BITS => N_BITS
        )
        port map (
            rca_u_a => a_tb,
            rca_u_b => b_tb,
            rca_u_sum => sum_tb,
            rca_u_cout => cout_tb
        );

    STIMULI : process(clk_tb)
        variable t : integer := 0;
    begin
        if rising_edge(clk_tb) then
            case(t) is  
                when 0 =>
                    report("Start simulation");
                    a_tb <= std_logic_vector(to_unsigned(10, N_BITS));
                    b_tb <= std_logic_vector(to_unsigned(5, N_BITS));
                when 1 =>
                    a_tb <= std_logic_vector(to_unsigned(5, N_BITS));
                    b_tb <= std_logic_vector(to_unsigned(10, N_BITS));
                when 2 =>
                    a_tb <= std_logic_vector(to_unsigned(255, N_BITS));
                    b_tb <= std_logic_vector(to_unsigned(0, N_BITS));
                when 3 =>
                    a_tb <= std_logic_vector(to_unsigned(255, N_BITS));
                    b_tb <= std_logic_vector(to_unsigned(1, N_BITS));
                when 4 =>
                    a_tb <= std_logic_vector(to_unsigned(0, N_BITS));
                    b_tb <= std_logic_vector(to_unsigned(0, N_BITS));
                when 5 =>
                    a_tb <= std_logic_vector(to_unsigned(255, N_BITS));
                    b_tb <= std_logic_vector(to_unsigned(255, N_BITS));
                when 6 =>
                    a_tb <= std_logic_vector(to_unsigned(255, N_BITS));
                    b_tb <= std_logic_vector(to_unsigned(0, N_BITS));
                when others => 
                    report("End simulation"); 
                    testing <= false;
            end case;
            t := t + 1;
        end if;
    end process;
end architecture;