//===============================================================================
// FPGA Project - Phase 4
// Module Name: Full convolutional encoder (TX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module convEncoder
	(	// Ports Declaration
		input iFClk,			// clock (fast)
		input iSClk,			// clock (slow)
		input iRst,				// reset (async.)
		input iEN,				// enable signal
		input iData,			// serial input data
		output reg oData,		// serial output
		output wire oValid		// output-valid signal
	);

//---------- Local Parameters ----------//
	localparam IDLE = 1'b0,		// idle
				ENC = 1'b1;		// encode data
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	integer k;
	wire encOutA;				// encoder ouput A
	wire encOutB;				// encoder ouput B
	reg encOutSel;				// encoder output selector (acts as a counter)
	
	reg cState, nState;			// FSM current & next states
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign oValid = (cState != IDLE) ? 1'b1 : 1'b0;
//--------------------------------------------//

//---------- Module Instantiations ----------//
	// Convolutional encoder body
	encMain E0(
		.iClk(iSClk),
		.iRst(iRst),
		.iEN(iEN),
		.iData(iData),
		.oDataA(encOutA),
		.oDataB(encOutB)
	);
//-------------------------------------------//

//---------- Combinational Logic ----------//
	// Controller FSM
	always @(iEN, cState) begin
		nState = IDLE;
		case (cState)
			IDLE: nState = (!iEN) ? IDLE : ENC;
			ENC: nState = (iEN) ? ENC : IDLE;
		endcase
	end
//----------------------------------------//

//---------- Sequential Logic ----------//	
	// Controller FSM
	always @(posedge iFClk, posedge iRst) begin
		if (iRst)
			cState <= IDLE;
		else
			cState <= nState;
	end
	
	// Encoder output selector
	always @(posedge iFClk, posedge iRst) begin
		if (iRst)
			encOutSel <= 1'b0;
		else if (iEN)
			encOutSel <= ~encOutSel;
	end
	
	// Output data
	always @(posedge iFClk, posedge iRst) begin
		if (iRst)
			oData <= 1'b0;
		else if (iEN)
			oData <= (!encOutSel) ? encOutA : encOutB;
		else
			oData <= 1'b0;
	end
//--------------------------------------//

endmodule
