function [x] = enc(bits, prepend, ignore)
    % Don't need special sync symbols at the beginning because commcloud is
    % high SNR. Can get the start of the signal by inspecting power
   
   % power constraint and number of bits in total
   numbits = length(bits);
   P = 0.00125/((numbits+10)/(numbits+ignore));
   
   % Create the training signal
   % Might not need training crap in the freq region that we don't use
   % This will lower power usage
   rng(4670);
   randphase = rand([1, numbits]) - 0.5;
   TR = [sqrt(P)*exp(1i*randphase*2*pi) zeros(1, ignore)];
   TR_DC = [0 TR];
   TR_full = [TR_DC flip(conj(TR))];
   tr = sqrt(length(TR_full))*ifft(TR_full);
   tr_prepend = [tr(end-prepend+1:end) tr];
   
   % OOK for both real and imaginary parts
   X1_ook = bits*sqrt(2*P);
   
   % Append 0s in the freq domain so we don't use freq above 18.375khz
   % TODO: this is hardcoded right now, need to be change to an eqn
   X1_ook = [X1_ook.*exp(1i*randphase*2*pi) zeros(1, ignore)];
   
   % Pad 0 for DC and append 0 if length of X1_ook is even
   X1_ook_DC = [0 X1_ook];
   
   % Append flipped conjugate so that time domain is purely real
   X1_ook_DC_full = [X1_ook_DC flip(conj(X1_ook))];
   
   % iDFT to get X1 in time domain
   X1_td = sqrt(length(X1_ook_DC_full))*ifft(X1_ook_DC_full);

   % Prepend
   X1_td_prep = [X1_td(end-prepend+1:end) X1_td];
   
   x = [tr_prepend zeros(1, 300) X1_td_prep]; % May not need that zero pad in the middle
   %We need to create a wav file from x. Spec'd by project.
   %audiowrite('tx.wav', x, 44100, 'BitsPerSample', K);
return 
