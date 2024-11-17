//===============================================================================
// FPGA Project - Phase 3
// DIRECTORY MAP
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

== Folders ==
- Deinterleaver: includes these files/folders:
	- deinterleaver.v: deinterleaver HDL code
	- deinterleaver_tb.v: test-bench
	- dint_wave.do: Modelsim waveform
	- deintData_MATLAB.txt: MATLAB output (de-interleaved)
	- deintData_VERILOG.txt: test-bench output
	- input_info.txt: includes RATE and length of input data
	- intData_MATLAB.txt: MATLAB output, which acts as the input for the test-bench
	- /ISE Project: includes ISE project files (has copies of all .v files)
	-/work: Modelsim 'work' directory
	* Other files are Modelsim residual files!

- Interleaver: includes these files/folders:
	- interleaver.v: interleaver HDL code
	- interleaver_tb.v: test-bench
	- int_wave.do: Modelsim waveform
	- input_info.txt: includes RATE and length of input data
	- input_data.txt: raw input for test-bench
	- intData_MATLAB.txt: MATLAB output (interleaved)
	- intData_VERILOG.txt: test-bench output
	- /ISE Project: includes ISE project files (has copies of all .v files)
	-/work: Modelsim 'work' directory
	* Other files are Modelsim residual files!

- MATLAB Code: includes these files/folders:
	- Phase3_RTX.m: MATLAB code (TX & RX sides)
	- 'txt' files: explained before!
