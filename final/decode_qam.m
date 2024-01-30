function [out] = decode_qam(input)    
    % Tabela 17-15 do IEEE 802.11
    VALUES = [ 0 1 3 2 6 7 5 4 ];
    
    % maintain range in [0, 14] (it's [-7, 7] + 7 to be 0-based)
    x = max(min(real(input) + 7, 14), 0); 
    y = max(min(imag(input) + 7, 14), 0);
    
    % convert range to [0, 1]
    x = x / 14;
    y = y / 14;
    
    % indexes range is [1, 8]
    x_index = x * 7 + 1;
    y_index = y * 7 + 1;
    
    % determine indexes for soft decoding
    prev_x = floor(x_index);
    prev_y = floor(y_index);
    next_x = ceil(x_index);
    next_y = ceil(y_index);

    % determine index weights for soft decoding
    prev_x_weight = 1 - (x_index - prev_x);
    next_x_weight = 1 - prev_x_weight;
    prev_y_weight = 1 - (y_index - prev_y);
    next_y_weight = 1 - prev_y_weight;
    
    % get binary sequences for indexed values and multiply by weights
    part1 = de2bi(VALUES(prev_x), 'left-msb') .* repmat(prev_x_weight.', 1, 3) + de2bi(VALUES(next_x), 'left-msb') .* repmat(next_x_weight.', 1, 3);
    part2 = de2bi(VALUES(prev_y), 'left-msb') .* repmat(prev_y_weight.', 1, 3) + de2bi(VALUES(next_y), 'left-msb') .* repmat(next_y_weight.', 1, 3);
    
    % concatenate real and imaginary parts
    out = [part1, part2];
    
    % concatenate matrix lines into single line of bits
    out = out.';
    out = out(:).';
end