function runstim_microstim_saccade_attention_phosphenes_visual_version(Hnd)
%Written by Xing 9/8/18
%Visual version of task, for preliminary training.
%Attention task in which the monkey attends to a phosphene percept that is
%located either close to fixation, or further away in the periphery.
%The two attention conditions are blocked. First, the monkey has to fixate
%for 300 ms. The target can appear during one of two possible stimulus
%presentation intervals- immediately at 300 ms, or after a 600-ms interval, at 900 ms.
%A distractor appears on 50% of trials, in the other interval from the
%target. I.e. if the target appears at 300 ms, the distractor appears at
%900 ms, and vice versa (unless a saccade is made, terminating the trial).
%During the first 20 trials in each block, only a target is presented, 
%without a distractor. During the attend-close block, on the first 20
%trials, stimulation is delivered through a V1 electrode with an RF that is 
%close to fixation (e.g. array 16), at either 300 or 900 ms, and no 
%stimulation is delivered through a second electrode. On 50% of trials
%thereafter, microstimulation is delivered on a second electrode as well
%(using an array with RFs that are further away from fixation, e.g. array
%11. 
%During the attend-far task, on the first 20 trials, microstimulation is
%delivered on the electrode that elicits a peripheral phosphene. On 50% of trials 
%thereafter, microstimulation is delivered through the electrode that elicits a nearby phosphene, as well.
%Simultaneous recording from V4 channels, to check whether attending to a
%phosphene percept results in modulation of V4 activity.
%On attend-close blocks, the target is a nearby phosphene, whereas on attend-far blocks, the 
%target is a phosphene that is further away. The monkey is required to make
%a saccade to the target location, and if correct saccade made, fix
%spot changes colour and reward is given. No catch trials used.
%Time allowed to reach target reduced to maximum of 250 ms.

global Par   %global parameters
global trialNo
global behavResponse
global performance
global allSampleX
global allSampleY
global allFixT
global allFixTm
global allFixTv
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
global visualMiss
global microstimHit
global microstimMiss
global catchFalseAlarms
global numHitsElectrode
global numMissesElectrode
global electrodeInd
global hitCounter
global missCounter
global currentInd
global allStaircaseResponse
global missesAtMaxCurrent
global allDistractTrials
global allDrummingTrials
global allCurrentLevel2
global allElectrodeNum2
global allInstanceNum2
global allArrayNum2

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
durIndividualPhosphene=167;

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
% stimulatorNums=[14295 65372 65377 65374 65375 65376 65493 65494 65338];%stimulator to which each array is connected
stimulatorNums=[14295 65372 14173 65374 65375 65376 65493 14305 65338];%stimulator to which each array is connected

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
visualHit=0;
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
allCurrentLevel2=[];
allElectrodeNum2=[];
allInstanceNum2=[];
allArrayNum2=[];
allTargetArrivalTime=[];
allFalseAlarms=[];
allHitX=[];
allHitY=[];
allHitRT=[];
distractFirst=0;
allDistractTrials=[];
allDrummingTrials=[];

load('C:\Users\Xing\Lick\finalCurrentVals8','finalCurrentVals');%list of current amplitudes to deliver, including catch trials where current amplitude is 0 (50% of all trials)
staircaseFinishedFlag=0;
trialsDesired=20;
trialsDesiredInitialBlock=20;
currentThresholdChs=134;
electrode=34;
array=12;
electrode2=4;
array2=15;
drumming=1;
drummingCurrentAmplitudes=[15 15 15 10 5 1];
drummingCurrentAmplitudes2=[15 15 15 10 5 1];
drummingRecord=[];
firstTrial=1;

while ~Par.ESC&&staircaseFinishedFlag==0%&&electrodeNumInd<=length(electrodeNums)
    %Pretrial
    trialNo = trialNo+1;
    if trialNo==1
        blockNo=0;
        newBlock=1;
        corrTrialBlockCounter=0;%tallies the number of correct trials per block
        hitRT=NaN;
    end
    hitX=NaN;
    hitY=NaN;
    performance(trialNo)=NaN;
    if ~isempty(drummingRecord)
        drummingTrial=1;
    else
        drummingTrial=0;
    end
    
    if newBlock==1
        blockNo=blockNo+1;
        numTrialBlockCounter=0;
%         trialConds=[zeros(1,trialsDesired+trialsDesiredInitialBlock) ones(1,trialsDesired+trialsDesiredInitialBlock)];%trial conditions. 1: visual target, on left; 2: phosphene target, on right
        trialConds=[ones(1,trialsDesired+trialsDesiredInitialBlock) zeros(1,trialsDesired+trialsDesiredInitialBlock)];%trial conditions. 1: visual target, on left; 2: phosphene target, on right
        distractTrialsV=randperm(trialsDesired);%later trials (50% probability of distractor being first)
        distractTrialsV(find(distractTrialsV<=trialsDesired/2))=1;
        distractTrialsV(find(distractTrialsV>trialsDesired/2))=0;
        distractTrialsM=randperm(trialsDesired);
        distractTrialsM(find(distractTrialsM<=trialsDesired/2))=1;
        distractTrialsM(find(distractTrialsM>trialsDesired/2))=0;
        distractTrialsVInitial=randperm(trialsDesiredInitialBlock);%initial trials (no distractor present)
        distractTrialsVInitial(find(distractTrialsVInitial<=trialsDesiredInitialBlock/2))=1;
        distractTrialsVInitial(find(distractTrialsVInitial>trialsDesiredInitialBlock/2))=0;
        distractTrialsMInitial=randperm(trialsDesiredInitialBlock);%initial trials (no distractor present)
        distractTrialsMInitial(find(distractTrialsMInitial<=trialsDesiredInitialBlock/2))=1;
        distractTrialsMInitial(find(distractTrialsMInitial>trialsDesiredInitialBlock/2))=0;
        trialConds=[trialConds;distractTrialsVInitial distractTrialsV distractTrialsMInitial distractTrialsM];%second row in trialConds controls whether distractor is first (0) or second (1)
        trialConds=[trialConds;ones(1,trialsDesiredInitialBlock) zeros(1,trialsDesired) ones(1,trialsDesiredInitialBlock) zeros(1,trialsDesired)];%third row in trialConds controls whether this is one of the first trials (in which the distractor is absent) or one of the later trials (in which the distractor has a 50% chance of being first)
%         trialConds=[ones(1,trialsDesired) ones(1,trialsDesired)];%trial conditions. Target conds in first row: for TB trials, 1: target is above; 2: target is below
        condOrder=trialConds(1,:);%do not randomly interleave conditions, but keep them in blocks
        distractOrder=trialConds(2,:);
        initialTrials=trialConds(3,:);
    end
    
    %Assign code for trial identity, using sequence of random numbers
    bits = [0 2 6];
    ch = randi(length(bits),1,8);
    ident = bits(ch);
    TRLMAT(trialNo,:) = ident;
    
    %SET UP STIMULI FOR THIS TRIAL
    visualTrial=condOrder(1);
    distractFirst=distractOrder(1);
    initialTrial=initialTrials(1);
    if distractFirst==0%present target first
        FIXT=300;
    elseif distractFirst==1%present target second
        FIXT=500;
    end
    FIXT
    distractT=300;
    if visualTrial==0
        FIXTm=FIXT;
        FIXTv=distractT;
    elseif visualTrial==1
        FIXTm=distractT;
        FIXTv=FIXT;
    end
    
    %for target phosphene:
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
    RFx=0;
    currentAmplitude=0;
    
    numSimPhosphenes=1;
    %randomly set sizes of 'phosphenes'
    maxDiameter=5;%pixels
    minDiameter=5;%pixels   
    diameterSimPhosphenes=random('unid',maxDiameter-minDiameter+1,[numSimPhosphenes,1]);
    diameterSimPhosphenes=diameterSimPhosphenes+minDiameter-1;
    diameterSimPhosphenesDistract=diameterSimPhosphenes;
    drummingDiameters=[5 5 5 3 2 1];
    if visualTrial==0%if the distractor is a visually presented dot and there have been several consecutive drumming trials
        if length(drummingRecord)>3
            if length(drummingRecord)<=length(drummingDiameters)
                diameterSimPhosphenesDistract=drummingDiameters(length(drummingRecord));
            else
                diameterSimPhosphenesDistract=1;
            end
        end
    end
    radiusSimPhosphenes=ceil(diameterSimPhosphenes/2);
    for phospheneInd=1:numSimPhosphenes
        newPhosphene=[];
        ms=ceil(radiusSimPhosphenes(phospheneInd));
        [x,y]=meshgrid(-ms:ms, -ms:ms);
        
        % Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
        % mask.
        xsd=ms/2.0;
        ysd=ms/2.0;
        maskblob=uint8(round(exp(-((x/xsd).^2)-((y/ysd).^2))*255));
        phospheneRegion=maskblob~=0;
        phospheneStyle=randi(2);%mixture of dark and light phosphenes
        phospheneStyle=1;
        if phospheneStyle==1%light phosphenes
            phospheneCol=randi(200,[1 3]);
            if phospheneCol(1)>100
                phospheneCol(1)=phospheneCol(1)+55;
            end
            if phospheneCol(2)>100
                phospheneCol(2)=phospheneCol(2)+55;
            end
            if phospheneCol(3)>100
                phospheneCol(3)=phospheneCol(3)+55;
            end
%             phospheneCol=[0 0 0];
            for rbgIndex=1:3
                newPhosphene(:,:,rbgIndex)=uint8(phospheneRegion*phospheneCol(rbgIndex));
            end
        elseif phospheneStyle==2%dark phosphenes
            phospheneCol=randi(100,[1 3]);
            %                 phospheneCol=[0 0 0];
            for rbgIndex=1:3
                newPhosphene(:,:,rbgIndex)=uint8(phospheneRegion*phospheneCol(rbgIndex));
            end
        end
        newPhosphene(:,:,4)=maskblob;
        newPhosphenes{phospheneInd}=newPhosphene;
        masktex(phospheneInd)=Screen('MakeTexture', w, newPhosphene);
    end    
    
    radiusSimPhosphenesDistract=ceil(diameterSimPhosphenesDistract/2);
    for phospheneInd=1:numSimPhosphenes
        newPhospheneDistract=[];
        ms=ceil(radiusSimPhosphenesDistract(phospheneInd));
        [x,y]=meshgrid(-ms:ms, -ms:ms);
        
        % Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
        % mask.
        xsd=ms/2.0;
        ysd=ms/2.0;
        maskblob=uint8(round(exp(-((x/xsd).^2)-((y/ysd).^2))*255));
        phospheneRegion=maskblob~=0;
        phospheneStyle=randi(2);%mixture of dark and light phosphenes
        phospheneStyle=1;
        if phospheneStyle==1%light phosphenes
            phospheneCol=randi(200,[1 3]);
            if phospheneCol(1)>100
                phospheneCol(1)=phospheneCol(1)+55;
            end
            if phospheneCol(2)>100
                phospheneCol(2)=phospheneCol(2)+55;
            end
            if phospheneCol(3)>100
                phospheneCol(3)=phospheneCol(3)+55;
            end
%             phospheneCol=[0 0 0];
            for rbgIndex=1:3
                newPhospheneDistract(:,:,rbgIndex)=uint8(phospheneRegion*phospheneCol(rbgIndex));
            end
        elseif phospheneStyle==2%dark phosphenes
            phospheneCol=randi(100,[1 3]);
            %                 phospheneCol=[0 0 0];
            for rbgIndex=1:3
                newPhospheneDistract(:,:,rbgIndex)=uint8(phospheneRegion*phospheneCol(rbgIndex));
            end
        end
        newPhospheneDistract(:,:,4)=maskblob;
        newPhosphenesDistract{phospheneInd}=newPhospheneDistract;
        masktexDistract(phospheneInd)=Screen('MakeTexture', w, newPhospheneDistract);
    end
    
    visRFx=-RFx;%visual stimulus is always in bottom-left quadrant
    visRFy=RFy;
    numSimPhosphenes=length(electrode);
    finalPixelCoords=[RFx' -RFy'];
    jitterLocation=0;
    
    %for distractor phosphene:
    %Connect to the stimulator
    stimulatorInd2=find(arrays==array2);
    isconnected=stimulator(stimulatorInd2).isConnected();
    disp(['ISconnected? = ' num2str(isconnected)])
    pause(0.05)%adjust
    
    if ~isconnected
        % compulsory step
        stimulator(stimulatorInd2).connect
        pause(0.1)
    end
    %select array & electrode index (sorted by lowest to highest impedance) for microstimulation
    instance2=ceil(array2/2);
    load(['C:\Users\Xing\Lick\090817_impedance\array',num2str(array2),'.mat'])
    eval(['arrayRFs=array',num2str(array2),';']);
    electrodeInd2=find(arrayRFs(:,8)==electrode2);
    RFx2=arrayRFs(electrodeInd2,1);
    RFy2=arrayRFs(electrodeInd2,2);
    load(['C:\Users\Xing\Lick\currentThresholdChs',num2str(currentThresholdChs),'.mat']);%increased threshold for electrode 51, array 10 from 48 to 108, adjusted thresholds on all 4 electrodes

    currentAmplitude2=0;
    
    visRFx=RFx2;%the distractor and target RFs lie in the same quadrant
    visRFy=RFy2;
    
    if Par.Drum && Hit ~= 2 %if drumming and this was an error trial
        %just redo with current settings
    else
        if visualTrial==1%attend-far trial
%             visRFx=randi(60)-140;
            sampleX=visRFx;
            sampleY=visRFy;
            sampleX2 = RFx;%location of sample stimulus, in RF quadrant 150 230
            sampleY2 = RFy;
        elseif visualTrial==0%attend-near trial
            sampleX = RFx;%location of sample stimulus, in RF quadrant 150 230
            sampleY = RFy;
            sampleX2=visRFx;
            sampleY2=visRFy;
        end
        eccentricity=sqrt(sampleX^2+sampleY^2)
        if eccentricity<Par.PixPerDeg
            TargWinSz = 1;
        elseif eccentricity<2*Par.PixPerDeg
            TargWinSz = 1.5;
        elseif eccentricity<3*Par.PixPerDeg
            TargWinSz = 2.5;
        else
            TargWinSz=3;
        end
        
        eccentricity2=sqrt(sampleX2^2+sampleY2^2)
        if eccentricity2<Par.PixPerDeg
            DistWinSz2 = 1;
        elseif eccentricity2<2*Par.PixPerDeg
            DistWinSz2 = 1.5;
        elseif eccentricity2<3*Par.PixPerDeg
            DistWinSz2 = 2.5;
        else
            DistWinSz2=3;
        end
%             sampleX = 170;%arbitrarily large target window
%             sampleY = 170;%arbitrarily large target window
%             TargWinSz=17;
        %control window setup
        if initialTrial==1%only show target
            WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
                sampleX,  sampleY, Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];%2: target;
        elseif initialTrial==0
            WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
                sampleX,  sampleY, Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2; ... %2: target; do not have a distractor window, so that saccade can be made to target window
                sampleX2,  sampleY2, Par.PixPerDeg*DistWinSz2, Par.PixPerDeg*DistWinSz2, 1];%1: error
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
%     if initialTrial==1
%         cueTrial=randi(1,1,2);%only present the cue on some of the initial trials
%         if cueTrial<2
%             %         Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%cue
%             cueDiameter=20;
%             if visualTrial==1
%                 destRect=[screenWidth/2+visRFx(phospheneInd)-ceil(cueDiameter/2) screenHeight/2-visRFy(phospheneInd)-ceil(cueDiameter/2) screenWidth/2+visRFx(phospheneInd)+ceil(cueDiameter/2) screenHeight/2-visRFy(phospheneInd)+ceil(cueDiameter/2)];
%             elseif visualTrial==0
%                 destRect=[screenWidth/2+RFx(phospheneInd)-ceil(cueDiameter/2) screenHeight/2-RFy(phospheneInd)-ceil(cueDiameter/2) screenWidth/2+RFx(phospheneInd)+ceil(cueDiameter/2) screenHeight/2-RFy(phospheneInd)+ceil(cueDiameter/2)];
%             end
%             Screen('DrawArc',w,[200 200 200],destRect,0,360)
%         end
%     end
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
        distractFlagOnM=0;
        distractFlagOnV=0;
        distractFlagOffM=0;
        distractFlagOffV=0;
