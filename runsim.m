load('bits.mat')

prepend = 300;

% Encode bits
[encoded, randphase] = enc(bits, prepend);

% Clip the signal
encoded(encoded>1) = 1;
encoded(encoded<-1) = -1;

% Send through channel
afterchan = chansim(encoded);

% Decode
decoded = dec(afterchan, randphase, prepend);

correct = sum(decoded == bits)
power = (1/length(encoded))*sum(encoded.^2)