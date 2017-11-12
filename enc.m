function x = enc(bits)
   
   % power constraint and number of bits in total
   P = 1/4;
   numbits = length(bits);
   
   % OOK for both real and imaginary parts
   X1_ook = zeros(1, numbits/2);
   for i = 1:(numbits/2)
       X1_ook(i) = bits(i*2-1)*sqrt(2*P) + 1i*bits(i*2)*sqrt(2*P);
   end
   
   % Pad 0 for DC and append 0 if length of X1_ook is even
   if mod(length(X1_ook), 2) == 0
       X1_ook_DC = [0 X1_ook 0];
   else
       X1_ook_DC = [0 X1_ook];
   end
   
   % Append flipped conjugate so that time domain is purely real
   X1_ook_DC_full = [X1_ook_DC flip(conj(X1_ook_DC))];
   
   % iDFT to get X1 in time domain
   X1_td = ifft(X1_ook_DC_full, 'symmetric');

   x = X1_td;
   %We need to create a wav file from x. Spec'd by project.
   %audiowrite('tx.wav', x, 44100, 'BitsPerSample', K);
return 
