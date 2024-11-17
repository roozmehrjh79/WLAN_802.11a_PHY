//===============================================================================
// FPGA Project - Phase 4
// Module Name: sync.-read single-port RAM (SPRAM)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module SPRAM
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

//---------- Sequential Logic ----------//
	always @(posedge iClk, posedge iRst) begin
		if(iRst) begin
			for (k=0; k<RAM_DEPTH; k=k+1)
				mem[k] <= {(DATA_WIDTH){1'b0}};
			oData <= {(DATA_WIDTH){1'b0}};
		end
				
		else if (!iR_EN && iW_EN)
			mem[iAddr] <= iData;
		else if (iR_EN && !iW_EN)
			oData <= mem[iAddr];
	end
//--------------------------------------//

endmodule
