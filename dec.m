function outbits = dec(y, prepend, numbits)
    % The number of bits per symbol
    BPS = 1000;
    
    % Number of data symbols per training symbol and # of training symbols
    SPTS = 10;
    TS = ceil(numbits/BPS/SPTS);
    
    % The number of zeros to append in freq domain for a cut off of 18kHz
    ignore = ceil(BPS/18000*(22050-18000));
    
    %Power constraint
    P = 0.00125/((BPS + prepend/2)/(BPS+ignore + prepend/2));
    
    % Calculate the # of symboles, amount of padding in last symbol, and
    % the number of samples per symbol
    symbols = ceil(numbits/BPS);
    lastsympad = mod(numbits, BPS);
    SPS = (BPS+ignore)*2 + 1 + prepend;
    
    % Generate the random phases
    rng(4670);
    randphase = rand([1, BPS]) - 0.5;
    
    % Decode each symbol
    outbits = zeros(1, numbits+lastsympad);
    for t = 1:TS
        if t*SPS*(SPTS + 1) > length(y)
            symsty = y(((t-1)*SPS*(SPTS + 1)+1):end);
            SPTS = length(symsty)/SPS;
        else
            symsty = y(((t-1)*SPS*(SPTS + 1)+1):t*SPS*(SPTS + 1));
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
        
        for i = 1:SPTS
            % Extract one symbol
            symy = symsy(((i-1)*SPS+1):i*SPS);

            % Remove prepends
            symy = symy(prepend + 1:end);

            % Decode the training symbols
            TR = 1/sqrt(length(tr))*fft(tr);
            TR = TR(2:ceil(end/2) - ignore);
            lambda = TR./(sqrt(P)*exp(1i*randphase*2*pi));

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
                if((real(Y(j)) >= boundary))
                    outbits(((t-1)*SPTS + i-1)*BPS + j) = 1;
                end 
                if((real(Y(j)) <= boundary))
                    outbits(((t-1)*SPTS + i-1)*BPS + j) = 0;
                end 
            end
        end
    end
    outbits = outbits(1:numbits);

end
