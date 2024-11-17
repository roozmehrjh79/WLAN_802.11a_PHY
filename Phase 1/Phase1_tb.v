//===============================================================================
// FPGA Project - Phase 1
// Module Name: TEST-BENCH (TX & RX sides)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================
`timescale 1ns/1ps
`define PERIOD 10						// clock period

module Phase1_tb();
	
//---------- Local Parameters ----------//
	parameter SEED = 7'b1011101;		// scrambler initial seed
	parameter HEADER = 12'hFFF;			// PLCP preamble
	parameter SIZE = 10;				// no. of raw DATA octets
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	reg Rst;				// reset
	reg Start;				// start
	reg [3:0] Rate;			// RATE
	reg [11:0] Lenght;		// LENGHT
	reg Data_In;			// serial input (TX side)
	wire Data_Out;			// serial output (RX side)
	wire Data_Valid;		// RX output validity indicator
	
	reg [7:0] V [0:9];		// variable for storing input test vector
	reg [7:0] HEX_IN;		// hexadecimal input data
	reg [7:0] HEX_FRAME;	// hexadecimal Wifi frame
	reg [7:0] HEX_OUT;		// hexadecimal received output
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
	integer fileID3;								// file 3 pointer
    integer scan_file1;								// scanf of file 1
    integer scan_file2;								// scanf of file 2
	integer scan_file3;								// scanf of file 3
//-----------------------------------------//

//---------- Initial Blocks ----------//
	// Applying stimulus
    initial begin
    	Rst = 1;
    	Start = 0;
    	Rate = 4'h0;
    	Lenght = 12'h000;
    	Data_In = 0;
		fileID3 = $fopen("input_info.txt", "r");
    	$readmemh("input_data.txt", V);
		
    	
    	@(posedge Clk);
    	@(posedge Clk);
    	Rst = 0;
    	@(posedge Clk);
    	@(posedge Clk);
    	
		// Read info (RATE & LENGHT) from file
    	@(negedge Clk);
    	Start = 1;
		scan_file3 = $fscanf(fileID3, "RATE=%x\n", Rate);
    	scan_file3 = $fscanf(fileID3, "LENGHT=%x\n", Lenght);
    	@(negedge Clk);
    	Start = 0;
    	Rate = 4'bxxxx;
    	Lenght = 12'bx;
    	
		// Insert data to 'Data_In' port
    	for (i=0; i<SIZE; i=i+1) begin
			HEX_IN = V[i];
			for (j=7; j>-1; j=j-1) begin
				Data_In = HEX_IN[j];
				@(negedge Clk);
			end
    	end
    	Data_In = 1'bx;
		$fclose(fileID3);
    	
    end
    
	// Writing Wifi frame to file
	initial begin
		fileID1 = $fopen("frame_VERILOG.txt", "w");
		wait(DUT.TX_On);							// wait until transmition starts
		@(posedge Clk);
		HEX_FRAME[7:4] = 4'h0;
		for (k=3; k>-1; k=k-1) begin				// write 4 "zero" bits before HEADER, so that all
			HEX_FRAME[k] = DUT.Wifi_Frame;			//  written data would be byte-oriented
			@(posedge Clk);
		end
		$fwrite(fileID1, "%x\n", HEX_FRAME);		// write data to file
		while(DUT.TX_On) begin
			for (k=7; k>-1; k=k-1) begin
				HEX_FRAME[k] = DUT.Wifi_Frame;
				@(posedge Clk);
			end
			$fwrite(fileID1, "%x\n", HEX_FRAME);
		end
		$fclose(fileID1);
	end
	
	// Writing output data to file & Verification
    initial begin
    	fileID2 = $fopen("output_VERILOG.txt", "w");
    	wait (Data_Valid);
		@(posedge Clk);
    	while (Data_Valid) begin
			for (m=7; m>-1; m=m-1) begin
				HEX_OUT[m] = Data_Out;
				@(posedge Clk);
			end
    		$fwrite(fileID2, "%x\n", HEX_OUT);
    	end
    	$fclose(fileID2);
		wait(!DUT.TX_On);	// wait until transmitted frame is sent completely
							// note that b/c of ignoring TAIL and PAD bits at RX side
							// we still have to wait for them to arrive!
		
		
		// NOTE: HEX_IN and HEX_OUT are used to compare VERILOG and MATLAB outputs in here!
		// Output data check
		fileID1 = $fopen("output_VERILOG.txt", "r");
		fileID2 = $fopen("output_MATLAB.txt", "r");
		scan_file1 = $fscanf(fileID1, "%x\n", HEX_IN);
		scan_file2 = $fscanf(fileID2, "%x\n", HEX_OUT);
		while (!$feof(fileID1) && !$feof(fileID2)) begin
			if (HEX_IN != HEX_OUT) begin	// in case of mismatch, display error & stop
				$display("ERROR [Output Data]: Mismatch detected!");
				$fclose(fileID1);
				$fclose(fileID2);
				$finish;
			end
			else begin
				scan_file1 = $fscanf(fileID1, "%x\n", HEX_IN);
				scan_file2 = $fscanf(fileID2, "%x\n", HEX_OUT);
			end
		end
		$display("SUCCESS [Output Data]: Simulation matches MATLAB output!");
		$fclose(fileID1);
		$fclose(fileID2);

		// Wifi frame data check
		fileID1 = $fopen("frame_VERILOG.txt", "r");
		fileID2 = $fopen("frame_MATLAB.txt", "r");
		scan_file1 = $fscanf(fileID1, "%x\n", HEX_IN);
		scan_file2 = $fscanf(fileID2, "%x\n", HEX_OUT);
		while (!$feof(fileID1) && !$feof(fileID2)) begin
			if (HEX_IN != HEX_OUT) begin
				$display("ERROR [Wifi Frame]: Mismatch detected!");
				$fclose(fileID1);
				$fclose(fileID2);
				$finish;
			end
			else begin
				scan_file1 = $fscanf(fileID1, "%x\n", HEX_IN);
				scan_file2 = $fscanf(fileID2, "%x\n", HEX_OUT);
			end
		end
		$display("SUCCESS [Wifi Frame]: Simulation matches MATLAB output!");
		$fclose(fileID1);
		$fclose(fileID2);
		
		$finish;
    end
//------------------------------------//

//---------- Device Under Test ----------//
	defparam DUT.SEED = SEED;
	defparam DUT.HEADER = HEADER;
	Phase1 DUT(
		.Clk(Clk),
		.Rst(Rst),
		.Start(Start),
		.Rate(Rate),
		.Lenght(Lenght),
		.Input_Data(Data_In),
		.Output_Data(Data_Out),
		.Output_Valid(Data_Valid)
	);
//---------------------------------------//

endmodule
