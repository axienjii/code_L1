function generate_microstim_saccade_test_conds
%Written by Xing 7/9/17
%Generate mat file containing electrode indices and current threshold levels, which
%is loaded into runstim_microstim_saccade_catch10.m, in order to deliver
%microstimulation to electrodes in random order, at suprathreshold levels.
%Goal is to then check saccade end points for correlations with RF
%coordinates.

load('C:\Users\Xing\Lick\currentThresholds_060917.mat')
load('C:\Users\Xing\Lick\090817_impedance\array8.mat')
load('C:\Users\Xing\Lick\090817_impedance\array9.mat')
load('C:\Users\Xing\Lick\090817_impedance\array10.mat')
load('C:\Users\Xing\Lick\090817_impedance\array11.mat')
load('C:\Users\Xing\Lick\090817_impedance\array12.mat')
load('C:\Users\Xing\Lick\090817_impedance\array13.mat')
load('C:\Users\Xing\Lick\090817_impedance\array14.mat')
load('C:\Users\Xing\Lick\090817_impedance\array15.mat')
load('C:\Users\Xing\Lick\090817_impedance\array16.mat')

arrays8to16Thresholds=[array8_currentThresholds;array9_currentThresholds;array10_currentThresholds;array11_currentThresholds;array12_currentThresholds;array13_currentThresholds;array14_currentThresholds;array15_currentThresholds;array16_currentThresholds];
arrays8to16inds=[1:length(array8_currentThresholds) 1:length(array9_currentThresholds) 1:length(array10_currentThresholds) 1:length(array11_currentThresholds) 1:length(array12_currentThresholds) 1:length(array13_currentThresholds) 1:length(array14_currentThresholds) 1:length(array15_currentThresholds) 1:length(array16_currentThresholds)]';
goodCurrentThresholds=arrays8to16Thresholds(find(arrays8to16Thresholds~=0));
goodInds=arrays8to16inds(find(arrays8to16Thresholds~=0));
arrays8to16=[array8(1:length(array8_currentThresholds),:);array9(1:length(array9_currentThresholds),:);array10(1:length(array10_currentThresholds),:);array11(1:length(array11_currentThresholds),:);array12(1:length(array12_currentThresholds),:);array13(1:length(array13_currentThresholds),:);array14(1:length(array14_currentThresholds),:);array15(1:length(array15_currentThresholds),:);array16(1:length(array16_currentThresholds),:)];
goodArrays8to16=arrays8to16(find(arrays8to16Thresholds~=0),:);

%randomise electrode order:
originalChOrder=randperm(length(goodArrays8to16));
save('C:\Users\Xing\Lick\currentThresholdChs.mat','goodInds','goodCurrentThresholds','goodArrays8to16','originalChOrder');