//===============================================================================
// FPGA Project - Phase 1
// Module Name: Receiver Controller
// Author: Roozmehr Jalilian (97101467)
//===============================================================================

module RX_Controller
	#(	// Parameters
		parameter	HEADER = 12'hFFF	// PLCP preamble
	)
	(	// Ports Declaration
		input iClk,						// clock
		input iRst,						// async. reset
		input iData,					// input stream (serial)
		input iDSCMB_Out,				// descrambler output
		output reg oDSCMB_SEN,			// descrambler set-seed enable
		output wire oDSCMB_In,			// descrambler input
		output reg oData,				// output stream (serial)
		output wire oValid				// indicator for incoming RAW DATA
	);

//---------- Local Parameters ----------//
	localparam IDLE = 2'b00,			// idle (= reset)
				GET_SIGNAL = 2'b01,		// receive SIGNAL field
				GET_SERVICE = 2'b10,	// load descrambler with incoming SERVICE field	
				GET_DATA = 2'b11;		// get the remaining DATA field 
//--------------------------------------//

//---------- Wire & Variable Declaration ----------//
	integer k;
	reg [23:0] Input_Buffer;			// 24-bit input buffer
	// wire [3:0] RATE;					// RATE field (unused)
	wire [11:0] LENGHT;					// LENGHT field
	wire [15:0] N_RAW;					// no. of RAW DATA bits (no SERVICE, TAIL or PAD)
	// reg [7:0] RATE_Decoder;			// RATE to N_DBPS decoder (UNUSED)
	
	reg [15:0] counter;					// counter (used for state transition)
	wire CNT_ZERO;						// counter ZERO flag
	wire ReceiveCMD;					// valid reception command
	reg [1:0] cState, nState;			// current & next FSM states
	reg oData_In;						// input for 'oData' register
//-------------------------------------------------//

//---------- Continuous Assignments ----------//
	assign ReceiveCMD = (cState == IDLE && Input_Buffer[11:0] == HEADER) ? 1'b1 : 1'b0;
	assign CNT_ZERO = (counter == 16'h0000) ? 1'b1 : 1'b0;
	// assign RATE = Input_Buffer[23:20]; // (unused)
	assign LENGHT = Input_Buffer[18:7];
	assign N_RAW = $unsigned(LENGHT<<3) - 1'b1;	// = 8*LENGHT - 1
	assign oDSCMB_In = iData;
	assign oValid = (cState == GET_DATA) ? 1'b1 : 1'b0;
//--------------------------------------------//

//---------- Combinational Logic ----------//
	always @(ReceiveCMD, cState, CNT_ZERO, iDSCMB_Out) begin	// controller FSM
		nState = IDLE;
		oData_In = 1'b0;
		oDSCMB_SEN = 1'b0;
		case (cState)
			IDLE: nState = (ReceiveCMD) ? GET_SIGNAL : IDLE;
			GET_SIGNAL: begin 
				nState = (CNT_ZERO) ? GET_SERVICE : GET_SIGNAL;
				oDSCMB_SEN = (CNT_ZERO) ? 1'b1 : 1'b0;
			end
			
			GET_SERVICE: begin
				oDSCMB_SEN = (!CNT_ZERO) ? 1'b1 : 1'b0;
				nState = (CNT_ZERO) ? GET_DATA : GET_SERVICE;
				oData_In = (CNT_ZERO) ? iDSCMB_Out : 1'b0;
			end
			
			GET_DATA: begin
				nState = (CNT_ZERO) ? IDLE : GET_DATA;
				oData_In = (!CNT_ZERO) ? iDSCMB_Out : 1'b0;
			end
		endcase
	end
	
	/* ============== UNUSED ==============
	always @(RATE) begin						// RATE to N_DBPS decoder
		case(RATE)
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
	*/
//----------------------------------------//

//---------- Sequential Logic ----------//
	always @(posedge iClk, posedge iRst) begin	// controller FSM
		if (iRst)
			cState <= IDLE;
		else
			cState <= nState;
	end

	always @(posedge iClk, posedge iRst) begin	// Input_Buffer
		if (iRst)
			Input_Buffer <= {24{1'b0}};
		else if (cState == IDLE || (cState == GET_SIGNAL && !CNT_ZERO)) begin
			for (k=1; k<24; k=k+1)
				Input_Buffer[k] <= Input_Buffer[k-1];
			Input_Buffer[0] <= iData;
		end
	end
	
	always @(posedge iClk, posedge iRst) begin	// oData
		if (iRst)
			oData <= 1'b0;
		else
			oData <= oData_In;	
	end
	
	always @(posedge iClk, posedge iRst) begin	// counter
		if (iRst)
			counter <= {16{1'b0}};
		else if (ReceiveCMD)
			counter <= 16'd23;	// = sizeof(SIGNAL) - 1
		else if (CNT_ZERO && nState == GET_SERVICE)
			counter <= 16'd15;	// sizeof(SERVICE) - 1
		else if (CNT_ZERO && nState == GET_DATA)
			counter <= N_RAW;
		else if (cState != IDLE)
			counter <= counter - 1'b1;
	end
//--------------------------------------//

endmodule
