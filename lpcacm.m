function [akz, Rn] = lpcacm(fileName, start, ending)
%% lpcacm is an acronym for "Linear Predictive Coding Autocorrelation Method"
 % the autocorrelation method is used because it is guaranteed that the
 % poles will be in the unit circle.
 % inputs: 
  % fileName - string, input waveform file name
  % start - number, target beginning in seconds
  % ending - number, target ending in seconds
 % outputs: 
  % akz - the linear predictor coefficients 
  % Rn - the short-time autocorrelation function
 
 % read initial audio
 [s, fs] = audioread(fileName);
% s is the input waveform segment, zero outside the interval 0, N - 1
% sn(m) = s(m + n)w(m) - use a hamming window as it reduces error and the
% book recommends it
n = round(start*fs); % starting sample
m = round(ending*fs) - n; % number of samples to be considered
sn = s((n + 1):(n + m)).*hamming(m); % windowing selected segment

% plotting stuff debug
% plotting full waveform
t = linspace(0, length(s)/fs, length(s));
subplot(2,2,1)
plot(t, s);
title('Full Waveform');
xlabel('time (s)');
ylabel('audio waveform (V)');
% plotting waveform segment
subplot(2,2,2);
tn = linspace(start, ending, m);
plot(tn, sn);
title('Targeted Waveform');
xlabel('time (s)');
ylabel('audio waveform (V)');

% use p (length of akz) of 48 (44 + 4). This comes from:
 % 44 from 44 kHz sampling rate and 4 from source excitation spectrum and
 % radiation load
p = round(fs/1000 + 4);

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
akz = Rt\Rn(2:end);

% more debugging
subplot(2,2,3)
stem(akz);
title('Prediction Coefficients');
xlabel('coefficient number');
ylabel('values');

% linear predictor for targeted waveform
sSwoosh = zeros(length(sn), 1);
for n = (p + 3):(length(sSwoosh) - 1) % p + 2 to begin so n - k is always > 0
    for k = 2:(p + 1)
        sSwoosh(n) = sSwoosh(n) + akz(k - 1)*sn(n - k - 1);
    end
end

% plotting linear predictor
subplot(2,2,4);
plot(tn, sSwoosh);
title('Waveform Predictor');
xlabel('time (s)');
ylabel('audio waveform (V)');


% Error function
figure;

end