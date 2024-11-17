//===============================================================================
// FPGA Project - Phase 1
// Module Name: Top-level module
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module Phase1
	#(	// Parameters
		parameter SEED = 7'b1011101,	// scrambler initial seed
					HEADER = 12'hFFF	// PLCP preamble
	)
	(	// Ports Declaration
		input Clk,						// clock
		input Rst,						// async. reset
		input Start,					// input start signal
		input [3:0] Rate,				// input rate (not used in here)
		input [11:0] Lenght,			// LENGHT field
		input Input_Data,				// input stream (serial)
		output wire Output_Data,		// output stream (serial)
		output wire Output_Valid		// indicator for output DATA
	);

//---------- Wire & Variable Declaration ----------//
	wire Scrambler_In;
	wire Scrambler_Out;
	wire Scrambler_SEN;
	wire [6:0] Scrambler_Seed;
	wire Descrambler_In;
	wire Descrambler_Out;
	wire Descrambler_SEN;
	wire TX_On;							// transmission indicator
	wire Wifi_Frame;					// Wifi frame
//-------------------------------------------------//

//---------- Module Instantiations ----------//
	defparam TX_CTRL0.SEED = SEED;
	defparam TX_CTRL0.HEADER = HEADER;
	TX_Controller TX_CTRL0(
		.iClk(Clk),
		.iRst(Rst),
		.iStart(Start),
		.iRate(Rate),
		.iLenght(Lenght),
		.iData(Input_Data),
		.iSCMB_Out(Scrambler_Out),
		.oSCMB_SEN(Scrambler_SEN),
		.oSCMB_Seed(Scrambler_Seed),
		.oSCMB_In(Scrambler_In),
		.oData(Wifi_Frame),
		.oTransmit(TX_On)
	);
	
	TX_Scrambler TX_SCMB0(
		.iClk(Clk),
		.iRst(Rst),
		.iSEN(Scrambler_SEN),
		.iState(Scrambler_Seed),
		.iData(Scrambler_In),
		.oData(Scrambler_Out)
	);
	
	RX_Descrambler RX_DSCMB0(
		.iClk(Clk),
		.iRst(Rst),
		.iSEN(Descrambler_SEN),
		.iData(Descrambler_In),
		.oData(Descrambler_Out)
	);
	
	defparam RX_CTRL0.HEADER = HEADER;
	RX_Controller RX_CTRL0(
		.iClk(Clk),
		.iRst(Rst),
		.iData(Wifi_Frame),
		.iDSCMB_Out(Descrambler_Out),
		.oDSCMB_SEN(Descrambler_SEN),
		.oDSCMB_In(Descrambler_In),
		.oData(Output_Data),
		.oValid(Output_Valid)
	);
//-------------------------------------------//

endmodule
