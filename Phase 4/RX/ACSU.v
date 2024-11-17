//===============================================================================
// FPGA Project - Phase 4
// Module Name: add-compare-select unit (ACSU)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module ACSU
	#(
		parameter PM_WIDTH = 13			// path metric register BW
	)
	(	// Ports Declaration
		input iClk,						// clock
		input iRst,						// reset (async.)
		input iEN,						// PM write enable
		input [PM_WIDTH-1:0] iPM0,		// PM of previous state if input of conv. encoder was 0
		input [PM_WIDTH-1:0] iPM1,		// ~		~		~		~		~		~		~ 1
		input [1:0] iBM0,				// appropriate BM if input of conv. encoder was 0
		input [1:0] iBM1,				// ~		~		~		~		~		~	1
		output reg oSP,					// survivor path
		output reg [PM_WIDTH-1:0] oPM	// PM register (current state)
	);

//---------- Wire & Variable Declaration ----------//
	wire [PM_WIDTH-1:0] PM0_ADD_BM0;					// = iPM0 + iBM0
	wire [PM_WIDTH-1:0] PM1_ADD_BM1;					// = iPM1 + IBM1
	wire [PM_WIDTH-1:0] newPM;							// new value of current-state PM
	wire [PM_WIDTH-1:0] PM0_SUB_PM1;					// = csPM0 - csPM1
	wire PM0_GTE_PM1;									// flag determining if 'csPM0' is equal to or greater than 'csPM1'							
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign PM0_ADD_BM0 = iPM0 + iBM0;
	assign PM1_ADD_BM1 = iPM1 + iBM1;
	
	assign PM0_SUB_PM1 = PM0_ADD_BM0 - PM1_ADD_BM1;
	assign PM0_GTE_PM1 = ~PM0_SUB_PM1[PM_WIDTH-1];
	assign newPM = (PM0_GTE_PM1) ? PM1_ADD_BM1 : PM0_ADD_BM0;			// newPM = min(PM0, PM1)
//--------------------------------------------//

//---------- Sequential Logic ----------//
	// Current-state path metric
	always @(posedge iClk, posedge iRst) begin
		if (iRst) begin
			oPM <= {(PM_WIDTH){1'b0}};
		end
		else if (iEN)
			oPM <= newPM;
	end
	
	// Survivor path
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			oSP <= 1'b0;
		else if (iEN)
			oSP <= PM0_GTE_PM1;
	end
//--------------------------------------//

endmodule
