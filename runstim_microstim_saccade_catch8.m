function runstim_microstim_saccade_catch8(Hnd)
%Written by Xing 15/8/17
%Determine microstimulation thresholds for electrodes on which monkey
%reliably reports phosphene percept.
%On 50% of trials, deliver microstimulation (10 pulses). Monkey has to fixate for 300 ms, followed by
%an interval lasting anywhere from 0 to 400 ms. Monkey is required to make
%a saccade to RF location, and if correct saccade made, then at 100 ms, fix
%spot changes colour and reward given. On the other 50% of trials, no microstim
%administered, and monkey is rewarded for maintaining fixation after 1000 ms.
%Time allowed to reach target reduced to maximum of 200 ms.
%Implements Quest, using log10 values. Does not use a questCounterHit or
%questCounterMiss.

global Par   %global parameters
global trialNo
global behavResponse
global performance
global allSampleX
global allSampleY
global allFixT
global allStimDur
global trialsRemaining
global allTrialCond
global blockNo
global corrTrialBlockCounter
global allBlockNo
global allHitX
global allHitY
global allHitRT
global allCurrentLevel
global allElectrodeNum
global allInstanceNum
global allArrayNum
global allTargetArrivalTime
global currentAmplitude
global visualHit
global microstimHit
global microstimMiss
global catchHit
global catchFalseAlarms
global numHitsElectrode
global numMissesElectrode
global electrodeInd
global hitCounter
global missCounter
global currentInd
global allStaircaseResponse
global missesAtMaxCurrent
global allMeanThresholdEstimate
global meanThresholdEstimate
global allQ
global allStimCurrentLevel

format compact
oldEnableFlag = Screen('Preference', 'SuppressAllWarnings',1);
oldLevel = Screen('Preference', 'Verbosity',0);
mydir = 'C:\Users\Xing\Lick\saccade_task_logs\';
fn = input('Enter LOG file name (e.g. 20110413_B1), blank = no file\n','s');
%Copy the run_stim script
fnrs = [fn,'_','runstim.m'];
cfn = [mfilename('fullpath') '.m'];
copyfile(cfn,fnrs)

screenWidth=Par.HW*2;
screenHeight=Par.HH*2;
screenResX=screenWidth;
screenResY=screenHeight;
w=Par.w;
FixDotSize = 0.2;
rewSz=0.4;
% global LPStat  %das status values
Times = Par.Times; %copy timing structure

%WINDOWS
%Fix window
FixWinSz =1.5;%1.5

%Fixatie kleur
red = [255 0 0];
fixcol = red;  %mag ook red zijn

%timing
PREFIXT = 1000; %time to enter fixation window

%REactie tijd
TARGT = 0; %time to keep fixating after target onset before fix goes green (het liefst 400)
RACT = 250;      %reaction time 250 ms

Fsz = FixDotSize.*Par.PixPerDeg;
rewDotSize=0.4.*Par.PixPerDeg;

%Target positions (Diagonals)
% targx = [-150 -150 150 150 -100 -100 100 100 -200 -200 200 200];
% targy = [-150 150 150 -150 -100 100 100 -100 -200 200 200 -200];
catchDotY=-100;

grey = round([255/2 255/2 255/2]);

LOG.fn = 'runstim_microstim_saccade';
LOG.BG = grey;
LOG.Par = Par;
LOG.Times = Par.Times;
% LOG.Frame = frame;
LOG.PREFIXT=PREFIXT;
if isempty(fn)
    logon = 0;
else
    logon = 1;
    fn = [mydir,'microstim_saccade_',fn];
    save(fn,'LOG');
end

%Create stimulator object
stimulator = cerestim96()

my_devices = stimulator.scanForDevices
pause(.3)
stimulator. selectDevice(0); %the number inside the brackets is the stimulator instance number; numbering starts from 0
pause(.5)

%Connect to the stimulator
stimulator.connect;

%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
Hit = 2;
Par.ESC = false; %escape has not been pressed
trialNo=0;
catchHit=0;
microstimHit=0;
microstimMiss=0;
numHitsElectrode=0;
numMissesElectrode=0;
catchFalseAlarms=0;
hitCounter=0;
missCounter=0;
allStaircaseResponse=[];
allCurrentLevel=[];
missesAtMaxCurrent=0;        
allStimCurrentLevel=[];
allQ=[];
allMeanThresholdEstimate=[];
meanThresholdEstimate=[];

