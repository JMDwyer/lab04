load('bits.mat')

numbits = 200000;
bits = bits(1:numbits);

prepend = 300;

% Encode bits
encoded = enc(bits, prepend);
plot(encoded)
power = (1/length(encoded))*sum(encoded.^2)
powerperc = power/0.00125

% Send through channel
%afterchan = chansim(encoded);

Fs = 44100;
audiowrite('tx.wav', encoded, Fs, 'BitsPerSample', 24);
system('ccplay tx.wav rx.wav --channel audio0 --depth 24 --rate 44100')
[afterchan, Fs0] = audioread('rx.wav');

% Find the starting index
found = 0;
start_idx = 1;
while found == 0
    if abs(afterchan(start_idx)) > 0.0003
        found = 1;
    else
        start_idx = start_idx + 1;
    end
end
afterchan = afterchan(start_idx:start_idx + length(encoded));
afterchan = afterchan';

% Decode
decoded = dec(afterchan, prepend, numbits);

correct = sum(decoded == bits)
R = length(bits)/(length(encoded)/Fs);
N = (length(bits) - correct)*200000/length(bits);
P = power;
fom = (min(R, 3000000)*(1-N/100000)^10)/max(1,800*P)
