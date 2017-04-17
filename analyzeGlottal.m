function [g] = analyzeGlottal(fileName, start, ending)
%% analyzeGlottal - uses an interval of a larger waveform to estimate the 
% glottal waveform. A combination of lpcacm.m and glottalWav.m 
 % inputs:
  % fileName - string, input waveform file name
  % start - number, target beginning in seconds
  % ending - number, target ending in seconds
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
% p-value that isn't overkill:
p = 64;

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
gain = sqrt(Rn(1) - akRn); % Calculation of gain

% A(k) = 1 - sum(ak*z^-k)
% obtaining formant dft
ldft = floor((ending - start)*fs); % make length as long as possible
A = zeros(ldft, 1);
for k = 1:length(A)
    for n = 1:length(ak)
        A(k) = A(k) + ak(n)*(exp(-2j*pi*(k - 1)*(n - 1)/length(A))); 
    end
    A(k) = 1 - A(k);
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

% g(n) = ifft(G(z))
g = zeros(length(G), 1);
for n = 1:length(g)
    for k = 1:length(G)
        g(n) = g(n) + G(k)*exp(2j*pi*(k - 1)*(n - 1)/length(G));
    end
    g(n) = g(n)/length(G);
end

% plots ffts of the waveforms
figure;
subplot(2,2,1);
plot(fs/length(A)*(0:(length(A(1:round(end/2))) - 1)), abs(A(1:round(end/2))));
title('|A(k)|');
xlabel('frequency (Hz)');
ylabel('magnitude');
subplot(2,2,2);
plot(fs/length(V)*(0:(length(V(1:round(end/2))) - 1)), abs(V(1:round(end/2))));
title('|V(k)|')
xlabel('frequency (Hz)');
ylabel('magnitude');
subplot(2,2,3);
plot(fs/length(Sn)*(0:(length(Sn(1:round(end/2))) - 1)), abs(Sn(1:round(end/2))));
title('|Sn(k)|');
xlabel('frequency (Hz)');
ylabel('magnitude');
subplot(2,2,4);
plot(fs/length(G)*(0:(length(G(1:round(end/2))) - 1)), abs(G(1:round(end/2))));
title('|G(k)|');
xlabel('frequency (Hz)');
ylabel('magnitude');

% plots glottal waveform
figure;
subplot(2,1,1);
plot(0:1/fs:(length(g) - 1)/fs, abs(g));
title('|g(n)|');
xlabel('time  (s)');
ylabel('magnitude');
subplot(2,1,2);
plot(0:1/fs:(length(sn) - 1)/fs, abs(sn));
title('|sn(n)|');
xlabel('time (s)');
ylabel('magnitude');
end