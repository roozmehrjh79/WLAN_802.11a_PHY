//===============================================================================
// FPGA Project - Phase 3
// Module Name: TEST-BENCH (TX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================
`timescale 1ns/1ps
`define PERIOD 10						// fast clock period

module deinterleaver_tb();

//---------- Local Parameters ----------//
	parameter SIZE = 384;				// no. of input data bits
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	reg Rst;				// reset
	reg EN;					// enable
	reg [3:0] Rate;			// input data rate
	reg RateEN;				// input rate enable
	reg Data_In;			// serial input
	wire Data_Out;			// serial output
	wire Data_Valid;		// RX output validity indicator
	
	reg V [0:SIZE-1];		// variable for storing input test vector
	reg  DAT_OUT;			// deinterleaved output
	reg  MAT_OUT;			// MATLAB output
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
		RateEN = 0;
		Rate = 4'h0;
    	Data_In = 0;
		
		// Read data rate & input test vector
		fileID1 = $fopen("input_info.txt", "r");
		$fscanf(fileID1, "RATE=%b\n", Rate);
		$fclose(fileID1);
    	$readmemb("intData_MATLAB.txt", V);
    	
    	@(posedge Clk);
    	@(posedge Clk);
    	Rst = 0;
    	@(posedge Clk);
    	@(posedge Clk);
    	
		// Apply data rate into the module
		#1;
		RateEN = 1;
		@(posedge Clk);
		RateEN = #1 0;
		
		// Insert data to 'Data_In' port
		@(posedge Clk);
		RateEN = #1 0;
		EN = 1;
    	for (i=0; i<SIZE; i=i+1) begin
			Data_In = #1 V[i];
			@(posedge Clk);
    	end
    	Data_In = 1'b0;    	
    end
    
	// Writing deinterleaved output to file & Verification
	initial begin
		fileID1 = $fopen("deintData_VERILOG.txt", "w");
		wait(Data_Valid);							// wait until outputing starts
		#1;
		for (k=0; k<SIZE; k=k+1) begin
			DAT_OUT = Data_Out;
			$fwrite(fileID1, "%b\n", DAT_OUT);
			@(posedge Clk);
			#1;
		end
		$fclose(fileID1);
		
		// NOTE: DAT_OUT and MAT_OUT are used to compare VERILOG and MATLAB outputs!
		// Output data check
		fileID1 = $fopen("deintData_VERILOG.txt", "r");
		fileID2 = $fopen("deintData_MATLAB.txt", "r");
		scan_file1 = $fscanf(fileID1, "%b\n", DAT_OUT);
		scan_file2 = $fscanf(fileID2, "%b\n", MAT_OUT);
		while (!$feof(fileID1) && !$feof(fileID2)) begin
			if (DAT_OUT !== MAT_OUT) begin				// in case of mismatch, display error & stop
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
	deinterleaver DUT(
		.iClk(Clk),
		.iRst(Rst),
		.iEN(EN),
		.iRateEN(RateEN),
		.iRate(Rate),
		.iData(Data_In),
		.oData(Data_Out),
		.oValid(Data_Valid)
	);
//---------------------------------------//

endmodule
