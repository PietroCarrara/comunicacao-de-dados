function [ out ] = slice_qpsk( input )
    out = complex(sign(real(input)), sign(imag(input)));
end