electrodeInd=27;%electrodes 37 and 38 (indices 12 & 13, respectively) on array 13
% load('C:\Users\Xing\Lick\finalCurrentVals7','finalCurrentVals');%list of current amplitudes to deliver, including catch trials where current amplitude is 0 (50% of all trials)
% switch electrodeInd
%     case 12
%         load('C:\Users\Xing\Lick\finalCurrentVals2','finalCurrentVals');%list of current amplitudes to deliver, including catch trials where current amplitude is 0 (50% of all trials)
% end
% originalFinalCurrentVals=finalCurrentVals;
% currentInd=length(finalCurrentVals);%start with the highest current at beginning of staircase procedure
% currentInd=find(finalCurrentVals<=140);
% currentInd=currentInd(end);
% Provide our prior knowledge to QuestCreate, and receive the data struct "q".
tGuess=log10(110);%guess threshold value
tGuessSd=log10(20);%guess SD
pThreshold=0.82;
beta=3.5;delta=0.2;gamma=0.5;
q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,[],[1 214]);%range is between 1 and 214 uA
q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.

fprintf('Your initial guess was %g +- %g\n',10^tGuess,10^tGuessSd);
fprintf('Quest''s initial threshold estimate is %g +- %g\n',10^QuestMean(q),10^QuestSd(q));

% On each trial we ask Quest to recommend an intensity and we call QuestUpdate to save the result in q.
trialsDesired=40;
wrongRight={'wrong','right'};
staircaseFinishedFlag=0;%remains 0 until 40 reversals in staircase procedure have occured, at which point it is set to 1

while ~Par.ESC&&staircaseFinishedFlag==0
    %Pretrial
    trialNo = trialNo+1;
    if trialNo==1
        blockNo=1;
        corrTrialBlockCounter=0;%tallies the number of correct trials per block
        hitRT=NaN;
    end
    hitX=NaN;
    hitY=NaN;
    
    %Assign code for trial identity, using sequence of random numbers
    bits = [0 2 6];
    ch = randi(length(bits),1,8);
    ident = bits(ch);
    TRLMAT(trialNo,:) = ident;
    
    %SET UP STIMULI FOR THIS TRIAL
    catchDotTime=1000;%time before catch dot is presented
    stimDuration=randi([120 150]);
    catchTrial=randi(2)-1;%0 or 1. Randomly determined on each trial
    if catchTrial==1
        currentAmplitude=0;
    elseif catchTrial==0
%         currentAmplitude=finalCurrentVals(currentInd);
        %Get Quest's suggested intensity
        currentAmplitude= round(10.^QuestQuantile(q))% Recommended by Pelli (1987).        
        if currentAmplitude>210
            currentAmplitude=210;
        end
        if currentAmplitude<1
            currentAmplitude=1;
        end
    end
    if currentAmplitude==0
        FIXT=1000;
        electrode=NaN;
        instance=NaN;
        array=NaN;
        falseAlarm=0;
    elseif currentAmplitude>0
        FIXT=random('unif',300,700);%
        %Connect to the stimulator
        if length(my_devices)>1
            stimulator.connect;
        end
        falseAlarm=NaN;
        
        %select array & electrode index (sorted by lowest to highest impedance) for microstimulation
        array=12;
        switch array
            case 10
                maxElectrodes=7;
            case 12
                maxElectrodes=29;
            case 13
                maxElectrodes=16;
        end
        
        instance=ceil(array/2);
        load(['C:\Users\Xing\Lick\090817_impedance\array',num2str(array),'.mat'])
        eval(['arrayRFs=array',num2str(array),';']);
        electrode=arrayRFs(electrodeInd,8);
