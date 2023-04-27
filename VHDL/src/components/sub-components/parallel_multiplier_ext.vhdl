library IEEE;
	use ieee.std_logic_1164.all;

entity parallel_multiplier_ext is
	generic (
		PM_E_N_BITS : positive := 8
	);
	port ( 
		pm_e_a 		: in  std_logic_vector (PM_E_N_BITS-1 downto 0);
		pm_e_b 		: in  std_logic_vector (PM_E_N_BITS-1 downto 0);
		pm_e_prod	: out std_logic_vector (PM_E_N_BITS*2 - 1 downto 0)
	);
end entity;

architecture pm_e_arch of parallel_multiplier_ext is

	-- The parallel multiplier is organized as a matrix, each "element" of the matrix is composed by one or more components
	-- The indexes refers to the entire matrix, for example if a component is present on all columns excluded the first, then
	-- 	index range will be from '1' to 'PM_E_N_BITS-1'
	type partial_product_t is array (0 to PM_E_N_BITS-1) of std_logic_vector(PM_E_N_BITS-1 downto 0);
	type partial_sum_t is array (1 to PM_E_N_BITS-1) of std_logic_vector(PM_E_N_BITS-2 downto 1);
	type partial_cout_t is array (1 to PM_E_N_BITS-1) of std_logic_vector(PM_E_N_BITS-1 downto 1);

	constant PM_E_OUT_N_BITS : positive := PM_E_N_BITS*2;

	-- HALF ADDER
	component half_adder is port(
		ha_a     : in std_logic;
		ha_b     : in std_logic;
		ha_sum   : out std_logic;
		ha_cout  : out std_logic
	);
	end component;

	--FULL ADDER
	component full_adder is port(
		fa_a    :   in std_logic;
		fa_b    :   in std_logic;
		fa_cin  :   in std_logic;
		fa_sum  :   out std_logic;
		fa_cout :   out std_logic
	);
	end component;

	-- RCA unsigned
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

	signal partial_product_s 	: partial_product_t;
	signal partial_sum_s		: partial_sum_t;
	signal partial_cout_s		: partial_cout_t;
	
	signal product_s 			: std_logic_vector(PM_E_OUT_N_BITS-1 downto 0);
	
	signal rca_a_rev_s			: std_logic_vector(0 to PM_E_N_BITS-2);
	signal rca_a_s				: std_logic_vector(0 to PM_E_N_BITS-2);
	signal rca_b_s				: std_logic_vector(0 to PM_E_N_BITS-2);

begin
	 
	PARTIAL_PRODUCT_ROWS: 
	for i in 0 to PM_E_N_BITS-1 generate 
		PARTIAL_PRODUCT_COLS: 
		for j in 0 to PM_E_N_BITS-1 generate
			partial_product_s(i)(j) <= pm_e_a(PM_E_N_BITS-1-j) and pm_e_b(i);
		end generate;
	end generate;

	ADDERS_FIRST_ROW: -- Components of the first row
	for j in 1 to PM_E_N_BITS-1 generate -- First column excluded 
		INNER: if j < PM_E_N_BITS-1 generate -- Not last column
			FIRST_ROW_INNER_HA: half_adder port map(
				ha_a   	=> partial_product_s(0)(j-1),
				ha_b   	=> partial_product_s(1)(j),
				ha_sum 	=> partial_sum_s(1)(j),
				ha_cout	=> partial_cout_s(1)(j)
			);
		end generate;
		LAST: if j = PM_E_N_BITS-1 generate -- Last column
			FIRST_ROW_OUTER_HA: half_adder port map(
				ha_a   	=> partial_product_s(0)(j-1),
				ha_b   	=> partial_product_s(1)(j),
				ha_sum 	=> product_s(1),
				ha_cout	=> partial_cout_s(1)(j)
			);		
		end generate;
	end generate;
	
	INNER_ROWS_ADDER: 
	for i in 2 to PM_E_N_BITS-1 generate -- Components from second to last column
		INNER_COLS_ADDER:
		for j in 1 to PM_E_N_BITS-1 generate -- First column excluded
			INNER_ROWS_ADDER_FIRST_COL: if j = 1 generate -- Only second column
				FIRST_FA: full_adder port map(
					fa_a   	=> partial_product_s(i-1)(j-1),
					fa_b   	=> partial_product_s(i)(j),
					fa_cin 	=> partial_cout_s(i-1)(j),
					fa_sum 	=> partial_sum_s(i)(j),
					fa_cout	=> partial_cout_s(i)(j)
				);
			end generate;
			
			INNER_ROWS_ADDER_INNER_COL: if j > 1 and j < PM_E_N_BITS-1 generate -- Other columns
				INNER_FA: full_adder port map(
					fa_a   	=> partial_sum_s(i-1)(j-1),
					fa_b   	=> partial_product_s(i)(j),
					fa_cin 	=> partial_cout_s(i-1)(j),
					fa_sum 	=> partial_sum_s(i)(j),
					fa_cout	=> partial_cout_s(i)(j)
				);
			end generate;
			
			INNER_ROWS_ADDER_LAST_COL: if j = PM_E_N_BITS-1 generate -- Only last column
				LAST_FA: full_adder port map(
					fa_a   	=> partial_sum_s(i-1)(j-1),
					fa_b   	=> partial_product_s(i)(j),
					fa_cin 	=> partial_cout_s(i-1)(j),
					fa_sum 	=> product_s(i),
					fa_cout	=> partial_cout_s(i)(j)
				);
			end generate;
		end generate;
	end generate;

	-- Input for RCA, the bits of first operand must be flipped (the MSB will be the LSB and so on) 
	rca_a_rev_s <= partial_sum_s(PM_E_N_BITS-1)(PM_E_N_BITS-2 downto 1) & partial_product_s(PM_E_N_BITS-1)(0);
	FLIP: for i in PM_E_N_BITS-2 downto 0 generate
		rca_a_s(PM_E_N_BITS-2 - i) <= rca_a_rev_s(i);
		rca_b_s(i) <= partial_cout_s(PM_E_N_BITS-1)(i+1);
    end generate;

	-- RCA, not considered as part of the matrix
	-- Produces the MSBs of the final product
	RCA: ripple_carry_adder_unsigned
	generic map(
		RCA_U_N_BITS	=> PM_E_N_BITS-1
	)
	port map(
		rca_u_a  	=> rca_a_s, 
		rca_u_b  	=> rca_b_s,
		rca_u_sum	=> product_s(PM_E_OUT_N_BITS-2 downto PM_E_N_BITS),
		rca_u_cout	=> product_s(PM_E_OUT_N_BITS-1)
	);

	-- Assign output 
	product_s(0) <= partial_product_s(0)(PM_E_N_BITS-1);
	pm_e_prod <= product_s;

end architecture;

