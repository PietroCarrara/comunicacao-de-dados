function [ out ] = encode_qpsk(bits)
% Implementa a tabela 17-13 do IEEE 802.11
    out = zeros(1, ceil(length(bits)/2));
    for i = 1:length(out)
        index = (i-1)*2 + 1;
        
        x = -1;
        y = -1;
        
        if (bits(index) == 1)
            x = 1;
        end
        if (index+1 <= length(bits) && bits(index+1) == 1)
            y = 1;
        end
        
        out(i) = complex(x, y);
    end
end