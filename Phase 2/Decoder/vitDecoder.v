//===============================================================================
// FPGA Project - Phase 2
// Module Name: Viterbi decoder
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module vitDecoder
	(	// Ports Declaration
		input iClk,					// slow clock
		input iRst,					// reset (async.)
		input iEN,					// enable signal
		input [1:0] iData,			// 2-bit input
		output wire oData,			// serial output
		output wire oValid			// output validity indicator
	);

//---------- Wire & Variable Declaration ----------//
	// Module interconnections
	wire [1:0] BM [0:3];
	wire [63:0] SP;
	wire SP_Valid;
	wire [5:0] MinPM;
	wire MinFound;
	wire [4:0] Counter;
	wire CNT_ZERO;
//-------------------------------------------------//

//---------- Module Instantiations ----------//
	// BMU
	BMU BMU0(
		.iA(iData[1]),
		.iB(iData[0]),
		.oBM00(BM[0]),
		.oBM01(BM[1]),
		.oBM10(BM[2]),
		.oBM11(BM[3])
	);
	
	// PMU
	PMU PMU0(
		.iClk(iClk),
		.iRst(iRst),
		.iEN(iEN),
		.iBM00(BM[0]),
		.iBM01(BM[1]),
		.iBM10(BM[2]),
		.iBM11(BM[3]),
		.oSP(SP),
		.oSP_Valid(SP_Valid),
		.oMinPM(MinPM),
		.oMinFound(MinFound),
		.oCounter(Counter),
		.oCNT_ZERO(CNT_ZERO)
	);
	
	// TBU
	TBU TBU0(
		.iClk(iClk),
		.iRst(iRst),
		.iEN(iEN),
		.iSP(SP),
		.iSP_Valid(SP_Valid),
		.iMinPM(MinPM),
		.iMinPM_Found(MinFound),
		.iCounter(Counter),
		.iCNT_ZERO(CNT_ZERO),
		.oData(oData),
		.oDEC_EN(oValid)
	);
//-------------------------------------------//

endmodule
