library ieee;
    use ieee.std_logic_1164.all;

entity accumulator is
generic(
    ACC_N_BITS          : positive := 20;
    ACC_FACTOR_N_BITS   : positive := 8
);
port(
    acc_step    : in std_logic_vector(ACC_N_BITS-1 downto 0);
    acc_c_fact  : out std_logic_vector(ACC_FACTOR_N_BITS-1 downto 0);
    acc_keepn   : in std_logic; -- Active low signal
    acc_clk     : in std_logic;
    acc_resetn  : in std_logic
);
end entity;

architecture acc_arch of accumulator is    
    -- COUNTER
    component counter is 
    generic ( CTR_N_BITS : positive := 8);
    port(
        ctr_step    : in std_logic_vector(CTR_N_BITS-1 downto 0);
        ctr_out     : out std_logic_vector(CTR_N_BITS-1 downto 0);   
        ctr_resetn  : in std_logic;
        ctr_en      : in std_logic;
        ctr_clk     : in std_logic
    );
    end component;

    signal c_fact_ext_s : std_logic_vector(ACC_N_BITS-1 downto 0);

begin     
    -- The counter is enabled only when keep = '1', otherwise the counter holds the value reached
    CTR: counter
    generic map(
        CTR_N_BITS => ACC_N_BITS
    )
    port map(
        ctr_step    => acc_step,
        ctr_out     => c_fact_ext_s,
        ctr_resetn  => acc_resetn,
        ctr_en      => acc_keepn,
        ctr_clk     => acc_clk
    );

    -- Tout: truncate correction factor, keeping the MSBs bits
    -- If the sign of the signal (the MSB) is flipped the circuit will produce a wrong result (more details in the docs)
    acc_c_fact <= c_fact_ext_s(ACC_N_BITS-1 downto ACC_N_BITS-ACC_FACTOR_N_BITS); 
end architecture;