//===============================================================================
// FPGA Project - Phase 2
// Module Name: TEST-BENCH (RX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================
`timescale 1ns/1ps
`define PERIOD 10						// slow clock period

module vitDecoder_tb();

//---------- Local Parameters ----------//
	parameter SIZE = 70;				// no. of encoded data bit-pairs
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	reg Rst;				// reset
	reg EN;					// enable
	reg [1:0] Data_In;		// 2-bit input
	wire Data_Out;			// serial output
	wire Data_Valid;		// RX output validity indicator
	
	reg [1:0] V [0:SIZE-1];		// variable for storing input test vector
	reg [1:0] DAT_IN;			// 2-bit encoded input
	reg DAT_OUT;				// decoded output
	reg MAT_OUT;				// MATLAB output
//-------------------------------------------------//

//---------- Clock Signal Generation ----------//
	reg Clk = 1'b1;
    always @(Clk)
        Clk <= #(`PERIOD/2) ~Clk;
//---------------------------------------------//

//---------- Integer Declaration ----------//
	integer i, j, k, m;
    integer fileID1;								// file 1 pointer
    integer fileID2;								// file 2 pointer
    integer scan_file1;								// scanf of file 1
    integer scan_file2;								// scanf of file 2
//-----------------------------------------//

//---------- Initial Blocks ----------//
	// Applying stimulus
    initial begin
    	Rst = 1;
    	EN = 0;
    	Data_In = 0;
    	$readmemb("encData_VERILOG.txt", V);
    	
    	@(posedge Clk);
    	@(posedge Clk);
    	Rst = 0;
    	@(posedge Clk);
    	@(posedge Clk);
    	
		// Insert data to 'Data_In' port
		@(posedge Clk);
		EN = #1 1;
    	for (i=0; i<SIZE; i=i+1) begin
			DAT_IN = V[i];
			Data_In = DAT_IN;
			@(posedge Clk);
    	end
    	Data_In = 1'b0;    	
    end
    
	// Writing decoded output to file & Verification
	initial begin
		fileID1 = $fopen("decData_VERILOG.txt", "w");
		wait(Data_Valid);							// wait until decoding starts
		@(negedge Clk);
		for (m=0; m<SIZE; m=m+1) begin
				DAT_OUT = Data_Out;
				@(negedge Clk);
			$fwrite(fileID1, "%b\n", DAT_OUT);
		end
		$fclose(fileID1);
		
		// NOTE: DAT_OUT and MAT_OUT are used to compare VERILOG and MATLAB outputs!
		// Output data check
		fileID1 = $fopen("decData_VERILOG.txt", "r");
		fileID2 = $fopen("decData_MATLAB.txt", "r");
		scan_file1 = $fscanf(fileID1, "%b\n", DAT_OUT);
		scan_file2 = $fscanf(fileID2, "%b\n", MAT_OUT);
		while (!$feof(fileID1) && !$feof(fileID2)) begin
			if (DAT_OUT !== MAT_OUT) begin					// in case of mismatch, display error & stop
				$display("ERROR: Mismatch detected!");
				$fclose(fileID1);
				$fclose(fileID2);
				$stop;
			end
			else begin
				scan_file1 = $fscanf(fileID1, "%b\n", DAT_OUT);
				scan_file2 = $fscanf(fileID2, "%b\n", MAT_OUT);
			end
		end
		
		$display("SUCCESS: Simulation matches MATLAB output!");
		$fclose(fileID1);
		$fclose(fileID2);
		$stop;
	end
	

//------------------------------------//

//---------- Device Under Test ----------//
	vitDecoder DUT(
		.iClk(Clk),
		.iRst(Rst),
		.iEN(EN),
		.iData(Data_In),
		.oData(Data_Out),
		.oValid(Data_Valid)
	);
//---------------------------------------//

endmodule
