//===============================================================================
// FPGA Project - Phase 4
// Module Name: Receiver controller (RX side)
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module RX_Controller
	#(	// Parameters
		parameter HEADER = 12'hFFF		// PLCP preamble
	)
	(	// Ports Declaration
		input iClk,						// clock
		input iRst,						// async. reset
		input iData,					// input stream (serial)
		output reg oData,				// output stream (serial)
		output reg oRX_EN,				// reception status indicator
		output wire oBusy				// busy status indicator (is HIGH when controller isn't in IDLE mode)
	);

//---------- Local Parameters ----------//
	localparam IDLE = 4'd0,			// idle mode
				GET_SIGNAL = 4'd1,		// get first 48 bits (signal)
				DEC_SIGNAL = 4'd2,		// wait for the decoding of SIGNAL field to be finished
				EX_SIGNAL = 4'd3,		// extract the SIGNAL field
				FLUSH1 = 4'd4,			// flush everything but the FIFO memory (1st attempt)
				SET_RATE = 4'd5,		// set de-interleaver RATE
				DEC_SERVICE = 4'd6,		// wait for decoding of SERVICE field to be finished
				EX_SERVICE = 4'd7,		// extract SERVICE field
				WT_DATA = 4'd8,			// wait for 'oData' latency
				EX_DATA = 4'd9,			// extract raw data
				FLUSH2 = 4'd10;			// flush everything (2nd attempt)
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	integer k;

	// Slow clock
	reg slwClk;
	
	// Seq. detector siganl
	wire SEQ_OK;

	// Controller FSM
	reg [3:0] cState, nState;
	
	// Counters & Pointers
	reg [15:0] mainCnt;				// main counter
	wire CNT_ZERO;					// main counter ZERO flag
	reg [4:0] sigPtr;				// pointer for reading SIGNAL
	
	// Storage
	reg [10:0] SEQ;					// sequence detector register (used to detec PREAMBLE)
									//  is 11-bits wide to act like a MEALY machine! Meaning
									//  the final bit of the PREAMBLE will be detected
									//  through combinational circuitary!
	reg [17:0] SIGNAL;
	wire [3:0] RATE;
	wire [11:0] LENGTH;
	wire [14:0] N_RAW;				// no. of RAW data bits
	
	// Puncturer
	reg [1:0] punct;				// puncturing register
	reg [1:0] delay;				// delay counter
	wire PUNCT_V;					// puncturer output valid flag
	
	// Module interconnections
	reg GLB_FLUSH;					// global flush signal
	wire GLB_RST;					// global reset signal
	reg SIG_FLUSH;					// SIGNAL register flush
	wire SIG_RST;					// SIGNAL reset
	reg F0_FLUSH;					// FIFO flush signal
	wire F0_RST;					// FIFO reset signal
	reg F0_WrEN, F0_ReEN;
	wire F0_OUT, F0_EMPTY, F0_FULL;
	reg DINT0_EN, DINT0_REN, DINT0_IN;
	wire DINT0_OUT, DINT0_V;
	reg DEC0_EN;
	wire DEC0_OUT, DEC0_V;
	reg DSCMB0_SEN;
	wire DSCMB0_OUT;
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign SEQ_OK = ({SEQ,iData} == HEADER) ? 1'b1 : 1'b0;
	assign CNT_ZERO = ~(|mainCnt);
	assign PUNCT_V = ~(|delay);
	assign oBusy = (cState != IDLE) ? 1'b1 : 1'b0;
	
	// Global Reset
	assign GLB_RST = GLB_FLUSH | iRst;
	
	// FIFO reset
	assign F0_RST = F0_FLUSH | iRst;
	
	// SIGNAL reset
	assign SIG_RST = SIG_FLUSH | iRst;
	
	assign RATE = SIGNAL[17:14];
	assign LENGTH = SIGNAL[12:1];
	assign N_RAW = {LENGTH,3'b0};					// = 8 * LENGTH
//--------------------------------------------//

//---------- Module Instantiations ----------//
	// Input FIFO
	defparam F0.ADDR_WIDTH = 8;
	FIFO F0(
		.iClk(iClk),
		.iRst(F0_RST),
		.iW_EN(F0_WrEN),
		.iR_EN(F0_ReEN),
		.iData(iData),
		.oData(F0_OUT),
		.oEmpty(F0_EMPTY),
		.oFull(F0_FULL)
	);
	
	// Decrambler
	descrambler DSCMB0(
		.iClk(slwClk),
		.iRst(GLB_RST),
		.iSEN(DSCMB0_SEN),
		.iData(DEC0_OUT),
		.oData(DSCMB0_OUT)
	);
	
	// Viterbi decoder
	vitDecoder DEC0(
		.iClk(slwClk),
		.iRst(GLB_RST),
		.iEN(PUNCT_V),
		.iData(punct),
		.oData(DEC0_OUT),
		.oValid(DEC0_V)
	);
	
	// Data de-interleaver
	deinterleaver DINT0(
		.iClk(iClk),
		.iRst(GLB_RST),
		.iRateEN(DINT0_REN),
		.iRate(RATE),
		.iEN(DINT0_EN),
		.iData(DINT0_IN),
		.oData(DINT0_OUT),
		.oValid(DINT0_V)
	);
	
//-------------------------------------------//

//---------- Combinational Logic ----------//	
	// Control signals
	always @(*) begin
		nState = IDLE;
		GLB_FLUSH = 1'b0;		// global flush signal
		F0_FLUSH = 1'b0;		// FIFO flush signal
		SIG_FLUSH = 1'b0;		// SIGNAL register flush signal
		F0_WrEN = 1'b1;			// FIFO write enable
		F0_ReEN = 1'b1;			// FIFO read enable
		DINT0_EN = 1'b1;		// de-interleaver enable
		DINT0_REN = 1'b0;		// de-interleaver rate-enable (allows updating its RATE value)
		DINT0_IN = F0_OUT;		// de-interleaver input
		DEC0_EN = 1'b0;			// decoder enable signal
		DSCMB0_SEN = 1'b0;		// descramblr seed-enable signal (allows updating its internal shift-register)
		
		case(cState)
			IDLE: begin
				F0_WrEN = 1'b0;
				F0_ReEN = 1'b0;
				DINT0_EN = 1'b0;
				nState = (SEQ_OK) ? GET_SIGNAL : IDLE;
			end
			
			GET_SIGNAL: begin
				F0_WrEN = 1'b0;
				F0_ReEN = 1'b0;
				DINT0_IN = iData;
				nState = (CNT_ZERO) ? DEC_SIGNAL : GET_SIGNAL;
			end
			
			DEC_SIGNAL: begin
				F0_ReEN = 1'b0;
				DINT0_IN = 1'b0;
				DEC0_EN = PUNCT_V;
				nState = (DEC0_V) ? EX_SIGNAL : DEC_SIGNAL;
			end
			
			EX_SIGNAL: begin
				F0_ReEN = 1'b0;
				DINT0_IN = 1'b0;
				DEC0_EN = PUNCT_V;
				nState = (CNT_ZERO) ? FLUSH1 : EX_SIGNAL;
			end
			
			FLUSH1: begin
				GLB_FLUSH = 1'b1;
				F0_ReEN = 1'b0;
				DINT0_EN = 1'b0;
				nState = SET_RATE;
			end
			
			SET_RATE: begin
				F0_ReEN = 1'b0;
				DINT0_REN = 1'b1;
				DINT0_EN = 1'b0;
				nState = DEC_SERVICE;
			end
			
			DEC_SERVICE: begin
				DEC0_EN = PUNCT_V;
				DSCMB0_SEN = DEC0_V;
				nState = (DEC0_V) ? EX_SERVICE : DEC_SERVICE;
			end
			
			EX_SERVICE: begin
				DEC0_EN = PUNCT_V;
				DSCMB0_SEN = DEC0_V;
				nState = (CNT_ZERO) ? WT_DATA : EX_SERVICE;
			end
			
			WT_DATA: begin
				DEC0_EN = PUNCT_V;
				nState = (CNT_ZERO) ? EX_DATA : WT_DATA;
			end
			
			EX_DATA: begin
				DEC0_EN = PUNCT_V;
				nState = (CNT_ZERO) ? FLUSH2 : EX_DATA;
			end
			
			FLUSH2: begin
				F0_WrEN = 1'b0;
				F0_ReEN = 1'b0;
				DINT0_EN = 1'b0;
				GLB_FLUSH = 1'b1;
				F0_FLUSH = 1'b1;
				SIG_FLUSH = 1'b1;
				nState = IDLE;
			end
			
		endcase
	end
	
	// Signal pointer
	always @(mainCnt[5:1]) begin
		sigPtr = 5'h00;
		if (mainCnt[5:1] < 5'd18)
			sigPtr = mainCnt[5:1];
	end
//----------------------------------------//

//---------- Sequential Logic ----------//
	// Slow clock 1
	always @(negedge iClk, posedge iRst) begin
		if (iRst)
			slwClk <= 1'b0;
		else
			slwClk <= ~slwClk;
	end	
	
	// Controller FSM
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			cState <= IDLE;
		else
			cState <= nState;
	end
	
	// Main counter
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			mainCnt <= {16{1'b0}};
		else if (cState == IDLE && SEQ_OK)
			mainCnt <= 16'd47;	// = 48 - 1
		else if (cState == DEC_SIGNAL && DEC0_V)
			mainCnt <= 16'd34;	// = 18 * 2 - 1 -1
		else if (CNT_ZERO && cState == EX_SIGNAL)
			mainCnt <= 16'd11;	// = 6 * 2 - 1
		else if (cState == DEC_SERVICE && DEC0_V)
			mainCnt <= 16'd31;	// = 16 * 2 -1 -1
		else if (CNT_ZERO && cState == EX_SERVICE)
			mainCnt <= 16'd1;			// = 2 - 1
		else if (CNT_ZERO && cState == WT_DATA)
			mainCnt <= {N_RAW,1'b0};	// = 2 * {no. of RAW data bits}
		else if (!CNT_ZERO)								// general case
			mainCnt <= mainCnt - 1'b1;
	end
	
	// Seq. detector
	always @(posedge iClk, posedge iRst) begin
		if (iRst)
			SEQ <= {11{1'b0}};
		else begin
			for (k=10; k>0; k=k-1)
				SEQ[k] <= SEQ[k-1];
			SEQ[0] <= iData;
		end
	end
	
	// SIGNAL register (SIGNAL[0] is the PARITY bit)
	always @(posedge iClk, posedge SIG_RST) begin
		if (SIG_RST)
			SIGNAL <= {18{1'b0}};
		else if (cState == EX_SIGNAL)
			SIGNAL[sigPtr] <= DEC0_OUT;
	end
	
	// Puncturer
	always @(posedge iClk, posedge GLB_RST) begin
		if (GLB_RST) begin
			punct <= 2'b00;
			delay <= 2'b10;
		end
		else if (DINT0_V) begin
			punct[1] <= punct[0];
			punct[0] <= DINT0_OUT;
			delay <= (|delay) ? delay - 1'b1 : 2'b00;
		end
	end
	
	// Output & Output validity
	always @(posedge slwClk, posedge GLB_RST) begin
		if (GLB_RST) begin
			oData <= 1'b0;
			oRX_EN <= 1'b0;
		end
		else if (cState == WT_DATA || cState == EX_DATA) begin
			oData <= DSCMB0_OUT;
			oRX_EN <= 1'b1;
		end
	end
//--------------------------------------//

endmodule
