function outbits = dec(y, prepend, ignore, numbits)
    %Power constraint
    P = 0.00125/((numbits+10)/(numbits+ignore));
    
    %skinny version of the decoder
    
    % Split up the training and data
    tr = y(1:(numbits + ignore)*2 + 1 + prepend);
    y = y((numbits + ignore)*2 + 1 + prepend + 301:end);
    
    % Remove prepends
    tr = tr(prepend + 1:end);
    y = y(prepend + 1:end);
    
    % Decode the training symbols
    rng(4670);
    randphase = rand([1, numbits]) - 0.5;
    TR = 1/sqrt(length(tr))*fft(tr);
    TR = TR(2:ceil(end/2) - ignore);
    lambda = TR./(sqrt(P)*exp(1i*randphase*2*pi));

    %take DFT of the recieved signal
    Y = 1/sqrt(length(y))*fft(y);

    %remove bottom half
    Y = Y(1:ceil(end/2));

    %Drop DC component
    Y = Y(2:end);
    
    Y = Y(1:end - ignore);

%     %ADD LAMBDA HERE
%     load('IR0.mat', 'impulse')
%     impulse_padded = [impulse zeros(1, length(y) - length(impulse))];
%     lambda = 1/sqrt(length(impulse_padded))*fft(impulse_padded);
%     lambda = lambda(1:ceil(end/2));
%     lambda = lambda(2:end);
%     lambda_invang = -angle(lambda);
%     lambda_real = real(lambda.*exp(1i*lambda_invang));

%     %Remove phase shift
%     Y = Y.*exp(1i*lambda_invang);
% 
%     %Remove real gains
%     Y = Y./lambda_real;

    % Remove channel effects
    Y = Y./lambda;
    
    % Remove the random phase
    Y = Y./exp(1i*randphase*2*pi);

    %DECODE REAL AND IMAG COMPONENTS
    boundary = sqrt(P/2);
    outbits = zeros(1, numbits);
    for i = (1:numbits)
        if((real(Y(i)) >= boundary))
            outbits(i) = 1;
        end 
        if((real(Y(i)) <= boundary))
            outbits(i) = 0;
        end 
    end

end