%         disp(FIXT);
        while Time < FIXT && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
            if distractFirst==1&&initialTrial==0
                dasbit(Par.StimB,1);%send the trigger signal
                if visualTrial==1%attend-far trial
                    if Time>=distractT&&distractFlagOnM==0%turn on the simulated phosphene distractor
                        for phospheneInd=1:numSimPhosphenes
                            destRect=[screenWidth/2+RFx(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-RFy(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenWidth/2+RFx(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-RFy(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2)];
                            Screen('DrawTexture',w, masktexDistract(phospheneInd), [], destRect);
                            Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
                        end
                        Screen('Flip', w);
                        distractFlagOnM=1;
                    end
                    if Time>=durIndividualPhosphene&&distractFlagOffM==0
                        Screen('FillRect',w,grey);
                        Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                        Screen('Flip', w);
                        distractFlagOffM=1;
                    end
                elseif visualTrial==0%attend-near trial
                    if Time>=distractT&&distractFlagOnV==0%turn on the simulated phosphene distractor
                        for phospheneInd=1:numSimPhosphenes
                            destRect=[screenWidth/2+visRFx(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-visRFy(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenWidth/2+visRFx(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-visRFy(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2)];
                            Screen('DrawTexture',w, masktexDistract(phospheneInd), [], destRect);
                            Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
                        end
                        Screen('Flip', w);
                        distractFlagOnV=1;
                    end
                    if Time>=durIndividualPhosphene&&distractFlagOffV==0
                        Screen('FillRect',w,grey);
                        Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                        Screen('Flip', w);
                        distractFlagOffV=1;
                    end
                end
            end
        end
        if currentAmplitude==0&&Hit==1%catch trial
            falseAlarm=1;
        end
    else
        Hit = -1; %the subject did not fixate
    end
    
    
    %///////// EVENT 2 DISPLAY TARGET(S) //////////////////////////////////////
    if Hit == 0 %subject kept fixation, display stimulus
        dasreset(1);     %set test parameters for exiting fix window        
        Time = 1;
        Hit = 0;
        stimFlag=1;
        stimFlag2=1;
        stimOffFlag=0;
        dasbit(Par.TargetB, 1);
        if visualTrial==1&&stimFlag2==1%attend-far trial
            %CCW phosphene target
            tic
            for phospheneInd=1:numSimPhosphenes
                destRect=[screenWidth/2+visRFx(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-visRFy(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenWidth/2+visRFx(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-visRFy(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2)];
                Screen('DrawTexture',w, masktex(phospheneInd), [], destRect);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
            end
            Screen('Flip', w);
            stimFlag2=0;
        elseif visualTrial==0&&stimFlag==1%attend-near trial
            %CW phosphene target
            tic            
            for phospheneInd=1:numSimPhosphenes
                destRect=[screenWidth/2+RFx(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-RFy(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenWidth/2+RFx(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-RFy(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2)];
                Screen('DrawTexture',w, masktex(phospheneInd), [], destRect);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
            end
            Screen('Flip', w);
            stimFlag=0;
        end
        toc
        %///////// EVENT 3 REACTION TIME%%//////////////////////////////////////
        
%         if Hit == 0 %subject kept fixation, subject may make an eye movement
            dasreset(2); %check target window  enter
            refreshtracker(3) %set fix point to green
            Time = 0;
            while Time < RACT && Hit <= 0  %RACT = time to respond to microstim (reaction time)
                %Check for 5 ms
                dasrun(5)
                [Hit Time] = DasCheck;
                if Time>=durIndividualPhosphene&&stimOffFlag==0
                    Screen('FillRect',w,grey);
                    Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                    Screen('Flip', w);
                    stimOffFlag=1;
                end
            end
            if Hit==2
                WIN = [sampleX,  sampleY, Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 0];%2: set the target to become the new fixation window
                Par.WIN = WIN';
%                 refreshtracker(1) %for your control display
                SetWindowDas      %for the dascard
                dasreset(1);     %set test parameters for exiting fix window (to determine how long his gaze stayed on the targer)
                Hit2 = 0;
                Time2 = 0;                
                while Time2 < 100 && Hit2 <= 0  %RACT = time to respond to microstim (reaction time)
                    %Check for 5 ms
                    dasrun(5)
                    [Hit2 Time2] = DasCheck;
                end
                Screen('FillOval',w,[0 255 255],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                Screen('Flip', w);
                Hit2
            elseif Hit <= 0%did not make saccade to correct location
            end
%         else
%             Abort = true;
%         end
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
        if Hit == 2 && LPStat(5) < Times.Sacc && Hit2==0 %correct target, stayed within target window for at least 100 ms, give juice
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
            if visualTrial==1%visual trial
                fprintf('Trial %3d (visual) is a hit\n',trialNo);
                visualHit=visualHit+1;
            elseif visualTrial==0
                fprintf('Trial %3d at %5.2f uA is a hit\n',trialNo,currentAmplitude);
                microstimHit=microstimHit+1;
                numHitsElectrode=numHitsElectrode+1;%counter for a given electrode
                hitCounter=hitCounter+1;
                missesAtMaxCurrent=[missesAtMaxCurrent 0];
                response=NaN;
            end
            if drumming==1%if drumming is desired and response is correct for this trial, then remove condition. otherwise, keep it
                if length(condOrder)>1
                    condOrder=condOrder(2:end);
                    distractOrder=distractOrder(2:end);
                    initialTrials=initialTrials(2:end);
                    newBlock=0;
                elseif length(condOrder)==1
                    newBlock=1;
                    numTrialBlockCounter
                end
                drummingRecord=[];
            end
        elseif Hit == 1
            performance(trialNo)=-1;%error
            numTrialBlockCounter=numTrialBlockCounter+1;
            if visualTrial==1%visual trial
                fprintf('Trial %3d (visual) is a miss\n',trialNo);
                visualMiss=visualMiss+1;
            elseif visualTrial==0
                dasbit(Par.ErrorB, 1);
                Par.Errcount = Par.Errcount + 1;
                fprintf('Trial %3d at %5.2f uA is a miss\n',trialNo,currentAmplitude);
                microstimMiss=microstimMiss+1;
                numMissesElectrode=numMissesElectrode+1;%counter for a given electrode
                missCounter=missCounter+1;
                missesAtMaxCurrent=[missesAtMaxCurrent 1];
            end
            if drumming==1%incorrect response, do not remove condition
                drummingRecord=[drummingRecord 1];
            end
        end
        if drumming==0%if drumming is not desired, remove the condition
            if length(condOrder)>1
                condOrder=condOrder(2:end);
                distractOrder=distractOrder(2:end);
                initialTrials=initialTrials(2:end);
                newBlock=0;
            elseif length(condOrder)==1
                newBlock=1;
                numTrialBlockCounter
            end
        end
        for n=1:length(ident)
            dasbit(ident(n),1);
            pause(0.05);%add a time buffer between sending of dasbits
            dasbit(ident(n),0);
            pause(0.05);%add a time buffer between sending of dasbits
        end
    elseif Hit == 0 && ~Abort && distractFirst==0 && initialTrial==0%if fixation was maintained following presentation of target in first stimulus interval, present distractor in second interval
        dasreset(1);     %set test parameters for exiting fix window        
        Time = 1;
        Hit = 0;
%         disp(FIXT);
        while Time < 900-300-250 && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck;
        end
        dasbit(Par.StimB,1);%send the trigger signal
        if visualTrial==1%attend-CW trial
            for phospheneInd=1:numSimPhosphenes
                destRect=[screenWidth/2+RFx(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-RFy(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenWidth/2+RFx(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-RFy(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2)];
                Screen('DrawTexture',w, masktexDistract(phospheneInd), [], destRect);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
            end
        elseif visualTrial==0%attend-CCW trial
            for phospheneInd=1:numSimPhosphenes
                destRect=[screenWidth/2+visRFx(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-visRFy(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenWidth/2+visRFx(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-visRFy(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2)];
                Screen('DrawTexture',w, masktexDistract(phospheneInd), [], destRect);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
            end
        end
        Screen('Flip', w);
        dasreset(2); %check target window enter
        refreshtracker(3) %set fix point to green
        Time = 0;
        while Time < RACT && Hit <= 0  %RACT = time to respond to microstim (reaction time)
            %Check for 5 ms
            dasrun(5)
            [Hit Time] = DasCheck;
            if Time>=durIndividualPhosphene&&stimOffFlag==0
                Screen('FillRect',w,grey);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                Screen('Flip', w);
                stimOffFlag=1;
            end
        end
        %incorrect response due to maintainence of fixation after target presentation
        performance(trialNo)=-1;%error
        numTrialBlockCounter=numTrialBlockCounter+1;
        if visualTrial==1%visual trial
            fprintf('Trial %3d (visual) is a miss\n',trialNo);
            visualMiss=visualMiss+1;
        elseif visualTrial==0
            dasbit(Par.ErrorB, 1);
            Par.Errcount = Par.Errcount + 1;
            fprintf('Trial %3d at %5.2f uA is a miss\n',trialNo,currentAmplitude);
            microstimMiss=microstimMiss+1;
            numMissesElectrode=numMissesElectrode+1;%counter for a given electrode
            missCounter=missCounter+1;
            missesAtMaxCurrent=[missesAtMaxCurrent 1];
        end
        if drumming==1%incorrect response, do not remove condition
            drummingRecord=[drummingRecord 1];
        end
        if drumming==0%if drumming is not desired, remove the condition
            if length(condOrder)>1
                condOrder=condOrder(2:end);
                distractOrder=distractOrder(2:end);
                initialTrials=initialTrials(2:end);
                newBlock=0;
            elseif length(condOrder)==1
                newBlock=1;
                numTrialBlockCounter
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
    allFixTm(trialNo)=FIXTm;
    allFixTv(trialNo)=FIXTv;
    allStimDur(trialNo)=durIndividualPhosphene;
    allBlockNo(trialNo)=blockNo;
    allCurrentLevel(trialNo)=currentAmplitude;
    allElectrodeNum{trialNo}=electrode;
    allInstanceNum{trialNo}=instance;
    allArrayNum{trialNo}=array;
    allCurrentLevel2(trialNo)=currentAmplitude2;
    allElectrodeNum2{trialNo}=electrode2;
    allInstanceNum2{trialNo}=instance2;
    allArrayNum2{trialNo}=array2;
    allTargetArrivalTime(trialNo)=Time;
    allFalseAlarms(trialNo)=falseAlarm;
    allAttentionCond(trialNo)=visualTrial;
    allDistractTrials(trialNo)=distractFirst;
    allDrummingTrials(trialNo)=drummingTrial;
    if performance(trialNo)==1
        allHitX(trialNo)=hitX;
        allHitY(trialNo)=hitY;
        allHitRT(trialNo)=hitRT;
    elseif performance(trialNo)==-1
        allHitX(trialNo)=hitX;
        allHitY(trialNo)=hitY;
        allHitRT(trialNo)=hitRT;
    else
        allHitX(trialNo)=NaN;
        allHitY(trialNo)=NaN;
        allHitRT(trialNo)=NaN;
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
    SCNT(2) = { ['N: ' num2str(visualHit+microstimHit+microstimMiss) ]};
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
    fprintf(['Electrode: ',num2str(electrode),' Hits: ',num2str(numHitsElectrode),' Misses: ',num2str(numMissesElectrode)]);
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