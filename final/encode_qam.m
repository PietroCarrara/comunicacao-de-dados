function [ out ] = encode_qam(bits)
    % Implementa a tabela 17-15 do IEEE 802.11
    TABLE = [-7 -5 -1 -3 7 5 1 3];
    
    % Transforma o vetor linha de bits em uma matriz onde cada linha tem 3 bits
    BIN_VECS = reshape(bits, 3, []).'; 
    
    % Transforma a matriz de bits em uma matriz de índices de duas colunas, uma real e outra imaginaria
    INDEXES = reshape(bi2de(BIN_VECS, 'left-msb'), 2, []).' + 1;
    
    % Obtem os valores para a parte real e imaginaria, cada uma em uma coluna, de acordo com a tabela 17-15
    VALUES = TABLE(INDEXES); 
        
    % Combina as duas colunas de valores em um vetor linha de numeros complexos
    out = complex(VALUES(:,1), VALUES(:,2)).';
end
