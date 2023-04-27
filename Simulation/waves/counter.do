onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /counter_tb/step_tb
add wave -noupdate -radix unsigned /counter_tb/out_tb
add wave -noupdate -radix unsigned /counter_tb/resetn_tb
add wave -noupdate -radix unsigned /counter_tb/en_tb
add wave -noupdate -radix unsigned /counter_tb/clk_tb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5015711 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 130
configure wave -valuecolwidth 40
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
WaveRestoreZoom {3819719 ps} {6800067 ps}
