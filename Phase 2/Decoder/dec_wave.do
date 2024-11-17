onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /vitDecoder_tb/Clk
add wave -noupdate -color {Orange Red} /vitDecoder_tb/Rst
add wave -noupdate /vitDecoder_tb/EN
add wave -noupdate -color {Pale Green} /vitDecoder_tb/Data_In
add wave -noupdate -color Magenta /vitDecoder_tb/Data_Out
add wave -noupdate /vitDecoder_tb/Data_Valid
add wave -noupdate /vitDecoder_tb/DUT/BM
add wave -noupdate -radix unsigned /vitDecoder_tb/DUT/PMU0/PM
add wave -noupdate /vitDecoder_tb/DUT/SP
add wave -noupdate /vitDecoder_tb/DUT/SP_Valid
add wave -noupdate -color {Slate Blue} -radix unsigned /vitDecoder_tb/DUT/PMU0/oCounter
add wave -noupdate -color {Slate Blue} /vitDecoder_tb/DUT/PMU0/oCNT_ZERO
add wave -noupdate -radix unsigned /vitDecoder_tb/DUT/PMU0/oMinPM
add wave -noupdate /vitDecoder_tb/DUT/PMU0/oMinFound
add wave -noupdate /vitDecoder_tb/DUT/TBU0/tracePtr
add wave -noupdate /vitDecoder_tb/DUT/TBU0/updatePtr
add wave -noupdate /vitDecoder_tb/DUT/TBU0/cLIFO
add wave -noupdate -color Cyan -radix unsigned /vitDecoder_tb/DUT/TBU0/TB_BIT
add wave -noupdate -color Cyan /vitDecoder_tb/DUT/TBU0/DEC_BIT
add wave -noupdate /vitDecoder_tb/DUT/TBU0/L0_PUSH
add wave -noupdate /vitDecoder_tb/DUT/TBU0/L0_POP
add wave -noupdate /vitDecoder_tb/DUT/TBU0/L0_EMPTY
add wave -noupdate /vitDecoder_tb/DUT/TBU0/L0_FULL
add wave -noupdate /vitDecoder_tb/DUT/TBU0/L1_PUSH
add wave -noupdate /vitDecoder_tb/DUT/TBU0/L1_POP
add wave -noupdate /vitDecoder_tb/DUT/TBU0/L1_EMPTY
add wave -noupdate /vitDecoder_tb/DUT/TBU0/L1_FULL
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
WaveRestoreZoom {1238809 ps} {1466529 ps}
