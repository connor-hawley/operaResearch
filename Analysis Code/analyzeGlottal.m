function [g] = analyzeGlottal(fileName, start, ending, ldft)
%% analyzeGlottal - uses an interval of a larger waveform to estimate the 
% glottal waveform. A combination of lpcacm.m and glottalWav.m 
 % inputs:
  % fileName - string, input waveform file name
  % start - number, target beginning in seconds
  % ending - number, target ending in seconds
  % ldft - length of the dft to be used
 % outputs
  % g - glottal waveform
  
% read initial audio
 [s, fs] = audioread(fileName);
% s is the input waveform segment, zero outside the interval 0, N - 1
% sn(m) = s(m + n)w(m) - use a hamming window as it reduces error and the
% book recommends it
n = round(start*fs); % starting sample
m = round(ending*fs) - n; % number of samples to be considered
sn = s(n:(n + m - 1)).*hamming(m); % windowing selected segment

% use p (length of akz) of 48 (44 + 4). This comes from:
 % 44 from 44 kHz sampling rate and 4 from source excitation spectrum and
 % radiation load
% p = round(fs/1000) + 4;
 p = 15;

% calculating the short-time autocorrelation function Rn(k)
Rn = zeros(p + 1, 1); % plus one because no zero indexing
for k = 1:(p + 1)
    for m = 1:(length(sn) - k)
        Rn(k) = Rn(k) + sn(m)*s(m + k);
    end
end

% solving the vector system Rt*a = Rn for a -> a = (Rt^-1)*Rn
 % The autocorrelation method takes advantage of Rt being the Toeplitz
 % matrix of Rn
Rt = toeplitz(Rn(1:(end - 1)));
ak = Rt\Rn(2:end);

 % Calculating gain for waveform
 akRn = 0;
 for k = 1:length(ak)
     akRn = akRn + ak(k)*Rn(k + 1);
 end
 gain = sqrt(Rn(1) - akRn); % Calculation of G

% A(k) = 1 - sum(ak*z^-k)
% obtaining formant dft
A = zeros(ldft, 1);
for z = 1:length(A)
    for k = 1:length(ak)
        A(z) = A(z) + ak(k)*(exp(2j*pi/length(A)*(z - 1)))^(1 - k); 
    end
    A(z) = 1 - A(z);
end
 
% V(z) = G/A(z)
V = gain./A;

% Sn = fft(sn)
Sn = zeros(length(V), 1);
for k = 1:length(Sn)
   for n = 1:length(sn)
       Sn(k) = Sn(k) + sn(n)*exp(-2j*pi*(k - 1)*(n - 1)/length(sn));
   end    
end    
% G(z) = Sn(z)/V(z)
G = Sn./V;

% g(n) = idft(G(z))
g = zeros(length(G), 1);
for n = 1:length(g)
    for k = 1:length(G)
        g(n) = g(n) + G(k)*exp(2j*pi/length(G)*(k - 1)*(n - 1));
    end
    g(n) = g(n)/length(G);
end

% plots ffts of the waveforms
figure;
subplot(2,2,1);
plot(abs(A));
title('|A(k)|');
subplot(2,2,2);
plot(abs(V));
title('|V(k)|')
subplot(2,2,3);
plot(abs(Sn));
title('|Sn(k)|');
subplot(2,2,4);
plot(abs(G));
title('|G(k)|');

% plots glottal waveform
figure;
subplot(2,1,1);
plot(0:1/fs:(length(g) - 1)/fs, abs(g));
title('|g(n)|');
subplot(2,1,2);
plot(0:1/fs:(length(sn) - 1)/fs, abs(sn));
title('|sn(n)|');
end