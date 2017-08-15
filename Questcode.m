% Modified from QuestDemo.m

% GetSecs is part of the Psychophysics Toolbox.  If you are running 
% QuestDemo without the Psychtoolbox, we use CPUTIME instead of GetSecs.
if exist('GetSecs')
	getSecsFunction='GetSecs';
else
	getSecsFunction='cputime';
end

tActual=[];
while isempty(tActual)
	tActual=input('Please specify the true threshold of the simulated observer (e.g. -2): ');
end

% Provide our prior knowledge to QuestCreate, and receive the data struct "q".
tGuess=25;%guess threshold value
tGuessSd=25;%guess SD
pThreshold=0.82;
beta=3.5;delta=0.01;gamma=0.5;
q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);
q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.

% fprintf('Your initial guess was %g +- %g\n',tGuess,tGuessSd);
% fprintf('Quest''s initial threshold estimate is %g +- %g\n',QuestMean(q),QuestSd(q));

% Simulate a series of trials. 
% On each trial we ask Quest to recommend an intensity and we call QuestUpdate to save the result in q.
trialsDesired=40;
wrongRight={'wrong','right'};
timeZero=eval(getSecsFunction);

% Get recommended level.  Choose your favorite algorithm. Carry out for
% each trial:
tTest=QuestQuantile(q);	% Recommended by Pelli (1987), and still our favorite.

timeZero=timeZero+eval(getSecsFunction)-timeSplit;
updateQuestFlag=0;
response=NaN;
if questCounterHit==2
    updateQuestFlag=1;
    response=1;
elseif questCounterMiss==2
    updateQuestFlag=1;
    response=0;
end
timeSplit=eval(getSecsFunction); % Omit simulation and printing from the timing measurements.
response=QuestSimulate(q,tTest,tActual);
fprintf('Trial %3d at %5.2f uA is %s\n',k,tTest,char(wrongRight(response+1)));
if updateQuestFlag==1
    % Update the pdf
    q=QuestUpdate(q,tTest,response); % Add the new datum (actual test intensity and observer response) to the database.
end

% Print results of timing.
fprintf('%.0f ms/trial\n',1000*(eval(getSecsFunction)-timeZero)/trialsDesired);

%After enough reversals have been carried out:
% Ask Quest for the final estimate of threshold.
t=QuestMean(q);		% Recommended by Pelli (1989) and King-Smith et al. (1994). Still our favorite.
sd=QuestSd(q);
fprintf('Final threshold estimate (mean+-sd) is %.2f +- %.2f\n',t,sd);
