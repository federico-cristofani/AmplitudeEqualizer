library ieee;
    use ieee.std_logic_1164.all;

entity absolute_value is 
generic(
    ABS_N_BITS   : positive := 8
);
port(
    abs_x   : in std_logic_vector(ABS_N_BITS-1 downto 0);
    abs_y   : out std_logic_vector(ABS_N_BITS-1 downto 0);
    abs_ow  : out std_logic
);
end entity;

architecture abs_arch of absolute_value is 
    component incrementer is 
        generic ( INC_N_BITS : positive );
        port(
            inc_a   : in std_logic_vector(INC_N_BITS-1 downto 0);
            inc_sum : out std_logic_vector(INC_N_BITS-1 downto 0);
            inc_ow  : out std_logic
        );
    end component;
   
    signal abs_x_neg_s  : std_logic_vector(ABS_N_BITS-1 downto 0);
    signal abs_y_s      : std_logic_vector(ABS_N_BITS-1 downto 0);

begin 
    -- Increment inverted input by 1 
    INC: incrementer
    generic map(INC_N_BITS => ABS_N_BITS)
    port map(
        inc_a   => abs_x_neg_s,
        inc_sum => abs_y_s,
        inc_ow  => abs_ow
    );

    -- Invert the input value
    abs_x_neg_s <= not abs_x;

    -- The abs value is obtained inverting all input bits and adding 1 to the inverted input [(not X) + 1]
    abs_y <= abs_x when (abs_x(ABS_N_BITS-1) = '0') else abs_y_s;

end architecture;