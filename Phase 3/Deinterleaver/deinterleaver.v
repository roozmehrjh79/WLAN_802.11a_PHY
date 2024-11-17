//===============================================================================
// FPGA Project - Phase 3
// Module Name: data deinterleaver (RX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module deinterleaver
	(	// Ports Declaration
		input iClk,				// clock (fast)
		input iRst,				// reset (async.)
		input iEN,				// enable signal
		input iRateEN,			// RATE enable signal (allows changes to RATE)
		input [3:0] iRate,		// input data rate
		input iData,			// serial input data
		output wire oData,		// serial output data
		output wire oValid		// output validity indicator
	);

//---------- Local Parameters ----------//
	localparam R_6MBPS = 4'b1101,			// different values of RATE
				R_9MBPS = 4'b1111,
				R_12MBPS = 4'b0101,
				R_18MBPS = 4'b0111,
				R_24MBPS = 4'b1001,
				R_36MBPS = 4'b1011,
				R_48MBPS = 4'b0001,
				R_54MBPS = 4'b0011;
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	integer k;
	reg [3:0] RATE;			// holds the RATE value
	reg [3:0] rowCnt;		// row counter
	reg [3:0] colCnt;		// column counter
	wire ROW_EXP;			// row counter EXPIRATION flag (reaches max value)
	wire COL_EXP;			// column counter EXPIRATION flag (reaches max value)
	
	reg [3:0] Ni;			// Ni = Ncbps/16
	reg [3:0] offset;		// chooses between 'rC', 'rC+1' or 'rC-1', where 'rC' is the row counter
	wire [7:0] shOffset;	// shifted version of 'offset'
	wire [7:0] kPtr;		// interleaving bit address
	
	reg [191:0] bReg;		// back register
	reg [191:0] fReg;		// front register
	reg selReg;				// back & front register selector
	reg OUT_EN;				// output enable (used for 'oValid')
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign kPtr = colCnt + shOffset;
	assign ROW_EXP = (rowCnt == Ni - 1'b1) ? 1'b1 : 1'b0;
	assign COL_EXP = (&colCnt) ? 1'b1 : 1'b0;
	assign shOffset = {offset,4'h0};
	
	assign oData = (!selReg) ? fReg[0] : bReg[0];
	assign oValid = iEN & OUT_EN;
//--------------------------------------------//

//---------- Combinational Logic ----------//
	// Offset
	always @(*) begin
		offset = rowCnt;			// default value (applies for R = 6 or 12 Mbit/s)
		case (RATE)
			R_6MBPS: offset = rowCnt;
			R_12MBPS: offset = rowCnt;
			R_24MBPS: begin
				if (colCnt[0])
					offset = (!rowCnt[0]) ? rowCnt+1'b1 : rowCnt-1'b1;
			end
		endcase			
	end
	
	// 'Ni'
	always @(*) begin
		Ni = 4'd3;					// default value
		case (RATE)
			R_6MBPS: Ni = 4'd3;
			R_12MBPS: Ni = 4'd6;
			R_24MBPS: Ni = 4'd12;
		endcase
	end
//----------------------------------------//

//---------- Sequential Logic ----------//
	// RATE
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			RATE <= R_6MBPS;
		else if (iRateEN)
			RATE <= iRate;
	end
	
	// Row counter
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			rowCnt <= 4'h0;
		else if (iEN)
			rowCnt <= (!ROW_EXP) ? rowCnt + 1'b1 : 4'h0;
	end
	
	// Column counter
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			colCnt <= 4'h0;
		else if (iEN && ROW_EXP)
			colCnt <= (!COL_EXP) ? colCnt + 1'b1 : 4'h0;
	end
	
	// Register selector
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			selReg <= 1'b0;
		else if (iEN && ROW_EXP && COL_EXP)
			selReg <= ~selReg;
	end
	
	// Back & Front registers
	always @(posedge iClk, posedge iRst) begin
		if (iRst) begin
			bReg <= {192{1'b0}};
			fReg <= {192{1'b0}};
		end
		else if (iEN) begin
			if (!selReg) begin
				bReg[kPtr] <= iData;
				for (k=0; k<191; k=k+1)
					fReg[k] <= fReg[k+1];
				fReg[191] <= 1'b0;
			end
			else begin
				fReg[kPtr] <= iData;
				for (k=0; k<191; k=k+1)
					bReg[k] <= bReg[k+1];
				bReg[191] <= 1'b0;				
			end
		end
	end
	
	// Output enable
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			OUT_EN <= 1'b0;
		else if (iRateEN)
			OUT_EN <= 1'b0;
		else if (iEN && ROW_EXP && COL_EXP)
			OUT_EN <= 1'b1;
	end
//--------------------------------------//

endmodule
