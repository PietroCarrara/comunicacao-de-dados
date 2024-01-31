clear;
close;

NUM_BITS = 100008;
RAW_DATA = randi(2, 1, NUM_BITS)-1;

assert(mod(NUM_BITS, 4) == 0 && mod(NUM_BITS, 6) == 0, 'Para poder fazer puncturing, especifique uma quantidade de bits válida');

% https://sci-hub.se/10.1109/TCOM.1984.1096047
TWO_THIRDS_PUNCTURE = [1 0 1 1];
THREE_FOURTHS_PUNCTURE = [1 1 0 1 0 1];
TRELLIS = poly2trellis(7, [171 133]);
CONV_DATA_2_3 = convenc(RAW_DATA, TRELLIS, TWO_THIRDS_PUNCTURE);
CONV_DATA_3_4 = convenc(RAW_DATA, TRELLIS, THREE_FOURTHS_PUNCTURE);

QPSK_DATA = encode_qpsk(RAW_DATA);
QAM_DATA = encode_qam(RAW_DATA);

CONV_QPSK_DATA_2_3 = encode_qpsk(CONV_DATA_2_3);
CONV_QAM_DATA_2_3 = encode_qam(CONV_DATA_2_3);
CONV_QPSK_DATA_3_4 = encode_qpsk(CONV_DATA_3_4);
CONV_QAM_DATA_3_4 = encode_qam(CONV_DATA_3_4);

Eb_N0_dB = 1:12;                % faixa de Eb/N0
Eb_N0_lin = 10 .^ (Eb_N0_dB/10); % faixa de Eb/N0 linearizada

% Pré-alocações
QPSK_BER = zeros(size(Eb_N0_lin));
QAM_BER = zeros(size(Eb_N0_lin));
CONV_2_3_QPSK_BER = zeros(size(Eb_N0_lin));
CONV_2_3_QAM_BER = zeros(size(Eb_N0_lin));
CONV_3_4_QPSK_BER = zeros(size(Eb_N0_lin));
CONV_3_4_QAM_BER = zeros(size(Eb_N0_lin));

ENERGY_PER_BIT_QPSK = sqrt(2)^2 / 2; % energia por bit para a modulação QPSK utilizada
ENERGY_PER_BIT_QAM = mean((real(QAM_DATA).^2 + imag(QAM_DATA).^2)) / log2(64); % energia média por bit do QAM (x^2 + y^2 = tamanho_do_vetor^2)

NP_QPSK = ENERGY_PER_BIT_QPSK ./ (Eb_N0_lin); % vetor de potências do ruí­do
NA_QPSK = sqrt(NP_QPSK);                      % vetor de amplitudes do ruí­do
NP_QAM = ENERGY_PER_BIT_QAM ./ (Eb_N0_lin);
NA_QAM = sqrt(NP_QAM);

for i = 1:length(Eb_N0_lin)
    % QPSK
    n = NA_QPSK(i)*complex(randn(1, length(QPSK_DATA)), randn(1, length(QPSK_DATA)))*sqrt(0.5);
    r = QPSK_DATA + n;
    QPSK_DEMOD = decode_qpsk(slice_qpsk(r));
    QPSK_BER(i) = sum(RAW_DATA ~= QPSK_DEMOD(1:length(RAW_DATA))) / length(RAW_DATA);

    % 64-QAM
    n = NA_QAM(i)*complex(randn(1, length(QAM_DATA)), randn(1, length(QAM_DATA)))*sqrt(0.5);
    r = QAM_DATA + n;
    QAM_DEMOD = decode_qam(slice_qam(r));
    QAM_BER(i) = sum(RAW_DATA ~= QAM_DEMOD(1:length(RAW_DATA))) / length(RAW_DATA);

    % QPSK + convolution coding 2/3
    n = NA_QPSK(i)*complex(randn(1, length(CONV_QPSK_DATA_2_3)), randn(1, length(CONV_QPSK_DATA_2_3)))*sqrt(0.5);
    r = CONV_QPSK_DATA_2_3 + n;
    % QPSK_DEMOD = vitdec(decode_qpsk(slice_qpsk(r)), TRELLIS, 32, 'trunc', 'hard', TWO_THIRDS_PUNCTURE); % hard decoding
    QPSK_DEMOD = vitdec(round(decode_qpsk(r)*255), TRELLIS, 32, 'trunc', 'soft', 8, TWO_THIRDS_PUNCTURE); % soft decoding
    CONV_2_3_QPSK_BER(i) = sum(RAW_DATA ~= QPSK_DEMOD(1:length(RAW_DATA))) / length(RAW_DATA);

    % 64-QAM + convolution coding 2/3
    n = NA_QAM(i)*complex(randn(1, length(CONV_QAM_DATA_2_3)), randn(1, length(CONV_QAM_DATA_2_3)))*sqrt(0.5);
    r = CONV_QAM_DATA_2_3 + n;
    % CONV_QAM_DEMOD = vitdec(decode_qam(slice_qam(r)), TRELLIS, 32, 'trunc', 'hard', TWO_THIRDS_PUNCTURE); % hard encoding
    CONV_QAM_DEMOD = vitdec(round(decode_qam(r)*255), TRELLIS, 32, 'trunc', 'soft', 8, TWO_THIRDS_PUNCTURE); % soft encoding
    CONV_2_3_QAM_BER(i) = sum(CONV_QAM_DEMOD(1:length(RAW_DATA)) ~= RAW_DATA) / length(RAW_DATA);

    % QPSK + convolution coding 3/4
    n = NA_QPSK(i)*complex(randn(1, length(CONV_QPSK_DATA_3_4)), randn(1, length(CONV_QPSK_DATA_3_4)))*sqrt(0.5);
    r = CONV_QPSK_DATA_3_4 + n;
    % QPSK_DEMOD = vitdec(decode_qpsk(slice_qpsk(r)), TRELLIS, 32, 'trunc', 'hard', THREE_FOURTHS_PUNCTURE); % hard decoding
    QPSK_DEMOD = vitdec(round(decode_qpsk(r)*255), TRELLIS, 32, 'trunc', 'soft', 8, THREE_FOURTHS_PUNCTURE); % soft decoding
    CONV_3_4_QPSK_BER(i) = sum(RAW_DATA ~= QPSK_DEMOD(1:length(RAW_DATA))) / length(RAW_DATA);

    % 64-QAM + convolution coding 3/4
    n = NA_QAM(i)*complex(randn(1, length(CONV_QAM_DATA_3_4)), randn(1, length(CONV_QAM_DATA_3_4)))*sqrt(0.5);
    r = CONV_QAM_DATA_3_4 + n;
    % CONV_QAM_DEMOD = vitdec(decode_qam(slice_qam(r)), TRELLIS, 32, 'trunc', 'hard', THREE_FOURTHS_PUNCTURE); % hard encoding
    CONV_QAM_DEMOD = vitdec(round(decode_qam(r)*255), TRELLIS, 32, 'trunc', 'soft', 8, THREE_FOURTHS_PUNCTURE); % soft encoding
    CONV_3_4_QAM_BER(i) = sum(CONV_QAM_DEMOD(1:length(RAW_DATA)) ~= RAW_DATA) / length(RAW_DATA);
