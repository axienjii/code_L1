function letter_discrim_behav_perf2
%Modified by Xing 29/6/17 from letter_discrim_behav_perf.
close all;
allLetters=['EIXT';'OUKV';'SDAZ';'LNYH'];
% dirName=cd;
% load([dirName,'\test\',date,'_perf.mat'])
date='26-Jun-2017';
dirName='C:\Users\Xing\Lick\visual_letter_task_logs';
fileName=[date,'_perf.mat'];
load(fullfile(dirName,fileName));
indCorr=find(performance==1);
indIncorr=find(performance==-1);
numCorrTrials=length(indCorr);
numIncorrTrials=length(indIncorr);
meanPerfAll=numCorrTrials/(numCorrTrials+numIncorrTrials);%average performance across conditions

for i=1:size(allLetters,1)
    for j=1:size(allLetters,2)
        trialsMatchingCondition=find(char(allTargetLetters)==allLetters(i,j));
        trialsMatchingCondition=trialsMatchingCondition(trialsMatchingCondition<=length(performance));
        trialCorrCond{i,j}=trialsMatchingCondition(performance(trialsMatchingCondition)==1);%trial numbers where correct response was made, for each condition
        trialIncorrCond{i,j}=trialsMatchingCondition(performance(trialsMatchingCondition)==-1);%trial numbers where incorrect response was made, for each condition
        numCorrTrialsCond(i,j)=length(trialCorrCond{i,j});%number of trials where correct response was made, for each condition
        numIncorrTrialsCond(i,j)=length(trialIncorrCond{i,j});%number of trials where incorrect response was made, for each condition
        meanPerfCond(i,j)=numCorrTrialsCond(i,j)/(numCorrTrialsCond(i,j)+numIncorrTrialsCond(i,j));%performance for each condition
        incorrResponses{i,j}=behavResponse(trialIncorrCond{i,j});%record down the responses made during incorrect trials
    end
end

%calculate mean performance for each location:
%1) average across all trials at each location
numCorrTrialsLoc1=zeros(size(allLetters,1),1);
numIncorrTrialsLoc1=zeros(size(allLetters,1),1);
for i=1:size(allLetters,1)
    for j=1:size(allLetters,2)
        numCorrTrialsLoc1(i)=numCorrTrialsLoc1(i)+numCorrTrialsCond(i,j);
        numIncorrTrialsLoc1(i)=numIncorrTrialsLoc1(i)+numIncorrTrialsCond(i,j);
    end
    meanPerfCond1(i,1)=numCorrTrialsLoc1(i)/(numCorrTrialsLoc1(i)+numIncorrTrialsLoc1(i));
end
%2) average across mean for each condition at each location
meanPerfCond2=mean(meanPerfCond,2);

