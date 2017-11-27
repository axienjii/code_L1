function update_current_thresholds
%Written by Xing 25/10/17
%Write newly determined current threshoolds to file,
%currentThresholdChs.mat

% electrodes=[29 38 63 40 46 46 40 61 50 27 63 44 37 20 32 51];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[12 13 15 10 16 15 8 12 16 8 14 12 10 10 13 10];
% electrodes=[29 38 63 40 46 46 40 61 50 63 44 37 20 32 51 42 55];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[12 13 15 10 16 15 8 12 16 14 12 10 10 13 10 13 11];
% newCurrentThresholds=[69 12 5 12 44 4 18 12 36 25 51 12 7 7 18 11 12];%uA
electrodes=[44 26 37 25 34 49 50 48 35 42 15 63 62 30 42 35 8 24 22];%first row: set 1, LRTB; second row: set 2, LRTB
arrays=[12 12 12 12 13 13 13 13 13 13 15 15 15 10 10 10 10 11 11];
newCurrentThresholds=[47 53 55 43 2 6 35 6 56 14 4 4 6 12 13 12 23 3 5];%uA

latestCurrentThresholdsFile=36;
load(['C:\Users\Xing\Lick\currentThresholdChs',num2str(latestCurrentThresholdsFile),'.mat']);
for i=1:length(newCurrentThresholds)
    electrode=electrodes(i);
    array=arrays(i);
    electrodeIndtemp1=find(goodArrays8to16(:,8)==electrode);%matching channel number
    electrodeIndtemp2=find(goodArrays8to16(:,7)==array);%matching array number
    electrodeInd=intersect(electrodeIndtemp1,electrodeIndtemp2);%channel number
    goodCurrentThresholds(electrodeInd)=newCurrentThresholds(i);
end
save(['C:\Users\Xing\Lick\currentThresholdChs',num2str(latestCurrentThresholdsFile+1),'.mat'],'goodArrays8to16','goodCurrentThresholds','goodInds','originalChOrder')
