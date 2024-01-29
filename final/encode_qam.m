function [ out ] = encode_qam(bits)
    % Implementa a tabela 17-15 do IEEE 802.11
    TABLE = [-7 -5 -1 -3 7 5 1 3];
    
    out = zeros(1, ceil(length(bits)/6));
    for i = 1:length(out)
        index = (i-1)*6 + 1;
        b5 = 0;
        b4 = 0;
        b3 = 0;
        b2 = 0;
        b1 = 0;
        b0 = 0;
        
        if index+0 <= length(bits)
            b0 = bits(index+0);
        end
        if index+1 <= length(bits)
            b1 = bits(index+1);
        end
        if index+2 <= length(bits)
            b2 = bits(index+2);
        end
        if index+3 <= length(bits)
            b3 = bits(index+3);
        end
        if index+4 <= length(bits)
            b4 = bits(index+4);
        end
        if index+5 <= length(bits)
            b5 = bits(index+5);
        end
        
        out(i) = complex(TABLE(binvec2dec([b2 b1 b0])+1), TABLE(binvec2dec([b5 b4 b3])+1));
    end
end

