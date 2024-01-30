function [ out ] = encode_qam(bits)
    % Implementa a tabela 17-15 do IEEE 802.11
    TABLE = [-7 -5 -1 -3 7 5 1 3];

    out = zeros(1, ceil(length(bits)/6));
    for i = 1:length(out)
        index = (i-1)*6 + 1;
        index_final = min(index + 5, length(bits));

        seq = zeros(1, 6);

        seq(1:(index_final - index + 1)) = bits(index:index_final);

        out(i) = complex(TABLE(binvec2dec(fliplr(seq(1:3)))+1), TABLE(binvec2dec(fliplr(seq(4:6)))+1));
    end
end
