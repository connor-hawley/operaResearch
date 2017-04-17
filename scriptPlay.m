function [] = scriptPlay()
operaFilesCa = {'01\01RawA.wav', '02\02RawA.wav', '03\03RawA.wav', '04\04RawA.wav', '05\05RawA.wav', '06\06RawA.wav', '07\07RawA.wav', '08\08RawA.wav', '09\09RawA.wav', '10\10RawA.wav', '11\11RawA.wav', '12\12RawA.wav', '13\13RawA.wav', '14\14RawA.wav', '15\15RawA.wav', '16\16RawA.wav', '17\17RawA.wav', '18\18RawA.wav', '19\19RawA.wav', '20\20RawA.wav', '21\21RawA.wav';
           '01\01RawE.wav', '02\02RawE.wav', '03\03RawE.wav', '04\04RawE.wav', '05\05RawE.wav', '06\06RawE.wav', '07\07RawE.wav', '08\08RawE.wav', '09\09RawE.wav', '10\10RawE.wav', '11\11RawE.wav', '12\12RawE.wav', '13\13RawE.wav', '14\14RawE.wav', '15\15RawE.wav', '16\16RawE.wav', '17\17RawE.wav', '18\18RawE.wav', '19\19RawE.wav', '20\20RawE.wav', '21\21RawE.wav';
           '01\01RawO.wav', '02\02RawO.wav', '03\03RawO.wav', '04\04RawO.wav', '05\05RawO.wav', '06\06RawO.wav', '07\07RawO.wav', '08\08RawO.wav', '09\09RawO.wav', '10\10RawO.wav', '11\11RawO.wav', '12\12RawO.wav', '13\13RawO.wav', '14\14RawO.wav', '15\15RawO.wav', '16\16RawO.wav', '17\17RawO.wav', '18\18RawO.wav', '19\19RawO.wav', '20\20RawO.wav', '21\21RawO.wav';
           '01\01RawG.wav', '02\02RawG.wav', '03\03RawG.wav', '04\04RawG.wav', '05\05RawG.wav', '06\06RawG.wav', '07\07RawG.wav', '08\08RawG.wav', '09\09RawG.wav', '10\10RawG.wav', '11\11RawG.wav', '12\12RawG.wav', '13\13RawG.wav', '14\14RawG.wav', '15\15RawG.wav', '16\16RawG.wav', '17\17RawG.wav', '18\18RawG.wav', '19\19RawG.wav', '20\20RawG.wav', '21\21RawG.wav'};

averageFormants = cell(3, 1);
% Plotting the formant spectra for each vowel of each singer:
[r, c] = size(operaFilesCa);
for vowel = 1:(r - 1)
    figure;
   for singer = 1:c
       % retrieve data with helper function
       [fVec, V] = analyzeFormants(['Test Files\', operaFilesCa{vowel, singer}], 10, 10.08);
       % running average of formant spectra
       if singer ~= 1
           averageFormants{vowel, 1} = averageFormants{vowel, 1} + V;
       else
           averageFormants{vowel, 1} = V;
       end
       % subplot of each vowel
       subplot(7,3,singer);
       plot(fVec, abs(V));
   end
   averageFormants{vowel, 1} = averageFormants{vowel, 1}./c; 
end
% plot average formants for all the opera singers
figure;
for vowel = 1:(r - 1)
    subplot(3, 1, vowel);
    plot(fVec, exp(abs(averageFormants{vowel, 1})));
end
end