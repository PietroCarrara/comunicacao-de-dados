function [out] = decode_qam(input)
    % Tabela 17-15 do IEEE 802.11
    TABLE = [-7 -5 -1 -3 7 5 1 3];
    out = zeros(1, length(input)*6);
    
    input = slice_qam(input);
    
    for i = 1:length(input)
        index = (i-1)*6 + 1;
        
        x = real(input(i));
        y = imag(input(i));
        
        x_index = find(x == TABLE)-1; % index-1 to make the index zero-based
        y_index = find(y == TABLE)-1;
        
        part1 = dec2binvec(x_index(1), 3);
        part2 = dec2binvec(y_index(1), 3);
        
        out(index:index+5) = [fliplr(part1) fliplr(part2)];
    end
end