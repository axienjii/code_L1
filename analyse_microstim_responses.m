function analyse_microstim_responses
%Written by Xing 8/8/17 to plot current amplitudes across microstimulation
%session.

close all
load('C:\Users\Xing\Lick\saccade_task_logs\microstim_saccade_070817_B1.mat')
% load('C:\Users\Xing\Lick\saccade_task_logs\microstim_saccade_140817_B8.mat')
microstimHitTrials=intersect(find(allWhichTarget==1),find(performance==1));
a=find(performance==1);
b=find(allWhichTarget==1);
microstimMissTrials=intersect(find(allWhichTarget==2),find(performance==1));
microstimResponseTrials=intersect(find(allWhichTarget>0),find(performance==1));
max(microstimResponseTrials)


tGuess=40;
tGuessSd=30;
range=30;
pThreshold=0.82;
beta=3.5;delta=0.01;gamma=0.5;
q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,[],range);
q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
col=[];
for k=1:length(microstimResponseTrials)
    % Update the pdf
    if allWhichTarget(microstimResponseTrials(k))==1
        response=1;
        col=[col;0 0 0];
    elseif allWhichTarget(microstimResponseTrials(k))==2
        response=0;
        col=[col;1 0 0];
    end
    q=QuestUpdate(q,allCurrentLevel(microstimResponseTrials(k)),response); % Add the new datum (actual test intensity and observer response) to the database.
end
scatter(1:length(microstimResponseTrials),allCurrentLevel(microstimResponseTrials),8,col);
figure;hold on
scatter(1:length(microstimResponseTrials),allCurrentLevel(microstimResponseTrials));
figure;hold on
plot(1:length(microstimResponseTrials),allCurrentLevel(microstimResponseTrials));

% Ask Quest for the final estimate of threshold.
t=QuestMean(q);		% Recommended by Pelli (1989) and King-Smith et al. (1994). Still our favorite.
sd=QuestSd(q);
fprintf('Final threshold estimate (mean+-sd) is %.2f +- %.2f\n',t,sd);