onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /interleaver_tb/Clk
add wave -noupdate -color {Orange Red} /interleaver_tb/Rst
add wave -noupdate /interleaver_tb/RateEN
add wave -noupdate /interleaver_tb/Rate
add wave -noupdate /interleaver_tb/EN
add wave -noupdate /interleaver_tb/Data_In
add wave -noupdate -color Magenta /interleaver_tb/Data_Out
add wave -noupdate -color Magenta /interleaver_tb/Data_Valid
add wave -noupdate -color {Dark Orchid} -radix unsigned /interleaver_tb/DUT/rowCnt
add wave -noupdate -color {Dark Orchid} -radix unsigned /interleaver_tb/DUT/colCnt
add wave -noupdate -color Yellow /interleaver_tb/DUT/ROW_EXP
add wave -noupdate -color Yellow /interleaver_tb/DUT/COL_EXP
add wave -noupdate -color {Dark Orchid} -radix unsigned /interleaver_tb/DUT/jPtr
add wave -noupdate /interleaver_tb/DUT/bReg
add wave -noupdate /interleaver_tb/DUT/fReg
add wave -noupdate -color Blue /interleaver_tb/DUT/selReg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {3642314 ps} {4140325 ps}
