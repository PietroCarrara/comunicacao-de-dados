function [out] = slice_qam(symbol)
% Pega um n�mero vetor de n�meros complexos e retorna um vetor com os s�mbolos 64-QAM
% mais pr�ximos de cada entrada
    QAM_OPTIONS = [-7 -5 -3 -1  1  3  5  7];
    out = ones(size(symbol)) * complex(999, 999);
    min_dist = ones(size(symbol)) * Inf;
    for i = 1:length(QAM_OPTIONS)
        for j = 1:length(QAM_OPTIONS)
            x = QAM_OPTIONS(i);
            y = QAM_OPTIONS(j);

            dist = sqrt((real(symbol)-x).^2 + (imag(symbol)-y).^2);

            out(dist <= min_dist) = complex(x, y);
            min_dist(dist <= min_dist) = dist(dist <= min_dist);
        end
    end
end