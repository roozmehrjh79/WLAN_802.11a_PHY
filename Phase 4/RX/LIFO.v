//===============================================================================
// FPGA Project - Phase 4
// Module Name: LIFO (stack) memory
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module LIFO
	#(
		parameter DATA_WIDTH = 1,
		parameter ADDR_WIDTH = 5,
		parameter RAM_DEPTH = 32
	)
	(	// Ports Declaration
		input iClk,					// clock
		input iRst,					// reset (async.)
		input iData,				// input data
		input iPush,				// push command
		input iPop,					// pop command
		output wire oData,			// output data
		output wire oEmpty,			// stack empty flag
		output wire oFull			// stack full flag
	);

//---------- Wire & Variable Declaration ----------//
	reg [ADDR_WIDTH:0] stackPtr;	// stack pointer
	wire [ADDR_WIDTH:0] decPtr;		// decremented stack pointer
	wire [ADDR_WIDTH:0] incPtr;		// incremented stack pointer
	wire validWrite;				// valid write command
	wire validRead;					// valid read commmand
	wire [ADDR_WIDTH-1:0] Addr;		// RAM access address
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign oFull = stackPtr[ADDR_WIDTH];
	assign oEmpty = ~oFull & (&(stackPtr[ADDR_WIDTH-1:0]));
	assign validWrite = iPush & (~oFull);
	assign validRead = iPop & (~oEmpty);
	assign decPtr = stackPtr - 1'b1;
	assign incPtr = (!oFull) ? stackPtr + 1'b1 : {(ADDR_WIDTH+1){1'b0}};
	assign Addr = (iPop) ? incPtr[ADDR_WIDTH-1:0] : stackPtr[ADDR_WIDTH-1:0];
//--------------------------------------------//

//---------- Module Instantiations ----------//
	defparam RAM0.DATA_WIDTH = DATA_WIDTH;
	defparam RAM0.ADDR_WIDTH = ADDR_WIDTH;
	defparam RAM0.RAM_DEPTH = RAM_DEPTH;
	SPRAM RAM0(
		.iClk(iClk),
		.iRst(iRst),
		.iR_EN(validRead),
		.iW_EN(validWrite),
		.iAddr(Addr),
		.iData(iData),
		.oData(oData)
	);
//-------------------------------------------//

//---------- Sequential Logic ----------//
	// Stack pointer
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			stackPtr <= 6'b011111;
		else if (validWrite && !validRead)
			stackPtr <= decPtr;
		else if (validRead && !validWrite)
			stackPtr <= incPtr;
	end
//--------------------------------------//

endmodule
