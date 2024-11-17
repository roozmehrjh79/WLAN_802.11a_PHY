//===============================================================================
// FPGA Project - Phase 2
// Module Name: controller (TX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module TX_Controller
	(	// Ports Declaration
		input iClk,				// clock (fast)
		input iRst,				// reset (async.)
		input iEN,				// enable signal
		input iData,			// serial input data
		output reg oData,		// serial output
		output wire oTX			// transmission-enable signal
	);

//---------- Local Parameters ----------//
	localparam IDLE = 1'b0,		// idle
				ENC = 1'b1;		// encode data
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	integer k;
	reg slwClk;					// slow clock
	wire encOutA;				// encoder ouput A
	wire encOutB;				// encoder ouput B
	reg encOutSel;				// encoder output selector (acts as a counter)
	
	reg cState, nState;			// FSM current & next states
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign oTX = (cState != IDLE) ? 1'b1 : 1'b0;
//--------------------------------------------//

//---------- Module Instantiations ----------//
	// Convolutional encoder
	convEncoder ENC0(
		.iClk(slwClk),
		.iRst(iRst),
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
	// Slow clock (1/2 frequency of 'iClk')
	always @(negedge iClk, posedge iRst) begin
		if (iRst)
			slwClk <= 1'b0;
		else
			slwClk <= ~slwClk;
	end
	
	// Controller FSM
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			cState <= IDLE;
		else
			cState <= nState;
	end
	
	// Encoder output selector
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			encOutSel <= 1'b0;
		else if (iEN)
			encOutSel <= ~encOutSel;
	end
	
	
	// Output data
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			oData <= 1'b0;
		else if (iEN)
			oData <= (!encOutSel) ? encOutA : encOutB;
		else
			oData <= 1'b0;
	end
//--------------------------------------//

endmodule
