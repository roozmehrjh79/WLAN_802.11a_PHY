//===============================================================================
// FPGA Project - Phase 2
// DIRECTORY MAP
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

== Folders ==
- Decoder: includes these files/folders:
	- ACSU.v: Add-Compare-Select Unit HDL code
	- ASPRAM.v: async.-read RAM HDL code
	- SPRAMv: sync.-read RAM HDL code
	- BMU: branch metric unit HDL code
	- PMU: path metric unit HDL code
	- TBU: traceback unit HDL code
	- LIFO: stack memory HDL code
	- vitDecoder.v: top-level Viterbi Decoder module
	- vitDecoder_tb.b: test-bench
	- decData_MATLAB.txt: MATLAB decoded output
	- decData_VERILOG.txt: HDL	~	~
	- encData_VERILOG.txt: HDL encoded output (from encoder module)
	- dec_wave.do: Modelsim waveform
	- /ISE Project: includes ISE project files (has copies of all .v files)
	-/work: Modelsim 'work' directory
	* Other files are Modelsim residual files!

- Encoder: includes these files/folders:
	- convEncoder.v: HDL code for conv. encoder
	- TX_Controller.v: top-level module
	- encoder_tb.v: test-bench
	- 'txt' files: MATLAB & HDL outputs (encoded), and 'raw_input.txt' is raw input bits!
	- enc_wave.do: Modelsim waveform
	- /ISE Project: includes ISE project files (has copies of all .v files)
	-/work: Modelsim 'work' directory
	* Other files are Modelsim residual files!

- MATLAB Code: includes these files/folders:
	- Phase2_RTX.m: MATLAB code (TX & RX sides)
	- 'txt' files: explained before!
