function x = enc(bits)
   
   % power constraint
   P = 1/4;
   numbits = length(bits);
   %BITS ARE DIVIDED IN AUDIOWRITE
   %K is the bits/sample   
   K = 24;

   %OFDM STEPS
   %STEP 1, TAKE FFT OF BITS
   X_fft = fft(bits);
   
   %APPEND CYCLIC PREFIX

    
   %We need to create a wav file from x. Spec'd by project.
   audiowrite('tx.wav', x, 44100, 'BitsPerSample', K);
   
return 
