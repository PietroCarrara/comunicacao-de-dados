clear;
close all;

% Input data (choose one)
DATA = randi(2, 3*3, 1) - 1; % Random stream of bits
% DATA = [0 0 0 0 0 1 0 1 0 0 1 1 1 0 0 1 0 1 1 1 0 1 1 1];
% DATA = [0 0 0 0 0 1];


% Simulation conditions
SAMPLING_FREQUENCY = 100;
BIT_DURATION       = 1;
CARRIER_FREQUENCY  = 10;
BIT_COUNT          = length(DATA);

% Derivative constants
SAMPLING_PERIOD = 1 / SAMPLING_FREQUENCY;
TIME            = 0:SAMPLING_PERIOD:(BIT_COUNT * BIT_DURATION - SAMPLING_PERIOD); % Discretization of the time array
FFT_POINT_COUNT = 2^nextpow2(length(TIME)); % Number of points to sample while computing the fourier transform
FREQUENCY_ARRAY = SAMPLING_FREQUENCY / 2*linspace(-1, 1, FFT_POINT_COUNT); % Frequency array (for frequency-domain signals)

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
figure(1);
tiledlayout(2, 1);
nexttile;
plot(TIME, ENCODED_I, 'b');
title('I Component');
nexttile;
plot(TIME, ENCODED_Q, 'r');
title('Q Component');

% Part 2: Modulating the signal
figure(2);
MODULATED = ENCODED_I .* cos(2*pi*CARRIER_FREQUENCY*TIME) - ENCODED_Q .* sin(2*pi*CARRIER_FREQUENCY*TIME);
plot(TIME, MODULATED, 'black');
title('Carrier');

%
% The signal is flying through the network....
%

% Part 3: Receiving the signal
figure(3);
tiledlayout(2, 1);

DEMODULATED_I = MODULATED .* cos(2*pi*CARRIER_FREQUENCY*TIME);
nexttile;
plot(TIME, DEMODULATED_I, 'blue');
title('Demodulated I');

DEMODULATED_Q = MODULATED .* -sin(2*pi*CARRIER_FREQUENCY*TIME);
nexttile;
plot(TIME, DEMODULATED_Q, 'red');
title('Demodulated Q');

% Part 4: Filtering the received signal
figure(4);
tiledlayout(2, 1);
LEFT_CUTOFF = find(FREQUENCY_ARRAY>-CARRIER_FREQUENCY, 1);
RIGHT_CUTOFF = find(FREQUENCY_ARRAY>CARRIER_FREQUENCY, 1);

I_FREQUENCY = fftshift(fft(DEMODULATED_I, FFT_POINT_COUNT));
I_FREQUENCY(1:LEFT_CUTOFF) = 0;
I_FREQUENCY(RIGHT_CUTOFF:length(I_FREQUENCY)) = 0;
I_FREQUENCY = ifftshift(I_FREQUENCY);
I_FREQUENCY = real(ifft(I_FREQUENCY))*2;
I_FREQUENCY = I_FREQUENCY(1:length(DEMODULATED_I)); % Trim remaining data

nexttile;
plot(real(I_FREQUENCY), 'blue');
title('Filtered I');

Q_FREQUENCY = fftshift(fft(DEMODULATED_Q, FFT_POINT_COUNT));
Q_FREQUENCY(1:LEFT_CUTOFF) = 0;
Q_FREQUENCY(RIGHT_CUTOFF:length(Q_FREQUENCY)) = 0;
Q_FREQUENCY = ifftshift(Q_FREQUENCY);
Q_FREQUENCY = real(ifft(Q_FREQUENCY))*2;
Q_FREQUENCY = Q_FREQUENCY(1:length(DEMODULATED_Q)); % Trim remaining data

nexttile;
plot(real(Q_FREQUENCY), 'red');
title('Filtered Q');