library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity absolute_value_tb is
end absolute_value_tb;

architecture abs_tb of absolute_value_tb is 
    constant CLK_PERIOD : time := 100 ns;
    constant N_BITS : positive := 8;

    component absolute_value is 
    generic( 
        ABS_N_BITS   : positive 
    );  
    port(
        abs_x   : in std_logic_vector(ABS_N_BITS-1 downto 0);
        abs_y   : out std_logic_vector(ABS_N_BITS-1 downto 0);
        abs_ow  : out std_logic
    );
    end component;

    signal x_tb     : std_logic_vector(N_BITS-1 downto 0) := std_logic_vector(to_signed(0, N_BITS));
    signal y_tb     : std_logic_vector(N_BITS-1 downto 0);
    signal ow_tb    : std_logic;
    signal clk_tb   : std_logic := '0';

    -- Testing
    signal testing  : boolean := true;
    
begin         
    DUT: absolute_value
    generic map(ABS_N_BITS => N_BITS)
    port map(
        abs_x   => x_tb,
        abs_y   => y_tb,
        abs_ow  => ow_tb
    );

    clk_tb <= not clk_tb after CLK_PERIOD/2 when testing else '1';

    STIMULI : process(clk_tb)
    variable t : integer := 0;
    begin
        if rising_edge(clk_tb) then
            case(t) is  
                when 0 =>
                    report("Start simulation");
                    x_tb <= std_logic_vector(to_signed(10, N_BITS));
                when 1 =>
                    x_tb <= std_logic_vector(to_signed(-10, N_BITS));
                when 2 =>
                    x_tb <= std_logic_vector(to_signed(0, N_BITS));
                when 3 =>
                    x_tb <= std_logic_vector(to_signed(-1, N_BITS));
                when 4 =>
                    x_tb <= std_logic_vector(to_signed(-128, N_BITS));
                when 5 =>
                    x_tb <= std_logic_vector(to_signed(127, N_BITS));
                when others => 
                    report("End simulation"); 
                    testing <= false;
            end case;
            t := t + 1;
        end if;
    end process;

end architecture;