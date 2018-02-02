function runstim_microstim_saccade_catch_batch_compare_v4(Hnd)
%Written by Xing 18/1/18
%Used to send stimulation on adjacent V1 electrodes (with relatively
%different current threshold values), while simultaneously recording from
%V4 channels, to examine whether current thresholds can be deduced from V4
%responses.
%Determine microstimulation thresholds for electrodes on which monkey
%reliably reports phosphene percept.
%On 50% of trials, deliver microstimulation (10 pulses). Monkey has to fixate for 300 ms, followed by
%an interval lasting anywhere from 0 to 400 ms. Monkey is required to make
%a saccade to RF location, and if correct saccade made, then at 100 ms, fix
%spot changes colour and reward given. On the other 50% of trials, no microstim
%administered, and monkey is rewarded for maintaining fixation after 1000 ms.
%Time allowed to reach target reduced to maximum of 200 ms.

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
brown = [105 0 0];%pink
fixcol = red;  %mag ook red zijn
fixcol = brown;  

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

arrays=8:16;
stimulatorNums=[14295 65372 65377 65374 65375 65376 65493 65494 65338];%stimulator to which each array is connected

%Create stimulator object
for deviceInd=1:length(stimulatorNums)
    stimulator(deviceInd) = cerestim96();
end

my_devices=stimulator(1).scanForDevices
pause(0.3)
for deviceInd=1:length(my_devices)
    stimulatorInd=find(my_devices==stimulatorNums(deviceInd));
    stimulator(deviceInd).selectDevice(stimulatorInd-1) %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
    pause(0.5)
end

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
performance=[];
allSampleX=[];
allSampleY=[];
allFixT=[];
allStimDur=[];
allBlockNo=[];
allElectrodeNum=[];
allInstanceNum=[];
allArrayNum=[];
allTargetArrivalTime=[];
allFalseAlarms=[];
allHitX=[];
allHitY=[];
allHitRT=[];
currentHigh=50;
currentLow=1;
numIntervals=6;%one less than number of current conditions
currentInterval=round((currentHigh-currentLow)/numIntervals);
currentValsDesired=currentLow;
for ind=1:numIntervals
    currentValsDesired=[currentValsDesired currentValsDesired(end)+currentInterval];
end
subblockCount=0;

