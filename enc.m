function x = enc(bits)

   % number of bits to send; 'bits' should be a column vector of
   % this size
   numbits = 24;
   % power constraint
   P = 1/4;
   % time constant of the channel: approx. number of nonzero samples
   % in the impulse response
   K = 250;

   % the length of our transmission. After sending one bit, we
   % wait for the channel to settle down before sending another,
   % so it takes numbits*K samples overall.
   n = numbits*K;

   % Construct the generic transmission pulse consisting of
   % an impulse whose amplitude is dictated by the power 
   % constraint, followed by K-1 zeros.
   pulse = (n*P/numbits)^.5*[1; zeros(K-1,1)];

   % Build the transmitted signal. We send a +/- impulse, 
   % with amplitude dictated by the power constraint, for
   % each bit. Between pulses, we send K-1 zeros for the
   % channel to settle down.
   x = [];
   for i = 1:numbits,
      x = [x; pulse*(2*bits(i) - 1)];
   end

return 
