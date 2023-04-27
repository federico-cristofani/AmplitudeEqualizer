onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /ripple_carry_adder_signed_ext_tb/a_tb
add wave -noupdate -radix decimal /ripple_carry_adder_signed_ext_tb/b_tb
add wave -noupdate -radix decimal /ripple_carry_adder_signed_ext_tb/sum_tb
add wave -noupdate -format Literal -radix decimal /ripple_carry_adder_signed_ext_tb/cin_tb
add wave -noupdate -radix decimal /ripple_carry_adder_signed_ext_tb/clk_tb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {244527 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 127
configure wave -valuecolwidth 80
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
WaveRestoreZoom {0 ps} {288750 ps}
