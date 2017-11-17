load('bits.mat')

bits = bits';

% Encode bits
[encoded] = enc(bits);
power = (1/length(encoded))*sum(encoded.^2)
powerperc = power/0.00125

% Send through channel
%afterchan = chansim(encoded);

Fs = 44100;
system('ccplay tx.wav rx.wav --prepause 0.27 --channel audio0 --depth 24 --rate 44100');

% Decode
decoded = dec();

correct = sum(decoded == bits)
R = length(bits)/(length(encoded)/Fs);
N = (length(bits) - correct)*200000/length(bits);
P = power;
fom = (min(R, 3000000)*(1-N/100000)^10)/max(1,800*P)
