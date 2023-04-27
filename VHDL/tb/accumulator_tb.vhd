library IEEE;
	use IEEE.std_logic_1164.all;
	use ieee.numeric_std.all;

entity accumulator_tb is
end entity;

architecture acc_tb of accumulator_tb is 

constant CLK_PERIOD         : time      := 100 ns;
constant SIM_CLK_CYCLES     : integer   := 5000;

constant N_BITS				: positive	:= 20;
constant FACTOR_N_BITS		: positive	:= 8;

component accumulator is
	generic(
		ACC_N_BITS			: positive;
		ACC_FACTOR_N_BITS	: positive
	);
	port(
		acc_step  	: in std_logic_vector(ACC_N_BITS-1 downto 0);
		acc_keepn  	: in std_logic;
		acc_clk   	: in std_logic;
		acc_resetn	: in std_logic;
		acc_c_fact 	: out std_logic_vector(ACC_FACTOR_N_BITS-1 downto 0)
	);
end component;

signal step_tb		: std_logic_vector(N_BITS-1 downto 0) := std_logic_vector(to_unsigned(50, N_BITS));
signal c_fact_tb	: std_logic_vector(FACTOR_N_BITS-1 downto 0);
signal keepn_tb 	: std_logic	:= '0';
signal resetn_tb	: std_logic := '0';
signal clk_tb		: std_logic := '1';

-- Simulation only
signal testing		:  boolean := true;

begin

DUT : accumulator
	generic map(
		ACC_N_BITS			=> N_BITS,
		ACC_FACTOR_N_BITS	=> FACTOR_N_BITS
	)
	port map (
		acc_step  	=> step_tb,
		acc_keepn  	=> keepn_tb,
		acc_clk   	=> clk_tb,
		acc_resetn	=> resetn_tb,
		acc_c_fact	=> c_fact_tb
	);

clk_tb <= not(clk_tb) after CLK_PERIOD / 2 when testing else '1';

STIMULI : process(clk_tb)
	variable t : integer := 0;
begin
	if rising_edge(clk_tb) then 
	case(t) is 
		when 0 =>
			resetn_tb <= '1';
		when SIM_CLK_CYCLES + 1 => 
			report("End simulation"); 
			testing <= false;            
		when SIM_CLK_CYCLES / 2 => 
			keepn_tb <= '1';
		when others => null;
	end case;
	t := t + 1;
	end if;
end process;

end architecture;
