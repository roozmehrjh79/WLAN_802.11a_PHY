//===============================================================================
// FPGA Project - Phase 4
// Module Name: async.-read single-port RAM (ASPRAM)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module ASPRAM
	#(
		parameter DATA_WIDTH = 64,
		parameter ADDR_WIDTH = 5,
		parameter RAM_DEPTH = 32
	)
	(	// Ports Declaration
		input iClk,
		input iRst,
		input iR_EN,
		input iW_EN,
		input [ADDR_WIDTH-1:0] iAddr,
		input [DATA_WIDTH-1:0] iData,
		output reg [DATA_WIDTH-1:0] oData
	);
	
//---------- Wire & Variable Declaration ----------//
	integer k;
	reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];
//-------------------------------------------------//

//---------- Combinational Logic ----------//
	always @(*) begin
		oData = {(DATA_WIDTH){1'b0}};
		if (iR_EN)
			oData = mem[iAddr];
	end
//----------------------------------------//

//---------- Sequential Logic ----------//
	always @(posedge iClk, posedge iRst) begin
		if(iRst)
			for (k=0; k<RAM_DEPTH; k=k+1)
				mem[k] <= {(DATA_WIDTH){1'b0}};		
		else if (iW_EN)
			mem[iAddr] <= iData;
	end
//--------------------------------------//

endmodule