end

QPSK_BER_THEORETICAL = erfc(sqrt(2*Eb_N0_lin)/sqrt(2)); % BER teÃ³rico para comparaÃ§Ã£o
QAM_BER_THEORETICAL = 2/log2(64) * (1 - (1/sqrt(64))) * erfc(sqrt((3*log2(64)/(2*(64-1)))*Eb_N0_lin)); % BER teórico para comparação (https://www.etti.unibw.de/labalive/experiment/qam/)

semilogy(...
    Eb_N0_dB, CONV_2_3_QPSK_BER, 'b+', ...
    Eb_N0_dB, CONV_2_3_QAM_BER, 'r+', ...
    Eb_N0_dB, CONV_3_4_QPSK_BER, 'b*', ...
    Eb_N0_dB, CONV_3_4_QAM_BER, 'r*', ...
    ...%Eb_N0_dB, QPSK_BER, 'bx', ...
    ...%Eb_N0_dB, QAM_BER, 'rx', ...
    Eb_N0_dB, QAM_BER_THEORETICAL, 'r:', ...
    Eb_N0_dB, QPSK_BER_THEORETICAL, 'b:', ...
    'LineWidth', 2, 'MarkerSize', 10 ...
);

xlabel('Eb/N0 (dB)');
ylabel('Bit Error Rate (BER)');
legend(...
    'qpsk conv 2/3',...
    'qam conv 2/3',...
    'qpsk conv 3/4',...
    'qam conv 3/4',...
    ...%'qpsk',...
    ...%'qam',...
    'qam ter.',...
    'qpsk ter.',...
    'Location', 'southwest'...
);

figure;

FRAME_SIZE = 2300*8; % 2300 bytes
plot(...
    Eb_N0_dB, 1-(1-CONV_2_3_QPSK_BER).^FRAME_SIZE, 'b+', ...
    Eb_N0_dB, 1-(1-CONV_2_3_QAM_BER).^FRAME_SIZE, 'r+', ...
    Eb_N0_dB, 1-(1-CONV_3_4_QPSK_BER).^FRAME_SIZE, 'b*', ...
    Eb_N0_dB, 1-(1-CONV_3_4_QAM_BER).^FRAME_SIZE, 'r*', ...
    ...%Eb_N0_dB, 1-(1-QPSK_BER).^FRAME_SIZE, 'bx', ...
    ...%Eb_N0_dB, 1-(1-QAM_BER).^FRAME_SIZE, 'rx', ...
    ...%Eb_N0_dB, 1-(1-QAM_BER_THEORETICAL).^FRAME_SIZE, 'r:', ...
    ...%Eb_N0_dB, 1-(1-QPSK_BER_THEORETICAL).^FRAME_SIZE, 'b:', ...
    'LineWidth', 2, 'MarkerSize', 10 ...
);

xlabel('Eb/N0 (dB)');
ylabel('Frame Error Rate (FER)');
legend(...
    'qpsk conv 2/3',...
    'qam conv 2/3',...
    'qpsk conv 3/4',...
    'qam conv 3/4',...
    ...%'qpsk',...
    ...%'qam',...
    ...%'qam ter.',...
    ...%'qpsk ter.',...
    'Location', 'southwest'...
);
