onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Analog-Step -height 74 -max 20.0 -min -20.0 -radix decimal /amplitude_equalizer_tb/x_tb
add wave -noupdate -format Analog-Step -height 74 -max 2039.9999999999998 -min -2040.0 -radix decimal /amplitude_equalizer_tb/y_tb
add wave -noupdate -radix decimal /amplitude_equalizer_tb/reference_tb
add wave -noupdate -radix decimal /amplitude_equalizer_tb/resetn_tb
add wave -noupdate -radix decimal /amplitude_equalizer_tb/clk_tb
add wave -noupdate -radix decimal /amplitude_equalizer_tb/DUT/c_fact_s
add wave -noupdate -format Analog-Step -height 74 -max 524254.0 -min -524287.0 -radix decimal /amplitude_equalizer_tb/DUT/ACC/c_fact_ext_s
add wave -noupdate -radix decimal /amplitude_equalizer_tb/reference_tb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1105039951 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 161
configure wave -valuecolwidth 69
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits sec
update
WaveRestoreZoom {0 ps} {6300262500 ps}