load('C:\Users\Xing\Lick\finalCurrentVals8','finalCurrentVals');%list of current amplitudes to deliver, including catch trials where current amplitude is 0 (50% of all trials)
staircaseFinishedFlag=0;
trialsDesired=10;
trialConds=repmat(1:length(currentValsDesired),1,trialsDesired);%trial conditions. Target conds in first row: for TB trials, 1: target is above; 2: target is below
currentThresholdChs=70;
electrodeNums=47;
arrayNums=16;
% tryDifferentCurrents=[];
tryDifferentCurrents=[];
uniqueInd=unique([electrodeNums' arrayNums'],'rows','stable');
electrodeNums=uniqueInd(:,1);
arrayNums=uniqueInd(:,2);
electrodeNumInd=1;
array=arrayNums(electrodeNumInd);
electrode=electrodeNums(electrodeNumInd);
firstTrial=1;
while ~Par.ESC&&staircaseFinishedFlag==0%&&electrodeNumInd<=length(electrodeNums)
    %Pretrial
    trialNo = trialNo+1;
    if trialNo==1
        blockNo=0;
        newSubblock=1;
        corrTrialBlockCounter=0;%tallies the number of correct trials per block
        hitRT=NaN;
    end
    hitX=NaN;
    hitY=NaN;
    
    if newSubblock==1
        numTrialBlockCounter=0;  
        newOrder=randperm(length(trialConds));
        condOrder=trialConds(1,newOrder);
    end
    
    %Assign code for trial identity, using sequence of random numbers
    bits = [0 2 6];
    ch = randi(length(bits),1,8);
    ident = bits(ch);
    TRLMAT(trialNo,:) = ident;
    
    %SET UP STIMULI FOR THIS TRIAL
    catchDotTime=1200;%time before catch dot is presented
    stimDuration=randi([120 150]);
    tempTrialType=randi(4)-1;
    if tempTrialType<2%3
        catchTrial=0;%0 or 1. Randomly determined on each trial
    else
        catchTrial=1;%0 or 1. Randomly determined on each trial
    end
    if catchTrial==1
        currentAmplitude=0;
        FIXT=catchDotTime;
        electrode=NaN;
        instance=NaN;
        array=NaN;
        falseAlarm=0;
    elseif catchTrial==0
        FIXT=random('unif',300,900);%
        array=arrayNums(electrodeNumInd);
        electrode=electrodeNums(electrodeNumInd);
        %Connect to the stimulator
        stimulatorInd=find(arrays==array);
        isconnected=stimulator(stimulatorInd).isConnected();
        disp(['ISconnected? = ' num2str(isconnected)])
        pause(0.05)%adjust
        
        if ~isconnected
            % compulsory step
            stimulator(stimulatorInd).connect
            pause(0.1)
        end
        falseAlarm=NaN;
        
        %select array & electrode index (sorted by lowest to highest impedance) for microstimulation        
        instance=ceil(array/2);
        load(['C:\Users\Xing\Lick\090817_impedance\array',num2str(array),'.mat'])
        eval(['arrayRFs=array',num2str(array),';']);
        electrodeInd=find(arrayRFs(:,8)==electrode);
        RFx=arrayRFs(electrodeInd,1);
        RFy=arrayRFs(electrodeInd,2);
        if staircaseFinishedFlag==1||firstTrial==1
            load(['C:\Users\Xing\Lick\currentThresholdChs',num2str(currentThresholdChs),'.mat']);%increased threshold for electrode 51, array 10 from 48 to 108, adjusted thresholds on all 4 electrodes
            electrodeIndtemp1=find(goodArrays8to16(:,8)==electrode);%matching channel number
            electrodeIndtemp2=find(goodArrays8to16(:,7)==array);%matching array number
            electrodeIndCurrent=intersect(electrodeIndtemp1,electrodeIndtemp2);%channel number
            existingThreshold=goodCurrentThresholds(electrodeIndCurrent);
            currentInd=find(finalCurrentVals<=existingThreshold);
            if electrodeNumInd<=length(tryDifferentCurrents)&&~isempty(tryDifferentCurrents)
                tryDifferentCurrent=tryDifferentCurrents(electrodeNumInd);%use this line and the next, for manually adjusted estimate of current threshold
                currentInd=find(finalCurrentVals<=tryDifferentCurrent);
            end
            currentInd=currentInd(end);
            firstTrial=0;
            staircaseFinishedFlag=0;
        end
