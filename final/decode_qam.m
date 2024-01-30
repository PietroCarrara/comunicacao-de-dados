function [out] = decode_qam(input)
    % Tabela 17-15 do IEEE 802.11
    VALUES = [ 0 1 3 2 6 7 5 4 ];
    out = zeros(1, length(input)*6);

    for i = 1:length(input)
        index = (i-1)*6 + 1;

        x = max(min(real(input(i))+7, 14), 0); % maintain range in [0, 14] (it's [-7, 7] + 7 to be 0-based)
        y = max(min(imag(input(i))+7, 14), 0); % maintain range in [0, 14] (it's [-7, 7] + 7 to be 0-based)

        x = x / 14; % convert range to [0, 1]
        y = y / 14; % convert range to [0, 1]

        x_index = x*7+1;
        y_index = y*7+1;

        prev_x = floor(x_index);
        prev_y = floor(y_index);
        next_x = ceil(x_index);
        next_y = ceil(y_index);

        prev_x_weight = 1 - (x_index - prev_x);
        next_x_weight = 1 - prev_x_weight;
        prev_y_weight = 1 - (y_index - prev_y);
        next_y_weight = 1 - prev_y_weight;

        part1 = dec2binvec(VALUES(prev_x), 3)*prev_x_weight + dec2binvec(VALUES(next_x), 3)*next_x_weight;
        part2 = dec2binvec(VALUES(prev_y), 3)*prev_y_weight + dec2binvec(VALUES(next_y), 3)*next_y_weight;

        out(index:index+5) = [fliplr(part1) fliplr(part2)];
    end
end