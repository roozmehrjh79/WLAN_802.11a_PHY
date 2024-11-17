//===============================================================================
// FPGA Project - Phase 1
// Module Name: Transmitter Controller
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
		input [3:0] iRate,				// input rate (not used in here)
		input [11:0] iLenght,			// LENGHT field
		input iData,					// input stream (serial)
		input iSCMB_Out,				// scrambler output
		output reg oSCMB_SEN,			// scrambler set-seed enable
		output wire [6:0] oSCMB_Seed,	// scrambler initial seed
		output wire oSCMB_In,			// scrambler output
		output reg oData,				// output stream (serial)
		output reg oTransmit			// transmition status indicator
	);

//---------- Local Parameters ----------//
	localparam IDLE = 3'b000,			// idle (= reset)
				SEND_RAW = 3'b001,		// feed RAW DATA into the scrambler buffer
				SEND_REM = 3'b010,		// send remaining DATA (considering SERVICE & SIGNAL & PREAMBLE fields)
				SEND_TAIL = 3'b011,		// send TAIL bits	
				SEND_PAD = 3'b100;		// send PAD bits
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	integer k;
	wire [11:0] Preamble;				// preamble header
	wire [23:0] SIGNAL;					// SIGNAL field
	wire PARITY;						// parity bit
	reg [35:0] Output_Buffer;			// output buffer
	reg [15:0] SCMB_Buffer;				// scrambler input buffer
	
	reg [15:0] counter;					// counter (used for state transition)
	wire CNT_ZERO;						// counter ZERO flag
	reg [15:0] TMP_PAD;					// TEMPORARY no. of PAD bits
	wire [15:0] nextPAD;				// next value of N_PAD to be updated
	wire [15:0] N_PAD;					// no. of PAD bits
	reg [7:0] RATE_Decoder;				// RATE to N_DBPS decoder
	reg [7:0] N_DBPS;					// no. of DATA bits per OFDM symbol
	
	reg [2:0] cState, nState;			// current & next FSM states
	wire StartCMD;						// valid start command
	wire [15:0] N_RAW;					// no. of RAW DATA bits
	wire oData_In;						// input for 'oData' register
	wire Idle;							// idle status indicator
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign StartCMD = (iStart && cState == IDLE) ? 1'b1 : 1'b0;
	assign CNT_ZERO = (counter == 16'h0000) ? 1'b1 : 1'b0;
	assign N_RAW = $unsigned(iLenght<<3);				// = 8*LENGHT
	assign nextPAD = TMP_PAD - N_DBPS;
	assign N_PAD = ~nextPAD + 1'b1;
	assign Preamble = HEADER;
	assign PARITY = ^{iRate, iLenght};
	assign SIGNAL = {iRate, 1'b0, iLenght, PARITY, 6'b000000};
	assign oData_In = (!Idle && cState != SEND_TAIL) ? Output_Buffer[35] : 1'b0;
	assign oSCMB_In = SCMB_Buffer[15];
	assign oSCMB_Seed = SEED;
	assign Idle = (cState == IDLE) ? 1'b1 : 1'b0;
//--------------------------------------------//

//---------- Combinational Logic ----------//
	always @(iStart, cState, CNT_ZERO) begin		// controller FSM
		nState = IDLE;
		oSCMB_SEN = 0;
		case (cState)
			IDLE: begin 
				nState = (iStart) ? SEND_RAW : IDLE;
				oSCMB_SEN = (iStart) ? 1'b1 : 1'b0;
			end
			SEND_RAW: nState = (CNT_ZERO) ? SEND_REM : SEND_RAW;
			SEND_REM: nState = (CNT_ZERO) ? SEND_TAIL : SEND_REM;
			SEND_TAIL: nState = (CNT_ZERO) ? SEND_PAD : SEND_TAIL;
			SEND_PAD: nState = (CNT_ZERO) ? IDLE : SEND_PAD;
		endcase
	end
	
	always @(iRate) begin						// RATE to N_DBPS decoder
		case(iRate)
			4'b1101: RATE_Decoder = 8'd24;
			4'b1111: RATE_Decoder = 8'd36;
			4'b0101: RATE_Decoder = 8'd48;
			4'b0111: RATE_Decoder = 8'd72;
			4'b1001: RATE_Decoder = 8'd96;
			4'b1011: RATE_Decoder = 8'd144;
			4'b0001: RATE_Decoder = 8'd192;
			4'b0011: RATE_Decoder = 8'd216;
			default: RATE_Decoder = 8'd24;
		endcase
	end
//----------------------------------------//

//---------- Sequential Logic ----------//
	always @(posedge iClk, posedge iRst) begin	// controller FSM
		if (iRst)
			cState <= IDLE;
		else
			cState <= nState;
	end
	
	always @(posedge iClk, posedge iRst) begin	// N_DBPS
		if (iRst)
			N_DBPS <= 8'h00;
		else if (StartCMD)
			N_DBPS <= RATE_Decoder;
	end
	
	always @(posedge iClk, posedge iRst) begin	// TMP_PAD
		if (iRst)
			TMP_PAD <= 16'h0000;
		else if (StartCMD)
			TMP_PAD <= N_RAW + 16'd22;			// = 16 + 8*LENGHT + 6
		else if (!nextPAD[15])					// as long as TMP_PAD > N_DBPS
			TMP_PAD <= nextPAD;					// keep subtracting N_DBPS from TMP_PAD
	end
	
	always @(posedge iClk, posedge iRst) begin	// counter
		if (iRst)
			counter <= {16{1'b0}};
		else if (StartCMD)
			counter <= N_RAW;
		else if (CNT_ZERO && nState == SEND_REM)
			counter <=  16'd51;						// = sizeof(PREAMBLE + SIGNAL + SERVICE) - 1
		else if (CNT_ZERO && nState == SEND_TAIL)
			counter <= 16'd5;						// = sizeof(TAIL) - 1
		else if (CNT_ZERO && nState == SEND_PAD)
			counter <= N_PAD;
		else if (!Idle)
			counter <= counter - 1'b1;
	end

	always @(posedge iClk, posedge iRst) begin	// Output_Buffer
		if (iRst)
			Output_Buffer <= {36{1'b0}};
		else if (StartCMD)
			Output_Buffer <= {Preamble, SIGNAL};
		else begin
			for (k=1; k<36; k=k+1)
				Output_Buffer[k] <= Output_Buffer[k-1];
			Output_Buffer[0] <= iSCMB_Out;
		end
	end
	
	always @(posedge iClk, posedge iRst) begin	// oData
		if (iRst)
			oData <= 1'b0;
		else
			oData <= oData_In;	
	end
	
	always @(posedge iClk, posedge iRst) begin	// scrambler input buffer
		if (iRst)
			SCMB_Buffer <= {16{1'b0}};
		else if (StartCMD)
			SCMB_Buffer <= {16{1'b0}};
		else begin
			for (k=1; k<16; k=k+1)
				SCMB_Buffer[k] <= SCMB_Buffer[k-1];
			if (!CNT_ZERO && cState == SEND_RAW)
				SCMB_Buffer[0] <= iData;
			else
				SCMB_Buffer[0] <= 1'b0;
		end		
	end
	
	always @(posedge iClk, posedge iRst) begin	// transmition status
		if (iRst)
			oTransmit <= 1'b0;
		else
			oTransmit <= ~Idle;
	end
//--------------------------------------//

endmodule
