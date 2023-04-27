library ieee;
    use ieee.std_logic_1164.all;

entity downsampler is 
generic ( 
    DWS_N_BITS              : positive := 8;
    DWS_CTR_N_BITS          : positive := 2   
);
port(
    dws_input   : in std_logic_vector(DWS_N_BITS-1 downto 0);
    dws_output	: out std_logic_vector(DWS_N_BITS-1 downto 0);
    dws_peak  	: out std_logic;
    dws_resetn  : in std_logic;
    dws_en      : in std_logic;
    dws_clk     : in std_logic
);
end entity;

architecture dws_arch of downsampler is 

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

    -- COUNTER
    component counter is 
    generic ( CTR_N_BITS : positive);
    port(
        ctr_step    : in std_logic_vector(CTR_N_BITS-1 downto 0);
        ctr_out     : out std_logic_vector(CTR_N_BITS-1 downto 0);   
        ctr_resetn  : in std_logic;
        ctr_en      : in std_logic;
        ctr_clk     : in std_logic
    );
    end component;

    signal peak_reg_in_s    : std_logic_vector(DWS_N_BITS-1 downto 0);
    signal peak_reg_out_s   : std_logic_vector(DWS_N_BITS-1 downto 0);
    signal ctr_step_s       : std_logic_vector(DWS_CTR_N_BITS-1 downto 0);
    signal ctr_out_s        : std_logic_vector(DWS_CTR_N_BITS-1 downto 0);
    signal flag_reg_in_s    : std_logic_vector(0 downto 0); -- 1 bit only, it's required a std_logic_vector 
    signal flag_reg_out_s    : std_logic_vector(0 downto 0); -- 1 bit only, it's required a std_logic_vector 

    
begin
    -- OUTPUT DFF instance
    OUT_FF: d_flip_flop 
        generic map ( DFF_N_BITS => DWS_N_BITS )
        port map (
            dff_di      => peak_reg_in_s,
            dff_do      => peak_reg_out_s,
            dff_clk     => dws_clk,
            dff_resetn  => dws_resetn,
            dff_en      => dws_en
        );

    -- PEAK FLAG DFF instance
    PEAK_FF: d_flip_flop 
    generic map ( DFF_N_BITS => 1 )
    port map (
        dff_di      => flag_reg_in_s,
        dff_do      => flag_reg_out_s,
        dff_clk     => dws_clk,
        dff_resetn  => dws_resetn,
        dff_en      => dws_en
    );
    
    -- CTR instance
    CTR: counter
        generic map( CTR_N_BITS => DWS_CTR_N_BITS)
        port map(
            ctr_step    => ctr_step_s,  
            ctr_out     => ctr_out_s,     
            ctr_resetn  => dws_resetn,
            ctr_en      => dws_en,
            ctr_clk     => dws_clk 
        );

    -- Step is fixed to 1
    ctr_step_s <= (DWS_CTR_N_BITS-1 downto 1 => '0') & '1';

    -- Memorize peak value (new peak when counter = 0)
    peak_reg_in_s <= dws_input when (ctr_out_s = (DWS_CTR_N_BITS-1 downto 0  => '0')) else peak_reg_out_s; 

    -- Update output sample (1 clock delay)
    dws_output <=  peak_reg_out_s;
    
    -- Peak flag: '1' if counter = 0 and en = '1', '0' otherwise
    flag_reg_in_s(0) <= dws_en when (ctr_out_s = (DWS_CTR_N_BITS-1 downto 0  => '0')) else '0';
    
    -- Update peak flag output (1 clock delay)
    dws_peak <= flag_reg_out_s(0);
    
end architecture;
