%% FPGA Project - Phase 3 - Deinterleaver Function
% Author: Roozmehr Jalilian (97101467)

function Z = deinterleave(X,Rate)
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
    
    % 1st stage of deinterleaving
    SIZE = size(X,1);
    s = max(Nbpsc/2, 1);
    tmp = zeros(SIZE, Ncbps);
    
    for m = 1 : SIZE
        for j = 1 : Ncbps
            i = 1 + s*floor((j-1)/s) + mod((j-1)+floor((16*(j-1))/Ncbps),s);
            tmp(m,i) = X(m,j);
        end
    end
    
    % 2nd stage of deinterleaving
    Z = zeros(SIZE, Ncbps);
    
    for m = 1 : SIZE
        for i = 1 : Ncbps
            k = 1 + 16*(i-1) - (Ncbps-1)*floor((16*(i-1))/Ncbps);
            Z(m,k) = tmp(m,i);
        end
    end
    
end
