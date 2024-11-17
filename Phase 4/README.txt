//===============================================================================
// FPGA Project - Phase 4
// DIRECTORY MAP
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

== Folders ==
- TX: includes these files/folders:
	- TX_Controller.v: top-level transmitter HDL code
	- TX_tb.v: test-bench
	- FIFO.v: FIFO memory HDL code
		* other .v files are modules from previous phases!
	- TX_wave.do: Modelsim waveform
	- input_data.txt: raw data (byte-oriented)
	- input_info.txt: contains RATE & LENGTH
	- TXData_MATLAB.txt: MATLAB output
	- TXData_VERILOG.txt: test-bench output
	-/work: Modelsim 'work' directory
	* Other files are Modelsim residual files!

- RX: includes these files/folders:
	- RX_Controller.v: top-level receiver HDL code
	- RX_tb.v: test-bench
	- FIFO.v: FIFO memory HDL code
		* other .v files are modules from previous phases!
	- RX_wave.do: Modelsim waveform
	- input_data.txt: raw input (used for comparison with test-bench output)
	- TXData_VERILOG.txt: transmitter output (used as input for test-bench)
	- RXData_VERILOG.txt: test-bench output
	- /ISE Project: includes ISE project files (has copies of all .v files)
	-/work: Modelsim 'work' directory
	* Other files are Modelsim residual files!

- MATLAB Code: includes these files/folders:
	- Phase4_RTX.m: MATLAB code (TX & RX sides)
	- 'txt' files: explained before!
