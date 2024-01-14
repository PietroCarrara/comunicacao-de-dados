clear;
close all;

% Simulation conditions
SAMPLING_FREQUENCY = 100;
CHIPS_PER_BIT      = 1;
BIT_DURATION       = 1;
BIT_COUNT          = 8;

% Derivative constants
SAMPLING_PERIOD = 1 / SAMPLING_FREQUENCY;
TIME            = 0:SAMPLING_PERIOD:(BIT_COUNT * BIT_DURATION - SAMPLING_PERIOD); % Discretization of the time array
FFT_POINT_COUNT = 2^nextpow2(length(TIME)); % Number of points to sample while computing the fourier transform

% Part 1+2: Generate original data and spread it
DATA = randi(2, 4, BIT_COUNT) * 2 - 3; % Random stream of bits for 4 users (1 is 1, 0 is -1)
WALSH = hadamard(4);
for j = 1:4
    walsh = WALSH(j, :);

    for i = 1:length(TIME)
        current_bit = TIME(i) / BIT_DURATION + 1;
        sampling_segment = floor(current_bit);
        bit_progress = current_bit - sampling_segment; % From 0 to 1, how done are we with the current bit
        chip_segment = floor(bit_progress*CHIPS_PER_BIT*length(walsh));

        bit = DATA(j, sampling_segment);
        seq_bit = walsh(mod(chip_segment, length(walsh))+1);

        TIME_DATA(j, i) = bit;
        SPREAD_DATA(j, i) = bit * seq_bit;
    end
end

% Part 3: Generating frequency-domain data
for i = 1:4
    ORIGINAL_IN_FREQUENCY(i, :) = real(fftshift(fftshift(fft(TIME_DATA(i, :), FFT_POINT_COUNT))));
    SPREAD_IN_FREQUENCY(i, :) = real(fftshift(fftshift(fft(SPREAD_DATA(i, :), FFT_POINT_COUNT))));
end

% Part 4: recovering the bits
TRANSMITTED_DATA = SPREAD_DATA(1, :) + SPREAD_DATA(2, :) + SPREAD_DATA(3, :) + SPREAD_DATA(4, :);
for j = 1:4
    walsh = WALSH(j, :);
    code_size = length(walsh);
    % these values will sum <code_size> received bits together
    % in order to decode the CDMA
    accum = 0;
    accum_i = 1;

    for i = 1:length(TIME)
        current_bit = TIME(i) / BIT_DURATION + 1;
        sampling_segment = floor(current_bit);
        bit_progress = current_bit - sampling_segment; % From 0 to 1, how done are we with the current bit
        chip_segment = floor(bit_progress*CHIPS_PER_BIT*length(walsh));

        bit = SPREAD_DATA(j, i);
        seq_bit = walsh(mod(chip_segment, length(walsh))+1);

        accum = accum + bit*seq_bit;
        % once we've accumulated <code_size> bits together, fill the
        % resulting segment with them
        if mod(i, code_size) == 0
            RECEIVED_DATA(j, accum_i:accum_i+code_size-1) = accum;
            accum = 0;
            accum_i = accum_i+code_size;
        end
    end
end

% Plotting
figure(1);
tiledlayout(4, 1);
for i = 1:4
    nexttile;
    plot(TIME_DATA(i, :), 'b');
    title(['TIME\_DATA[' num2str(i) ']']);
end
figure(2);
tiledlayout(4, 1);
for i = 1:4
    nexttile;
    plot(SPREAD_DATA(i, :), 'b');
    title(['SPREAD\_DATA[' num2str(i) ']']);
end
figure(3);
tiledlayout(4, 1);
for i = 1:4
    nexttile;
    plot(ORIGINAL_IN_FREQUENCY(i, :), 'b');
    title(['ORIGINAL\_IN\_FREQUENCY[' num2str(i) ']']);
end
figure(4);
tiledlayout(4, 1);
for i = 1:4
    nexttile;
    plot(SPREAD_IN_FREQUENCY(i, :), 'b');
    title(['SPREAD\_IN\_FREQUENCY[' num2str(i) ']']);
end
figure(5);
plot(TRANSMITTED_DATA, 'b');
title('TRANSMITTED\_DATA');
figure(6);
tiledlayout(4, 1);
for i = 1:4
    nexttile;
    plot(RECEIVED_DATA(i, :), 'b');
    title(['RECEIVED\_DATA[' num2str(i) ']']);
end
