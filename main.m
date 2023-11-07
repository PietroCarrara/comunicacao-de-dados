clear;
close all;

% Simulation conditions
SAMPLING_FREQUENCY = 100;
BIT_DURATION       = 1;
BIT_COUNT          = 12;
CARRIER_FREQUENCY  = 10;
DATA               = randi(2, 3*60) - 1; % Random stream of bits

% Derivative constants
SAMPLING_PERIOD = 1 / SAMPLING_FREQUENCY;
TIME            = 0:SAMPLING_PERIOD:(BIT_COUNT * BIT_DURATION - SAMPLING_PERIOD); % Discretization of the time array
FFT_POINT_COUNT = 2^nextpow2(length(TIME)); % Number of points to sample while computing the fourier transform
FREQUENCY_ARRAY = SAMPLING_FREQUENCY / 2*linspace(-1, 1, FFT_POINT_COUNT); % Frequency array (for frequency-domain signals)

% Assertions
assert(mod(length(DATA), 3) == 0, 'Data must have a number of elements that are multiple of 3');

% Part 1: Encoding each 3 symbols of the data into two signals
for i = 1:length(DATA)/3
    bit0 = DATA(i*3-2);
    bit1 = DATA(i*3-1);
    bit2 = DATA(i*3-0);
    [ENCODED_I(i), ENCODED_Q(i)] = encode_8psk(bit0, bit1, bit2);
end
% Plot the resulting streams
plot(ENCODED_I, 'b'); hold on; plot(ENCODED_Q, 'r'); hold off;
