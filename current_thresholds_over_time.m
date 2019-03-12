function current_thresholds_over_time
%Written by Xing on 1/3/18.
%Reads in current threshold levels and plots the values across time, for
%each channel.
allThresholds=[];
for sessionInd=87:134%87:125%1:84%from 84 onwards, used larger set of electrodes for stimulation (300 instead of 201). refined set of electrodes from 87 onwards
    load(['C:\Users\Xing\Lick\currentThresholds_previous\currentThresholdChs',num2str(sessionInd),'.mat']);
    allThresholds=[allThresholds goodCurrentThresholds];
end

figure;
for chInd=1:size(allThresholds,1)
    plot(allThresholds(chInd,:));
    hold on
end

figure;
for chInd=1:size(allThresholds,1)
    thresholdCh=allThresholds(chInd,1);%plot threshold values if there is a change from one session to the next
    sessionCh=1;
    for sessionInd=2:size(allThresholds,2)
        if ~isequal(allThresholds(chInd,sessionInd-1),allThresholds(chInd,sessionInd))
            thresholdCh=[thresholdCh allThresholds(chInd,sessionInd)];
            sessionCh=[sessionCh sessionInd];
        end
    end
    plot(sessionCh,thresholdCh);
    hold on
end
xlabel('session')
ylabel('current threshold (uA)')
title('current thresholds on individual channels across time')
% xlim([0 84])
% ylim([0 220])

for chInd=1:size(allThresholds,1)
%     figure;
    thresholdCh=allThresholds(chInd,1);%plot threshold values if there is a change from one session to the next
    sessionCh=1;
    for sessionInd=2:size(allThresholds,2)
        if ~isequal(allThresholds(chInd,sessionInd-1),allThresholds(chInd,sessionInd))
            thresholdCh=[thresholdCh allThresholds(chInd,sessionInd)];
            sessionCh=[sessionCh sessionInd];
        end
    end
%     plot(sessionCh,thresholdCh);
%     hold on
    meanCh(chInd)=mean(thresholdCh);
    stdCh(chInd)=std(thresholdCh);
%     errorbar(1,meanCh,stdCh);
    if length(thresholdCh)>1
        diffCh(chInd)=abs(thresholdCh(end-1)-thresholdCh(end));
    else
        diffCh(chInd)=0;
    end
end
figure;
[meanChSorted indSort]=sort(meanCh);
stdChSorted=stdCh(indSort);
errorbar(1:length(meanChSorted),meanChSorted,stdChSorted);
xlabel('channel number, sorted')
ylabel('mean current threshold & SD (uA)')
% title('mean current thresholds on individual channels, over 5/3/18 - 9/5/18')
title('mean current thresholds on individual channels, over 5/3/18 - 24/7/18')
xlim([0 300])
figure;%box plot for size of standard deviation
boxplot(stdChSorted);
% title('size of standard deviation on individual channels, over 5/3/18 - 9/5/18')
title('size of standard deviation on individual channels, over 5/3/18 - 24/7/18')

%Draw box plots of current thresholds over time:
figure;hold on
xval=[];
dates=[];
for currentThresholdInd=87:134
    fileName=['C:\Users\Xing\Lick\currentThresholds_previous\currentThresholdChs',num2str(currentThresholdInd),'.mat'];
    fileInfo = dir(fileName);
    dateCreated = fileInfo.date;
    formatOut = 'yyyymmdd';
    xval=[xval datenum(dateCreated)];
    dates=[dates;cellstr(datestr(dateCreated,formatOut))];
%     subplot(1,15,dateInd);
end
% xval(4)=xval(4)+1;
% boxplot(allThresholds,'positions',xval,'boxstyle','filled','labels',dates);
boxplot(allThresholds,'positions',xval,'boxstyle','filled','labels',dates,'whisker',1000);
set(gca, 'FontSize', 8)
set(gca,'XTickLabelRotation',60)
xlabel('date')
ylabel('50% current threshold (uA)');
formatIn = 'ddmmyy';
surgery=datenum('200417',formatIn);
xlim([xval(1)-5 xval(end)+5]);
% plot([surgery surgery],[0 1500],'r');
ylim([0 215])
set(gca, 'Ticklength', [0 0])
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', 'r','LineWidth',5);
title('current threshold values over time')

%identify channels with large SD values:
largeSDchs=find(stdCh>10);
arrayNumsRedo=goodArrays8to16(largeSDchs,7)';
electrodeNumsRedo=goodArrays8to16(largeSDchs,8)';

%identify channels with a large difference between the two most recent values and/or where thresholding was only carried out once:
largeDiffChs=find(diffCh>10);
oneDatapointChs=find(diffCh==0);
largeDiffChs=union(largeDiffChs,oneDatapointChs);
arrayNumsRedo=goodArrays8to16(largeDiffChs,7)';
electrodeNumsRedo=goodArrays8to16(largeDiffChs,8)';

%identify channels where thresholding was only carried out once:
oneDatapointChs=find(diffCh==0);
arrayNumsRedo=goodArrays8to16(oneDatapointChs,7)';
electrodeNumsRedo=goodArrays8to16(largeDiffChs,8)';
