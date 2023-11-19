function [ I, Q ] = encode_8psk( bit0, bit1, bit2 )
%encode_8psk Encodes three bits into two signal components
    key = bit2*2^2 + bit1*2^1 + bit0*2^0; % Transform the input bits into a number for easy array indexing

    half = cos(pi/4); % Value when element is at 45 degrees

    % Answer in form [I, Q]
    switch key
        case 0 % 000
            I = -half;
            Q = -half;
        case 1 % 001
            I = -1;
            Q = 0;
        case 2 % 010
            I = 0;
            Q = 1;
        case 3 % 011
            I = -half;
            Q = half;
        case 4 % 100
            I = 0;
            Q = -1;
        case 5 % 101
            I = half;
            Q = -half;
        case 6 % 110
            I = half;
            Q = half;
        case 7 % 111
            I = 1;
            Q = 0;
    end
end

