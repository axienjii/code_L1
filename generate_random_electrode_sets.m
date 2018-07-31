function generate_random_electrode_sets
%Written by Xing 16/5/18 to pick a random set of electrodes for a control
%task. One expects that the random set would not give rise to a percept of a recognisable
%letter. The random set of electrodes are then used in
%runstim_microstim_letter_2point5_multiset.m, to check the monkey's
%performance on a stimulus that has not been designed to resemble a letter.

load('C:\Users\Xing\Lick\currentThresholds_previous\currentThresholdChs126.mat')
randomChannelInds=randperm(300,10);
setElectrodes=goodArrays8to16(randomChannelInds,8)'
setArrays=goodArrays8to16(randomChannelInds,7)'

%randomly selected electrodes, set 1:
%randomChannelInds=[71 282 51 101 206 58 293 41 136 13]
%setElectrodes=[15 24 58 57 62 32 62 39 14 9]
%setArrays=[10 16 10 12 14 10 16 10 12 8]

%randomly selected electrodes, set 2:
%randomChannelInds=[195 95 52 20 279 65 55 154 6 210]
%setElectrodes=[54 61 30 9 23 61 22 56 19 37]
%setArrays=[13 11 10 9 16 10 10 12 8 14]

%run the runstim and carry out the task manually using the mouse. load
%saved data and check number of trials:
a=find(performance~=0)
sort(allSetInd(a(1:40)))
%For example, for a recording in which the electrode set identity ranges from setInd 44 to
%63, one should get two occurrences of each condition (44 to 63) with the above code.