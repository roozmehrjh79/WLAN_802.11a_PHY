%% FPGA Project - Phase 4 - TX & RX Sides MATLAB Code
% Author: Roozmehr Jalilian (97101467)
clc
clearvars
close all

%% Stage 0 : Primary Frame Generation (TX Side)

% Header (as Preamble) & SEED (for scrambler)
HEADER = [0 0 0 0 ones(1,12)]'; % header = 12'hFFF
SEED = [1 0 1 1 1 0 1];

% Get RATE & LENGHT from file
fileID = fopen('input_info.txt', 'r');
dRate = fscanf(fileID, 'RATE=%x\n');
Length = fscanf(fileID, 'LENGHT=%x\n');
fclose(fileID);
RATE = de2bi(dRate, 4, 'left-msb');
LENGHT = de2bi(Length, 12, 'left-msb');

% Get raw DATA from file
DATA = zeros(Length, 8);
fileID = fopen('input_data.txt', 'r');
Data = fscanf(fileID, '%x\n');
for i = 1 : Length
    DATA(i,:) = de2bi(Data(i), 8, 'left-msb');
end
fclose(fileID);

% Parity bit generation
SIGNAL = [RATE 0 LENGHT];
Parity = 0;
for i = 1 : 17
    Parity = xor(Parity, SIGNAL(i));
end

% Updating SIGNAL
SIGNAL = [SIGNAL Parity zeros(1,6)]';

%% Stage 1.1 : Scrambling (TX Side)

% Concatenate SERVICE to the beginning of the DATA field
SCMB_DATA = [zeros(2,8); DATA];

% Calculate Ndbps from RATE
switch (dRate)
    case 13
        Ndbps = 24;
    case 15
        Ndbps = 36;
    case 5
        Ndbps = 48;        
    case 7
        Ndbps = 72;
    case 9
        Ndbps = 96;
    case 11
        Ndbps = 144;
    case 1
        Ndbps = 192;
    case 3
        Ndbps = 216;
    otherwise
        Ndbps = 24;
end

% Calculate data rate (in terms of MBit/s) from RATE!
switch(dRate)
    case 13
        Rate = 6;
    case 15
        Rate = 9;
    case 5
        Rate = 12;
    case 7
        Rate = 18;
    case 9
        Rate = 24;
    case 11
        Rate = 36;
    case 1
        Rate = 48;
    case 3
        Rate = 54;
    otherwise
        Rate = 6;
end
 
% Calculate required PAD bits
Nsym = ceil( (16+8*Length+6)/Ndbps );
Ndata = Nsym * Ndbps;
Npad = Ndata - (16 + 8*Length + 6);
n = (Npad + 6)/8;						% PAD + TAIL bits

% Scramble the DATA field
SCMB_DATA = scramble(SEED, SCMB_DATA);

% Append TAIL & PAD bits
SCMB_DATA = [SCMB_DATA; zeros(n, 8)];

% Reshape the vectors into pure binary format
SIZE = size(SCMB_DATA, 1);
SCMB_DATA = reshape(SCMB_DATA', 1, SIZE*8)';

%% Stage 1.2 : Encoding (TX Side)

% Construct Trellis structure (constraint lenght = 7)
trellis = poly2trellis(7,{'1 + x + x^3 + x^4 + x^6', '1 + x^3 + x^4 + x^5 + x^6'});

% Encode data; Note that left bit is transmitted first!
ENC_SIGNAL = convenc(SIGNAL, trellis);
ENC_DATA = convenc(SCMB_DATA, trellis);

%% Stage 1.3 : Interleaving (TX Side)

% Decode 'Rate' into Ncbps
switch(Rate)
    case {6, 9}
        Ncbps = 48;
    case {12, 18}
        Ncbps = 96; 
    case {24, 36}
        Ncbps = 192; 
    case {48, 54}
        Ncbps = 288; 
    otherwise
        Ncbps = 48;
end

% Organize data into rows of size Ncbps
INT_DATA = reshape(ENC_DATA', Ncbps, size(ENC_DATA,1)/Ncbps)';

% Interleave & Reorganize
INT_SIGNAL = interleave(ENC_SIGNAL', 6);
INT_SIGNAL = reshape(INT_SIGNAL', 1, 48)';
INT_DATA = interleave(INT_DATA, Rate);
INT_DATA = reshape(INT_DATA', 1, size(INT_DATA,1)*Ncbps)';

%% Stage 1.4 Writing Frame to file (TX Side)

% Append modified SIGNAL & DATA fields
TX_FRAME = [HEADER; INT_SIGNAL; INT_DATA];
HEX_FRAME = binaryVectorToHex(TX_FRAME')'; % hex format

% Write to file
fileID = fopen('TXData_MATLAB.txt', 'w');
SIZE = size(HEX_FRAME, 1);
for i = 1 : SIZE/2
    fprintf(fileID, '%s%s\n', HEX_FRAME(1+(i-1)*2,:), HEX_FRAME(i*2,:));
end
fclose(fileID);

%% Stage 2.1 Extracting SIGNAL Field (RX Side)

% Cut-off PREAMBLE header
RX_FRAME = TX_FRAME(17:end);

% Get SIGNAL & DATA fields
RX_SIGNAL = RX_FRAME(1:48);
RX_DATA = RX_FRAME(49:end);

% De-interleave
DINT_SIGNAL = deinterleave(RX_SIGNAL', 6)';

% Decode
DEC_SIGNAL = vitdec(DINT_SIGNAL,trellis,24,'trunc','hard');

% Check if this matches original SIGNAL
if (DEC_SIGNAL == SIGNAL)
    disp("Received SIGNAL field is correct!");
else
    disp("WARNING: Received SIGNAL field is incorrect!");
    disp("BER = " + biterr(DEC_SIGNAL, SIGNAL));
end

%% Stage 2.2 Extracting DATA Field (RX Side)

% Assume we've already extracted RATE and LENGHT;
% so we move on to extracting the RAW DATA!

% De-interleave & Re-organize
DINT_DATA = deinterleave(reshape(RX_DATA', Ncbps, length(RX_DATA)/Ncbps)', Rate);
DINT_DATA = reshape(DINT_DATA', 1, size(DINT_DATA,1)*Ncbps)';

% Decode
DEC_DATA = vitdec(DINT_DATA,trellis,32,'trunc','hard');

% Get the SEED from SERVICE field (last 7 bits)
RX_SEED = DEC_DATA(10:16);

% Reshape DATA
DEC_DATA = DEC_DATA(17:end);

% Descramble & Reshape DATA
DSCMB_DATA = scramble(RX_SEED, reshape(DEC_DATA', 8, length(DEC_DATA)/8)');

% Destroy redundant TAIL & PAD bits!
DSCMB_DATA = DSCMB_DATA(1:Length,:);

% Check if received data is equal to the original
if ( DSCMB_DATA == DATA )
    disp("SUCCESS: Received data matches the original one!");
else
    disp("WARNING: Received data does NOT match the original one!");
end

