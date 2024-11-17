%% FPGA Project - Phase 3 - Interleaver Function
% Author: Roozmehr Jalilian (97101467)

function Y = interleave(X,Rate)
    % Decode 'Rate' into Ncbps & Nbpsc
    switch(Rate)
        case {6, 9}
            Ncbps = 48;
            Nbpsc = 1;
        case {12, 18}
            Ncbps = 96; 
            Nbpsc = 2;
        case {24, 36}
            Ncbps = 192; 
            Nbpsc = 4;
        case {48, 54}
            Ncbps = 288; 
            Nbpsc = 6;
        otherwise
            Ncbps = 48;
            Nbpsc = 1;
    end
    
    % 1st stage of interleaving
    SIZE = size(X,1);
    tmp = zeros(SIZE, Ncbps);
    
    for m = 1 : SIZE
        for k = 1 : Ncbps
            i = 1 + (Ncbps/16)*mod(k-1,16) + floor((k-1)/16);
            tmp(m,i) = X(m,k);
        end
    end
    
    % 2nd stage of interleaving
    Y = zeros(SIZE, Ncbps);
    s = max(Nbpsc/2, 1);
    
    for m = 1 : SIZE
        for i = 1 : Ncbps
            j = 1 + s*floor((i-1)/s) + mod((i-1)+Ncbps-floor((16*(i-1))/Ncbps),s);
            Y(m,j) = tmp(m,i);
        end
    end
    
end
