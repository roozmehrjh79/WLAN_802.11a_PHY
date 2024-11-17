//===============================================================================
// FPGA Project - Phase 4
// Module Name: traceback unit (TBU)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module TBU
	#(
		parameter DATA_WIDTH = 64,
		parameter ADDR_WIDTH = 5,
		parameter RAM_DEPTH = 32
	)
	(	// Ports Declaration
		input iClk,						// clock
		input iRst,						// reset (async.)
		input iEN,						// enable signal
		
			// These come from the PMU
			input [63:0] iSP,
			input iSP_Valid,
			input [5:0] iMinPM,
			input iMinPM_Found,
			input [4:0] iCounter,
			input iCNT_ZERO,
			
		output wire oData,				// serial output (decoded data)
		output reg oDEC_EN				// output valid enable (decode-enable)
	);

//---------- Wire & Variable Declaration ----------//
	integer k;
	
	// Traceback & RAM update pointers
	reg [1:0] tracePtr;					// chooses which RAM to traceback
	reg [1:0] updatePtr;				// chooses which RAM to update
	reg [1:0] nextTPtr;					// next value of 'tracePtr'
	reg [1:0] nextUPtr;					// next value of 'updatePtr'
	
	// Traceback start flags & address
	wire TB_ON;							// determines if traceback has started or not
	reg traceFlag;						// stores TB_ON
	wire [4:0] traceAddr;				// pointer for reading data from RAMs;
										//  will read BACKWARDS
	
	// RAM ports
	wire UP_ON;							// determines if updating RAMs has started or not					
	wire RAM_SWITCH;
	wire RAM0_ReEN;
	wire RAM0_WrEN;
	wire [ADDR_WIDTH-1:0] RAM0_Addr;
	wire [DATA_WIDTH-1:0] RAM0_Out;
	wire RAM1_ReEN;
	wire RAM1_WrEN;
	wire [ADDR_WIDTH-1:0] RAM1_Addr;
	wire [DATA_WIDTH-1:0] RAM1_Out;
	wire RAM2_ReEN;
	wire RAM2_WrEN;
	wire [ADDR_WIDTH-1:0] RAM2_Addr;
	wire [DATA_WIDTH-1:0] RAM2_Out;
	
	// RAM current data selector
	reg [63:0] cData;
	
	// Trace-back procedure
	wire [5:0] TB_BIT;		// bit address for reading currect survivor path from 'cData'
	reg [5:0] nBit;			// gets next TB bit address
	reg [5:0] cBit;			// stores next survivor path bit address to be accessed
	wire DEC_BIT;			// decoded bit
	
	// LIFO management
	wire L0_PUSH;
	wire L0_POP;
	wire L0_EMPTY;
	wire L0_FULL;
	wire L0_OUT;
	wire L1_PUSH;
	wire L1_POP;
	wire L1_EMPTY;
	wire L1_FULL;
	wire L1_OUT;
	wire LIFO_SEL;		// LIFO selector; Switches if a LIFO gets full
	wire LIFO_SWITCH;	// LIFO switch flag (is set to HIGH if one LIFO gets full)
	reg cLIFO;			// current LIFO (for writing)	
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign TB_ON = (iEN & (iMinPM_Found | traceFlag)) ? 1'b1 : 1'b0;
	assign UP_ON = iEN & iSP_Valid;
	assign RAM_SWITCH = iCNT_ZERO;
	assign traceAddr = 5'd31 - iCounter;
	
	assign RAM0_ReEN = (~(|tracePtr) & TB_ON) ? 1'b1 : 1'b0;
	assign RAM0_WrEN = (~(|updatePtr) & UP_ON) ? 1'b1 : 1'b0;
	assign RAM0_Addr = (RAM0_WrEN) ? iCounter : traceAddr;
	assign RAM1_ReEN = (tracePtr[0] & TB_ON) ? 1'b1 : 1'b0;
	assign RAM1_WrEN = (updatePtr[0] & UP_ON) ? 1'b1 : 1'b0;
	assign RAM1_Addr = (RAM1_WrEN) ? iCounter : traceAddr;
	assign RAM2_ReEN = (tracePtr[1] & TB_ON) ? 1'b1 : 1'b0;
	assign RAM2_WrEN = (updatePtr[1] & UP_ON) ? 1'b1 : 1'b0;
	assign RAM2_Addr = (RAM2_WrEN) ? iCounter : traceAddr;
	
	assign TB_BIT = (iMinPM_Found) ? iMinPM : cBit;
	assign DEC_BIT = TB_BIT[0];
	
	assign LIFO_SWITCH = (~cLIFO & L0_FULL) | (cLIFO & L1_FULL);
	assign LIFO_SEL = (LIFO_SWITCH) ? ~cLIFO : cLIFO;
	assign L0_PUSH = TB_ON & ~LIFO_SEL;
	assign L1_PUSH = TB_ON & LIFO_SEL;
	assign L0_POP = TB_ON & ~L0_PUSH & ~L0_EMPTY;
	assign L1_POP = TB_ON & ~L1_PUSH & ~L1_EMPTY;
	
	assign oData = (cLIFO) ? L0_OUT : L1_OUT;
