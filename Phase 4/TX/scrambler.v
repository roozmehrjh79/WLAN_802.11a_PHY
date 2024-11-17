//===============================================================================
// FPGA Project - Phase 4
// Module Name: lenght-127 frame-synchronous scrambler (TX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module scrambler
	(	// Ports Declaration
		input iClk,					// clock
		input iRst,					// async. reset
		input iSEN,					// set initial state enable
		input [7:1] iState,			// initial state
		input iData,				// input data stream
		output wire oData			// scrambled output stream
	);

//---------- Wire & Variable Declaration ----------//
	integer k;
	reg [7:1] LFSR;					// linear-feedback shift-register
	wire XOR_mid;					// middle XOR gate (LFSR[4]^LFSR[7])
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign XOR_mid = LFSR[7] ^ LFSR[4];
	assign oData = XOR_mid ^ iData;
//--------------------------------------------//

//---------- Sequential Logic ----------//
	always @(posedge iClk, posedge iRst) begin
		if (iRst)						// reset has top priority
			LFSR <= 7'b0000000;
		else if (iSEN)					// loads initial state if enabled
			LFSR <= iState;
		else begin						// normal behavior
			for (k=2; k<=7; k=k+1)
				LFSR[k] <= LFSR[k-1];
			LFSR[1] <= XOR_mid;
		end
	end
//--------------------------------------//

endmodule
