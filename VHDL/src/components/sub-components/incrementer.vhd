library ieee;
    use ieee.std_logic_1164.all;

entity incrementer is 
generic (
    INC_N_BITS : positive := 8
);
port(
    inc_a   : in std_logic_vector(INC_N_BITS-1 downto 0);
    inc_sum : out std_logic_vector(INC_N_BITS-1 downto 0);
    inc_ow  : out std_logic
);
end entity;

architecture inc_arch of incrementer is 
    
    -- HALF ADDER
    component half_adder is port(
        ha_a    : in std_logic;
        ha_b    : in std_logic;
        ha_sum  : out std_logic;
        ha_cout : out std_logic
    );
    end component;

    signal cout_s       : std_logic_vector(INC_N_BITS-2 downto 0);
    signal inc_sum_s    : std_logic;

begin

    FA: for i in 0 to INC_N_BITS-1 generate
    
        -- First half adder
        FA_FIRST: if i = 0 generate
            i_FA : half_adder port map(
                ha_a    => inc_a(i),
                ha_b    => '1',     
                ha_sum  => inc_sum(i),
                ha_cout => cout_s(0)
        );    
        end generate;
    
        -- Internal half adders
        FA_INTERNAL: if i > 0 and i < INC_N_BITS-1 generate
            i_FA : half_adder port map(
                ha_a    => inc_a(i),
                ha_b    => cout_s(i-1),
                ha_sum  => inc_sum(i),
                ha_cout => cout_s(i)
        );    
        end generate;

        -- Last half adder
        FA_LAST: if i = INC_N_BITS-1 generate
            i_FA : half_adder port map(
                ha_a    => inc_a(i),
                ha_b    => cout_s(i-1),
                ha_sum  => inc_sum_s
        );    
        end generate;
    end generate;

    inc_ow <= not inc_a(INC_N_BITS-1) and inc_sum_s; -- Overflow when positive input -> negative output
    inc_sum(INC_N_BITS-1) <= inc_sum_s;

end architecture;