//--------------------------------------------//

//---------- Module Instantiations ----------//
	// Async. RAMs
	ASPRAM RAM0(
		.iClk(iClk),
		.iRst(iRst),
		.iR_EN(RAM0_ReEN),
		.iW_EN(RAM0_WrEN),
		.iAddr(RAM0_Addr),
		.iData(iSP),
		.oData(RAM0_Out)
	);
	
	ASPRAM RAM1(
		.iClk(iClk),
		.iRst(iRst),
		.iR_EN(RAM1_ReEN),
		.iW_EN(RAM1_WrEN),
		.iAddr(RAM1_Addr),
		.iData(iSP),
		.oData(RAM1_Out)
	);
	
	ASPRAM RAM2(
		.iClk(iClk),
		.iRst(iRst),
		.iR_EN(RAM2_ReEN),
		.iW_EN(RAM2_WrEN),
		.iAddr(RAM2_Addr),
		.iData(iSP),
		.oData(RAM2_Out)
	);
	
	// Sync. LIFOs
	LIFO L0(
		.iClk(iClk),
		.iRst(iRst),
		.iData(DEC_BIT),
		.iPush(L0_PUSH),
		.iPop(L0_POP),
		.oData(L0_OUT),
		.oEmpty(L0_EMPTY),
		.oFull(L0_FULL)
	);
	
	LIFO L1(
		.iClk(iClk),
		.iRst(iRst),
		.iData(DEC_BIT),
		.iPush(L1_PUSH),
		.iPop(L1_POP),
		.oData(L1_OUT),
		.oEmpty(L1_EMPTY),
		.oFull(L1_FULL)
	);
//-------------------------------------------//

//---------- Combinational Logic ----------//
	// Traceback & Update pointers
	always @(tracePtr, updatePtr, RAM_SWITCH) begin
		nextTPtr = 2'b00;
		nextUPtr = 2'b00;
		
		case(tracePtr)
			2'b00 : nextTPtr = (RAM_SWITCH) ? 2'b01 : 2'b00;
			2'b01 : nextTPtr = (RAM_SWITCH) ? 2'b10 : 2'b01;
			2'b10 : nextTPtr = (RAM_SWITCH) ? 2'b00 : 2'b10;
		endcase
		
		case(updatePtr)
			2'b00: nextUPtr = (RAM_SWITCH) ? 2'b01 : 2'b00;
			2'b01: nextUPtr = (RAM_SWITCH) ? 2'b10 : 2'b01;
			2'b10: nextUPtr = (RAM_SWITCH) ? 2'b00 : 2'b10;
		endcase
	end
	
	// RAM current data selector
	always @(tracePtr, RAM0_Out, RAM1_Out, RAM2_Out) begin
		cData = {(DATA_WIDTH){1'b0}};
		case(tracePtr)
			2'b00: cData = RAM0_Out;
			2'b01: cData = RAM1_Out;
			2'b10: cData = RAM2_Out;
		endcase
	end
	
	// Next TB bit address
	always @(TB_BIT, cData) begin
		nBit = 6'b000000;
		/*for (k=0; k<64; k=k+2)
			if (TB_BIT == k)
				nBit = (~cData[TB_BIT]) ? k/2 : 6'd32 + k/2;
		for (k=1; k<64; k=k+2)
			if (TB_BIT == k)
				nBit = (~cData[TB_BIT]) ? (k-1)/2 : 6'd32 + (k-1)/2;
		*/
		nBit = (~cData[TB_BIT]) ? TB_BIT>>1 : (TB_BIT>>1) + 6'd32;
	end

//----------------------------------------//

//---------- Sequential Logic ----------//	
	// Traceback flag
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			traceFlag <= 1'b0;
		else if (iEN && TB_ON)
			traceFlag <= 1'b1;
	end
	
	// Traceback pointer
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			tracePtr <= 2'b01;
		else
			tracePtr <= nextTPtr;
	end
	
	// Updatable RAM selector
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			updatePtr <= 2'b00;
		else
			updatePtr <= nextUPtr;
	end
	
	// Current TB bit address
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			cBit <= 6'b000000;
		else if (TB_ON)
			cBit <= nBit;
	end
	
	// Current LIFO
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			cLIFO <= 1'b0;
		else
			cLIFO <= (LIFO_SWITCH) ? ~cLIFO : cLIFO;
	end
	
	// Decoding indicator
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			oDEC_EN <= 1'b0;
		else if (!iEN)
			oDEC_EN <= 1'b0;
		else if (L0_POP | L1_POP)
			oDEC_EN <= 1'b1;
	end
//--------------------------------------//

endmodule
