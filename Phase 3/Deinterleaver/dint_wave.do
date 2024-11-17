onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /deinterleaver_tb/Clk
add wave -noupdate -color {Orange Red} /deinterleaver_tb/Rst
add wave -noupdate /deinterleaver_tb/RateEN
add wave -noupdate /deinterleaver_tb/Rate
add wave -noupdate /deinterleaver_tb/EN
add wave -noupdate /deinterleaver_tb/Data_In
add wave -noupdate -color Magenta /deinterleaver_tb/Data_Out
add wave -noupdate -color Magenta /deinterleaver_tb/Data_Valid
add wave -noupdate -color {Dark Orchid} -radix unsigned /deinterleaver_tb/DUT/rowCnt
add wave -noupdate -color {Dark Orchid} -radix unsigned /deinterleaver_tb/DUT/colCnt
add wave -noupdate -color Yellow /deinterleaver_tb/DUT/ROW_EXP
add wave -noupdate -color Yellow /deinterleaver_tb/DUT/COL_EXP
add wave -noupdate -color {Dark Orchid} -radix unsigned /deinterleaver_tb/DUT/kPtr
add wave -noupdate /deinterleaver_tb/DUT/bReg
add wave -noupdate /deinterleaver_tb/DUT/fReg
add wave -noupdate -color Blue /deinterleaver_tb/DUT/selReg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {47097 ps} 0}
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
WaveRestoreZoom {0 ps} {498011 ps}
