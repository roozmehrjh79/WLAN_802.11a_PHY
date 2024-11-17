%% FPGA Project - Phase 1 - Scrambler Function
% Author: Roozmehr Jalilian (97101467)

function outVect = scramble(SEED,inVect)
    % SEED = initial scrambler seed (must be a binary vector of size 7)
    % inVect = input binary matrix (must be a set of 8 bit binary vectors)
    SIZE = size(inVect,1);  % SIZE must always be greater than 2
    outVect = zeros(SIZE, 8);
    tmp = zeros(1, 8*SIZE);
    
    LFSR = SEED;                                % shift register
    for i = 1 : SIZE
        for j = 1 : 8
            XOR_mid = xor(LFSR(1), LFSR(4));    % middle XOR gate
            % Update 'tmp'
            tmp(j+(i-1)*8) = xor(XOR_mid, inVect(i,j));
            % LShift & update 'LFSR'
            LFSR = circshift(LFSR, -1);
            LFSR(7) = XOR_mid;                  % update LSB
        end
    end
    
    % Generate output
    %  output is a matrix containing multiple 8-bit vectors
    for i = 1 : SIZE
        for j = 1 : 8
            outVect(i,j) = tmp(j+(i-1)*8);
        end
    end
end

