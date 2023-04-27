library ieee;
    use ieee.std_logic_1164.all;

entity subtractor_signed_ext is 
generic (
    SUB_SE_N_BITS  : positive := 8
);
port(
    sub_se_a       : in std_logic_vector(SUB_SE_N_BITS-1 downto 0);
    sub_se_b       : in std_logic_vector(SUB_SE_N_BITS-1 downto 0);
    sub_se_diff    : out std_logic_vector(SUB_SE_N_BITS downto 0)
    -- No need for Bout because the extension allows to represents all possibile results 
);
end entity;

architecture sub_se_arch of subtractor_signed_ext is 

    component ripple_carry_adder_unsigned is 
    generic (
        RCA_U_N_BITS : positive
    );
    port(
        rca_u_a    : in std_logic_vector(RCA_U_N_BITS-1 downto 0);
        rca_u_b    : in std_logic_vector(RCA_U_N_BITS-1 downto 0);
        rca_u_sum  : out std_logic_vector(RCA_U_N_BITS-1 downto 0);
        rca_u_cout : out std_logic
    );
    end component;

    signal sub_se_b_neg_s      : std_logic_vector(SUB_SE_N_BITS-1 downto 0);
    signal sub_se_a_ext_s      : std_logic_vector(SUB_SE_N_BITS downto 0);
    signal sub_se_b_neg_ext_s  : std_logic_vector(SUB_SE_N_BITS downto 0);
begin

    -- Negate the subtrahend in order to use the RCA to perform subtraction 
    sub_se_b_neg_s <= not(sub_se_b);

    -- Extends the operands (2's complement sign extension)
    sub_se_a_ext_s <= sub_se_a(SUB_SE_N_BITS - 1) & sub_se_a;
    sub_se_b_neg_ext_s <= sub_se_b_neg_s(SUB_SE_N_BITS - 1) & sub_se_b_neg_s;

    -- RCA extended to accomodate each possible result (the Cout can be ignored)
    RCA: ripple_carry_adder_unsigned
    generic map ( 
        RCA_U_N_BITS  => SUB_SE_N_BITS + 1
    )
    port map (
        rca_u_a     => sub_se_a_ext_s,
        rca_u_b     => sub_se_b_neg_ext_s,
        rca_u_sum   => sub_se_diff
        -- no overlflow is possible due to the extension
    );

end architecture;
