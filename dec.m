function outbits = dec()
    % Number of total bits
    numbits = 200000;
    
    % Length of the encoded signal (hardcoded)
    enclen = 530053;

    % The number of bits per symbol
    BPS = 4000;
    
    % Number of data symbols per training symbol and # of training symbols
    SPTS = 20;
    TS = ceil(numbits/BPS/SPTS);
    
    % The number of zeros to append in freq domain for a cut off of 18kHz
    ignore = ceil(BPS/18000*(22050-18000));
    
    % Number of samples to prepend
    prepend = 200;
    
    %Power constraint
    P = 0.00125/((BPS + prepend/2)/(BPS+ignore + prepend/2));
    
    % Calculate the # of symboles, amount of padding in last symbol, and
    % the number of samples per symbol
    lastsympad = mod(numbits, BPS);
    SPS = (BPS+ignore)*2 + 1 + prepend;
    
    % Generate the random phases
    rng(4670);
    randphase = rand([1, BPS]);
    
    [afterchan, ~] = audioread('rx.wav');
    y = afterchan';
    
    % Find the starting index and truncate the initial zeros
    if length(y) > enclen
        found = 0;
        start_idx = 1;
        while found == 0
            if abs(y(start_idx)) > 0.0003
                found = 1;
            else
                start_idx = start_idx + 1;
            end
        end
        y = y(start_idx:start_idx + enclen);
    end
    
    % Decode each symbol
    outbits = zeros(1, numbits+lastsympad);
    for t = 1:TS
        if t*SPS*(SPTS + 1) > length(y)
            symsty = y(((t-1)*SPS*(SPTS + 1)+1):end);
            SPTS_adj = length(symsty)/SPS - 1;
        else
            symsty = y(((t-1)*SPS*(SPTS + 1)+1):t*SPS*(SPTS + 1));
            SPTS_adj = SPTS;
        end
        
        % Extract the training and data samples
        tr = symsty(1:SPS);
        symsy = symsty(SPS+1:end);

        % Remove prepends
        tr = tr(prepend + 1:end);

        % Decode the training symbols
        TR = 1/sqrt(length(tr))*fft(tr);
        TR = TR(2:ceil(end/2) - ignore);
        lambda = TR./(sqrt(P)*exp(1i*randphase*2*pi));
        
        for i = 1:SPTS_adj
            % Extract one symbol
            symy = symsy(((i-1)*SPS+1):i*SPS);

            % Remove prepends
            symy = symy(prepend + 1:end);

            %take DFT of the recieved signal
            Y = 1/sqrt(length(symy))*fft(symy);

            %remove bottom half
            Y = Y(1:ceil(end/2));

            %Drop DC component
            Y = Y(2:end);

            % Drop the high freq components (above 18kHz)
            Y = Y(1:end - ignore);

            % Remove channel effects
            Y = Y./lambda;

            % Remove the random phase
            Y = Y./exp(1i*randphase*2*pi);

            % Decode OOK
            boundary = sqrt(P/2);
            for j = (1:BPS)
                if((abs(Y(j)) >= boundary))
                    outbits(((t-1)*SPTS + i-1)*BPS + j) = 1;
                else
                    outbits(((t-1)*SPTS + i-1)*BPS + j) = 0;
                end
            end
        end
    end
    outbits = (outbits(1:numbits))';

end
