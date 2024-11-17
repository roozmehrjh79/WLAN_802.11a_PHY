onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /encoder_tb/Clk
add wave -noupdate /encoder_tb/slwClk
add wave -noupdate -color {Orange Red} /encoder_tb/Rst
add wave -noupdate /encoder_tb/EN
add wave -noupdate -color {Medium Spring Green} /encoder_tb/Data_In
add wave -noupdate -color Magenta /encoder_tb/Data_Out
add wave -noupdate /encoder_tb/Data_Valid
add wave -noupdate /encoder_tb/DUT/encOutA
add wave -noupdate /encoder_tb/DUT/encOutB
add wave -noupdate /encoder_tb/DUT/encOutSel
add wave -noupdate -color Cyan -radix unsigned /encoder_tb/DUT/ENC0/SREG
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {956274 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {727313 ps} {1489089 ps}