%         while electrode<33%if only 2nd bank is connected to CereStim, not 1st bank
%             electrodeInd=electrodeInd+1;
%             if electrodeInd>maxElectrodes
%                 staircaseFinishedFlag=1;
%             end
%         end
        electrode=arrayRFs(electrodeInd,8);
        RFx=arrayRFs(electrodeInd,1);
        RFy=arrayRFs(electrodeInd,2);
        
        % define a waveform
        waveform_id = 1;
        numPulses=40;%originally set to 5 pulses
        %         amplitude=50;%set current level in uA
        stimulator.setStimPattern('waveform',waveform_id,...
            'polarity',0,...
            'pulses',numPulses,...
            'amp1',currentAmplitude,...
            'amp2',currentAmplitude,...
            'width1',170,...
            'width2',170,...
            'interphase',60,...
            'frequency',300);
        %'polarity' -	Polarity of the first phase, 0 (cathodic), 1 (anodic)
    end
    
    if Par.Drum && Hit ~= 2 %if drumming and this was an error trial
        %just redo with current settings
    else
        if currentAmplitude==0
            sampleX=NaN;
            sampleY=NaN;
        elseif currentAmplitude>0
            sampleX = RFx;%location of sample stimulus, in RF quadrant 150 230
            sampleY = -RFy;
            eccentricity=sqrt(sampleX^2+sampleY^2);
            if eccentricity<Par.PixPerDeg
                TargWinSz = 1;
            elseif eccentricity<2*Par.PixPerDeg
                TargWinSz = 1.5;
            elseif eccentricity<3*Par.PixPerDeg
                TargWinSz = 2;
            elseif eccentricity<4*Par.PixPerDeg
                TargWinSz = 2.5;
            elseif eccentricity<5*Par.PixPerDeg
                TargWinSz = 3;
            elseif eccentricity<6*Par.PixPerDeg
                TargWinSz = 3.5;
            elseif eccentricity<7*Par.PixPerDeg
                TargWinSz = 4;
            else
                TargWinSz=4.5;
            end
        end
        %control window setup
        if currentAmplitude==0
            WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
                0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 2];  %2: target;
        elseif currentAmplitude>0
            WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
                sampleX,  -sampleY, Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];
        end
        Par.WIN = WIN';
    end
    
    %/////////////////////////////////////////////////////////////////////
    %START THE TRIAL
    %set control window positions and dimensions
    refreshtracker(1) %for your control display
    SetWindowDas      %for the dascard
    Abort = false;    %whether subject has aborted before end of trial
    
    %///////// EVENT 0 START FIXATING//////////////////////////////////////
    Screen('FillRect',w,grey);
    Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
    Screen('Flip', w);
    
    % Bump priority for speed
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    dasreset(0);   %test enter fix window
    %     0 enter fix window
    %     1 leave fix window
    %     2 enter target window
    
    %subject has to start fixating central dot
    Par.SetZero = false; %set key to false to remove previous presses
    %Par.Updatxy = 1; %centering key is enabled
    Time = 1;
    Hit = 0;
    while Time < PREFIXT && Hit == 0
        dasrun(5)
        [Hit Time] = DasCheck; %retrieve position values and plot on Control display
    end
    %disp( [num2str(hitbreak) '  enter  ' num2str(toc)])
    
    %///////// EVENT 1 KEEP FIXATING or REDO  ////////////////////////////////////
    
    if Hit ~= 0  %subjects eyes are in fixation window keep fixating for FIX time
        dasreset(1);     %set test parameters for exiting fix window        
        Time = 1;
        Hit = 0;