%analyse effects of sample location:
fig1=figure;
fig2=figure;
fig6=figure;
fig7=figure;
fig8=figure;
fig15=figure;
allDistanceCorr=[];%vector distance
allDistanceIncorr=[];
allDistanceCorrX=[];%x distance
allDistanceIncorrX=[];
allDistanceCorrY=[];%y distance
allDistanceIncorrY=[];
allSizeCorr=[];%stimulus size
allSizeIncorr=[];
for i=1:size(allLetters,1)
    for j=1:size(allLetters,2)
        locXcorr{i,j}=allSampleX(trialCorrCond{i,j});%x-coordinates for correct trials
        locXincorr{i,j}=allSampleX(trialIncorrCond{i,j});%x-coordinates for incorrect trials
        locYcorr{i,j}=allSampleY(trialCorrCond{i,j});%y-coordinates for correct trials
        locYincorr{i,j}=allSampleY(trialIncorrCond{i,j});%y-coordinates for incorrect trials
        resCorr{i,j}=allVisualHeightResolution(trialCorrCond{i,j});%number of subdivisions in the image height for correct trials
        resIncorr{i,j}=allVisualHeightResolution(trialIncorrCond{i,j});%number of subdivisions in the image height for incorrect trials
        sizeCorr{i,j}=allSampleSize(trialCorrCond{i,j});%number of subdivisions in the image height for correct trials
        sizeIncorr{i,j}=allSampleSize(trialIncorrCond{i,j});%number of subdivisions in the image height for incorrect trials
        figure(fig1)
        plot(locXcorr{i,j},locYcorr{i,j},'ko');hold on
        plot(locXincorr{i,j},locYincorr{i,j},'rx');
        figure(fig2)
        plot(locXcorr{i,j},locYcorr{i,j},'o','MarkerEdgeColor',[0.25*i 0.5 0.25*j]);hold on
        plot(locXincorr{i,j},locYincorr{i,j},'x','MarkerEdgeColor',[0.25*i 0.5 0.25*j]);
        %calculate vector between fix spot and centre of stimulus. Examine
        %correct vs incorrect trials as a function of vector distance.
        figure(fig6)
        subplot(size(allLetters,1),size(allLetters,2),i+(j-1)*4);
        histBinWidth=20;
        histBins=0:histBinWidth:180;
        distanceIncorr=sqrt(locXincorr{i,j}.^2+locYincorr{i,j}.^2);
        hist(distanceIncorr,histBins);hold on
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','facealpha',0.5)
        distanceCorr=sqrt(locXcorr{i,j}.^2+locYcorr{i,j}.^2);
        hist(distanceCorr,histBins);
        h = findobj(gca,'Type','patch');
        set(h,'facealpha',0.5)
        ylims=ylim;
        %plot means:
        meanCorr=mean(distanceCorr);
        plot([meanCorr meanCorr],[ylims(1) ylims(2)],':','Color','b');
        meanIncorr=mean(distanceIncorr);
        plot([meanIncorr meanIncorr],[ylims(1) ylims(2)],':','Color','r');
        xlim([histBins(1)-histBinWidth histBins(end)+histBinWidth]);
        [h p]=ttest2(distanceCorr,distanceIncorr);
        titleStr=[allLetters(i,j),' p=',num2str(p,3)];
        if p<0.05
            titleStr=[titleStr,'*'];
        end
        if i==1&&j==1
            titleStr=[titleStr,' B- corr; R- incorr'];
        end
        title(titleStr);
        %compile distance values for corr and incorr trials across letter
        %conditions:
        allDistanceCorr=[allDistanceCorr distanceCorr];
        allDistanceIncorr=[allDistanceIncorr distanceIncorr];
        %Examine correct vs incorrect trials as a function of X distance.
        figure(fig7)
        subplot(size(allLetters,1),size(allLetters,2),i+(j-1)*4);
        histBinWidth=20;
        histBins=0:histBinWidth:180;
        distanceIncorr=locXincorr{i,j};
        hist(distanceIncorr,histBins);hold on
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','facealpha',0.5)
        distanceCorr=locXcorr{i,j};
        hist(distanceCorr,histBins);
        h = findobj(gca,'Type','patch');
        set(h,'facealpha',0.5)
        ylims=ylim;
        %plot means:
        meanCorr=mean(distanceCorr);
        plot([meanCorr meanCorr],[ylims(1) ylims(2)],':','Color','b');
        meanIncorr=mean(distanceIncorr);
        plot([meanIncorr meanIncorr],[ylims(1) ylims(2)],':','Color','r');
        xlim([histBins(1)-histBinWidth histBins(end)+histBinWidth]);
        [h p]=ttest2(distanceCorr,distanceIncorr);
        titleStr=[allLetters(i,j),' p=',num2str(p,3)];
        if p<0.05
            titleStr=[titleStr,'*'];
        end
        if i==1&&j==1
            titleStr=[titleStr,' B- corr; R- incorr'];
        end
        title(titleStr);
        %compile distance values for corr and incorr trials across letter
        %conditions:
        allDistanceCorrX=[allDistanceCorrX distanceCorr];
        allDistanceIncorrX=[allDistanceIncorrX distanceIncorr];
        %Examine correct vs incorrect trials as a function of Y distance.
        figure(fig8)
        subplot(size(allLetters,1),size(allLetters,2),i+(j-1)*4);
        histBinWidth=20;
        histBins=0:histBinWidth:180;
        distanceIncorr=locYincorr{i,j};
        hist(distanceIncorr,histBins);hold on
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','facealpha',0.5)
        distanceCorr=locYcorr{i,j};
        hist(distanceCorr,histBins);
        h = findobj(gca,'Type','patch');
        set(h,'facealpha',0.5)
        ylims=ylim;
        %plot means:
        meanCorr=mean(distanceCorr);
        plot([meanCorr meanCorr],[ylims(1) ylims(2)],':','Color','b');
        meanIncorr=mean(distanceIncorr);
        plot([meanIncorr meanIncorr],[ylims(1) ylims(2)],':','Color','r');
        xlim([histBins(1)-histBinWidth histBins(end)+histBinWidth]);
        [h p]=ttest2(distanceCorr,distanceIncorr);
        titleStr=[allLetters(i,j),' p=',num2str(p,3)];
        if p<0.05
            titleStr=[titleStr,'*'];
        end
        if i==1&&j==1
            titleStr=[titleStr,' B- corr; R- incorr'];
        end
        title(titleStr);
        %compile distance values for corr and incorr trials across letter
        %conditions:
        allDistanceCorrY=[allDistanceCorrY distanceCorr];
        allDistanceIncorrY=[allDistanceIncorrY distanceIncorr];
        %Examine correct vs incorrect trials as a function of sample size.
        figure(fig15)
        subplot(size(allLetters,1),size(allLetters,2),i+(j-1)*4);
        histBinWidth=10;
        histBins=40:histBinWidth:180;
        hist(sizeIncorr{i,j},histBins);hold on
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','facealpha',0.5)
        hist(sizeCorr{i,j},histBins);
        h = findobj(gca,'Type','patch');
        set(h,'facealpha',0.5)
        ylims=ylim;
        %plot means:
        meanCorr=mean(sizeCorr{i,j});
        plot([meanCorr meanCorr],[ylims(1) ylims(2)],':','Color','b');
        meanIncorr=mean(sizeIncorr{i,j});
        plot([meanIncorr meanIncorr],[ylims(1) ylims(2)],':','Color','r');
        xlim([histBins(1)-histBinWidth histBins(end)+histBinWidth]);
        [h p]=ttest2(sizeCorr{i,j},sizeIncorr{i,j});
        titleStr=[allLetters(i,j),' p=',num2str(p,3)];
        if p<0.05
            titleStr=[titleStr,'*'];
        end
        if i==1&&j==1
            titleStr=[titleStr,' B- corr; R- incorr'];
        end
        title(titleStr);
        %compile distance values for corr and incorr trials across letter
        %conditions:
        allSizeCorr=[allSizeCorr sizeCorr{i,j}];
        allSizeIncorr=[allSizeIncorr sizeIncorr{i,j}];
        set(gca,'XTick',40:20:160,'XTickLabel',40:20:160);
    end
