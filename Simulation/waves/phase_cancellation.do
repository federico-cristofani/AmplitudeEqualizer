onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Analog-Step -height 74 -max 10.0 -min -10.0 -radix decimal /phase_cancellation_tb/input_tb
add wave -noupdate -format Analog-Step -height 74 -max 10.0 -min -10.0 -radix decimal /phase_cancellation_tb/output_tb
add wave -noupdate /phase_cancellation_tb/resetn_tb
add wave -noupdate /phase_cancellation_tb/clk_tb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {875863 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {10762500 ps}
