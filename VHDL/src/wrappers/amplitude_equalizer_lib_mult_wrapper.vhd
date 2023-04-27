library ieee;
    use ieee.std_logic_1164.all;

entity amplitude_equalizer_lib_mult_wrapper is
generic(
    N_BITS               : positive := 8;
    OUT_N_BITS           : positive := 16;
    REFERENCE_N_BITS     : positive := 14;
    ACCUMULATOR_N_BITS   : positive := 20;
    DOWNSAMPLING_FACTOR  : positive := 2;
    PERIOD_N_SAMPLES     : positive := 8;
    PHASE_REFERENCE      : std_logic_vector := "10000011"
);
port(
    X       : in std_logic_vector(N_BITS-1 downto 0);
    Y       : out std_logic_vector(OUT_N_BITS-1 downto 0);
    R       : in std_logic_vector(REFERENCE_N_BITS-1 downto 0);
    clk     : in std_logic;
    rst     : in std_logic
);
end entity;

architecture ae_wrap_arch of amplitude_equalizer_lib_mult_wrapper is

	component amplitude_equalizer_lib_mult is
		generic(
			AE_N_BITS               : positive;
			AE_OUT_N_BITS           : positive;
			AE_REFERENCE_N_BITS     : positive;
			AE_ACCUMULATOR_N_BITS   : positive;
			AE_DOWNSAMPLING_FACTOR  : positive; 
			AE_PERIOD_N_SAMPLES     : positive; 
			AE_PHASE_REFERENCE      : std_logic_vector    
		);
		port(
			ae_clk 		: in std_logic;
			ae_resetn 	: in std_logic;
			ae_ref		: in std_logic_vector(AE_REFERENCE_N_BITS-1 downto 0);
			ae_x   		: in std_logic_vector(AE_N_BITS-1 downto 0);
			ae_y   		: out std_logic_vector(AE_OUT_N_BITS-1 downto 0)
		);
	end component;

    component d_flip_flop is 
    generic (
        DFF_N_BITS : positive
    );
    port(
        dff_di      :   in std_logic_vector(DFF_N_BITS-1 downto 0);
        dff_do      :   out std_logic_vector(DFF_N_BITS-1 downto 0);
        dff_resetn  :   in std_logic;
        dff_en      :   in std_logic;
        dff_clk     :   in std_logic
    );
    end component;

    signal resetn   : std_logic;
    signal X_reg    : std_logic_vector(N_BITS-1 downto 0);
    signal Y_reg    : std_logic_vector(OUT_N_BITS-1 downto 0);    
begin

    resetn <= not rst;

    -- Input register barrier
    INPUT_REG: d_flip_flop
        generic map(
            DFF_N_BITS => N_BITS
        )
        port map(
            dff_di     => X,
            dff_do     => X_reg,
            dff_resetn => resetn,
            dff_en     => '1',
            dff_clk    => clk
        );

    -- Output register barrier
    OUTPUT_REG: d_flip_flop
        generic map(
            DFF_N_BITS => OUT_N_BITS
        )
        port map(
            dff_di     => Y_reg,
            dff_do     => Y,
            dff_resetn => resetn,
            dff_en     => '1',
            dff_clk    => clk
        );


    -- Amplitude Equalizer
    AE : amplitude_equalizer_lib_mult
    generic map (
        AE_N_BITS             	=> N_BITS,
        AE_OUT_N_BITS         	=> OUT_N_BITS,
        AE_REFERENCE_N_BITS   	=> REFERENCE_N_BITS,
        AE_ACCUMULATOR_N_BITS 	=> ACCUMULATOR_N_BITS,
        AE_DOWNSAMPLING_FACTOR	=> DOWNSAMPLING_FACTOR,
        AE_PERIOD_N_SAMPLES   	=> PERIOD_N_SAMPLES,
        AE_PHASE_REFERENCE    	=> PHASE_REFERENCE
    )
    port map (
        ae_x    	=> X_reg,
        ae_y    	=> Y_reg,
        ae_ref		=> R,
        ae_clk  	=> clk,
        ae_resetn  	=> resetn
    );

end architecture ;