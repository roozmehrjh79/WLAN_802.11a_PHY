//===============================================================================
// FPGA Project - Phase 4
// Module Name: TEST-BENCH (TX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================
`timescale 1ns/1ps
`define PERIOD 10						// fast clock period

module TX_tb();

//---------- Local Parameters ----------//
	parameter SIZE = 10;				// no. of RAW data octets
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	reg Rst;				// reset
	reg Start;				// start signal
	reg [3:0] Rate;			// input data rate
	reg [11:0] Length;		// no. of input bytes
	reg Input_Data;			// serial input
	wire Output_Data;		// serial output
	wire Output_Valid;		// TX output validity indicator
	wire Busy;				// busy status indicator
	
	reg [7:0] V [0:SIZE-1];	// variable for storing input test vector
	reg [7:0] HEX_IN;		// hexadecimal input data
	reg [7:0] HEX_OUT;		// hexadecimal received output
//-------------------------------------------------//

//---------- Clock Signal Generation ----------//
	reg Clk = 1'b1;
    always @(Clk)
        Clk <= #(`PERIOD/2) ~Clk;
		
	// Slow clocks
	wire slwClk1, slwClk2;
	assign slwClk1 = DUT.slwClk1;
	assign slwClk2 = ~(DUT.slwClk2);
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
    	Start = 0;
    	Rate = 4'h0;
    	Length = 12'h000;
    	Input_Data = 0;
		
		// Read input test vector
		fileID1 = $fopen("input_info.txt", "r");
    	$readmemh("input_data.txt", V);
    	
    	@(posedge Clk);
    	@(posedge Clk);
    	Rst = 0;
    	@(posedge Clk);
    	@(posedge Clk);
    	
		// Read info (RATE & Length) from file
    	@(posedge slwClk1);
    	Start = #1 1;
		scan_file1 = $fscanf(fileID1, "RATE=%x\n", Rate);
    	scan_file1 = $fscanf(fileID1, "LENGTH=%x\n", Length);
    	@(posedge slwClk1);
    	Start = #1 0;
    	Rate = 4'bxxxx;
    	Length = 12'bx;
		
		// Insert data to 'iData' port
    	for (i=0; i<SIZE; i=i+1) begin
			HEX_IN = V[i];
			for (j=7; j>-1; j=j-1) begin
				Input_Data = HEX_IN[j];
				@(posedge slwClk1);
				#1;
			end
    	end
    	Input_Data = 1'b0;
		$fclose(fileID1);
    end
    
	// Writing output to file & Verification
	initial begin
		fileID2 = $fopen("TXData_VERILOG.txt", "w");
		wait(Output_Valid);							// wait until transmition starts
		@(posedge Clk);
		HEX_OUT[7:4] = 4'h0;
		for (k=3; k>-1; k=k-1) begin				// write 4 "zero" bits before HEADER, so that all
			HEX_OUT[k] = Output_Data;				//  written data would be byte-oriented
			@(posedge Clk);
		end
		$fwrite(fileID2, "%x\n", HEX_OUT);			// write data to file
		while(Output_Valid) begin
			for (k=7; k>-1; k=k-1) begin
				HEX_OUT[k] = Output_Data;
				@(posedge Clk);
			end
			$fwrite(fileID2, "%x\n", HEX_OUT);
		end
		$fclose(fileID2);
		
		// NOTE: HEX_IN and HEX_OUT are used to compare VERILOG and MATLAB outputs in here!
		// Output data check
		fileID1 = $fopen("TXData_VERILOG.txt", "r");
		fileID2 = $fopen("TXData_MATLAB.txt", "r");
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
		$display("SUCCESS: Simulation matches MATLAB output!");
		$fclose(fileID1);
		$fclose(fileID2);
		$stop;
	end
	

//------------------------------------//

//---------- Device Under Test ----------//
	TX_Controller DUT(
		.iClk(Clk),
		.iRst(Rst),
		.iStart(Start),
		.iRate(Rate),
		.iLength(Length),
		.iData(Input_Data),
		.oData(Output_Data),
		.oTX_EN(Output_Valid),
		.oBusy(Busy)
	);
//---------------------------------------//

endmodule
