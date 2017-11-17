function [x] = enc(bits)
    % Don't need special sync symbols at the beginning because commcloud is
    % high SNR. Can get the start of the signal by inspecting power
    
    % Make into row vector
    bits = bits';
   
    % The number of bits per symbol
    BPS = 4000;
    
    % Number of data symbols per training symbol
    SPTS = 20;
    
    % The number of zeros to append in freq domain for a cut off of 18kHz
    ignore = ceil(BPS/18000*(22050-18000));
    
    % Number of samples to prepend
    prepend = 200;
    
    % power constraint and number of bits in total
    numbits = length(bits);
    P = 0.00125/((BPS + prepend/2)/(BPS+ignore + prepend/2));
    
    % Number of symbols to send and do any required padding
    symbols = ceil(numbits/BPS);
    lastsympad = mod(numbits, BPS);
    bits = [bits zeros(1, lastsympad)];
    
    % Generate the random phases
    rng(4670);
    randphase = rand([1, BPS]);
    
    % Create the training signal
    TR = [sqrt(P)*exp(1i*randphase*2*pi) zeros(1, ignore)];
    TR_DC = [0 TR];
    TR_full = [TR_DC flip(conj(TR))];
    tr = sqrt(length(TR_full))*ifft(TR_full);
    tr_prepend = [tr(end-prepend+1:end) tr];
    
    % Create the train of symbols
    x = [];
    for i = 1:symbols
        symbits = bits(((i-1)*BPS+1):i*BPS);

        % OOK for both real and imaginary parts
        X1_ook = symbits*sqrt(2*P);

        % Append 0s in the freq domain so we don't use freq above 18.375khz
        % TODO: this is hardcoded right now, need to be change to an eqn
        X1_ook = [X1_ook.*exp(1i*randphase*2*pi) zeros(1, ignore)];
        
        if i == 29
            X1_ook_out = X1_ook;
        end

        % Pad 0 for DC and append 0 if length of X1_ook is even
        X1_ook_DC = [0 X1_ook];

        % Append flipped conjugate so that time domain is purely real
        X1_ook_DC_full = [X1_ook_DC flip(conj(X1_ook))];

        % iDFT to get X1 in time domain
        X1_td = sqrt(length(X1_ook_DC_full))*ifft(X1_ook_DC_full);

        % Prepend
        X1_td_prep = [X1_td(end-prepend+1:end) X1_td];

        if mod(i-1, SPTS) == 0
            X1_td_full = [tr_prepend X1_td_prep];
        else
            X1_td_full = [X1_td_prep];
        end
        x = [x X1_td_full];
        %We need to create a wav file from x. Spec'd by project.
    end
    audiowrite('tx.wav', x, 44100, 'BitsPerSample', 24);
return 
