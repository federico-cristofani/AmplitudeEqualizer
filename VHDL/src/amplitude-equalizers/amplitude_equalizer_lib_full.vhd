library ieee;
    use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity amplitude_equalizer_lib_full is
generic(
    AE_N_BITS               : positive := 8;
    AE_OUT_N_BITS           : positive := 16;
    AE_REFERENCE_N_BITS     : positive := 14;
    AE_ACCUMULATOR_N_BITS   : positive := 20;
    AE_DOWNSAMPLING_FACTOR  : positive := 2;    -- Downsampling factor -> Reduce frequency by 2^(AE_DOWNSAMPLING_FACTOR)
    AE_PERIOD_N_SAMPLES     : positive := 8;    -- Samples per period
    AE_PHASE_REFERENCE      : std_logic_vector := "10000011"
);
port(
    ae_clk      : in std_logic;
    ae_resetn   : in std_logic;
    ae_ref      : in std_logic_vector(AE_REFERENCE_N_BITS-1 downto 0);
    ae_x        : in std_logic_vector(AE_N_BITS-1 downto 0);
    ae_y        : out std_logic_vector(AE_OUT_N_BITS-1 downto 0)
);
end entity;

architecture ae_arch of amplitude_equalizer_lib_full is

    -- PHASE CANCELLATION
    component phase_cancellation is 
    generic ( 
        PC_N_BITS               : positive;
        PC_PERIOD_N_SAMPLES     : positive      
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

    -- DOWNSAMPLER
    component downsampler is 
    generic ( 
        DWS_N_BITS      : positive;
        DWS_CTR_N_BITS  : positive   
    );
    port(
        dws_input   : in std_logic_vector(DWS_N_BITS-1 downto 0);
        dws_output	: out std_logic_vector(DWS_N_BITS-1 downto 0);
        dws_peak  	: out std_logic;
        dws_resetn  : in std_logic;
        dws_en      : in std_logic;
        dws_clk     : in std_logic
    );
    end component;

    -- ACCUMULATOR
    component accumulator is
        generic(
            ACC_N_BITS          : positive;
            ACC_FACTOR_N_BITS   : positive
        );
        port(
            acc_step    : in std_logic_vector(ACC_N_BITS-1 downto 0);
            acc_keepn    : in std_logic;
            acc_clk     : in std_logic;
            acc_resetn  : in std_logic;
            acc_c_fact  : out std_logic_vector(ACC_FACTOR_N_BITS-1 downto 0)
        );
    end component;

    -- Interface signals
    signal y_s                      : std_logic_vector(AE_OUT_N_BITS-1 downto 0);
    signal ref_ext_s                : std_logic_vector(AE_OUT_N_BITS-1 downto 0);

    -- Internal signals
    signal c_fact_s                 : std_logic_vector(AE_N_BITS-1 downto 0);
    signal step_s                   : std_logic_vector(AE_OUT_N_BITS downto 0);
    signal step_ext_s               : std_logic_vector(AE_ACCUMULATOR_N_BITS-1 downto 0);
    signal peak_sample_s            : std_logic_vector(AE_OUT_N_BITS-1 downto 0);
    signal abs_out_sample_peak_s    : std_logic_vector(AE_OUT_N_BITS-1 downto 0);
    signal in_phase_out_s           : std_logic_vector(AE_N_BITS -1 downto 0);
    
    -- Control signals
    signal ready_s  : std_logic;    -- '1' when input signal is in phase with the reference
    signal peak_s   : std_logic;    -- '1' when processed sample is on the peak of the sampled signal 

begin
    
    -- Output port
    ae_y <= y_s;

    -- Two's complements sign extension
    ref_ext_s <= (ref_ext_s'length - 1 downto ae_ref'length  => ae_ref(ae_ref'length-1)) & ae_ref;
    step_ext_s <= (step_ext_s'length - 1 downto step_s'length => step_s(step_s'length-1)) & step_s;

    -- The circuit requires a signal without phase shifting to correcly identify the peaks
    PC: phase_cancellation
        generic map(
            PC_N_BITS           => AE_N_BITS,
            PC_PERIOD_N_SAMPLES => AE_PERIOD_N_SAMPLES  
        )
        port map(
            pc_input        => ae_x,
            pc_output       => in_phase_out_s,
            pc_reference    => AE_PHASE_REFERENCE, -- Constant value, to obatain greater flexibility the value should come 
            pc_ready        => ready_s,            --       from outside (input of circuit)
            pc_resetn       => ae_resetn,
            pc_clk          => ae_clk
        );

    -- Holds only the values on the peaks (actually, peak * c_fact) of the input signal
    DWS: downsampler
        generic map(
            DWS_N_BITS      => AE_OUT_N_BITS,      
            DWS_CTR_N_BITS  => AE_DOWNSAMPLING_FACTOR
        )
        port map(
            dws_input   => y_s,
            dws_output  => peak_sample_s,
            dws_peak    => peak_s,
            dws_en      => ready_s,
            dws_resetn  => ae_resetn,
            dws_clk     => ae_clk
        );

    -- Produce the absolute value of peak * c_fact, the possible overflow is ignored (more on the docs)
    abs_out_sample_peak_s <= std_logic_vector(to_signed(abs(to_integer(signed(peak_sample_s))), AE_OUT_N_BITS));
    
    -- Subtract the positive quantity from the reference
    step_s <= std_logic_vector(to_signed(to_integer(signed(ref_ext_s)) - to_integer(signed(abs_out_sample_peak_s)), AE_OUT_N_BITS + 1));

    -- Accumulate the result and truncate the ouput of the accumulator to obtain the new correction factor
    --      for each sample on the peak
    ACC : accumulator
        generic map(
            ACC_N_BITS          => AE_ACCUMULATOR_N_BITS,
            ACC_FACTOR_N_BITS   => AE_N_BITS
        )
        port map (
            acc_step    => step_ext_s,
            acc_keepn   => peak_s,
            acc_clk     => ae_clk,
            acc_resetn  => ae_resetn,
            acc_c_fact  => c_fact_s
        );

    -- Multipy the input sample by the current correction factor 
    y_s <= std_logic_vector(to_signed(to_integer(signed(in_phase_out_s)) * to_integer(signed(c_fact_s)), AE_OUT_N_BITS));

end architecture ;