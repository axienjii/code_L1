function select_random_electrodes_arrays
%Written by Xing on 17/9/18. Randomly select 5 electrodes on each array (8
%to 16), for saccade task (using script
%runstim_microstim_saccade_endpoints_letter). Originally, runstim was used
%to send microstimulation on electrodes that comprised a particular letter
%or set of letters, but in this case, it is used to send microstimulation
%on randomly selected electrodes across all electrodes that have been used
%for stimulation. Purpose is to generate movie with eye movements to
%phosphene locations, and carry out ANOVA on RTs with electrode and array
%identity, electrode impedance, RF eccentricity, and current amplitude.
electrodeNums=[];
arrayNums=[];
for arrayNum=8:16
   rows=find(goodArrays8to16(:,7)==arrayNum);
   rowOrder=randperm(length(rows));
   chosenElectrodes=rows(rowOrder(1:5));
   electrodeNums=[electrodeNums;goodArrays8to16(chosenElectrodes,8)]
   arrayNums=[arrayNums;goodArrays8to16(chosenElectrodes,7)]
end
electrodeNums=electrodeNums';
arrayNums=arrayNums';
% electrodeNums=[52 9 27 11 22 36 44 19 56 1 46 40 28 41 34 51 64 18 32 34 6 20 14 12 30 35 52 22 43 31 31 12 13 6 36 1 37 40 62 63 47 34 4 53 46];%010518_B & B
% arrayNums=[8 8 8 8 8 9 9 9 9 9 10 10 10 10 10 11 11 11 11 11 12 12 12 12 12 13 13 13 13 13 14 14 14 14 14 15 15 15 15 15 16 16 16 16 16];
