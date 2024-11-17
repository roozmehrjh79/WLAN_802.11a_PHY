//===============================================================================
// FPGA Project - Phase 4
// Module Name: TEST-BENCH (RX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================
`timescale 1ns/1ps
`define PERIOD 10						// fast clock period

module RX_tb();

//---------- Local Parameters ----------//
	parameter SIZE = 56;				// no. of input octets
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	reg Rst;				// reset
	reg Input_Data;			// serial input
	wire Output_Data;		// serial output
	wire Output_Valid;		// RX output validity indicator
	wire Busy;				// busy status indicator
	
	reg [7:0] V [0:SIZE-1];	// variable for storing input test vector
	reg [7:0] HEX_IN;		// hexadecimal input data
	reg [7:0] HEX_OUT;		// hexadecimal received output
//-------------------------------------------------//

//---------- Clock Signal Generation ----------//
	reg Clk = 1'b1;
    always @(Clk)
        Clk <= #(`PERIOD/2) ~Clk;
		
	// Slow clock
	wire slwClk;
	assign slwClk = DUT.slwClk;
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
    	Input_Data = 0;
		
		// Read input test vector
    	$readmemh("TXData_VERILOG.txt", V);
    	
    	@(posedge Clk);
    	@(posedge Clk);
    	Rst = 0;
    	@(posedge Clk);
    	@(posedge Clk);
    	
		// Read info (RATE & LENGHT) from file
    	@(posedge Clk);
    	@(posedge Clk);
		
		// Insert data to 'iData' port
    	for (i=0; i<SIZE; i=i+1) begin
			HEX_IN = V[i];
			for (j=7; j>-1; j=j-1) begin
				Input_Data = #1 HEX_IN[j];
				@(posedge Clk);
			end
    	end
    	Input_Data = 1'b0;
    end
    
	// Writing output to file & Verification
	initial begin
		fileID2 = $fopen("RXData_VERILOG.txt", "w");
		wait(Output_Valid);							// wait until reception starts
		@(posedge slwClk);
		while(Output_Valid) begin
			for (k=7; k>-1; k=k-1) begin
				HEX_OUT[k] = Output_Data;
				@(posedge slwClk);
			end
			$fwrite(fileID2, "%x\n", HEX_OUT);
		end
		$fclose(fileID2);
		
		// NOTE: HEX_IN and HEX_OUT are used to compare VERILOG output and ORIGINAL DATA in here!
		// Output data check
		fileID1 = $fopen("RXData_VERILOG.txt", "r");
		fileID2 = $fopen("input_data.txt", "r");
		scan_file1 = $fscanf(fileID1, "%x\n", HEX_IN);
		scan_file2 = $fscanf(fileID2, "%x\n", HEX_OUT);
		while (!$feof(fileID1) && !$feof(fileID2)) begin
			if (HEX_IN !== HEX_OUT) begin	// in case of mismatch, display error & stop
				$display("ERROR: Mismatch detected!");
				$fclose(fileID1);
				$fclose(fileID2);
				$stop;
			end
			else begin
				scan_file1 = $fscanf(fileID1, "%x\n", HEX_IN);
				scan_file2 = $fscanf(fileID2, "%x\n", HEX_OUT);
			end
		end
		$display("SUCCESS: Simulation output matches original data!");
		$fclose(fileID1);
		$fclose(fileID2);
		$stop;
	end
	

//------------------------------------//

//---------- Device Under Test ----------//
	RX_Controller DUT(
		.iClk(Clk),
		.iRst(Rst),
		.iData(Input_Data),
		.oData(Output_Data),
		.oRX_EN(Output_Valid),
		.oBusy(Busy)
	);
//---------------------------------------//

endmodule
