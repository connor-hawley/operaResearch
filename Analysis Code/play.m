%% Ratchet script
figure;
load('kevinError.mat');
load('operaError.mat');
subplot(2,2,1);
plot(tn, kevinError);
subplot(2,2,2);
plot(tn, operaError);
subplot(2,2,3);
y1 = fft(kevinError);
f1 = (0:length(y1)-1)*2000/length(y1);
%plot(f1, 20*log(abs(y1)));
%subplot(2,2,4);
y2 = fft(operaError);
f2 = (0:length(y2)-1)*2000/length(y2);
plot(f1, 20*log(abs(y1)), f2, 20*log(abs(y2)));
legend('show');
legend('kevin', 'opera');