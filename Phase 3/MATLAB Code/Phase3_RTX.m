%% FPGA Project - Phase 3 - TX & RX Sides MATLAB Code
% Author: Roozmehr Jalilian (97101467)
clc
clearvars
close all

%% Stage 0 : Generate Random Vector (Run only once!)

% Set Rate & no. of blocks
SIZE = 2; % no. of rows
Rate = 24;

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

% Decode Rate into bit-format (RATE)
switch(Rate)
    case 6
        RATE = '1101';
    case 9
        RATE = '1111'; 
    case 12
        RATE = '0101';
    case 18
        RATE = '0111'; 
    case 24
        RATE = '1001';
    case 36
        RATE = '1011'; 
    case 48
        RATE = '0001';
    case 54
        RATE = '0011';
    otherwise
        RATE = '1101';
end

% Generate random vector
data = randi([0 1], SIZE*Ncbps, 1);

% Organize 'data' into rows of size Ncbps
X = reshape(data, Ncbps, SIZE)';

% Write data to file
fileID = fopen('input_info.txt', 'w');
fprintf(fileID, 'RATE=%s\nLEN=%i\n', RATE, SIZE*Ncbps);
fclose(fileID);

fileID = fopen('input_data.txt', 'w');
for m = 1 : SIZE*Ncbps
    fprintf(fileID, '%i\n', data(m));
end
fclose(fileID);

%% Stage 1 - Interleaving (TX Side)

% Interleave
Y = interleave(X, Rate);
intData = reshape(Y', 1, SIZE*Ncbps)';

% Write to file
fileID = fopen('intData_MATLAB.txt', 'w');
for m = 1 : SIZE*Ncbps
    fprintf(fileID, '%i\n', intData(m));
end
fclose(fileID);

%% Stage 2 - Deinterleaving (RX Side)

% Deinterleave
Z = deinterleave(Y, Rate);
deintData = reshape(Z', 1, SIZE*Ncbps)';

% Write to file
fileID = fopen('deintData_MATLAB.txt', 'w');
for m = 1 : SIZE*Ncbps
    fprintf(fileID, '%i\n', deintData(m));
end
fclose(fileID);

% Check if original data has been retrieved without error
BE = biterr(data, deintData); % no. of bit errors
if (BE==0)
    disp("SUCCESS: Deinterleaved data matches primary data!");
else
    disp("WARNING: " + BE + " bit errors where found after deinterleaving!");
end