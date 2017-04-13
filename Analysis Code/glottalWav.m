function g = glottalWav(ak, Rn, sn)
% glottalWav - aims to calculate the glottal waveform based on prediction
% coefficients and short-time autocorrelation function
 % inputs:
  % ak - the linear predictive coefficients of the formant waveform
  % Rn - the short time autocorrelation function
  % sn - waveform segment whose glottal waveform is to be extracted
 % outputs
  % g - glottal waveform

 % Calculating gain for waveform
 akRn = 0;
 for k = 1:length(ak)
     akRn = akRn + ak(k)*Rn(k + 1);
 end
 G = sqrt(Rn(1) - akRn); % Calculation of G

% A(k) = 1 - sum(ak*z^-k)
% obtaining formant dft
A = zeros(length(ak), 1);
for z = 1:length(A)
    for k = 1:length(ak)
        A(z) = A(z) + ak(k)*(exp(1j*2*pi/length(A)*(z - 1)))^(1 - k); 
    end
    A(z) = 1 - A(z);
end
 
% V(z) = G/A(z)
V = G./A;

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

% plots glottal waveform
figure;
plot((0:1/44100:(length(g) - 1)/44100), g);
end