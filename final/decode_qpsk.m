function [ out ] = decode_qpsk( input )
    out = zeros(1, length(input)*2);

    for i = 1:length(input)
        index = (i-1)*2 + 1;

        x = max(min(real(input(i)), 1), -1); % keep value between [-1, 1]
        y = max(min(imag(input(i)), 1), -1); % keep value between [-1, 1]

        x = (x+1) / 2; % convert value to be between [0, 1]
        y = (y+1) / 2; % convert value to be between [0, 1]

        out(index) = x;
        out(index+1) = y;
    end
end

