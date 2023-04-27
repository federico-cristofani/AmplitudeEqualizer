library IEEE;
	use IEEE.std_logic_1164.all;
	use ieee.numeric_std.all;

entity phase_cancellation_tb is
end entity;

architecture pc_tb of phase_cancellation_tb is 


constant CLK_PERIOD   	: time     := 100 ns;
constant SIM_CLK_CYCLES	: positive := 100;

constant N_BITS     			: positive := 8;
constant REFERENCE				: std_logic_vector := "10000011";
constant SIGNAL_PERIOD_N_SAMPLE	: positive := 8;

type triangle is array (natural range SIGNAL_PERIOD_N_SAMPLE-1 downto 0) of integer;

constant PHASE_SHIFT	: natural := 1;
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

component phase_cancellation is 
generic ( 
    PC_N_BITS          	: positive;
    PC_PERIOD_N_SAMPLES	: positive     
);
port(
    pc_input    : in std_logic_vector(PC_N_BITS-1 downto 0);
    pc_output   : out std_logic_vector(PC_N_BITS-1 downto 0);
	pc_reference: in std_logic_vector(PC_PERIOD_N_SAMPLES-1 downto 0);
    pc_ready    : out std_logic;
    pc_resetn   : in std_logic;
    pc_clk      : in std_logic
);
end component;

signal input_tb		: std_logic_vector(N_BITS-1 downto 0) := std_logic_vector(to_unsigned(0, N_BITS));
signal output_tb	: std_logic_vector(N_BITS-1 downto 0);
signal resetn_tb  	: std_logic := '0';
signal clk_tb     	: std_logic := '1';

-- Simulation only
signal testing    	: boolean := true;

begin

clk_tb <= not(clk_tb) after CLK_PERIOD / 2 when testing else '1';

DUT : phase_cancellation
	generic map (
		PC_N_BITS           => N_BITS,
        PC_PERIOD_N_SAMPLES => SIGNAL_PERIOD_N_SAMPLE 
	)
	port map (
        pc_input		=> input_tb,
        pc_output		=> output_tb,
		pc_reference	=> REFERENCE,
        pc_resetn  		=> resetn_tb,
        pc_clk     		=> clk_tb
	);

	STIMULI : process(clk_tb)
		variable t : natural := 0;
	begin
		if rising_edge(clk_tb) then
		case(t) is 
			when SIM_CLK_CYCLES + 1 => 
				report("End simulation"); 
				testing <= false;
			when others =>
				resetn_tb <= '1';
				input_tb <= std_logic_vector(to_signed(TRIANGLE_WAVE(((t + PHASE_SHIFT)) mod SIGNAL_PERIOD_N_SAMPLE), SIGNAL_PERIOD_N_SAMPLE));
			end case;
		t := t + 1;
		end if;
	end process;

end architecture;
