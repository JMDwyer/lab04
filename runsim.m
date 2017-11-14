load('bits.mat')

bits = bits(1:20000);

prepend = 300;

% Encode bits
[encoded, randphase] = enc(bits, prepend);
plot(encoded)
power = (1/length(encoded))*sum(encoded.^2)
% Clip the signal
% encoded(encoded>1) = 1;
% encoded(encoded<-1) = -1;

% Send through channel
%afterchan = chansim(encoded);

Fs = 44100;
audiowrite('encoded.wav', encoded, Fs, 'BitsPerSample', 24);
!ccplay encoded.wav afterchan.wav --channel audio0 --depth 24 --rate 44100
[afterchan, Fs0] = audioread('afterchan.wav');

% Find the starting index
found = 0;
start_idx = 1;
while found == 0
    if abs(afterchan(start_idx)) > 0.0001
        found = 1;
    else
        start_idx = start_idx + 1;
    end
end
afterchan = afterchan(start_idx:start_idx + length(encoded));
afterchan = afterchan';

% Decode
decoded = dec(afterchan, randphase, prepend);

correct = sum(decoded == bits)