end
figure(fig1)
title('black- corr; red- incorr');
%plot vector distance values for corr and incorr trials across letter conditions:
fig9=figure;
hist(allDistanceIncorr,histBins);hold on
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','facealpha',0.5)
hist(allDistanceCorr,histBins);
h = findobj(gca,'Type','patch');
set(h,'facealpha',0.5)
ylims=ylim;
allMeanCorr=mean(allDistanceCorr);
plot([allMeanCorr allMeanCorr],[ylims(1) ylims(2)],':','Color','b');
allMeanIncorr=mean(allDistanceIncorr);
plot([allMeanIncorr allMeanIncorr],[ylims(1) ylims(2)],':','Color','r');
xlim([histBins(1)-histBinWidth histBins(end)+histBinWidth]);
[h p]=ttest2(allDistanceCorr,allDistanceIncorr);
titleStr=['Vector distance from fix. B- corr, R- incorr. p=',num2str(p,3)];
if p<0.05
    titleStr=[titleStr,'*'];
end
title(titleStr);

%plot X distance values for corr and incorr trials across letter conditions:
fig10=figure;
hist(allDistanceIncorrX,histBins);hold on
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','facealpha',0.5)
hist(allDistanceCorrX,histBins);
h = findobj(gca,'Type','patch');
set(h,'facealpha',0.5)
ylims=ylim;
allMeanCorrX=mean(allDistanceCorrX);
plot([allMeanCorrX allMeanCorrX],[ylims(1) ylims(2)],':','Color','b');
allMeanIncorrX=mean(allDistanceIncorrX);
plot([allMeanIncorrX allMeanIncorrX],[ylims(1) ylims(2)],':','Color','r');
xlim([histBins(1)-histBinWidth histBins(end)+histBinWidth]);
[h p]=ttest2(allDistanceCorrX,allDistanceIncorrX);
titleStr=['X coordinate. B- corr, R- incorr. p=',num2str(p,3)];
if p<0.05
    titleStr=[titleStr,'*'];
