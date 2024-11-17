onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /RX_tb/Clk
add wave -noupdate /RX_tb/slwClk
add wave -noupdate -color {Orange Red} /RX_tb/Rst
add wave -noupdate /RX_tb/Input_Data
add wave -noupdate -color Magenta /RX_tb/Output_Data
add wave -noupdate -color Magenta /RX_tb/Output_Valid
add wave -noupdate /RX_tb/Busy
add wave -noupdate -color Cyan /RX_tb/DUT/SEQ
add wave -noupdate /RX_tb/DUT/SEQ_OK
add wave -noupdate -color {Dark Orchid} /RX_tb/DUT/cState
add wave -noupdate -color {Dark Orchid} -radix unsigned /RX_tb/DUT/mainCnt
add wave -noupdate /RX_tb/DUT/SIGNAL
add wave -noupdate /RX_tb/DUT/DINT0_EN
add wave -noupdate /RX_tb/DUT/DINT0_REN
add wave -noupdate /RX_tb/DUT/DINT0_V
add wave -noupdate -color Yellow /RX_tb/DUT/punct
add wave -noupdate -color Yellow /RX_tb/DUT/delay
add wave -noupdate /RX_tb/DUT/PUNCT_V
add wave -noupdate /RX_tb/DUT/DEC0_EN
add wave -noupdate /RX_tb/DUT/DEC0_V
add wave -noupdate -color Cyan /RX_tb/DUT/DSCMB0/LFSR
add wave -noupdate /RX_tb/DUT/DSCMB0_SEN
add wave -noupdate -color Blue -radix unsigned /RX_tb/DUT/F0/stPtr
add wave -noupdate -color {Orange Red} /RX_tb/DUT/GLB_FLUSH
add wave -noupdate -color {Orange Red} /RX_tb/DUT/SIG_FLUSH
add wave -noupdate -color {Orange Red} /RX_tb/DUT/F0_FLUSH
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
WaveRestoreZoom {0 ps} {498011 ps}
