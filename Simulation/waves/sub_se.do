onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /subtractor_signed_ext_tb/a_tb
add wave -noupdate -radix decimal /subtractor_signed_ext_tb/b_tb
add wave -noupdate -radix decimal /subtractor_signed_ext_tb/diff_tb
add wave -noupdate -radix decimal /subtractor_signed_ext_tb/bin_tb
add wave -noupdate -radix decimal /subtractor_signed_ext_tb/clk_tb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {973062 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 88
configure wave -valuecolwidth 89
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
WaveRestoreZoom {0 ps} {1155 ns}
