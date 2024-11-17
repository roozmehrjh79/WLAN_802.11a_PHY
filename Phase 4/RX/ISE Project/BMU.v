//===============================================================================
// FPGA Project - Phase 4
// Module Name: branch metric unit (BMU)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module BMU
	(	// Ports Declaration
		input iA,					// 1st input (output 'A' of the conv. encoder)
		input iB,					// 2nd input (output 'B' of the conv. encoder)
		output wire [1:0] oBM00,	// branch metrics for 00, 01, 10 and 11
		output wire [1:0] oBM01,
		output wire [1:0] oBM10,
		output wire [1:0] oBM11
	);

//---------- Wire & Variable Declaration ----------//
	wire A_NEG = ~iA;
	wire B_NEG = ~iB;
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign oBM00 = iA + iB;
	assign oBM10 = iA + B_NEG;
	assign oBM01 = A_NEG + iB;
	assign oBM11 = A_NEG + B_NEG;
//--------------------------------------------//

endmodule
