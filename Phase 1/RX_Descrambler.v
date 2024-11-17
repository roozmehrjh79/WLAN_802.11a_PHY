//===============================================================================
// FPGA Project - Phase 1
// Module Name: lenght-127 frame-synchronous descrambler (RX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module RX_Descrambler
	(	// Ports Declaration
		input iClk,					// clock
		input iRst,					// async. reset
		input iSEN,					// set-seed enable
		input iData,				// input data stream (scrambled) OR incoming seed
		output wire oData			// descrambled output stream
	);

//---------- Wire & Variable Declaration ----------//
	integer k;
	reg [7:1] LFSR;					// linear-feedback shift-register
	wire LFSR_In;					// input to LFSR[1]
	wire XOR_mid;					// middle XOR gate (LFSR[4]^LFSR[7])
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign XOR_mid = LFSR[7] ^ LFSR[4];
	assign oData = XOR_mid ^ iData;
//--------------------------------------------//

//---------- Sequential Logic ----------//
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			LFSR <= 7'b0000000;
		else begin
			for(k=7; k>1; k=k-1)
				LFSR[k] <= LFSR[k-1];
			LFSR[1] <= (iSEN) ? iData : XOR_mid;
		end
	end
//--------------------------------------//

endmodule
