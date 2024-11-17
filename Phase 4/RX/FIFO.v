//===============================================================================
// FPGA Project - Phase 4
// Module Name: Synchronous FIFO memory
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module FIFO
	#(	// Parameters
		parameter DATA_WIDTH = 1,
				   ADDR_WIDTH = 6,
				   RAM_DEPTH = 1 << ADDR_WIDTH
	)
	(	// Ports Declaration
		input iClk,										// clock
		input iRst,										// async. reset
		input iW_EN,									// write enable
		input iR_EN,									// read enable
		input [DATA_WIDTH-1:0] iData,					// input data
		output reg [DATA_WIDTH-1:0] oData,				// output data (async. read)
		output wire oEmpty,
		output wire oFull
	);

//---------- Wire & Variable Declaration ----------//
	integer k;
	reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];			// memory
	reg [ADDR_WIDTH-1:0] wrPtr;							// write pointer
	reg [ADDR_WIDTH-1:0] rdPtr;							// read pointer
	reg [ADDR_WIDTH:0] stPtr;							// status pointer (checks for full or empty)
	wire EQU;											// checks if wrPtr == rdPtr
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign EQU = (wrPtr == rdPtr) ? 1'b1 : 1'b0;
	assign oEmpty = EQU & ~(|stPtr);
	assign oFull = EQU & stPtr[ADDR_WIDTH]; 
//--------------------------------------------//

//---------- Combinational Logic ----------//
	always @(*) begin
		oData = {(DATA_WIDTH){1'b0}};
		if (iR_EN && !oEmpty)
			oData = mem[rdPtr];
	end
//----------------------------------------//

//---------- Sequential Logic ----------//
	// Write pointer
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			wrPtr <= {(ADDR_WIDTH){1'b0}};
		else if (iW_EN && !oFull)
			wrPtr <= wrPtr + 1'b1;
	end
	
	// Read pointer
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			rdPtr <= {(ADDR_WIDTH){1'b0}};
		else if (iR_EN && !oEmpty)
			rdPtr <= rdPtr + 1'b1;
	end
	
	// Status pointer
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			stPtr <= {(ADDR_WIDTH+1){1'b0}};
		else if (iW_EN && !iR_EN && !oFull)
			stPtr <= stPtr + 1'b1;
		else if (!iW_EN && iR_EN && !oEmpty)
			stPtr <= stPtr - 1'b1;
	end
	
	// Memory
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			for (k=0; k<RAM_DEPTH; k=k+1)
				mem[k] <= {(DATA_WIDTH){1'b0}};
		else if (iW_EN && !oFull)
			mem[wrPtr] <= iData;
	end
//--------------------------------------//

endmodule