%         disp(FIXT);
        while Time < FIXT && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
        end
        if currentAmplitude==0&&Hit==1%catch trial
            falseAlarm=1;
        end
    else
        Hit = -1; %the subject did not fixate
    end
    
    
    %///////// EVENT 2 DISPLAY TARGET(S) //////////////////////////////////////
    if Hit == 0 %subject kept fixation, display stimulus
        if currentAmplitude==0%catch trial
            %do nothing
        elseif currentAmplitude>0
            %deliver microstimulation
            stimulator.manualStim(electrode,waveform_id)
            if length(my_devices)>1
                %disconnect CereStim
                stimulator.disconnect;
            end
        end
        dasbit(  Par.TargetB, 1);
        tic
        
        %///////// EVENT 3 REACTION TIME%%//////////////////////////////////////
        
        if Hit == 0 %subject kept fixation, subject may make an eye movement
            dasreset(2); %check target window  enter
            refreshtracker(3) %set fix point to green
            if currentAmplitude==0%catch trial
                Time = 0;
                Hit = 0;
                Screen('FillOval',w,[0 255 0],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                Screen('Flip', w);
                while Time < RACT && Hit <= 0  %if no saccade made to RF, keep waiting till catch dot is presented
                    %Check for 5 ms
                    dasrun(5)
                    [Hit Time] = DasCheck;
                end                
            elseif currentAmplitude>0                
                Time = 0;
                while Time < RACT && Hit <= 0  %RACT = time to respond to microstim (reaction time)
                    %Check for 5 ms
                    dasrun(5)
                    [Hit Time] = DasCheck;
                end
                if Hit==2                    
                    while Time < catchDotTime-RACT-FIXT %if correct saccade made to RF, keep waiting till time of reward delivery
                        %Check for 5 ms
                        dasrun(5)
                        [Hit Time] = DasCheck;
                    end
                    Screen('FillOval',w,[0 255 255],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                    Screen('Flip', w);
                elseif Hit <= 0%did not make saccade to correct location
                    Hit=1;%miss
                    while Time < catchDotTime-RACT-FIXT && Hit <= 0 
                        %do nothing
                    end
                end
            end
        else
            Abort = true;
        end
        %END EVENT 3
    else
        Abort = true;
    end
    %END EVENT 2
    
    targetIdentity=LPStat(6);
    LPStat();
    dirName=cd;
    %     save([dirName,'\test\',date,'_perf.mat'],'behavResponse','performance')
    
    %///////// POSTTRIAL AND REWARD //////////////////////////////////////
    if Hit ~= 0 && ~Abort %has entered a target window (false or correct)
        
        HP = line('XData', Par.ZOOM *LPStat(2), 'YData', Par.ZOOM *LPStat(3));
        set(HP, 'Marker', '+', 'MarkerSize', 20, 'MarkerEdgeColor', 'm')
        
        performance(trialNo)=0;
        if Hit == 2 &&LPStat(5) < Times.Sacc %correct target, give juice
            dasbit(  Par.CorrectB, 1);
            dasjuice(5.1);
            Par.Corrcount = Par.Corrcount + 1; %log correct trials
            % beep
            
            pause(Par.RewardTime) %RewardTime is in seconds
            
            dasjuice(0.0);
            performance(trialNo)=1;%hit
            hitX=LPStat(3);%hit x position
            hitY=LPStat(4);%hit y position
            hitRT=LPStat(5);%RT
            if currentAmplitude==0%catch trial 
                fprintf('Trial %3d (catch) is completed\n',trialNo);
                catchHit=catchHit+1;
            elseif currentAmplitude>0
                fprintf('Trial %3d at %5.2f uA is a hit\n',trialNo,currentAmplitude);
                microstimHit=microstimHit+1;
                numHitsElectrode=numHitsElectrode+1;%counter for a given electrode
                hitCounter=hitCounter+1;
                missesAtMaxCurrent=[missesAtMaxCurrent 0];
                meanThresholdEstimate=[meanThresholdEstimate 10.^QuestMean(q)];
                allStimCurrentLevel=[allStimCurrentLevel currentAmplitude];
                response=1;%feed 'hit' response into Quest
                q=QuestUpdate(q,log10(currentAmplitude),response);%Update Quest
            end
        elseif Hit == 1
            if currentAmplitude>0%miss trial
                dasbit(Par.ErrorB, 1);
                Par.Errcount = Par.Errcount + 1;
                performance(trialNo)=-1;%error
                fprintf('Trial %3d at %5.2f uA is a miss\n',trialNo,currentAmplitude);
                microstimMiss=microstimMiss+1;
                numMissesElectrode=numMissesElectrode+1;%counter for a given electrode
                missCounter=missCounter+1;
                missesAtMaxCurrent=[missesAtMaxCurrent 1];
                meanThresholdEstimate=[meanThresholdEstimate 10.^QuestMean(q)];
                allStimCurrentLevel=[allStimCurrentLevel currentAmplitude];
                response=0;%feed 'miss' response into Quest
                q=QuestUpdate(q,log10(currentAmplitude),response);%Update Quest
            end
        end
        for n=1:length(ident)
            dasbit(ident(n),1);
            pause(0.05);%add a time buffer between sending of dasbits
            dasbit(ident(n),0);
            pause(0.05);%add a time buffer between sending of dasbits
        end
    end
    if falseAlarm==1
        catchFalseAlarms=catchFalseAlarms+1;
        dasbit(Par.ErrorB,1);
        fprintf('Trial %3d is a false alarm\n',trialNo);
    end
    
    Screen('FillRect',w, grey);
    Screen('Flip', w);
    trialNo;
    allSampleX(trialNo)=sampleX;
    allSampleY(trialNo)=sampleY;
    allFixT(trialNo)=FIXT;
    allStimDur(trialNo)=stimDuration;
    allBlockNo(trialNo)=blockNo;
    allCurrentLevel(trialNo)=currentAmplitude;
    allMeanThresholdEstimate(trialNo)=10.^QuestMean(q);
    allQ{trialNo}=q;
    allElectrodeNum{trialNo}=electrode;
    allInstanceNum{trialNo}=instance;
    allArrayNum{trialNo}=array;
    allTargetArrivalTime(trialNo)=Time;
    allFalseAlarms(trialNo)=falseAlarm;
    if Hit==2
        allHitX(trialNo)=hitX;
        allHitY(trialNo)=hitY;
        allHitRT(trialNo)=hitRT;
    else
        allHitX(trialNo)=NaN;
        allHitY(trialNo)=NaN;
        allHitRT(trialNo)=NaN;
    end
    if numHitsElectrode+numMissesElectrode>=10%if performance on microstim trials is poor from beginning, with high current levels, move on to next electrode
        if sum(missesAtMaxCurrent)/length(missesAtMaxCurrent)>=0.9
%             staircaseFinishedFlag=1;
            electrodeInd=electrodeInd+1;
            catchHit=0;
            microstimHit=0;
            microstimMiss=0;
            numHitsElectrode=0;
            numMissesElectrode=0;
            catchFalseAlarms=0;
            hitCounter=0;
            missCounter=0;
            allStaircaseResponse=[];
            allCurrentLevel=[];
            missesAtMaxCurrent=0;
            if electrodeInd>maxElectrodes
                staircaseFinishedFlag=1;
            end
        end
    end
    send_serial_data(trialNo);%send trial number to NSPs via serial port
    dirName=cd;
    %///////////////////////INTERTRIAL AND CLEANUP
    
    %reset all bits to null
    for i = [0 1 2 3 4 5 6 7]  %Error, Stim, Saccade, Trial, Correct,
        dasbit(  i, 0);
    end
    dasclearword();
    
    SCNT = {'TRIALS'};
    %     SCNT(2) = { ['N: ' num2str(Par.Trlcount) ]};
    %     SCNT(3) = { ['C: ' num2str(Par.Corrcount) ] };
    %     SCNT(4) = { ['E: ' num2str(Par.Errcount) ] };
    SCNT(2) = { ['N: ' num2str(catchHit+microstimHit+microstimMiss) ]};
    %     SCNT(3) = { ['Hit: ' num2str(microstimHit) ] };
    %     SCNT(4) = { ['Miss: ' num2str(microstimMiss) ] };
    SCNT(3) = { ['Hit: ' num2str(numHitsElectrode) ] };
    SCNT(4) = { ['Miss: ' num2str(numMissesElectrode) ] };
    SCNT(5) = { ['Electrode: ' num2str(electrode) ] };
    set(Hnd(1), 'String', SCNT ) %display updated numbers in GUI
    
    % Blank screen
    Screen('FillRect',w, grey);
    Screen('Flip', w);
    
    if trialNo > 0
        save(fn,'*');
    end
    minNumReversals=40;
    if length(allStimCurrentLevel)>=trialsDesired||(numHitsElectrode/numMissesElectrode<0.05&&numHitsElectrode+numMissesElectrode>=20)%sum(logical(diff(allStaircaseResponse)))>=minNumReversals%||numHitsElectrode+numMissesElectrode>80%if there are min num of reversals, or the proportion of hits to misses is low after a sufficient number of trials, terminate staircase procedure
        fprintf(['Electrode: ',num2str(electrode),' Hits: ',num2str(numHitsElectrode),' Misses: ',num2str(numMissesElectrode)]);
        staircaseFinishedFlag=1;
%         numHitsElectrode=0;
%         numMissesElectrode=0;
    end
end
%After enough reversals have been carried out:
% Ask Quest for the final estimate of threshold.
t=QuestMean(q);		% Recommended by Pelli (1989) and King-Smith et al. (1994). Still our favorite.
sd=QuestSd(q);
fprintf('Final threshold estimate (mean+-sd) is %.2f +- %.2f\n',10^t,10^sd);

% figure,subplot(1,2,1),errorbar(1:length(meanThresholdEstimate),mean(meanThresholdEstimate),std(meanThresholdEstimate))
% % hold on,line([1 ntrials],[realthresh realthresh]),xlim([0 ntrials+1])
% subplot(1,2,2),errorbar(1:ntrials,mean(allStimCurrentLevel),std(allStimCurrentLevel)),xlim([0 ntrials+1])

if length(my_devices)==1
    %disconnect CereStim
    stimulator.disconnect;
end
Screen('Preference','SuppressAllWarnings',oldEnableFlag);
Screen('Preference', 'Verbosity', oldLevel);