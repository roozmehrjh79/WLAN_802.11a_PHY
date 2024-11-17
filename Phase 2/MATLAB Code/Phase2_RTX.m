%% FPGA Project - Phase 2 - TX & RX Sides MATLAB Code
% Author: Roozmehr Jalilian (97101467)
clc
clearvars
close all

%% Stage 1 : Convolutional Encoding (TX Side)

% Read binary data from file
fileID = fopen('raw_data.txt', 'r');
data = fscanf(fileID, '%i\n');
SIZE = length(data);                    % lenght of binary input
fclose(fileID);

% Construct Trellis structure (constraint lenght = 7)
trellis = poly2trellis(7,{'1 + x + x^3 + x^4 + x^6', '1 + x^3 + x^4 + x^5 + x^6'});

% Encode data in the form of a 2-bit vector
% NOTE: left bit is transmitted first!
tmp = convenc(data, trellis);                   % temp variable
encData = zeros(SIZE, 2);                       % encoded data (2-bit vector)
for i = 1 : SIZE
    for j = 1 : 2
        encData(i,j) = tmp(2*(i-1) + j);
    end
end

% Write encoded data to file
fileID = fopen('encData_MATLAB.txt', 'w');
for i = 1 : SIZE
    fprintf(fileID, '%i%i\n', encData(i,1), encData(i,2));
end
fclose(fileID);

%% Stage 2 : Viterbi Decoding

% Traceback depth is set to 32
% also we'll use Hard decision Viterbi decoding and
% we assume the final encoder state could be anything,
% not necessarily all-zero!
decData = vitdec(tmp,trellis,32,'trunc','hard');        % decoded data

% Write decoded data to file & compare output to original input
% NOTE: Use Notepad++ to read this file!
fileID = fopen('decData_MATLAB.txt', 'w');
for i = 1 : SIZE
    fprintf(fileID, '%i\n', decData(i));
end
fclose(fileID);

% Check for any bit errors
BE = biterr(data, decData);
if (BE > 0)
    disp("WARNING: " + BE + " bit errors where found after decoding!");
else
    disp("SUCCESS: Decoded data matches primary data!");
end