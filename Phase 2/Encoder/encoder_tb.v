//===============================================================================
// FPGA Project - Phase 2
// Module Name: TEST-BENCH (TX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================
`timescale 1ns/1ps
`define PERIOD 10						// fast clock period

module encoder_tb();

//---------- Local Parameters ----------//
	parameter SIZE = 70;				// no. of input data bits
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	wire slwClk;			// slow clock
	reg Rst;				// reset
	reg EN;					// enable
	reg Data_In;			// serial input
	wire Data_Out;			// serial output
	wire Data_Valid;		// TX output validity indicator
	
	reg V [0:SIZE-1];		// variable for storing input test vector
	reg [1:0] DAT_OUT;		// encoded output (2-bit format)
	reg [1:0] MAT_OUT;		// MATLAB output (2-bit format)
//-------------------------------------------------//

//---------- Clock Signal Generation ----------//
	reg Clk = 1'b1;
    always @(Clk)
        Clk <= #(`PERIOD/2) ~Clk;
		
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
    	EN = 0;
    	Data_In = 0;
    	$readmemb("raw_data.txt", V);
    	
    	@(posedge Clk);
    	@(posedge Clk);
    	Rst = 0;
    	@(posedge Clk);
    	@(posedge Clk);
    	
		// Insert data to 'Data_In' port
		@(posedge slwClk);
		EN = #1 1;
    	for (i=0; i<SIZE; i=i+1) begin
			Data_In = V[i];
			@(posedge slwClk);
    	end
    	Data_In = 1'b0;    	
    end
    
	// Writing decoded output to file & Verification
	initial begin
		fileID1 = $fopen("encData_VERILOG.txt", "w");
		wait(Data_Valid);							// wait until encoding starts
		#1;
		for (k=0; k<SIZE; k=k+1) begin
			for (m=1; m>-1; m=m-1) begin
				DAT_OUT[m] = Data_Out;
				@(posedge Clk);
				#1;
			end
			$fwrite(fileID1, "%b\n", DAT_OUT);
		end
		$fclose(fileID1);
		
		// NOTE: DAT_OUT and MAT_OUT are used to compare VERILOG and MATLAB outputs!
		// Output data check
		fileID1 = $fopen("encData_VERILOG.txt", "r");
		fileID2 = $fopen("encData_MATLAB.txt", "r");
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
	TX_Controller DUT(
		.iClk(Clk),
		.iRst(Rst),
		.iEN(EN),
		.iData(Data_In),
		.oData(Data_Out),
		.oTX(Data_Valid)
	);
//---------------------------------------//

endmodule
