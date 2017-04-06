function g = glottalWav(akz, Rn)
% glottalWav - aims to calculate the glottal waveform based on prediction
% coefficients and short-time autocorrelation function
 % inputs
 % outputs

 % Calculating gain for waveform
 akzRn = 0;
 for k = 2:length(akz)
     akzRn = akzRn + akz(k)*Rn(k);
 end
 G = sqrt(Rn(1) - akzRn); % Calculation of G
 z = 
end