end
title(titleStr);

%plot Ydistance values for corr and incorr trials across letter conditions:
fig11=figure;
hist(allDistanceIncorrY,histBins);hold on
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','facealpha',0.5)
hist(allDistanceCorrY,histBins);
h = findobj(gca,'Type','patch');
set(h,'facealpha',0.5)
ylims=ylim;
allMeanCorrY=mean(allDistanceCorrY);
plot([allMeanCorrY allMeanCorrY],[ylims(1) ylims(2)],':','Color','b');
allMeanIncorrY=mean(allDistanceIncorrY);
plot([allMeanIncorrY allMeanIncorrY],[ylims(1) ylims(2)],':','Color','r');
xlim([histBins(1)-histBinWidth histBins(end)+histBinWidth]);
[h p]=ttest2(allDistanceCorrY,allDistanceIncorrY);
titleStr=['Y coordinate. B- corr, R- incorr. p=',num2str(p,3)];
if p<0.05
    titleStr=[titleStr,'*'];
end
title(titleStr);

%analyse effects of simulated phosphene resolution:
for i=1:size(allLetters,1)
    for j=1:size(allLetters,2)
        if ~isempty(min(resCorr{i,j}))
            minResCorr(i,j)=min(resCorr{i,j});
        else
            minResCorr(i,j)=0;
        end
        if ~isempty(min(resIncorr{i,j}))
            minResIncorr(i,j)=min(resIncorr{i,j});
        else
            minResIncorr(i,j)=0;
        end
        if ~isempty(max(resCorr{i,j}))
            maxResCorr(i,j)=max(resCorr{i,j});
        else
            maxResCorr(i,j)=0;
        end
        if ~isempty(max(resIncorr{i,j}))
            maxResIncorr(i,j)=max(resIncorr{i,j});
        else
            maxResIncorr(i,j)=0;
        end
    end
end
minRes=min(minResCorr(:));
maxRes=max(maxResCorr(:));
tallyCorr=zeros(1,maxRes-minRes+1);
tallyIncorr=zeros(1,maxRes-minRes+1);
tallyCorrCond=zeros(size(allLetters,1),size(allLetters,2),maxRes-minRes+1);
tallyIncorrCond=zeros(size(allLetters,1),size(allLetters,2),maxRes-minRes+1);
for k=1:maxRes-minRes+1
    resolutions=minRes:maxRes;
    for i=1:size(allLetters,1)
        for j=1:size(allLetters,2)
            tallyCorr(k)=tallyCorr(k)+sum(resCorr{i,j}==resolutions(k));
            tallyIncorr(k)=tallyIncorr(k)+sum(resIncorr{i,j}==resolutions(k));
            tallyCorrCond(i,j,k)=tallyCorrCond(i,j,k)+sum(resCorr{i,j}==resolutions(k));
            tallyIncorrCond(i,j,k)=tallyIncorrCond(i,j,k)+sum(resIncorr{i,j}==resolutions(k));
        end
    end
    perfRes(k)=tallyCorr(k)/(tallyCorr(k)+tallyIncorr(k));%calculate average performance across conditions, for each resolution. Equal weight given to each condition regardless of number of trials for each condition
