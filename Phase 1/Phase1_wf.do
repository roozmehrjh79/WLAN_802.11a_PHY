onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Phase1_tb/Clk
add wave -noupdate -color {Orange Red} /Phase1_tb/Rst
add wave -noupdate /Phase1_tb/Start
add wave -noupdate /Phase1_tb/Rate
add wave -noupdate /Phase1_tb/Lenght
add wave -noupdate /Phase1_tb/Data_In
add wave -noupdate -color Yellow /Phase1_tb/DUT/TX_On
add wave -noupdate -color Cyan /Phase1_tb/DUT/Wifi_Frame
add wave -noupdate /Phase1_tb/Data_Out
add wave -noupdate -color Yellow /Phase1_tb/Data_Valid
add wave -noupdate -color Magenta -radix unsigned /Phase1_tb/DUT/TX_CTRL0/counter
add wave -noupdate /Phase1_tb/DUT/TX_CTRL0/cState
add wave -noupdate /Phase1_tb/DUT/TX_SCMB0/iSEN
add wave -noupdate -radix binary /Phase1_tb/DUT/TX_SCMB0/iState
add wave -noupdate -color {Green Yellow} -radix unsigned /Phase1_tb/DUT/TX_SCMB0/LFSR
add wave -noupdate -color Magenta -radix unsigned /Phase1_tb/DUT/RX_CTRL0/counter
add wave -noupdate -radix hexadecimal /Phase1_tb/DUT/RX_CTRL0/cState
add wave -noupdate /Phase1_tb/DUT/RX_DSCMB0/iSEN
add wave -noupdate -color {Green Yellow} -radix unsigned /Phase1_tb/DUT/RX_DSCMB0/LFSR
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
WaveRestoreZoom {1231025 ps} {1661525 ps}
