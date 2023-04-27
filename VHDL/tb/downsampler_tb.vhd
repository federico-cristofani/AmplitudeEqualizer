library IEEE;
	use IEEE.std_logic_1164.all;
	use ieee.numeric_std.all;

entity downsampler_tb is
end entity;

architecture dws_tb of downsampler_tb is 

constant CLK_PERIOD   	: time     := 100 ns;
constant SIM_CLK_CYCLES	: positive := 160;
constant N_BITS     	: positive := 8;
constant CTR_N_BITS   	: positive := 2;

type triangle is array (natural range N_BITS-1 downto 0) of integer;

constant TRIANGLE_WAVE  : triangle := (
	0 => -10,
	1 => -5,
	2 => 0,
	3 => 5,
	4 => 10,
	5 => 5, 
	6 => 0,
	7 => -5
);

component downsampler is 
generic (
		DWS_N_BITS      : positive;
		DWS_CTR_N_BITS  : positive
	);
	port (
		dws_input   : in std_logic_vector(DWS_N_BITS-1 downto 0);
		dws_output	: out std_logic_vector(DWS_N_BITS-1 downto 0);
		dws_peak  	: out std_logic;    
		dws_resetn	: in std_logic;
		dws_en		: in std_logic;
		dws_clk   	: in std_logic
	);
end component;

signal input_tb		: std_logic_vector(N_BITS-1 downto 0) := std_logic_vector(to_unsigned(0, N_BITS));
signal output_tb	: std_logic_vector(N_BITS-1 downto 0);
signal peak_tb		: std_logic;
signal resetn_tb  	: std_logic := '0';
signal en_tb		: std_logic := '0';
signal clk_tb     	: std_logic := '1';

-- Simulation only
signal testing    	: boolean := true;

begin

clk_tb <= not(clk_tb) after CLK_PERIOD / 2 when testing else '1';

DUT : downsampler
	generic map (
		DWS_N_BITS  	=> N_BITS,
		DWS_CTR_N_BITS	=> CTR_N_BITS
	)
	port map (
		dws_input	=> input_tb,
		dws_output 	=> output_tb,
		dws_peak 	=> peak_tb,
		dws_resetn  => resetn_tb,
		dws_en		=> en_tb,
		dws_clk     => clk_tb
	);

	STIMULI : process(clk_tb)
		variable t : natural := 0;
	begin
		if rising_edge(clk_tb) then
		case(t) is 
			when SIM_CLK_CYCLES + 1 => 
				report("End simulation"); 
				testing <= false;
			when SIM_CLK_CYCLES / 2 => 
				input_tb <= std_logic_vector(to_signed(TRIANGLE_WAVE(((t)) mod N_BITS), N_BITS));
				en_tb <= '1';
			when others =>
				resetn_tb <= '1';
				input_tb <= std_logic_vector(to_signed(TRIANGLE_WAVE(((t)) mod N_BITS), N_BITS));
			end case;
		t := t + 1;
		end if;
	end process;

end architecture;
