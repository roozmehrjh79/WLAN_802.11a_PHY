//===============================================================================
// FPGA Project - Phase 2
// Module Name: path metric unit (PMU)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module PMU
	#(
		parameter PM_WIDTH = 13			// path metric register BW
	)
	(	// Ports Declaration
		input iClk,						// clock
		input iRst,						// reset (async.)
		input iEN,						// internal registers write-enable
		input [1:0] iBM00,				// BMU outputs
		input [1:0] iBM01,
		input [1:0] iBM10,
		input [1:0] iBM11,
		
		// These will go to the TBU!
		output wire [63:0] oSP,		// survivor path vector
		output wire oSP_Valid,			// survivor path output valid flag
		output reg [5:0] oMinPM,		// minimum PM
		output reg oMinFound,			// minimum PM found flag
		output reg [4:0] oCounter,		// main counter
		output wire oCNT_ZERO			// main counter ZERO flag
	);

//---------- Wire & Variable Declaration ----------//
	integer k;
	wire [1:0] BM [0:3];				// wires for routing 'iBMxx'
	
	// ACS units BM inputs
	wire [1:0] BM_0 [0:63];
	wire [1:0] BM_1 [0:63];
	
	wire [PM_WIDTH-1:0] PM [0:63];		// ACS units PM outputs
	
	// MUX selectors (for finding the smallest PM value)
	wire [5:0] MUX00_Addr;
	wire [5:0] MUX01_Addr;
	wire [5:0] MUX10_Addr;
	wire [5:0] MUX11_Addr;
	
	wire [PM_WIDTH-1:0] SUB0;			// 1st subtractor output
	wire [PM_WIDTH-1:0] SUB1;			// 2nd subtractor output
	wire SUB0_NEG;						// 1st sub. MSB
	wire SUB1_NEG;						// 2nd sub. MSB
	reg [5:0] minPM0;					// stores address of the minumum of first 32 PMs
	reg [5:0] minPM1;					// stores address of the min. of second 32 PMs
	
	reg [PM_WIDTH-1:0] memPM [0:63];	// registers used to store all PM outputs for comparison
	reg latFlg;							// latency counter (treated as a flag); 
										//  must be modified if the design is pipelined
										
	reg prepFlg;						// preparation flag (is HIGH for 33 clock cycles)
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	/* BEGIN Trellis LUT */
		assign {BM_0[0], BM_1[0]} = {BM[0], BM[3]};
		assign {BM_0[1], BM_1[1]} = {BM[3], BM[0]};
		assign {BM_0[2], BM_1[2]} = {BM[2], BM[1]};
		assign {BM_0[3], BM_1[3]} = {BM[1], BM[2]};
		assign {BM_0[4], BM_1[4]} = {BM[3], BM[0]};
		assign {BM_0[5], BM_1[5]} = {BM[0], BM[3]};
		assign {BM_0[6], BM_1[6]} = {BM[1], BM[2]};
		assign {BM_0[7], BM_1[7]} = {BM[2], BM[1]};
		assign {BM_0[8], BM_1[8]} = {BM[3], BM[0]};
		assign {BM_0[9], BM_1[9]} = {BM[0], BM[3]};
		assign {BM_0[10], BM_1[10]} = {BM[1], BM[2]};
		assign {BM_0[11], BM_1[11]} = {BM[2], BM[1]};
		assign {BM_0[12], BM_1[12]} = {BM[0], BM[3]};
		assign {BM_0[13], BM_1[13]} = {BM[3], BM[0]};
		assign {BM_0[14], BM_1[14]} = {BM[2], BM[1]};
		assign {BM_0[15], BM_1[15]} = {BM[1], BM[2]};
		assign {BM_0[16], BM_1[16]} = {BM[0], BM[3]};
		assign {BM_0[17], BM_1[17]} = {BM[3], BM[0]};
		assign {BM_0[18], BM_1[18]} = {BM[2], BM[1]};
		assign {BM_0[19], BM_1[19]} = {BM[1], BM[2]};
		assign {BM_0[20], BM_1[20]} = {BM[3], BM[0]};
		assign {BM_0[21], BM_1[21]} = {BM[0], BM[3]};
		assign {BM_0[22], BM_1[22]} = {BM[1], BM[2]};
		assign {BM_0[23], BM_1[23]} = {BM[2], BM[1]};
		assign {BM_0[24], BM_1[24]} = {BM[3], BM[0]};
		assign {BM_0[25], BM_1[25]} = {BM[0], BM[3]};
		assign {BM_0[26], BM_1[26]} = {BM[1], BM[2]};
		assign {BM_0[27], BM_1[27]} = {BM[2], BM[1]};
		assign {BM_0[28], BM_1[28]} = {BM[0], BM[3]};
		assign {BM_0[29], BM_1[29]} = {BM[3], BM[0]};
		assign {BM_0[30], BM_1[30]} = {BM[2], BM[1]};
		assign {BM_0[31], BM_1[31]} = {BM[1], BM[2]};
		assign {BM_0[32], BM_1[32]} = {BM[1], BM[2]};
		assign {BM_0[33], BM_1[33]} = {BM[2], BM[1]};
		assign {BM_0[34], BM_1[34]} = {BM[3], BM[0]};
		assign {BM_0[35], BM_1[35]} = {BM[0], BM[3]};
		assign {BM_0[36], BM_1[36]} = {BM[2], BM[1]};
		assign {BM_0[37], BM_1[37]} = {BM[1], BM[2]};
		assign {BM_0[38], BM_1[38]} = {BM[0], BM[3]};
		assign {BM_0[39], BM_1[39]} = {BM[3], BM[0]};
		assign {BM_0[40], BM_1[40]} = {BM[2], BM[1]};
		assign {BM_0[41], BM_1[41]} = {BM[1], BM[2]};
		assign {BM_0[42], BM_1[42]} = {BM[0], BM[3]};
		assign {BM_0[43], BM_1[43]} = {BM[3], BM[0]};
		assign {BM_0[44], BM_1[44]} = {BM[1], BM[2]};
		assign {BM_0[45], BM_1[45]} = {BM[2], BM[1]};
		assign {BM_0[46], BM_1[46]} = {BM[3], BM[0]};
		assign {BM_0[47], BM_1[47]} = {BM[0], BM[3]};
		assign {BM_0[48], BM_1[48]} = {BM[1], BM[2]};
		assign {BM_0[49], BM_1[49]} = {BM[2], BM[1]};
		assign {BM_0[50], BM_1[50]} = {BM[3], BM[0]};
		assign {BM_0[51], BM_1[51]} = {BM[0], BM[3]};
		assign {BM_0[52], BM_1[52]} = {BM[2], BM[1]};
		assign {BM_0[53], BM_1[53]} = {BM[1], BM[2]};
		assign {BM_0[54], BM_1[54]} = {BM[0], BM[3]};
		assign {BM_0[55], BM_1[55]} = {BM[3], BM[0]};
		assign {BM_0[56], BM_1[56]} = {BM[2], BM[1]};
		assign {BM_0[57], BM_1[57]} = {BM[1], BM[2]};
		assign {BM_0[58], BM_1[58]} = {BM[0], BM[3]};
		assign {BM_0[59], BM_1[59]} = {BM[3], BM[0]};
		assign {BM_0[60], BM_1[60]} = {BM[1], BM[2]};
		assign {BM_0[61], BM_1[61]} = {BM[2], BM[1]};
		assign {BM_0[62], BM_1[62]} = {BM[3], BM[0]};
		assign {BM_0[63], BM_1[63]} = {BM[0], BM[3]};
	/* END Trellis LUT */
	
	/* BEGIN PM comparator circuit */
		assign MUX00_Addr = minPM0;
		assign MUX01_Addr = (!oCNT_ZERO) ? oCounter : minPM1;
		assign MUX10_Addr = minPM1;
		assign MUX11_Addr = (!oCNT_ZERO) ? {1'b0, oCounter} + 6'd32 : minPM0;
		assign SUB0 = memPM[MUX00_Addr] - memPM[MUX01_Addr];
		assign SUB1 = memPM[MUX10_Addr] - memPM[MUX11_Addr];
		assign SUB0_NEG = SUB0[PM_WIDTH-1];
		assign SUB1_NEG = SUB1[PM_WIDTH-1];
	/* END PM comparator circuit */
	
	assign BM[0] = iBM00;
	assign BM[1] = iBM01;
	assign BM[2] = iBM10;
	assign BM[3] = iBM11;
	
	assign oCNT_ZERO = ~(|oCounter);
	assign oSP_Valid = (iEN & !latFlg) ? 1'b1 : 1'b0;
//--------------------------------------------//

//---------- Generate Block ----------//
	genvar i;
	generate
		for (i=0; i<64; i=i+1) begin : GenACSU
			if (i%2 == 0) begin
				defparam ACSU0.PM_WIDTH = PM_WIDTH;
				ACSU ACSU0(
					.iClk(iClk),
					.iRst(iRst),
					.iEN(iEN),
					.iPM0(PM[i/2]),
					.iPM1(PM[32+i/2]),
					.iBM0(BM_0[i]),
					.iBM1(BM_1[i]),
					.oSP(oSP[i]),
					.oPM(PM[i])
				);
			end
			else begin
				defparam ACSU0.PM_WIDTH = PM_WIDTH;
				ACSU ACSU0(
					.iClk(iClk),
					.iRst(iRst),
					.iEN(iEN),
					.iPM0(PM[(i-1)/2]),
					.iPM1(PM[32+(i-1)/2]),
					.iBM0(BM_0[i]),
					.iBM1(BM_1[i]),
					.oSP(oSP[i]),
					.oPM(PM[i])
				);
			end
		end
	endgenerate
//------------------------------------//

//---------- Sequential Logic ----------//	
	// Latency flag
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			latFlg <= 1'b1;
		else if (iEN)
			latFlg <= 1'b0;
	end
	
	// Main counter
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			oCounter <= 5'd31;
		else if (iEN && !latFlg)
			oCounter <= oCounter - 1'b1;
	end
	
	// 'memPM'
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
	 		for (k=0; k<64; k=k+1)
	 			memPM[k] <= {(PM_WIDTH){1'b0}};
	 	else if(iEN && oCNT_ZERO)
	 		for (k=0; k<64; k=k+1)
	 			memPM[k] <= PM[k];	
	end
	
	// 'minPMx'
	always @(posedge iClk, posedge iRst) begin
		if (iRst) begin
			minPM0 <= 6'b000000;
			minPM1 <= 6'd32;
		end
		else if (iEN && oCNT_ZERO) begin
			minPM0 <= 6'b000000;
			minPM1 <= 6'd32;
		end
		else if (iEN) begin
			minPM0 <= (SUB0_NEG) ? MUX00_Addr : MUX01_Addr;
			minPM1 <= (SUB1_NEG) ? MUX10_Addr : MUX11_Addr;
		end
	end	
	
	// Preparation flag
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			prepFlg <= 1'b1;
		else if (iEN && oCNT_ZERO)
			prepFlg <= 1'b0;
	end
	
	// Minimum PM
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			oMinPM <= 6'b000000;
		else if (iEN && oCNT_ZERO && !prepFlg)
			oMinPM <= (SUB0_NEG) ? minPM0 : minPM1;
	end
	
	// Minimum PM found flag
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			oMinFound <= 1'b0;
		else if (iEN && oCNT_ZERO && !prepFlg)
			oMinFound <= 1'b1;
		else
			oMinFound <= 1'b0;
	end
//--------------------------------------//

endmodule
