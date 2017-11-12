function [ output ] = chansim( input )
%CHANSIM Summary of this function goes here
%   Detailed explanation goes here

    % Load impulse response
	load('IR0.mat','impulse');
    
    % Convolve input signal with impulse response
    afterfilter = conv(impulse, input);
    
    % Add white noise
    snr = 100;
    output = awgn(afterfilter, snr);
end

