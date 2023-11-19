clear;
close all;

% Simulation conditions
SAMPLING_FREQUENCY = 100;
BIT_DURATION       = 1;
% CARRIER_FREQUENCY  = 10;
CARRIER_FREQUENCY  = 2;
% DATA               = randi(2, 3*3, 1) - 1; % Random stream of bits
% DATA = [0 0 0 0 0 1 0 1 0 0 1 1 1 0 0 1 0 1 1 1 0 1 1 1];
DATA = [0 0 0 0 0 1];
BIT_COUNT          = length(DATA);

% Derivative constants
SAMPLING_PERIOD = 1 / SAMPLING_FREQUENCY;
TIME            = 0:SAMPLING_PERIOD:(BIT_COUNT * BIT_DURATION - SAMPLING_PERIOD); % Discretization of the time array
FFT_POINT_COUNT = 2^nextpow2(length(TIME)); % Number of points to sample while computing the fourier transform
FREQUENCY_ARRAY = SAMPLING_FREQUENCY / 2*linspace(-1, 1, FFT_POINT_COUNT); % Frequency array (for frequency-domain signals)

% Setup plots
tiledlayout(3, 1);

% Assertions
assert(mod(length(DATA), 3) == 0, 'Data must have a number of elements that is multiple of 3');

% Part 1: Encoding each 3 symbols of the data into two signals
for i = 1:length(TIME)
    sampling_segment = floor(TIME(i) / BIT_DURATION / 3)+1;

    bit0 = DATA(sampling_segment*3-2);
    bit1 = DATA(sampling_segment*3-1);
    bit2 = DATA(sampling_segment*3-0);

    [ENCODED_I(i), ENCODED_Q(i)] = encode_8psk(bit0, bit1, bit2);
end
% Plot I and Q
nexttile;
plot(TIME, ENCODED_I, 'b');
title('I Component');
nexttile;
plot(TIME, ENCODED_Q, 'r');
title('Q Component');

% Part 2: Modulating the signal
MODULATED_FINAL = ENCODED_I .* cos(2*pi*CARRIER_FREQUENCY*TIME) - ENCODED_Q .* sin(2*pi*CARRIER_FREQUENCY*TIME);
nexttile;
plot(TIME, MODULATED_FINAL, 'black');
title('Carrier');

% The signal is flying through the network....
