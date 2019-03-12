function current_thresholds_histogram
%Written by Xing on 9/1/19.
%Reads in current threshold levels, identifies the lowest values obtained,
%and plots the values in a histogram across all channels.

%Lick:
allThresholds=[];
for sessionInd=87:134%87:125%1:84%from 84 onwards, used larger set of electrodes for stimulation (300 instead of 201). refined set of electrodes from 87 onwards
    load(['C:\Users\Xing\Lick\currentThresholds_previous\currentThresholdChs',num2str(sessionInd),'.mat']);
    allThresholds=[allThresholds goodCurrentThresholds];
end

lowestThresholds=[];
for chInd=1:size(allThresholds,1)
    chThresholds=sort(allThresholds(chInd,:));
    chThresholds(chThresholds==0)=[];
    lowestThresholds(chInd)=chThresholds(1);
end
lowestThresholdsSorted=sort(lowestThresholds);

figure;
subplot(1,2,1);
h=histogram(lowestThresholdsSorted,0:20:210);
h.FaceColor='k';
xlabel('current threshold (uA)');
ylabel('count');
set(gca,'box','off');
axis square

clear all

%Aston:
allThresholds1=[];
allThresholds2=[];
allThresholds3=[];
allThresholds4=[];
arrayNums1=[];
electrodeNums1=[];
arrayNums2=[];
electrodeNums2=[];
arrayNums3=[];
electrodeNums3=[];
arrayNums4=[];
electrodeNums4=[];
for sessionInd=1:5%[10:13 17:37]%38:43%
    load(['C:\Users\Xing\Aston\currentThresholds_previous\currentThresholdChs',num2str(sessionInd),'.mat']);
    allThresholds1=[allThresholds1;goodCurrentThresholds];
    arrayNums1=[arrayNums1;goodArrays8to16(:,7)];
    electrodeNums1=[electrodeNums1;goodArrays8to16(:,8)];
end
for sessionInd=6:9%1:5%[10:13 17:37]%38:43%
    load(['C:\Users\Xing\Aston\currentThresholds_previous\currentThresholdChs',num2str(sessionInd),'.mat']);
    allThresholds2=[allThresholds2;goodCurrentThresholdsNew];
    arrayNums2=[arrayNums2;goodArrays8to16New(:,7)];
    electrodeNums2=[electrodeNums2;goodArrays8to16New(:,8)];
end
for sessionInd=[10:13 17:37]%38:43%
    load(['C:\Users\Xing\Aston\currentThresholds_previous\currentThresholdChs',num2str(sessionInd),'.mat']);
    allThresholds3=[allThresholds3;goodCurrentThresholds];
    arrayNums3=[arrayNums3;goodArrays8to16(:,7)];
    electrodeNums3=[electrodeNums3;goodArrays8to16(:,8)];
end
for sessionInd=38:43%
    load(['C:\Users\Xing\Aston\currentThresholds_previous\currentThresholdChs',num2str(sessionInd),'.mat']);
    allThresholds4=[allThresholds4;goodCurrentThresholds];
    arrayNums4=[arrayNums4;goodArrays8to16(:,7)];
    electrodeNums4=[electrodeNums4;goodArrays8to16(:,8)];
end
arrayNums=[arrayNums1;arrayNums2;arrayNums3;arrayNums4];
electrodeNums=[electrodeNums1;electrodeNums2;electrodeNums3;electrodeNums4];
allThresholds=[allThresholds1;allThresholds2;allThresholds3;allThresholds4];
arrayElectrodeNums=[arrayNums electrodeNums];
uniqueArrayElectrodeNums=unique(arrayElectrodeNums,'rows');

lowestThresholds=[];
for chInd=1:size(uniqueArrayElectrodeNums,1)
    array=uniqueArrayElectrodeNums(chInd,1);
    electrode=uniqueArrayElectrodeNums(chInd,2);
    temp1=find(arrayNums==array);
    temp2=find(electrodeNums==electrode);
    rowInds=intersect(temp1,temp2);
    chThresholds=sort(allThresholds(rowInds));
    chThresholds(chThresholds==0)=[];
    lowestThresholds(chInd)=chThresholds(1);
end

lowestThresholdsSorted=sort(lowestThresholds);
lowestThresholdsSorted(lowestThresholdsSorted==210)=[];

subplot(1,2,2);
h=histogram(lowestThresholdsSorted,0:20:210);
h.FaceColor='k';
xlabel('current threshold (uA)');
ylabel('count');
set(gca,'box','off');
axis square
ylim([0 300]);