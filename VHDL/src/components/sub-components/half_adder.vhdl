library ieee;
    use ieee.std_logic_1164.all;

entity half_adder is port(
   ha_a     : in std_logic;
   ha_b     : in std_logic;
   ha_sum   : out std_logic;
   ha_cout  : out std_logic
);
end entity;

architecture ha of half_adder is 
begin 
    ha_sum <= ha_a xor ha_b;
    ha_cout <= ha_a and ha_b;
end architecture;