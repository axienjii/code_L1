function remove_poor_channels
%Written by Xing 5/3/18
%Reads in list of channels and current thresholds, and removes channels if
%no current threshold could be obtained, or if the RF location or size was
%biologically unrealistic.

% a=find(goodCurrentThresholds==0)
% b=goodArrays8to16(a,7:8);

load('C:\Users\Xing\Lick\currentThresholdChs86.mat')
badRFElectrodes=[53 58 59 60 61 63 62 19 25 57 5];
badRFArrays=[8 8 8 8 8 8 8 13 13 13 16];

for i=1:length(badRFElectrodes)
    electrode=badRFElectrodes(i);
    array=badRFArrays(i);
    electrodeIndtemp1=find(goodArrays8to16(:,8)==electrode);%matching channel number
    electrodeIndtemp2=find(goodArrays8to16(:,7)==array);%matching array number
    electrodeInd=intersect(electrodeIndtemp1,electrodeIndtemp2);%channel number
    goodCurrentThresholds(electrodeInd,:)=[];
    goodArrays8to16(electrodeInd,:)=[];
end