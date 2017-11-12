function outbits = dec(y)
 numbits = 200000;

 %Power constraint
 P=1/4;
 %skinny version of the decoder
 
 %take DFT of the recieved signal
 Y = dft(y);
 
 %remove bottom half
 Y = Y(1:end/2);
 
 %Drop DC component
 Y = Y(2:end-1);
 
 %ADD LAMBDA HERE
 
 %DECODE REAL AND IMAG COMPONENTS
 boundary = sqrt(P/2);
 outbits = zeros(1, numbits);
 for i = (1:length(Y))
    if((real(Y(i)) >= boundary)&&(imag(Y(i))>= boundary))
        outbits(i*2 - 1) = 1;
        outbits(i*2) = 1;
    end 
    if((real(Y(i)) >= boundary)&&(imag(Y(i))<= boundary))
        outbits(i*2 - 1) = 1;
        outbits(i*2) = 0;
    end 
    if((real(Y(i)) <= boundary)&&(imag(Y(i))>= boundary))
        outbits(i*2 - 1) = 0;
        outbits(i*2) = 1;
    end 
    if((real(Y(i)) <= boundary)&&(imag(Y(i))<= boundary))
        outbits(i*2 - 1) = 0;
        outbits(i*2) = 0;
    end 
 end    

end
