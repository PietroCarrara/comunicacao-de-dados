function [ out ] = decode_qpsk( input )
    out = zeros(1, length(input)*2);
    input = complex(sign(real(input)), sign(imag(input))); % slice
    
    for i = 1:length(input)
        index = (i-1)*2 + 1;
        
        if (real(input(i)) > 0)
            out(index) = 1;
        else
            out(index) = 0;
        end
        
        if (imag(input(i)) > 0)
            out(index+1) = 1;
        else
            out(index+1) = 0;
        end
    end
end

