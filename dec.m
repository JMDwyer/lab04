function outbits = dec(y)

   % number of bits to send; 'outbits' will be a column vector of
   % this size
   numbits = 24;

   % time constant of the channel: approx. number of nonzero samples
   % in the impulse response
   K = 250;

   % Generate the impulse response

   tmp = (0:K-1)';
   h = (-.99).^tmp;

   % Use the minimum-distance rule to decode each bit separately.
   outbits = [];

   for i = 1:numbits,
      outbits = [ outbits; (h'*y((i-1)*K+1:i*K) > 0)];
   end

end
