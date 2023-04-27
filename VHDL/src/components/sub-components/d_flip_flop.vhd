library ieee;
    use ieee.std_logic_1164.all;

entity d_flip_flop is 
generic (
    DFF_N_BITS : positive := 8
);
port(
    dff_di      :   in std_logic_vector(DFF_N_BITS-1 downto 0);
    dff_do      :   out std_logic_vector(DFF_N_BITS-1 downto 0);
    dff_resetn  :   in std_logic;
    dff_en      :   in std_logic;
    dff_clk     :   in std_logic
);
end entity;

architecture dff_arch of d_flip_flop is 
    signal dff_di_s : std_logic_vector(DFF_N_BITS-1 downto 0);
    signal dff_do_s : std_logic_vector(DFF_N_BITS-1 downto 0);
begin
    SET: process(dff_clk, dff_resetn)
    begin 
        if dff_resetn = '0' then
            dff_do_s <= (DFF_N_BITS-1 downto 0 => '0');
        elsif rising_edge(dff_clk) then
            dff_do_s <= dff_di_s;
        end if;
    end process;
    
    dff_di_s <= dff_di when dff_en = '1' else dff_do_s;
    dff_do <= dff_do_s;

end architecture;
