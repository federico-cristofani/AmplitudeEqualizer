library ieee;
    use ieee.std_logic_1164.all;

entity phase_cancellation is 
generic ( 
    PC_N_BITS               : positive := 8;
    PC_PERIOD_N_SAMPLES     : positive := 8      
);
port(
    pc_input    : in std_logic_vector(PC_N_BITS-1 downto 0);
    pc_output   : out std_logic_vector(PC_N_BITS-1 downto 0);
	pc_reference: in std_logic_vector(PC_PERIOD_N_SAMPLES-1 downto 0);
    pc_ready    : out std_logic;
    pc_resetn   : in std_logic;
    pc_clk      : in std_logic
);
end entity;

architecture pc_arch of phase_cancellation is 

    -- DFF
    component d_flip_flop is 
    generic ( DFF_N_BITS : positive );
    port (
        dff_di      : in std_logic_vector(DFF_N_BITS-1 downto 0);
        dff_do      : out std_logic_vector(DFF_N_BITS-1 downto 0);
        dff_resetn  : in std_logic;
        dff_en      : in std_logic;
        dff_clk     : in std_logic
    );
    end component;

    type shift_register_t is array (0 to PC_PERIOD_N_SAMPLES-1) of std_logic_vector(PC_N_BITS-1 downto 0);

    signal shift_reg_s      : shift_register_t;
    signal msb_sign_s       : std_logic_vector(PC_PERIOD_N_SAMPLES-1 downto 0);
    signal phase_cmp_s      : std_logic;
    signal in_phase_in_s    : std_logic_vector(0 downto 0); -- 1 bit only, it's required a std_vector
    signal in_phase_out_s   : std_logic_vector(0 downto 0); -- 1 bit only, it's required a std_vector 

begin

    -- IN PHASE DFF instance, memorize the bit '1' when the signal is correctly in phase
    IN_PHASE_FF: d_flip_flop 
    generic map ( DFF_N_BITS => 1 )
    port map (
        dff_di      => in_phase_in_s,
        dff_do      => in_phase_out_s,
        dff_clk     => pc_clk,
        dff_resetn  => pc_resetn,
        dff_en      => '1'              -- Always active, no need to disable
    );
    
    -- SHIFT REGISTER BUFFER, bufferize the input wave to checks whether it's in phase
    DFF_CHAIN: for i in 0 to PC_PERIOD_N_SAMPLES-1 generate

        -- First register
        FIRST_REG: if i = 0 generate
            DFF_FIRST: d_flip_flop
            generic map(
                DFF_N_BITS => PC_N_BITS
            )
            port map(
                dff_di      => pc_input,
                dff_do      => shift_reg_s(i),
                dff_resetn  => pc_resetn,
                dff_en      => '1',
                dff_clk     => pc_clk
            );
        end generate;
        
        -- Other registers
        OTHER_REG: if i > 0 generate 
            DFF: d_flip_flop
            generic map(
                DFF_N_BITS => PC_N_BITS
            )
            port map(
                dff_di      => shift_reg_s(i-1),
                dff_do      => shift_reg_s(i),
                dff_resetn  => pc_resetn,
                dff_en      => '1',
                dff_clk     => pc_clk
            );
        end generate;
        
        -- MSB bits pattern
        msb_sign_s(PC_PERIOD_N_SAMPLES-i-1) <= shift_reg_s(i)(PC_N_BITS-1);

    end generate;
    
    -- XNOR between reference phase and the msb bits and bits reduction by mux ('1' if msb bits equals to reference, '0' otherwise)
    phase_cmp_s <= '1' when ((msb_sign_s xnor pc_reference) = (PC_PERIOD_N_SAMPLES-1 downto 0 => '1')) else '0';

    -- Keep phase signal status (always '1' after signal phase match the reference)
    in_phase_in_s(0) <= in_phase_out_s(0) or phase_cmp_s;

    -- Output value, valid only when ready = '1'
    pc_output <= shift_reg_s(PC_PERIOD_N_SAMPLES-1);

    -- Control signal, when active the output is "in phase" with the reference (not connect to the register output )
    pc_ready <= in_phase_in_s(0);
    
end architecture;
