library IEEE;
	use ieee.std_logic_1164.all;

entity parallel_multiplier_signed_ext is
generic (
    PM_ES_N_BITS : positive := 8
);
port ( 
    pm_es_a     : in  std_logic_vector (PM_ES_N_BITS-1 downto 0);
    pm_es_b     : in  std_logic_vector (PM_ES_N_BITS-1 downto 0);
    pm_es_prod	: out std_logic_vector (PM_ES_N_BITS*2 - 1 downto 0)
);
end entity; 

architecture pm_es_arch of parallel_multiplier_signed_ext is

    constant PM_ES_OUT_N_BITS : positive := PM_ES_N_BITS*2;

    -- PARALLEL MULTIPLIER
    component parallel_multiplier_ext is
        generic (
            PM_E_N_BITS : positive := 8
        );
        port ( 
            pm_e_a 		: in  std_logic_vector (PM_E_N_BITS-1 downto 0);
            pm_e_b 		: in  std_logic_vector (PM_E_N_BITS-1 downto 0);
            pm_e_prod	: out std_logic_vector (PM_E_N_BITS*2 - 1 downto 0)
        );
    end component;

    -- INCREMENTER (needed for sign inversion)
    component incrementer is 
    generic ( INC_N_BITS : positive );
    port(
        inc_a   : in std_logic_vector(INC_N_BITS-1 downto 0);
        inc_sum : out std_logic_vector(INC_N_BITS-1 downto 0);
        inc_ow  : out std_logic
    );
    end component;
    
    -- ABS
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

    signal abs_a_s          : std_logic_vector(PM_ES_N_BITS-1 downto 0);        
    signal abs_b_s          : std_logic_vector(PM_ES_N_BITS-1 downto 0); 
    signal abs_prod_s       : std_logic_vector(PM_ES_OUT_N_BITS-1 downto 0);
    signal abs_prod_inv_s   : std_logic_vector(PM_ES_OUT_N_BITS-1 downto 0);
    signal neg_prod_s       : std_logic_vector(PM_ES_OUT_N_BITS-1 downto 0);

begin

    abs_prod_inv_s <= not abs_prod_s;

    -- First factor multiplication
    ABS_A: absolute_value
    generic map(
        ABS_N_BITS => PM_ES_N_BITS
    )
    port map(
        abs_x  => pm_es_a,
        abs_y  => abs_a_s
    );

    -- Second factor multiplication
    ABS_B: absolute_value
    generic map(
        ABS_N_BITS => PM_ES_N_BITS
    )
    port map(
        abs_x  => pm_es_b,
        abs_y  => abs_b_s
    );

    -- Negate output
    INC: incrementer
    generic map(
        INC_N_BITS => PM_ES_OUT_N_BITS
    )
    port map(
        inc_a   => abs_prod_inv_s,
        inc_sum => neg_prod_s
    );

    -- Unsigned multiplier
    MULT: parallel_multiplier_ext
    generic map(
        PM_E_N_BITS  => PM_ES_N_BITS
    )
    port map(
        pm_e_a 		=> abs_a_s,
        pm_e_b 	    => abs_b_s,
        pm_e_prod   => abs_prod_s
    );
    
    -- Choose the sign of the output, based on the sign of the input factors
    pm_es_prod <= abs_prod_s when ((pm_es_a(PM_ES_N_BITS-1) xor pm_es_b(PM_ES_N_BITS-1)) = '0') else neg_prod_s;

end architecture;

