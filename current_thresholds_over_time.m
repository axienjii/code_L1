function current_thresholds_over_time
%Written by Xing on 1/3/18.
%Reads in current threshold levels and plots the values across time, for
%each channel.
allThresholds=[];
for sessionInd=1:83
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
xlim([0 84])
ylim([0 220])