end
fig3=figure;
plot(perfRes);
perfResCond=tallyCorrCond./(tallyCorrCond+tallyIncorrCond);%mean perf for each resolution, for each condition
numConds=size(allLetters,1)*size(allLetters,2);
title('mean performance against letter resolution');
fig4=figure;
for k=1:maxRes-minRes+1
    formattedPerfResCond=perfResCond(:,:,k);
    formattedPerfResCond=formattedPerfResCond(:);
    meanPerfRes(k)=mean(formattedPerfResCond);
    stdPerfRes(k)=std(formattedPerfResCond);
    errorbar(resolutions(k),meanPerfRes(k),stdPerfRes(k));hold on
end
title('performance against letter resolution with SD');
fig5=figure;
for i=1:size(allLetters,1)
    for j=1:size(allLetters,2)
        perfCond=[];
        for k=1:maxRes-minRes+1
            perfCond=[perfCond perfResCond(i,j,k)];
        end
        subplot(size(allLetters,1),size(allLetters,2),i+(j-1)*4);
        plot(minRes:maxRes,perfCond,'MarkerEdgeColor',[i/numConds i/numConds j/numConds]);hold on
        title(allLetters(i,j));
        ylim([0 1]);
    end
end

allResCorr=[];
allResIncorr=[];
fig12=figure;
for i=1:size(allLetters,1)
    for j=1:size(allLetters,2)
        %Examine correct vs incorrect trials as a function of resolution.
        figure(fig12)
        subplot(size(allLetters,1),size(allLetters,2),i+(j-1)*4);
        histBinWidth=1;
        histBins=minRes:histBinWidth:maxRes;
        hist(resIncorr{i,j},histBins);hold on
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','facealpha',0.5)
        hist(resCorr{i,j},histBins);
        h = findobj(gca,'Type','patch');
        set(h,'facealpha',0.5)
        ylims=ylim;
        %plot means:
        meanCorr=mean(resCorr{i,j});
        plot([meanCorr meanCorr],[ylims(1) ylims(2)],':','Color','b');
        meanIncorr=mean(resIncorr{i,j});
        plot([meanIncorr meanIncorr],[ylims(1) ylims(2)],':','Color','r');
        xlim([histBins(1)-histBinWidth histBins(end)+histBinWidth]);
        [h p]=ttest2(resCorr{i,j},resIncorr{i,j});
        titleStr=[allLetters(i,j),' p=',num2str(p,3)];
        if p<0.05
            titleStr=[titleStr,'*'];
        end
        if i==1&&j==1
            titleStr=[titleStr,' B- corr; R- incorr'];
        end
        title(titleStr);
        %compile distance values for corr and incorr trials across letter
        %conditions:
        allResCorr=[allResCorr resCorr{i,j}];
        allResIncorr=[allResIncorr resIncorr{i,j}];
    end
end
%plot histograms for corr and incorr trials as a function of resolution, across letter conditions:
fig13=figure;
hist(allResIncorr,histBins);hold on
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','facealpha',0.5)
hist(allResCorr,histBins);
h = findobj(gca,'Type','patch');
set(h,'facealpha',0.5)
ylims=ylim;
allMeanCorr=mean(allResCorr);
plot([allMeanCorr allMeanCorr],[ylims(1) ylims(2)],':','Color','b');
allMeanIncorr=mean(allResIncorr);
plot([allMeanIncorr allMeanIncorr],[ylims(1) ylims(2)],':','Color','r');
xlim([histBins(1)-histBinWidth histBins(end)+histBinWidth]);
[h p]=ttest2(allResCorr,allResIncorr);
titleStr=['Resolution. B- corr, R- incorr. p=',num2str(p,3)];
if p<0.05
    titleStr=[titleStr,'*'];
end
title(titleStr);

