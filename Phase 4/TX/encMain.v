//===============================================================================
// FPGA Project - Phase 4
// Module Name: main frame of convolutional encoder (TX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module encMain
	(	// Ports Declaration
		input iClk,				// clock (slow)
		input iRst,				// reset (async.)
		input iEN,				// enable signal
		input iData,			// serial input data
		output wire oDataA,	// 1st output
		output wire oDataB		// 2nd output
	);

//---------- Wire & Variable Declaration ----------//
	integer k;
	reg [5:0] SREG;
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign oDataA = iData ^ SREG[1] ^ SREG[2] ^ SREG[4] ^ SREG[5];
	assign oDataB = iData ^ SREG[0] ^ SREG[1] ^ SREG[2] ^ SREG[5];
//--------------------------------------------//

//---------- Sequential Logic ----------//
	// Main shift register
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			SREG <= 6'b000000;
		else if (iEN) begin
			for (k=5; k>0; k=k-1)
				SREG[k] <= SREG[k-1];
			SREG[0] <= iData;
		end
	end
//--------------------------------------//

endmodule