%         currentAmplitude=finalCurrentVals(currentInd);
        currentAmplitude=currentValsDesired(condOrder(1));
        % define a waveform
        waveform_id = 1;
        numPulses=50;%originally set to 5 pulses
        %         amplitude=50;%set current level in uA
        stimulator(stimulatorInd).setStimPattern('waveform',waveform_id,...
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
            eccentricity=sqrt(sampleX^2+sampleY^2)
            if eccentricity<Par.PixPerDeg
                TargWinSz = 1;
            elseif eccentricity<2*Par.PixPerDeg
                TargWinSz = 1.5;
            elseif eccentricity<3*Par.PixPerDeg
                TargWinSz = 3.5;
            elseif eccentricity<4*Par.PixPerDeg
                TargWinSz = 4.5;
            elseif eccentricity<5*Par.PixPerDeg
                TargWinSz = 6;
            elseif eccentricity<6*Par.PixPerDeg
                TargWinSz = 7;
            elseif eccentricity<7*Par.PixPerDeg
                TargWinSz = 8;
            else
                TargWinSz=8;
            end
            sampleX = 170;%arbitrarily large target window
            sampleY = 170;%arbitrarily large target window
            TargWinSz=17;
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
            stimulator(stimulatorInd).manualStim(electrode,waveform_id)
            if length(my_devices)>1
                %disconnect CereStim
                stimulator(stimulatorInd).disconnect;
            end
        end
        dasbit(  Par.TargetB, 1);
        
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
            numTrialBlockCounter=numTrialBlockCounter+1;
            if currentAmplitude==0%catch trial 
                fprintf('Trial %3d (catch) is completed\n',trialNo);
                catchHit=catchHit+1;
            elseif currentAmplitude>0
                fprintf('Trial %3d at %5.2f uA is a hit\n',trialNo,currentAmplitude);
                microstimHit=microstimHit+1;
                numHitsElectrode=numHitsElectrode+1;%counter for a given electrode
                hitCounter=hitCounter+1;
                missesAtMaxCurrent=[missesAtMaxCurrent 0];
                response=NaN;
            end
            if length(condOrder)>1
                condOrder=condOrder(2:end);
                newSubblock=0;
            elseif length(condOrder)==1
                newSubblock=1;
                subblockCount=subblockCount+1;
                if subblockCount>=5
                    newBlock=1;
                    subblockCount=0;
                end
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
            end
            if length(condOrder)>1
                condOrder=condOrder(2:end);
                newSubblock=0;
            end
        end
        for n=1:length(ident)
            dasbit(ident(n),1);
            pause(0.05);%add a time buffer between sending of dasbits
            dasbit(ident(n),0);
            pause(0.05);%add a time buffer between sending of dasbits
        end
        if hitCounter==2%if two hits accrued
            currentInd=currentInd-1;%decrease current
            allStaircaseResponse=[allStaircaseResponse 1];
        elseif missCounter==2%if two misses accrued
            currentInd=currentInd+1;%increase current
            allStaircaseResponse=[allStaircaseResponse 0];
        end
        if currentInd>length(finalCurrentVals)
            currentInd=length(finalCurrentVals);
        end
        if currentInd<1
            currentInd=1;
        end
        if hitCounter==2||missCounter==2
            hitCounter=0;
            missCounter=0;
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
%     if numHitsElectrode+numMissesElectrode>=10%if performance on microstim trials is poor from beginning, with high current levels, move on to next electrode
%         if sum(missesAtMaxCurrent)/length(missesAtMaxCurrent)>=0.9
%             electrodeInd=electrodeInd+1;
%             catchHit=0;
%             microstimHit=0;
%             microstimMiss=0;
%             numHitsElectrode=0;
%             numMissesElectrode=0;
%             catchFalseAlarms=0;
%             hitCounter=0;
%             missCounter=0;
%             allStaircaseResponse=[];
%             allCurrentLevel=[];
%             missesAtMaxCurrent=0;
%             currentInd=length(finalCurrentVals);%start with the highest current at beginning of staircase procedure
%             staircaseFinishedFlag=1;
%         end
%     end
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
    if numHitsElectrode+numMissesElectrode>=trialsDesired*length(currentValsDesired)%sum(logical(diff(allStaircaseResponse)))>=minNumReversals%||(numHitsElectrode/numMissesElectrode<0.1&&numHitsElectrode+numMissesElectrode>=50)||numHitsElectrode+numMissesElectrode>80%if there are min num of reversals, or the proportion of hits to misses is low after a sufficient number of trials, terminate staircase procedure
        allStaircaseResponse=[];
        fprintf(['Electrode: ',num2str(electrode),' Hits: ',num2str(numHitsElectrode),' Misses: ',num2str(numMissesElectrode)]);
        staircaseFinishedFlag=1;
%         electrodeNumInd=electrodeNumInd+1;
        numHitsElectrode=0;
        numMissesElectrode=0;
        hitCounter=0;
        missCounter=0;
    end
end

if exist('my_devices','var')
    for deviceInd=1:length(my_devices)
        stimulator(deviceInd).selectDevice(deviceInd-1); %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
        stimulator(deviceInd).disconnect;
        pause(0.05)
    end
end
Screen('Preference','SuppressAllWarnings',oldEnableFlag);
Screen('Preference', 'Verbosity', oldLevel);