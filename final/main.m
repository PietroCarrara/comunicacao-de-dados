clear;
close;

NUM_BITS = 1000000;                                                        % número de bits a serem simulados
QPSK_DATA = complex(2*randi(2, 1, NUM_BITS)-3, 2*randi(2, 1, NUM_BITS)-3); % bits aleatórios modulados em QPSK (partes em 1 e -1)
QAM_DATA = complex(2*randi(8, 1, round(NUM_BITS/6))-9, 2*randi(8, 1, round(NUM_BITS/6))-9);  % bits aleatórios modulados em 64QAM (valores ímpares entre 7 e -7) 

Eb_N0_dB = 0:1:9;                % faixa de Eb/N0
Eb_N0_lin = 10 .^ (Eb_N0_dB/10); % faixa de Eb/N0 linearizada

QPSK_BER = zeros(size(Eb_N0_lin));                                      % pré-alocação do vetor de BER
QAM_BER = zeros(size(Eb_N0_lin));
ENERGY_PER_BIT_QPSK = 1;                                                % energia por bit para a modulação QPSK utilizada
ENERGY_PER_BIT_QAM = mean((real(QAM_DATA).^2 + imag(QAM_DATA).^2)) / log2(64); % energia média por bit do QAM (x^2 + y^2 = tamanho_do_vetor^2)

NP_QPSK = ENERGY_PER_BIT_QPSK ./ (Eb_N0_lin); % vetor de potências do ruído
NA_QPSK = sqrt(NP_QPSK);                      % vetor de amplitudes do ruído
NP_QAM = ENERGY_PER_BIT_QAM ./ (Eb_N0_lin);
NA_QAM = sqrt(NP_QAM);

for i = 1:length(Eb_N0_lin)
    % QPSK
    n = NA_QPSK(i)*complex(randn(1, NUM_BITS), randn(1, NUM_BITS))*sqrt(0.5); % vetor de ruído complexo com desvio padrão igual a uma posição do vetor NA
    r = QPSK_DATA + n;                                                        % vetor recebido
    QPSK_DEMOD = complex(sign(real(r)), sign(imag(r)));                       % QPSK: corrige a informação pra compensar pelo ruido (pode ser que corrija errado)
    QPSK_BER(i) = sum(QPSK_DATA ~= QPSK_DEMOD) / NUM_BITS;                    % contagem de erros e cálculo do BER

    % 64-QAM
    n = NA_QAM(i)*complex(randn(1, round(NUM_BITS/6)), randn(1, round(NUM_BITS/6)))*sqrt(0.5); % vetor de ruído complexo com desvio padrão igual a uma posição do vetor NA
    r = QAM_DATA + n;                                                        % vetor recebido
    QAM_DEMOD = slice_qam(r);                                                % 64-QAM: corrige a informação pra compensar pelo ruido (pode ser que corrija errado)
    QAM_BER(i) = sum(QAM_DATA ~= QAM_DEMOD) / NUM_BITS;                % contagem de erros e cálculo do BER
end

% QPSK_BER_THEORETICAL = erfc(sqrt(2*Eb_N0_lin)/sqrt(2)); % BER teórico para comparação
% semilogy(Eb_N0_dB, QPSK_BER, 'x', Eb_N0_dB, QPSK_BER_THEORETICAL, 'r', 'LineWidth', 2, 'MarkerSize', 10);
QAM_BER_THEORETICAL = 2/log2(64) * (1 - (1/sqrt(64))) * erfc(sqrt((3*log2(64)/(2*(64-1)))*Eb_N0_lin)); % BER teórico para comparação (https://www.etti.unibw.de/labalive/experiment/qam/)
semilogy(Eb_N0_dB, QAM_BER, 'x', Eb_N0_dB, QAM_BER_THEORETICAL, 'r', 'LineWidth', 2, 'MarkerSize', 10);

xlabel('Eb/N0 (dB)');
ylabel('BER');
legend('Simulado','Teórico');
