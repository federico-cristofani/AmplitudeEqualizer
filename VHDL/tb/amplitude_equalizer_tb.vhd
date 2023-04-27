library IEEE;
	use IEEE.std_logic_1164.all;
	use ieee.numeric_std.all;

entity amplitude_equalizer_tb is
end entity;

architecture ae_tb of amplitude_equalizer_tb is 

	constant CLK_PERIOD		: time := 100 ns;
	constant SIM_CLK_CYCLES	: positive	:= 2 * 10**4;

	-- Components sizing
	constant N_BITS					: positive := 8;				-- From specifications
	constant OUT_N_BITS				: positive := N_BITS * 2;		-- No overflow
	constant REFERENCE_N_BITS 		: positive := (N_BITS-1) * 2; 	-- Max reachable value due to the sizing of the other signals
	constant ACCUMULATOR_N_BITS		: positive := 20;				-- From specifications
	constant DOWNSAMPLING_FACTOR	: positive := 2;				-- Sample on peak every 4 samples (2 peaks every period of 8 samples)
	constant PERIOD_N_SAMPLES		: positive := 8; 				-- From specifications
	constant PHASE_REFERENCE		: std_logic_vector := "10000011"; -- Considering 8 samples per period 

	-- Testing
	constant REFERENCE			: std_logic_vector := std_logic_vector(to_unsigned(1023, REFERENCE_N_BITS));
	constant PHASE				: natural := 1; 	-- Phase shifting
	constant AMPLITUDE_SCALE	: positive := 2;	-- Amplitude multiplier

	type triangle is array (natural range PERIOD_N_SAMPLES-1 downto 0) of integer;  
	constant TRIANGLE_WAVE : triangle := (
		0 => -10,
		1 => -5,
		2 => 0,
		3 => 5,
		4 => 10,
		5 => 5, 
		6 => 0,
		7 => -5
	);
    
	-- AMPLITUDE EQUALIZER
	component amplitude_equalizer is
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

	-- Test signals
    signal x_tb 		: std_logic_vector(N_BITS -1 downto 0) := std_logic_vector(to_unsigned(0, N_BITS));
	signal y_tb 		: std_logic_vector(OUT_N_BITS - 1 downto 0);
	signal reference_tb : std_logic_vector(REFERENCE_N_BITS-1 downto 0) := REFERENCE;
    signal resetn_tb	: std_logic := '0';
    signal clk_tb		: std_logic := '1';

    -- Simulation only
    signal testing    :  boolean := true;

begin

	-- Amplitude Equalizer instance
	DUT : amplitude_equalizer
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
			ae_clk  	=> clk_tb,
			ae_resetn  	=> resetn_tb,
			ae_ref		=> reference_tb,
			ae_x    	=> x_tb,
			ae_y    	=> y_tb
		);

	-- Clock signal
	clk_tb <= not(clk_tb) after CLK_PERIOD / 2 when testing else '1';
	
	------------------------
	-- SIMULATION PROCESS --
	------------------------
	STIMULI : process(clk_tb)
		variable t : natural := 0;
		variable n : natural := 0;
	begin
		-- First test
		if rising_edge(clk_tb) and n = 0 then
			case(t) is 
				when SIM_CLK_CYCLES + 1 => -- Next test
					t := 0;
					n := 1; 
				when 0 => 
					report("First test"); 
					resetn_tb <= '1';
					x_tb <= std_logic_vector(to_signed(TRIANGLE_WAVE((t + PHASE) mod PERIOD_N_SAMPLES), PERIOD_N_SAMPLES));
				when others =>
					x_tb <= std_logic_vector(to_signed(TRIANGLE_WAVE((t + PHASE) mod PERIOD_N_SAMPLES), PERIOD_N_SAMPLES));
			end case;
			t := t + 1;
		end if;

		-- Second test
		if rising_edge(clk_tb) and n = 1 then
			case(t) is 
				when SIM_CLK_CYCLES + 1 => -- Next test
					report("End simulation"); 
					t := 0;
					n := 2;
				when 1 =>
					report("Second test"); 
					reference_tb <= std_logic_vector(to_unsigned(255, REFERENCE_N_BITS));
					x_tb <= std_logic_vector(to_signed(TRIANGLE_WAVE((t + PHASE) mod PERIOD_N_SAMPLES), PERIOD_N_SAMPLES));
				when others =>
					x_tb <= std_logic_vector(to_signed(TRIANGLE_WAVE((t + PHASE) mod PERIOD_N_SAMPLES), PERIOD_N_SAMPLES));
			end case;
			t := t + 1;
		end if;

		-- Third test
		if rising_edge(clk_tb) and n = 2 then
			case(t) is 
				when SIM_CLK_CYCLES + 1 => -- Next test
					report("End simulation"); 
					t := 0;
					n := 3;
				when 1 =>
					report("Third test"); 
					reference_tb <= std_logic_vector(to_unsigned(511, REFERENCE_N_BITS));
					x_tb <= std_logic_vector(to_signed(TRIANGLE_WAVE((t + PHASE) mod PERIOD_N_SAMPLES), PERIOD_N_SAMPLES));
				when others =>
					x_tb <= std_logic_vector(to_signed(TRIANGLE_WAVE((t + PHASE) mod PERIOD_N_SAMPLES), PERIOD_N_SAMPLES));
			end case;
			t := t + 1;
		end if;

		-- Fourth test
		if rising_edge(clk_tb) and n = 3 then
			case(t) is 
				when SIM_CLK_CYCLES + 1 => 
					t := 0;
					n := 4;
					testing <= false; -- End of the simulation
				when 1 =>
					report("Fourth test"); 
					x_tb <= std_logic_vector(to_signed(TRIANGLE_WAVE((t + PHASE) mod PERIOD_N_SAMPLES) * AMPLITUDE_SCALE, PERIOD_N_SAMPLES));
				when others =>
					x_tb <= std_logic_vector(to_signed(TRIANGLE_WAVE((t + PHASE) mod PERIOD_N_SAMPLES) * AMPLITUDE_SCALE, PERIOD_N_SAMPLES));
			end case;
			t := t + 1;
		end if;
	end process;
end architecture;
