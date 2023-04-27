library ieee;
    use ieee.std_logic_1164.all;

entity ripple_carry_adder_unsigned is 
generic (
    RCA_U_N_BITS : positive := 8
);
port(
    rca_u_a    : in std_logic_vector(RCA_U_N_BITS-1 downto 0);
    rca_u_b    : in std_logic_vector(RCA_U_N_BITS-1 downto 0);
    rca_u_sum  : out std_logic_vector(RCA_U_N_BITS-1 downto 0);
    rca_u_cout : out std_logic
);
end entity;

architecture rca_unsigned_arch of ripple_carry_adder_unsigned is 

    -- FULL ADDER
    component full_adder is 
    port (
        fa_a    : in std_logic;
        fa_b    : in std_logic;
        fa_sum  : out std_logic;
        fa_cin  : in std_logic;
        fa_cout : out std_logic
    );
    end component;

    signal cout_s   : std_logic_vector(RCA_U_N_BITS-2 downto 0);

    begin

        FA: for i in 0 to RCA_U_N_BITS-1 generate
        
            -- First full adder
            FA_FIRST: if i = 0 generate
                i_FA : full_adder port map(
                    fa_a => rca_u_a(i),
                    fa_b => rca_u_b(i),
                    fa_sum => rca_u_sum(i),
                    fa_cin => '0',
                    fa_cout => cout_s(0)
            );    
            end generate;
        
            -- Internal full adders
            FA_INTERNAL: if i > 0 and i < RCA_U_N_BITS-1 generate
                i_FA : full_adder port map(
                    fa_a => rca_u_a(i),
                    fa_b => rca_u_b(i),
                    fa_sum => rca_u_sum(i),
                    fa_cin => cout_s(i-1),
                    fa_cout => cout_s(i)
            );    
            end generate;

            -- Last full adder
            FA_LAST: if i = RCA_U_N_BITS-1 generate
                i_FA : full_adder port map(
                    fa_a => rca_u_a(i),
                    fa_b => rca_u_b(i),
                    fa_sum => rca_u_sum(i),
                    fa_cin => cout_s(i-1),
                    fa_cout => rca_u_cout
        );    
        end generate;
    end generate;

end architecture;
