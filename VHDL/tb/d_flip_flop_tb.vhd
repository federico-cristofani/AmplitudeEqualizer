library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity d_flip_flop_tb is
end d_flip_flop_tb;

architecture dff_tb of d_flip_flop_tb is 

    constant N_BITS : positive := 8;
    constant CLK_PERIOD : time := 100 ns;
    constant SIM_CLK_CYCLES : positive := 100;

    component d_flip_flop is 
    generic (
        DFF_N_BITS : positive
    );
    port (
        dff_di      : in std_logic_vector(DFF_N_BITS-1 downto 0);
        dff_do      : out std_logic_vector(DFF_N_BITS-1 downto 0);
        dff_resetn  : in std_logic;
        dff_en      : in std_logic;
        dff_clk     : in std_logic
    );
    end component;

    signal di_tb        : std_logic_vector(N_BITS-1 downto 0) := std_logic_vector(to_unsigned(0, N_BITS));
    signal do_tb        : std_logic_vector(N_BITS-1 downto 0);
    signal resetn_tb    : std_logic := '0';
    signal en_tb        : std_logic := '1';
    signal clk_tb       : std_logic := '0';

    -- Simulation only
    signal testing      : boolean := true;

begin         

    clk_tb <= not clk_tb after CLK_PERIOD/2 when testing else '1';

    DUT: d_flip_flop
        generic map(
            DFF_N_BITS => N_BITS
        )
        port map (
            dff_di      => di_tb,
            dff_do      => do_tb,
            dff_resetn  => resetn_tb,
            dff_en      => en_tb,
            dff_clk     => clk_tb
        );
    
    STIMULI : process(clk_tb)
    variable t : integer := 0;
    begin
        if rising_edge(clk_tb) then
            case(t) is  
                when 0 =>
                    report("Start simulation");
                    resetn_tb <= '1';
                when SIM_CLK_CYCLES / 2 =>
                    en_tb <= '0';
                when SIM_CLK_CYCLES - 1 => 
                    report("Reset");
                    en_tb <= '1';
                    resetn_tb <= '0';
                when SIM_CLK_CYCLES => 
                    report("End simulation"); 
                    testing <= false;
                when others => 
                    di_tb <= std_logic_vector(to_unsigned(t, N_BITS));
            end case;
            t := t + 1;
        end if;
    end process;
end architecture;