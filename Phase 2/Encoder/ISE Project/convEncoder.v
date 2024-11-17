//===============================================================================
// FPGA Project - Phase 2
// Module Name: convolutional encoder (TX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module convEncoder
	(	// Ports Declaration
		input iClk,				// clock (slow)
		input iRst,				// reset (async.)
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
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			SREG <= 6'b000000;
		else begin
			for (k=5; k>0; k=k-1)
				SREG[k] <= SREG[k-1];
			SREG[0] <= iData;
		end
	end
//--------------------------------------//

endmodule
