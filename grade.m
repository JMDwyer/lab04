function perf = grade
   
    % The number of bits that are sent in each transmission
    numbits = 24;
    % The max duration of the transmission over all the runs, 
    % initialized to be 1.
    dur = 1;

    % Run 100 times to average over the randomness
    for i = 1:100,

    	% Generate bits to transmit
        bits = round(rand(numbits,1));

    	% Generate transmitted signal
        x = enc(bits);
        x = real(x(:,1));

        % Record the duration of the signal
        dur = max(dur,length(x));

    	% Compute average power
        Po(i) = x'*x/length(x);

    	% Run decoder
        outbits = dec(channel(x));

    	% Compute the number of bits successfuly sent
        incorrbits(i) = sum(bits ~= outbits);

    end

    % Compute the score from the formula in the assignment sheet
    R = numbits/dur;
    N = mean(incorrbits);
    P = mean(Po);
    perf = (min(R,numbits) * (1 - N/(numbits/2))^6)/max(1,4*P);

return
