//===============================================================================
// FPGA Project - Phase 4
// Module Name: Transmitter controller (TX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module TX_Controller
	#(	// Parameters
		parameter SEED = 7'b1011101,	// scrambler initial seed
					HEADER = 12'hFFF	// PLCP preamble
	)
	(	// Ports Declaration
		input iClk,						// clock
		input iRst,						// async. reset
		input iStart,					// input start signal
		input [3:0] iRate,				// input rate
		input [11:0] iLength,			// LENGTH field
		input iData,					// input stream (serial)
		output wire oData,				// output stream (serial)
		output reg oTX_EN,				// transmition status indicator
		output wire oBusy				// busy status indicator (is HIGH when controller isn't in IDLE mode)
	);

//---------- Local Parameters ----------//
	localparam IDLE1 = 4'd0,			// idle states
				IDLE2 = 4'd1,
				GEN_PREAMBLE = 4'd2,	// feed the PREAMBLE field into the output FIFO
				GEN_SIGNAL1 = 4'd3,		// feed the SIGNAL field into the encoder -> interleaver -> output FIFO
				GEN_SIGNAL2 = 4'd4,		// feed 6 "0" bits into the encoder
				GET_SIGNAL = 4'd5,		// get SIGNAL field from interleaver
				GEN_SERVICE = 4'd6,		// feed 16 "0" bits into all other modules
				GEN_DATA = 4'd7,		// feed the raw data from input FIFO into all other modules
				GEN_TAIL = 4'd8,		// feed 0 bits (no. = TAIL + PAD) into the output FIFO
				WAIT_INT = 4'd9,		// wait for interleaver to finish sending
				WAIT_OUT = 4'd10,		// wait for output FIFO to become empty
				FLUSH_ALL = 4'd11;		// flush everything
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	// Slow clocks
	reg slwClk1;
	reg slwClk2;

	// Controller FSM
	reg [3:0] cState, nState;
	
	// Counters & Pointers
	reg [15:0] mainCnt;				// main counter
	wire CNT_ZERO;					// main counter ZERO flag
	reg [3:0] hdrPtr;				// pointer for reading PREAMBLE
	reg [4:0] sigPtr;				// pointer for reading SIGNAL
	
	// Storage
	wire [11:0] PREAMBLE;
	reg [17:0] SIGNAL;
	wire [3:0] RATE;
	wire [11:0] LENGTH;
	wire PARITY;
	wire [14:0] N_RAW;				// no. of RAW data bits
	
	// PAD bits management
	reg [15:0] TMP_PAD;				// temporary no. of PAD bits
	wire [15:0] N_PAD;				// no. of PAD bits
	wire [15:0] nextPAD;			// next number of N_PAD to be updated
	reg [7:0] N_DBPS;				// no. of DATA bits per OFDM symbol
	
	// Module interconnections
	reg GLB_FLUSH;					// global flush signal
	wire GLB_RST;					// global reset signal
	reg F0_WrEN, F0_ReEN;
	wire F0_OUT, F0_EMPTY, F0_FULL;
	reg F1_WrEN, F1_ReEN, F1_IN;
	wire F1_OUT, F1_EMPTY, F1_FULL;
	wire [6:0] SCMB0_SEED;
	reg SCMB0_SEN, SCMB0_IN;
	wire SCMB0_OUT;
	reg ENC0_EN, ENC0_IN;
	wire ENC0_OUT, ENC0_V;
	reg INT0_REN;
	wire INT0_OUT, INT0_V;
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign SCMB0_SEED = SEED;
	assign CNT_ZERO = ~(|mainCnt);
	assign oBusy = (cState != IDLE1 && cState != IDLE2) ? 1'b1 : 1'b0;
	assign oData = F1_OUT;
	
	// Global Reset
	assign GLB_RST = GLB_FLUSH | iRst;
	
	assign PREAMBLE = HEADER;
	assign RATE = SIGNAL[17:14];
	assign LENGTH = SIGNAL[12:1];
	assign PARITY = SIGNAL[0];
	assign N_RAW = {LENGTH,3'b0};					// = 8 * LENGTH
	assign nextPAD = TMP_PAD - N_DBPS;
	assign N_PAD = ~nextPAD + 1'b1;
//--------------------------------------------//

//---------- Module Instantiations ----------//
	// Input FIFO
	defparam F0.ADDR_WIDTH = 8;
	FIFO F0(
		.iClk(slwClk1),
		.iRst(GLB_RST),
		.iW_EN(F0_WrEN),
		.iR_EN(F0_ReEN),
		.iData(iData),
		.oData(F0_OUT),
		.oEmpty(F0_EMPTY),
		.oFull(F0_FULL)
	);
	
	// Output FIFO
	FIFO F1(
		.iClk(iClk),
		.iRst(GLB_RST),
		.iW_EN(F1_WrEN),
		.iR_EN(F1_ReEN),
		.iData(F1_IN),
		.oData(F1_OUT),
		.oEmpty(F1_EMPTY),
		.oFull(F1_FULL)
	);
	
	// Scrambler
	scrambler SCMB0(
		.iClk(slwClk1),
		.iRst(GLB_RST),
		.iSEN(SCMB0_SEN),
		.iState(SCMB0_SEED),
		.iData(SCMB0_IN),
		.oData(SCMB0_OUT)
	);
	
	// Conv. encoder
	convEncoder ENC0(
		.iFClk(iClk),
		.iSClk(~slwClk2),
		.iRst(GLB_RST),
		.iEN(ENC0_EN),
		.iData(ENC0_IN),
		.oData(ENC0_OUT),
		.oValid(ENC0_V)
	);
	
	// Data interleaver
	interleaver INT0(
		.iClk(iClk),
		.iRst(GLB_RST),
		.iRateEN(INT0_REN),
		.iRate(RATE),
		.iEN(ENC0_V),
		.iData(ENC0_OUT),
		.oData(INT0_OUT),
		.oValid(INT0_V)
	);
	
//-------------------------------------------//

//---------- Combinational Logic ----------//
	// RATE to N_DBPS decoder (some are unused)
	always @(RATE) begin						
		case(RATE)
			4'b1101: N_DBPS = 8'd24;
			//4'b1111: N_DBPS = 8'd36;
			4'b0101: N_DBPS = 8'd48;
			//4'b0111: N_DBPS = 8'd72;
			4'b1001: N_DBPS = 8'd96;
			//4'b1011: N_DBPS = 8'd144;
			//4'b0001: N_DBPS = 8'd192;
			//4'b0011: N_DBPS = 8'd216;
			default: N_DBPS = 8'd24;
		endcase
	end
	
	// Control signals
	always @(*) begin
		nState = IDLE1;
		GLB_FLUSH = 1'b0;
		F0_WrEN = 1'b1;			// FIFO0 write enable
		F0_ReEN = 1'b0;			// FIFO0 read enable
		F1_WrEN = 1'b0;			// FIFO1 write enable
		F1_ReEN = 1'b0;			// FIFO1 read enable
		F1_IN = INT0_OUT;		// FIFO1 input
		SCMB0_SEN = 1'b0;		// scrambler seed-enable (allows updating its shift-register directly)
		SCMB0_IN = F0_OUT;		// scrambler input
		ENC0_EN = 1'b1;			// encoder enable
		ENC0_IN = SCMB0_OUT;	// encoder input
		INT0_REN = 1'b0;		// interleaver rate-enable (enables updating its RATE)
		oTX_EN = 1'b0;			// transmission indicator
		
		case(cState)
			IDLE1: begin
				F0_WrEN = 1'b0;
				ENC0_EN = 1'b0;
				nState = (iStart) ? IDLE2 : IDLE1;
			end
			
			IDLE2: begin
				F0_WrEN = 1'b0;
				ENC0_EN = 1'b0;
				nState = (iStart) ? GEN_PREAMBLE : IDLE1;
			end
			
			GEN_PREAMBLE: begin
				ENC0_EN = 1'b0;
				F1_WrEN = 1'b1;
				F1_IN = PREAMBLE[hdrPtr];
				nState = (CNT_ZERO) ? GEN_SIGNAL1 : GEN_PREAMBLE;
			end
			
			GEN_SIGNAL1: begin
				ENC0_EN = 1'b1;
				ENC0_IN = SIGNAL[sigPtr];
				nState = (CNT_ZERO) ? GEN_SIGNAL2: GEN_SIGNAL1;
			end
			
			GEN_SIGNAL2: begin
				ENC0_IN = 1'b0;
				nState = (CNT_ZERO) ? GET_SIGNAL : GEN_SIGNAL2;
			end
			
			GET_SIGNAL: begin
				F0_ReEN = (CNT_ZERO) ? 1'b1 : 1'b0;
				F1_WrEN = INT0_V;
				ENC0_IN = (CNT_ZERO) ? SCMB0_OUT : 1'b0;
				INT0_REN = (CNT_ZERO) ? 1'b1 : 1'b0;
				SCMB0_IN = 1'b0;
				SCMB0_SEN = (CNT_ZERO) ? 1'b1 : 1'b0;
				nState = (CNT_ZERO) ? GEN_SERVICE : GET_SIGNAL;
			end
			
			GEN_SERVICE: begin
				SCMB0_IN = 1'b0;
				F1_WrEN = INT0_V;
				F1_ReEN = INT0_V;
				oTX_EN = INT0_V;
				nState = (CNT_ZERO) ? GEN_DATA : GEN_SERVICE;
			end
			
			GEN_DATA: begin
				F0_ReEN = 1'b1;
				F1_WrEN = INT0_V;
				F1_ReEN = INT0_V;
				oTX_EN = INT0_V;
				nState = (CNT_ZERO) ? GEN_TAIL : GEN_DATA;
			end
			
			GEN_TAIL: begin
				F0_WrEN = 1'b0;
				ENC0_IN = 1'b0;
				F1_WrEN = INT0_V;
				F1_ReEN = 1'b1;
				oTX_EN = 1'b1;
				nState = (CNT_ZERO) ? WAIT_INT : GEN_TAIL;
			end
			
			WAIT_INT: begin
				F0_WrEN = 1'b0;
				ENC0_IN = 1'b0;
				F1_WrEN = INT0_V;
				F1_ReEN = 1'b1;
				oTX_EN = 1'b1;
				nState = (CNT_ZERO) ? WAIT_OUT : WAIT_INT;
			end
			
			WAIT_OUT: begin
				F0_WrEN = 1'b0;
				ENC0_IN = 1'b0;
				ENC0_EN = 1'b0;
				F1_ReEN = 1'b1;
				oTX_EN = (!F1_EMPTY) ? 1'b1 : 1'b0;
				nState = (F1_EMPTY) ? FLUSH_ALL : WAIT_OUT;
			end
			
			FLUSH_ALL: begin
				F0_WrEN = 1'b0;
				ENC0_EN = 1'b0;
				GLB_FLUSH = 1'b1;
				nState = IDLE1;
			end
			
		endcase
	end
	
	// Header & Signal pointer
	always @(*) begin
		hdrPtr = 4'h0;
		sigPtr = 5'h00;
		if (mainCnt[3:0] < 4'd12)
			hdrPtr = mainCnt[3:0];
		if (mainCnt[5:1] < 5'd18)
			sigPtr = mainCnt[5:1];
	end
//----------------------------------------//

//---------- Sequential Logic ----------//
	// Slow clock 1
	always @(negedge iClk, posedge iRst) begin
		if (iRst)
			slwClk1 <= 1'b0;
		else
			slwClk1 <= ~slwClk1;
	end
	
	// Slow clock 2
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			slwClk2 <= 1'b0;
		else
			slwClk2 <= ~slwClk2;
	end	
	
	// Controller FSM
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			cState <= IDLE1;
		else
			cState <= nState;
	end
	
	// Main counter
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			mainCnt <= {16{1'b0}};
		else if (CNT_ZERO && cState == IDLE2 && iStart)
			mainCnt <= 16'd11;	// = 12 - 1
		else if (CNT_ZERO && cState == GEN_PREAMBLE)
			mainCnt <= 16'd35;	// = 18 * 2 - 1
		else if (CNT_ZERO && cState == GEN_SIGNAL1)
			mainCnt <= 16'd11;	// = 6 * 2 - 1
		else if (CNT_ZERO && cState == GEN_SIGNAL2)
			mainCnt <= 16'd48;	// = 48 - 1
		else if (CNT_ZERO && cState == GET_SIGNAL)
			mainCnt <= 16'd31;	// = 16 * 2 - 1
		else if (CNT_ZERO && cState == GEN_SERVICE)
			mainCnt <= {N_RAW,1'b0} - 1'b1;				// = 2 * {no. of RAW data bits} - 1
		else if (CNT_ZERO && cState == GEN_DATA)
			mainCnt <= {N_PAD[14:0]+3'd6,1'b0} - 1'b1;	// = 2 * {no. of TAIL & PAD bits} - 1
		else if (CNT_ZERO && cState == GEN_TAIL)
			mainCnt <= {N_DBPS,1'b0} - 1'b1;
		else if (CNT_ZERO && cState == WAIT_INT)
			mainCnt <= {16{1'b0}};
		else if (!CNT_ZERO)								// general case
			mainCnt <= mainCnt - 1'b1;
	end
	
	// SIGNAL register (SIGNAL[0] is the PARITY bit)
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			SIGNAL <= {18{1'b0}};
		else if (cState == IDLE2 && iStart)
			SIGNAL <= {iRate,1'b0,iLength,1'b0};
		else if (cState == GEN_SIGNAL1)
			SIGNAL[0] <= SIGNAL[0] ^ SIGNAL[sigPtr];
	end
	
	// Tmp. no. of PAD bits
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			TMP_PAD <= {16{1'b0}};
		else if (cState == GEN_PREAMBLE)
			TMP_PAD <= N_RAW + 15'd22;			// = 16 + 8*LENGTH + 6
		else if (!nextPAD[15])					// as long as TMP_PAD > N_DBPS
			TMP_PAD <= nextPAD;					// keep subtracting N_DBPS from TMP_PAD
	end
//--------------------------------------//

endmodule
