%% FPGA Project - Phase 1 - TX & RX Sides MATLAB Code
% Author: Roozmehr Jalilian (97101467)
clc
clearvars
close all

%% Stage 1 : Primary Frame Generation (TX Side)

% Header (as Preamble) & SEED (for scrambler)
HEADER = [0 0 0 0 1 1 1 1; ones(1, 8)]; % header = 12'hFFF
SEED = [1 0 1 1 1 0 1];

% Get RATE & LENGHT from file
fileID = fopen('input_info.txt', 'r');
Rate = fscanf(fileID, 'RATE=%x\n');
Lenght = fscanf(fileID, 'LENGHT=%x\n');
fclose(fileID);
RATE = de2bi(Rate, 4, 'left-msb');
LENGHT = de2bi(Lenght, 12, 'left-msb');

% Get raw DATA from file
DATA = zeros(Lenght, 8);
fileID = fopen('input_data.txt', 'r');
Data = fscanf(fileID, '%x\n');
for i = 1 : Lenght
    DATA(i,:) = de2bi(Data(i), 8, 'left-msb');
end
fclose(fileID);

% Parity bit generation
SIGNAL = [RATE 0 LENGHT];
Parity = 0;
for i = 1 : 17
    Parity = xor(Parity, SIGNAL(i));
end

% Updating SIGNAL & Primary FRAME generation
SIGNAL = [RATE 0 LENGHT(1:3); LENGHT(4:11); LENGHT(12) Parity zeros(1,6)];
FRAME = [HEADER; SIGNAL];


%% Stage 2 : Scrambling & Sending Frame (TX Side)

% Concatenate SERVICE to the beginning of the DATA field
TX_DATA = [zeros(2,8); DATA];

% Calculate Ndbps from RATE
switch (Rate)
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
 
% Calculate required PAD bits
Nsym = ceil( (16+8*Lenght+6)/Ndbps );
Ndata = Nsym * Ndbps;
Npad = Ndata - (16 + 8*Lenght + 6);
n = (Npad + 6)/8;						% PAD + TAIL bits

% Update TX_DATA
TX_DATA = [TX_DATA; zeros(n, 8)];

% Scramble the new DATA field
TX_DATA = scramble(SEED, TX_DATA);  

% Force the TAIL bits to 0
SIZE = size(TX_DATA, 1); 
TX_DATA(SIZE-n+1,:) = and(TX_DATA(SIZE-n+1,:), [0 0 0 0 0 0 1 1]);

% Finalize output FRAME
FRAME = [FRAME; TX_DATA];

% Write FRAME to file
fileID = fopen('frame_MATLAB.txt', 'w');
Data = cell2mat( binaryVectorToHex(FRAME) );
SIZE = size(Data, 1);
for i = 1 : SIZE
    fprintf(fileID, '%s\n', Data(i,:));
end
fclose(fileID);

%% Stage 3 : Receiving & Descrambling (RX Side)

% Assume we've already ectracted RATE & LENGHT fields
%  so we'll calculate the position of SERVICE + raw DATA field!
%  note that PREAMBLE & SIGNAL fields have 32 bits (= 4 bytes) in total,
%  and SERVICE field has 16 bits (= 2 bytes)
SERVICE = FRAME(6:7, :);
RX_DATA = FRAME(8:8+(Lenght-1),:);

% Descramble RX_DATA
% NOTE: The 'useful' bits of SERVICE are bits 10 to 16, which will
% act as the seed for descrambler
RX_DATA = scramble(SERVICE(2, 2:8), RX_DATA);

% Write output to file
fileID = fopen('output_MATLAB.txt', 'w');
Data = cell2mat( binaryVectorToHex(RX_DATA) );
SIZE = size(Data, 1);
for i = 1 : SIZE
    fprintf(fileID, '%s\n', Data(i,:));
end
fclose(fileID);

% Check if RX_DATA = DATA
if (RX_DATA == DATA)
    disp('Operation successful!');
else
    disp('WARNING: Raw input & output data do not match!');
end