%plot histograms for corr and incorr trials as a function of stimulus size, across letter conditions:
fig16=figure;
histBinWidth=10;
histBins=40:histBinWidth:180;
hist(allSizeIncorr,histBins);hold on
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','facealpha',0.5)
hist(allSizeCorr,histBins);
h = findobj(gca,'Type','patch');
set(h,'facealpha',0.5)
ylims=ylim;
allMeanCorr=mean(allSizeCorr);
plot([allMeanCorr allMeanCorr],[ylims(1) ylims(2)],':','Color','b');
allMeanIncorr=mean(allSizeIncorr);
plot([allMeanIncorr allMeanIncorr],[ylims(1) ylims(2)],':','Color','r');
xlim([histBins(1)-histBinWidth histBins(end)+histBinWidth]);
[h p]=ttest2(allSizeCorr,allSizeIncorr);
titleStr=['Size (px). B- corr, R- incorr. p=',num2str(p,3)];
if p<0.05
    titleStr=[titleStr,'*'];
end
title(titleStr);

%analyse the letters chosen when incorrect responses were made:
fig14=figure;
for i=1:size(allLetters,1)
    for j=1:size(allLetters,2)
        subplot(size(allLetters,1),size(allLetters,2),i+(j-1)*4);
        numVersionAllLetters=uint8(allLetters(:));
        for ind=1:length(numVersionAllLetters)
            incorrResponses{i,j}(incorrResponses{i,j}==numVersionAllLetters(ind))=ind;
        end
        histBinWidth=1;
        histBins=1:histBinWidth:16;
        hist(incorrResponses{i,j},histBins);hold on
        ylims=ylim;
        set(gca,'XTick',1:length(allLetters(:)),'XTickLabel',allLetters(:));
        xlim([0 17]);
        title(allLetters(i,j));
    end
end

%save figures
dirName='C:\Users\Xing\Lick\test';
figure(fig15)%effects of sample size, individual letter conditions
fileName=[date,'_size_cond'];
imageName=fullfile(dirName,fileName);
printtext=sprintf('print -d%s %s','png',imageName);
eval(printtext)
figure(fig16)%effects of sample size, across letter conditions
fileName=[date,'_size_allcond'];
imageName=fullfile(dirName,fileName);
printtext=sprintf('print -d%s %s','png',imageName);
eval(printtext)
figure(fig6)
fileName=[date,'_vecdist_cond'];
imageName=fullfile(dirName,fileName);
printtext=sprintf('print -d%s %s','png',imageName);
eval(printtext)
figure(fig7)
fileName=[date,'_xdist_cond'];
imageName=fullfile(dirName,fileName);
printtext=sprintf('print -d%s %s','png',imageName);
eval(printtext)
figure(fig8)
fileName=[date,'_ydist_cond'];
imageName=fullfile(dirName,fileName);
printtext=sprintf('print -d%s %s','png',imageName);
eval(printtext)
figure(fig9)
fileName=[date,'_vecdist_allcond'];
imageName=fullfile(dirName,fileName);
printtext=sprintf('print -d%s %s','png',imageName);
eval(printtext)
figure(fig10)
fileName=[date,'_xdist_allcond'];
imageName=fullfile(dirName,fileName);
printtext=sprintf('print -d%s %s','png',imageName);
eval(printtext)
figure(fig11)
fileName=[date,'_ydist_allcond'];
imageName=fullfile(dirName,fileName);
printtext=sprintf('print -d%s %s','png',imageName);
eval(printtext)
figure(fig12)
fileName=[date,'_res_cond'];
imageName=fullfile(dirName,fileName);
printtext=sprintf('print -d%s %s','png',imageName);
eval(printtext)
figure(fig13)
fileName=[date,'_res_allcond'];
imageName=fullfile(dirName,fileName);
printtext=sprintf('print -d%s %s','png',imageName);
eval(printtext)
figure(fig14)
fileName=[date,'_incorrletterchoice_cond'];
imageName=fullfile(dirName,fileName);
printtext=sprintf('print -d%s %s','png',imageName);
eval(printtext)