function update_current_thresholds
%Written by Xing 25/10/17
%Write newly determined current threshoolds to file,
%currentThresholdChs.mat

% electrodes=[29 38 63 40 46 46 40 61 50 27 63 44 37 20 32 51];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[12 13 15 10 16 15 8 12 16 8 14 12 10 10 13 10];
% electrodes=[29 38 63 40 46 46 40 61 50 63 44 37 20 32 51 42 55];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[12 13 15 10 16 15 8 12 16 14 12 10 10 13 10 13 11];
% newCurrentThresholds=[69 12 5 12 44 4 18 12 36 25 51 12 7 7 18 11 12];%uA
% electrodes=[44 26 37 25 34 49 50 48 35 42 15 63 62 30 42 35 8 24 22];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[12 12 12 12 13 13 13 13 13 13 15 15 15 10 10 10 10 11 11];
% newCurrentThresholds=[47 53 55 43 2 6 35 6 56 14 4 4 6 12 13 12 23 3 5];%uA
% electrodes=[44 26 25 63 62 48 35 49 50 42 8 42 35 24 22];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[12 12 12 15 15 13 13 13 13 13 10 10 10 11 11];
% newCurrentThresholds=[43 41 35 22 23 6 65 5 56 17 22 18 16 3 1];%uA
% electrodes=[44 25 50 42 22 24];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[12 12 13 13 11 11];
% newCurrentThresholds=[8 34 85 18 3 3];%uA
% electrodes=[48 64 63 44 47 1 9 19 27 39 40 38 45 46 50 37 47 44 57 33 41 34 12 13 14 35 50 18 42 59];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[9 9 9 9 9 9 9 9 9 16 16 16 16 16 16 16 16 16 16 12 12 12 12 12 12 12 12 12 12 14];
% newCurrentThresholds=[12 4 18 21 13 7 14 18 19 23 22 18 35 35 28 96 123 12 24 27 107 54 35 36 23 44 12 46 44 6];%uA
% electrodes=[50 38 44 57 13 35 50 18 44 19 27 44];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[9 9 9 9 16 16 16 16 12 12 12 14];
% newCurrentThresholds=[18 5 6 13 25 35 11 34 14 15 15 3];%uA
% electrodes=[63 7 63 64 15 22 30 40 47 3 40 54 15 21 10 19];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[14 16 16 16 16 16 16 8 14 14 14 14 14 14 12 12];
% newCurrentThresholds=[3 21 25 28 74 64 35 16 7 12 12 7 7 3 39 36];%uA
% electrodes=[64 43 3];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[16 12 14];
% newCurrentThresholds=[18 21 14];%uA
% electrodes=[40 63 52];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[8 14 12];
% newCurrentThresholds=[16 4 14];%uA
% electrodes=[30 21 10];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[16 14 12];
% newCurrentThresholds=[80 9 43];%uA
% electrodes=[22 54 57];%first row: set 1, LRTB; second row: set 2, LRTB
% arrays=[16 14 12];
% newCurrentThresholds=[24 9 86];%uA
% load('Y:\Xing\061217_data\061217_B7_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% electrodes=[43 19 27 44 26 35 12 2 57 41 22 30 29 47 61 53 39 58 13 29 48 55 46 38 47 40 50 64 61 15 12 7];
% arrays=[8 8 9 9 9 12 12 12 12 12 12 12 12 13 13 13 14 14 14 14 15 15 15 16 16 16 16 16 16 16 16 16];
% newCurrentThresholds=[19 17 22 22 38 35 20 36 59 54 69 104 35 4 42 42 5 2 12 17 14 14 13 18 35 23 14 42 14 29 38 27];%uA
% load('Y:\Xing\081217_data\081217_B6_thresholds_1_3_4_5_6.mat');
% thresholds=thresholds_all;
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\121217_data\121217_B1_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\121217_data\121217_B2_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\121217_data\121217_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\131217_data\131217_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\131217_data\131217_B5_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\131217_data\131217_B6_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\131217_data\131217_B8_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\131217_data\131217_B9_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\141217_data\141217_B1_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\141217_data\141217_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\151217_data\151217_B1_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\151217_data\151217_B2_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\151217_data\151217_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\181217_data\181217_B2_thresholds.mat');
% load('Y:\Xing\181217_data\181217_B5_thresholds.mat');
% load('Y:\Xing\181217_data\181217_B6_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\191217_data\191217_B3_thresholds.mat');
% load('Y:\Xing\191217_data\191217_B5_thresholds.mat');
% load('Y:\Xing\191217_data\191217_B6_thresholds.mat');
% load('Y:\Xing\191217_data\191217_B7_thresholds.mat');
% load('Y:\Xing\191217_data\191217_B9_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\201217_data\201217_B1_thresholds.mat');
% load('Y:\Xing\201217_data\201217_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\211217_data\211217_B2_thresholds.mat');
% load('Y:\Xing\211217_data\211217_B5_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\221217_data\221217_B1_thresholds.mat');
% load('Y:\Xing\221217_data\221217_B6_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('Y:\Xing\030118_data\030118_B2_thresholds.mat');
% load('Y:\Xing\030118_data\030118_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('C:\Users\Xing\Lick\040118_data\040118_B1_thresholds.mat');
% load('C:\Users\Xing\Lick\040118_data\040118_B2_thresholds.mat');
% load('C:\Users\Xing\Lick\040118_data\040118_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\120118_data\120118_B1_thresholds.mat');
% load('X:\best\120118_data\120118_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\160118_data\160118_B2_thresholds.mat');
% load('X:\best\160118_data\160118_B3_thresholds.mat');
% load('X:\best\160118_data\160118_B4_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\180118_data\180118_B5_thresholds.mat');
% load('X:\best\180118_data\180118_B6_thresholds.mat');
% load('X:\best\180118_data\180118_B7_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\190118_data\190118_B1_thresholds.mat');
% load('X:\best\190118_data\190118_B2_thresholds.mat');
% load('X:\best\190118_data\190118_B3_thresholds.mat');
% load('X:\best\190118_data\190118_B6_thresholds.mat');
% load('X:\best\190118_data\190118_B7_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\290118_data\290118_B1_thresholds.mat');
% load('X:\best\290118_data\290118_B2_thresholds.mat');
% load('X:\best\290118_data\290118_B5_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\300118_data\300118_B2_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\310118_data\310118_B5_thresholds.mat');
% load('X:\best\310118_data\310118_B6_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\060218_data\060218_B1_thresholds.mat');
% load('X:\best\060218_data\060218_B2_thresholds.mat');
% load('X:\best\060218_data\060218_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\070218_data\070218_B1_thresholds.mat');
% load('X:\best\070218_data\070218_B2_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\080218_data\080218_B1_thresholds.mat');
% load('X:\best\080218_data\080218_B2_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\090218_data\090218_B1_thresholds.mat');
% load('X:\best\090218_data\090218_B2_thresholds.mat');
% load('X:\best\090218_data\090218_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\140218_data\140218_B1_thresholds.mat');
% load('X:\best\140218_data\140218_B2_thresholds.mat');
% load('X:\best\140218_data\140218_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\160218_data\160218_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\190218_data\190218_B1_thresholds.mat');
% load('X:\best\190218_data\190218_B2_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\200218_data\200218_B1_thresholds.mat');
% load('X:\best\200218_data\200218_B2_thresholds.mat');
% load('X:\best\200218_data\200218_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\210218_data\210218_B1_thresholds.mat');
% load('X:\best\210218_data\210218_B2_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\220218_data\220218_B1_thresholds.mat');
% load('X:\best\220218_data\220218_B2_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\220218_data\220218_B11_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\230218_data\230218_B1_thresholds.mat');
% load('X:\best\230218_data\230218_B2_thresholds.mat');
% load('X:\best\230218_data\230218_B3_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\260218_data\260218_B1_thresholds.mat');
% load('X:\best\260218_data\260218_B2_thresholds.mat');
% load('X:\best\260218_data\260218_B3_thresholds.mat');
% load('X:\best\260218_data\260218_B4_thresholds.mat');
% electrodes=thresholds(:,3);
% arrays=thresholds(:,4);
% newCurrentThresholds=ceil(thresholds(:,2));%uA
% load('X:\best\280218_data\280218_B2_thresholds.mat');
% load('X:\best\280218_data\280218_B3_thresholds.mat');
load('X:\best\280218_data\280218_B4_thresholds.mat');
electrodes=thresholds(:,3);
arrays=thresholds(:,4);
newCurrentThresholds=ceil(thresholds(:,2));%uA

latestCurrentThresholdsFile=85;
load(['C:\Users\Xing\Lick\currentThresholdChs',num2str(latestCurrentThresholdsFile),'.mat']);
% goodCurrentThresholds=goodCurrentThresholdsNew;
% goodArrays8to16=goodArrays8to16New;
for i=1:length(newCurrentThresholds)
    electrode=electrodes(i);
    array=arrays(i);
    electrodeIndtemp1=find(goodArrays8to16(:,8)==electrode);%matching channel number
    electrodeIndtemp2=find(goodArrays8to16(:,7)==array);%matching array number
    electrodeInd=intersect(electrodeIndtemp1,electrodeIndtemp2);%channel number
    goodCurrentThresholds(electrodeInd)=newCurrentThresholds(i);
end
save(['C:\Users\Xing\Lick\currentThresholdChs',num2str(latestCurrentThresholdsFile),'.mat'],'goodArrays8to16','goodCurrentThresholds')
