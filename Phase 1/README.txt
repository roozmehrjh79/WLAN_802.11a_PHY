//===============================================================================
// FPGA Project - Phase 1
// DIRECTORY MAP
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

== Folders ==
- ISE Project: includes ISE project files (has copies of all .v files)
- work: Modelsim 'work' directory

== Text Files ==
- frame_MATLAB.txt: MATLAB output frame (simulation)
- frame_VERILOG.txt: HDL output frame (simulation )
- output_MATLAB.txt: MATLAB output data (simulation)
- output_VERILOG.txt: HDL output data (simulation )
- input_data.txt: input RAW data (byte-oriented)
- input_info.txt: input RATE & LENGHT (hexadecimal)

== MATLAB files ==
- Phase1_TRX.m: MATLAB code for project
- scramble.m: scrambler function (in MATLAB)

== HDL files ==
- Phase1.v: top-level module
- Phase1_tb.v: text-bench
- RX_Controller: receiver controller
- RX_Descrambler: receiver descrambler
- TX_Controller: transmitter controller
- TX_Scrambler: transmitter scrambler

== Simulation Outputs ==
- Phase1_wf.do: Modelsim output waveform
