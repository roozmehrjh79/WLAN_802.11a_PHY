onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TX_tb/Clk
add wave -noupdate /TX_tb/slwClk1
add wave -noupdate /TX_tb/slwClk2
add wave -noupdate -color {Orange Red} /TX_tb/Rst
add wave -noupdate /TX_tb/Start
add wave -noupdate /TX_tb/Rate
add wave -noupdate /TX_tb/Length
add wave -noupdate /TX_tb/Input_Data
add wave -noupdate -color Magenta /TX_tb/Output_Data
add wave -noupdate -color Magenta /TX_tb/Output_Valid
add wave -noupdate /TX_tb/Busy
add wave -noupdate -color {Dark Orchid} /TX_tb/DUT/cState
add wave -noupdate -color {Dark Orchid} -radix unsigned /TX_tb/DUT/mainCnt
add wave -noupdate /TX_tb/DUT/SIGNAL
add wave -noupdate -color {Yellow Green} -radix unsigned /TX_tb/DUT/TMP_PAD
add wave -noupdate -color {Yellow Green} -radix unsigned /TX_tb/DUT/N_PAD
add wave -noupdate -color {Yellow Green} -radix unsigned /TX_tb/DUT/N_DBPS
add wave -noupdate -color {Orange Red} /TX_tb/DUT/GLB_FLUSH
add wave -noupdate /TX_tb/DUT/SCMB0_SEN
add wave -noupdate -color Cyan /TX_tb/DUT/SCMB0/LFSR
add wave -noupdate /TX_tb/DUT/ENC0_EN
add wave -noupdate /TX_tb/DUT/ENC0_V
add wave -noupdate -color Cyan /TX_tb/DUT/ENC0/E0/SREG
add wave -noupdate /TX_tb/DUT/INT0_REN
add wave -noupdate /TX_tb/DUT/INT0_V
add wave -noupdate -color Blue -radix unsigned /TX_tb/DUT/F0/stPtr
add wave -noupdate -color Blue -radix unsigned /TX_tb/DUT/F1/stPtr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {91395 ps} 0}
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
