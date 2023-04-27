library IEEE;
  use IEEE.std_logic_1164.all;
  use ieee.numeric_std.all;

entity counter_tb is
end entity;

architecture ctr_tb of counter_tb is 

  constant CLK_PERIOD     : time      := 100 ns;

  constant T_RESET        : time      := 25 ns; 
  constant CTR_N_TB       : positive  := 4;
  constant CYCLES         : positive  := 2;

  constant SIM_CLK_CYCLES : positive := 100;
  
  component counter is 
  generic (
        CTR_N_BITS : positive
    );
    port (
        ctr_step    : in std_logic_vector(CTR_N_BITS-1 downto 0);
        ctr_out     : out std_logic_vector(CTR_N_BITS-1 downto 0);   
        ctr_resetn  : in std_logic;
        ctr_en      : in std_logic;
        ctr_clk     : in std_logic
    );
  end component;

  signal step_tb    :  std_logic_vector(CTR_N_TB-1 downto 0) := std_logic_vector(to_unsigned(1, CTR_N_TB));
  signal out_tb     :  std_logic_vector(CTR_N_TB-1 downto 0);
  signal resetn_tb  :  std_logic := '0';
  signal en_tb      :  std_logic := '1';
  signal clk_tb     :  std_logic := '1';
  
  -- Simulation only
  signal testing    :  boolean := true;

begin

  clk_tb <= not(clk_tb) after CLK_PERIOD / 2 when testing else '1';

  DUT : counter
    generic map (CTR_N_BITS => CTR_N_TB)
    port map (
        ctr_step    =>  step_tb,
        ctr_out     =>  out_tb,
        ctr_resetn  =>  resetn_tb,
        ctr_en      =>  en_tb,
        ctr_clk     =>  clk_tb 
    );

  STIMULI : process(clk_tb)
    variable t : integer := 1;
  begin
    if resetn_tb = '0' then
        report("Start simulation");
        report("Reset");
        resetn_tb <= '1';
    elsif rising_edge(clk_tb) then
      case(t) is 
        when SIM_CLK_CYCLES / 2 => en_tb <= '0';
        when SIM_CLK_CYCLES => 
          report("End simulation"); 
          testing <= false;
        when others => null;
      end case;
      t := t + 1;
    end if;
  end process;

end architecture;
