library ieee;
    use ieee.std_logic_1164.all;

entity counter is 
generic ( CTR_N_BITS : positive := 8);
port(
    ctr_step    : in std_logic_vector(CTR_N_BITS-1 downto 0);
    ctr_out     : out std_logic_vector(CTR_N_BITS-1 downto 0);   
    ctr_resetn  : in std_logic;
    ctr_en      : in std_logic;
    ctr_clk     : in std_logic
);
end entity;

architecture ctr_arch of counter is 
   
    -- DFF
    component d_flip_flop is 
    generic ( DFF_N_BITS : positive );
    port (
        dff_di      : in std_logic_vector(DFF_N_BITS-1 downto 0);
        dff_do      : out std_logic_vector(DFF_N_BITS-1 downto 0);
        dff_resetn  : in std_logic;
        dff_en      : in std_logic;
        dff_clk     : in std_logic
    );
    end component;

    -- RCA unsigned
    component ripple_carry_adder_unsigned is 
    generic ( RCA_U_N_BITS : positive );
    port (
        rca_u_a    : in std_logic_vector(RCA_U_N_BITS-1 downto 0);
        rca_u_b    : in std_logic_vector(RCA_U_N_BITS-1 downto 0);
        rca_u_sum  : out std_logic_vector(RCA_U_N_BITS-1 downto 0);
        rca_u_cout : out std_logic
    );
    end component;

    signal loop_s   : std_logic_vector(CTR_N_BITS-1 downto 0);
    signal out_s    : std_logic_vector(CTR_N_BITS-1 downto 0);

begin

    -- DFF instance
    FF: d_flip_flop 
        generic map ( DFF_N_BITS => CTR_N_BITS )
        port map (
            dff_di      => loop_s,
            dff_do      => out_s,
            dff_clk     => ctr_clk,
            dff_resetn  => ctr_resetn,
            dff_en      => ctr_en
        );
    
    -- RCA instance
    RCA: ripple_carry_adder_unsigned
        generic map ( RCA_U_N_BITS => CTR_N_BITS )
        port map (
            rca_u_a    =>  ctr_step,
            rca_u_b    =>  out_s,
            rca_u_sum  =>  loop_s
            -- Cout is ignored
        );

    ctr_out <= out_s;
    
end architecture;
