function runstim_microstim_motion2(Hnd)
%Written by Xing 26/10/17
%Present 4 targets for direction-of-motion task. 
%Partially visual trials and partially
%microstim trials. For microstim trials, deliver monopolar microstimulation to electrodes (45 pulses). 
%Script uses stimulator.trigger() to trigger delivery
%of stimulation. 
%Uses new function, send_stim_multiple_CereStims, to set waveform
%parameters and triggers.

global Par   %global parameters
global trialNo
global behavResponse
global performance
global allSampleX
global allSampleY
global allSetInd
global allFixT
global allStimDur
global blockNo
global newBlock
global numTrialBlockCounter
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
global visualCorrect
global microstimCorrect
global microstimIncorrect
global visualIncorrect
global catchFalseAlarms
global numHitsElectrode
global numMissesElectrode
global electrodeInd
global hitCounter
global missCounter
global allStaircaseResponse
global missesAtMaxCurrent
global condInd
global allMultiCereStim
global recentPerf
global recentPerfMicro
global lastTrials
global lastTrialsMicro
global allTrialType
global trialConds
global allLRorTB
global allTargetLocation
global last200Trials
global recentPerf200Trials
global allNewPhosphenes

format compact
oldEnableFlag = Screen('Preference', 'SuppressAllWarnings',1);
Screen('Preference', 'Verbosity',0);
mydir = 'C:\Users\Xing\Lick\saccade_task_logs\';
fn = input('Enter LOG file name (e.g. 20110413_B1), blank = no file\n','s');
%Copy the run_stim script
fnrs = [fn,'_','runstim.m'];
cfn = [mfilename('fullpath') '.m'];
copyfile(cfn,fnrs)
visStimDir=['C:\Users\Xing\Lick\saccade_task_logs\',fn];
if ~exist(visStimDir,'dir')
    mkdir(visStimDir);
end

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
TargWinSz = 4;  %CHANGE TO MAKE MORE ACCUARTE

%Fixatie kleur
red = [255 0 0];
fixcol = red;  %mag ook red zijn

%timing
PREFIXT = 1000; %time to enter fixation window

%REactie tijd
TARGT = 0; %time to keep fixating after target onset before fix goes green (het liefst 400)
RACT = 600;      %reaction time 250 ms %adjust

Fsz = FixDotSize.*Par.PixPerDeg;
rewDotSize=0.4.*Par.PixPerDeg;

%Target positions (Diagonals)
% targx = [-150 -150 150 150 -100 -100 100 100 -200 -200 200 200];
% targy = [-150 150 150 -150 -100 100 100 -100 -200 200 200 -200];
catchDotY=-100;

grey = round([255/2 255/2 255/2]);
black=[0 0 0];

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

%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
Hit = 2;
Par.ESC = false; %escape has not been pressed
trialNo=0;
microstimHit=0;
microstimMiss=0;
numHitsElectrode=0;
numMissesElectrode=0;
visualCorrect=0;
visualIncorrect=0;
catchFalseAlarms=0;
hitCounter=0;
missCounter=0;
allStaircaseResponse=[];
allCurrentLevel=[];
allCurrentLevel2=[];
missesAtMaxCurrent=0;
performance=[];
allSampleX=[];
allSampleY=[];
allFixT=[];
allStimDur=[];
allBlockNo=[];
newBlock=1;
allElectrodeNum=[];
allElectrodeNum2=[];
allInstanceNum=[];
allInstanceNum2=[];
allArrayNum=[];
allArrayNum2=[];
allTargetArrivalTime=[];
allFalseAlarms=[];
allHitX=[];
allHitY=[];
allHitRT=[];
allChOrder=[];
RFx=NaN;
RFy=NaN;
RFx2=NaN;
RFy2=NaN;
allMultiCereStim=[];
allTrialType=[];
allSetInd=[];
recentPerf=NaN;
recentPerfMicro=NaN;
recentPerf100Trials=NaN;
subblockCount=0;
newPhosphenes=[];
allNewPhosphenes=[];

trialConds=[1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2;1:4 1:4 1:4 1:4];%trial conditions. Target conds in first row: for TB trials, 1: target is above; 2: target is below
trialConds=[1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2;4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4];%trial conditions. Target conds in first row: for TB trials, 1: target is above; 2: target is below
%index of set of electrodes to use, in second row: 1 to 4
arrays=8:16;
% stimulatorNums=[14295 65372 14173 65374 65375 65376 65494 65493 65338];%stimulator to which each array is connected
arrays=[10 13 15];
stimulatorNums=[14295 14177 65376 65374 65375 65372 65494 65493 65338];%stimulator to which each array is connected
stimulatorNums=[65376 65372 65493];%stimulator to which each array is connected
multiCereStim=1;%set to 1 for stimulation involving more than 1 CereStim

for i = [0 1 2 3 4 5 6 7]  %Error, Stim, Saccade, Trial, Correct,
    dasbit(i,0);
    pause(0.1)
end
dasclearword();

load('C:\Users\Xing\Lick\currentThresholdChs37.mat');%increased threshold for electrode 51, array 10 from 48 to 108, adjusted thresholds on all 4 electrodes
staircaseFinishedFlag=0;%remains 0 until 40 reversals in staircase procedure have occured, at which point it is set to 1


stimulator1 = cerestim96();
stimulator2 = cerestim96();
stimulator3 = cerestim96();

my_devices=stimulator1.scanForDevices
for deviceInd=1:length(my_devices)
    stimulatorInd=find(my_devices==stimulatorNums(deviceInd));
    eval(['stimulator',num2str(deviceInd),'.selectDevice(stimulatorInd-1)']) %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
    pause(0.5)
end
while ~Par.ESC&&staircaseFinishedFlag==0
    %Pretrial
    trialNo = trialNo+1;
    if trialNo==1
        blockNo=0;
        newSubblock=1;
        hitRT=NaN;
    end
    if newSubblock==1
        numTrialBlockCounter=0;  
        newOrder=randperm(size(trialConds,2));
        condOrder=trialConds(1,newOrder);
        condOrderSet=trialConds(2,newOrder);
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
    visualTrialRand=randi(2);%50% of trials are visual trials %delete this line
    if newBlock==1
        blockNo=blockNo+1;
        if mod(blockNo,2)==1
            visualTrial=1;
        elseif mod(blockNo,2)==0
            visualTrial=0;
        end
        newBlock=0;
    end
    subblockCount
    condOrder
    condOrderSet
    blockNo
    visualTrial=0;%adjust
    numTargets=2;
    
    if visualTrial==1
        currentAmplitude=0;
        electrode=NaN;
        electrode2=NaN;
        instance=NaN;
        instance2=NaN;
        array=NaN;
        array2=NaN;
        falseAlarm=0;
    elseif visualTrial==0
        % define a waveform
        waveform_id = 1;
        numPulses=50;%originally set to 5 pulses
        %         amplitude=50;%set current level in uA
    end
    FIXT=random('unif',300,700);%on both visual and microstim trials, time during which monkey is required to fixate, before two dots appear
    FIXT=300;
    %specify array & electrode index (sorted by lowest to highest impedance) for microstimulation
%     LRorTB=condOrderSet(1);%2 targets, 1: left and right; 2: top and bottom
    LRorTB=2;
    setInd=condOrderSet(1);
    setInd=1;%adjust
    [setElectrodes,setArrays]=lookup_set_electrodes_motion(setInd);
    targetLocation=condOrder(1);
%     targetLocation=1;%adjust
    if LRorTB==1
        targetArrayX=[-200 200];
        targetArrayY=[0 0];
        targetArrayYTracker=[0 0];
        targetLocations='LR';
        if targetLocation==1
            array=setArrays{1};
            electrode=setElectrodes{1};
        elseif targetLocation==2
            array=setArrays{2};
            electrode=setElectrodes{2};
        end
    elseif LRorTB==2
        targetArrayX=[0 0];
        targetArrayY=[-200 200];
        targetArrayYTracker=[200 -200];
        targetLocations='BT';
        if targetLocation==1
            array=setArrays{3};
            electrode=setElectrodes{3};
        elseif targetLocation==2
            array=setArrays{4};
            electrode=setElectrodes{4};%check these assignments
        end
    end
    desiredStimulator=[];
    stimSequenceInd=[];
    electrodeInd=[];
    arrayInd=[];
    for electrodeSequence=1:length(setElectrodes{3});
        electrodeIndtemp1=find(goodArrays8to16(:,8)==electrode(electrodeSequence));%matching channel number
        electrodeIndtemp2=find(goodArrays8to16(:,7)==array(electrodeSequence));%matching array number
        electrodeInd(electrodeSequence)=intersect(electrodeIndtemp1,electrodeIndtemp2);%channel number
        arrayInd(electrodeSequence)=find(arrays==array(electrodeSequence));
        desiredStimulator(electrodeSequence)=stimulatorNums(arrayInd(electrodeSequence));
        instance(electrodeSequence)=ceil(array(electrodeSequence)/2);
        load(['C:\Users\Xing\Lick\090817_impedance\array',num2str(array(electrodeSequence)),'.mat']);
        eval(['arrayRFs=array',num2str(array(electrodeSequence)),';']);
        RFx(electrodeSequence)=goodArrays8to16(electrodeInd(electrodeSequence),1);
        RFy(electrodeSequence)=goodArrays8to16(electrodeInd(electrodeSequence),2);
    end
%     uniqueStimulators=unique(desiredStimulator)%identify stimulators that are needed
%     ind=[];
%     for iArrangeStimulators=1:length(uniqueStimulators)
%         ind(iArrangeStimulators)=find(uniqueStimulators(iArrangeStimulators)==stimulatorNums);
%     end
%     [dummy indStims]=sort(ind);
%     uniqueStimulators=uniqueStimulators(indStims);
    uniqueStimulators=desiredStimulator%identify stimulators that are needed
    for uniqueStimInd=1:length(uniqueStimulators)
        [dummy tempInd]=find(desiredStimulator==uniqueStimulators(uniqueStimInd));%identify at which point in sequence the stimulator should be activated
        stimSequenceInd{uniqueStimInd}=tempInd;
        electrodeSequenceInd{uniqueStimInd}=electrode(tempInd);%identify at which point in sequence the stimulator should be activated
        arraySequenceInd{uniqueStimInd}=array(tempInd);%identify at which point in sequence the stimulator should be activated
    end
    falseAlarm=NaN;
    
    visRFx=RFx;%locations of visual stimuli
    visRFy=RFy;
    numSimPhosphenes=length(setElectrodes{1});
    if visualTrial==1%visual trial
        finalPixelCoords=[RFx' -RFy'];
        jitterLocation=0;
        if jitterLocation==1
            %         finalPixelCoords=finalPixelCoords+random('unid',floor(spacing/2),[1,numSimPhosphenes]);%randomise position of phosphene within each 'pixel'
            %         finalPixelCoords2=random('unid',floor(spacing/2),[1,numSimPhosphenes]);
            maxJitterSize=5;
            finalPixelCoords=finalPixelCoords+random('unid',maxJitterSize,[numSimPhosphenes,numSimPhosphenes]);%randomise position of phosphene within each 'pixel'
        end
        
        %randomly set sizes of 'phosphenes'
        maxDiameter=15;%pixels
        minDiameter=10;%pixels
        diameterSimPhosphenes=random('unid',maxDiameter-minDiameter+1,[numSimPhosphenes,1]);
        diameterSimPhosphenes=diameterSimPhosphenes+minDiameter-1;
        %factor in scaling of RF sizes across cortex:
        sizeScaling=0;
        if sizeScaling==1
            diameterSimPhosphenes=diameterSimPhosphenes.*finalPixelCoords(:,1)*2/max(finalPixelCoords(:,1));
            diameterSimPhosphenes=diameterSimPhosphenes.*finalPixelCoords(:,2)*2/max(finalPixelCoords(:,2));
            singleQuadrant=1;
            %when stimulus location is confined to a single quadrant, the size of
            %phosphenes are expected to range from approximately 11.5 to 36 pixels in diameter.
            if singleQuadrant==1
                diameterSimPhosphenes=diameterSimPhosphenes/max(diameterSimPhosphenes)*(36-11.5)+11.5;
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
%                 phospheneCol=[0 0 0];
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
    elseif visualTrial==0        
        %set the waveform parameters for the real stimulation trains:
        for electrodeSequence=1:length(setElectrodes{1})
            currentAmplitude(electrodeSequence)=goodCurrentThresholds(electrodeInd(electrodeSequence))*1.5;%adjust
            if currentAmplitude(electrodeSequence)>210
                currentAmplitude(electrodeSequence)=210;
            end
        end
        currentAmplitude
        for uniqueStimInd=1:length(uniqueStimulators)
            [dummy tempInd]=find(desiredStimulator==uniqueStimulators(uniqueStimInd));%identify at which point in sequence the stimulator should be activated
            currentAmplitudeSequenceInd{uniqueStimInd}=currentAmplitude(tempInd);%identify at which point in sequence the stimulator should be activated
        end
        send_stim_multiple_CereStims_sepobj(uniqueStimulators,currentAmplitudeSequenceInd,electrodeSequenceInd,stimulatorNums,stimulator1,stimulator2,stimulator3,stimSequenceInd)
    end
    
    if Par.Drum && Hit ~= 2 %if drumming and this was an error trial
        %just redo with current settings
    else
        %set target & distractor locations
        stimInd=1:length(targetArrayX);
        distInd=stimInd(stimInd~=targetLocation);
        distLocations=targetLocations(stimInd~=targetLocation);
        for distCount=1:length(targetArrayX)-1
            distx(distCount) = targetArrayX(distInd(distCount));
            disty(distCount) = targetArrayY(distInd(distCount));
            distyTracker(distCount) = targetArrayYTracker(distInd(distCount));%difference between Cogent and PTB
        end    
        if targetLocation==1||targetLocation==2
            oppositeShape=1;
        else
            oppositeShape=3;
        end
        %control window setup
        WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
            targetArrayX(targetLocation),  targetArrayY(targetLocation), Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];   %2: target; 
        for distCount=1:length(targetArrayX)-1%distractor opposite from target
            WIN = [WIN;distx(distCount),  disty(distCount), Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 1];%1: error
        end
        if LRorTB==1%the other two distractors, for a 4-target task
            distractArrayX=[0 0];
            distractArrayY=[-200 200];
        elseif LRorTB==2
            distractArrayX=[-200 200];
            distractArrayY=[0 0];
        end
        for distCount=1:length(distractArrayX)
            WIN = [WIN;distractArrayX(distCount),  distractArrayY(distCount), Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 1];%1: error
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
        while Time < FIXT && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
        end
        if visualTrial==1&&Hit==1%catch trial
            falseAlarm=1;
        end
    else
        Hit = -1; %the subject did not fixate
    end    
    
    %///////// EVENT 2 DISPLAY TARGET(S)
    %//////////////////////////////////////
    if Hit == 0 %subject kept fixation, display stimulus
        dasreset(1);     %set test parameters for exiting fix window        
        Time = 1;
        Hit = 0;
        durIndividualPhosphene=150;
        FIXT2=durIndividualPhosphene*numSimPhosphenes+100%adjust
        stimFlag2=1;
        individualPhosphenesFlags=zeros(numSimPhosphenes,1);
        while Time < FIXT2 && Hit== 0            
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
            if visualTrial==1%visual trial
                %draw line composed of series of simulated phosphenes
                for phospheneInd=1:numSimPhosphenes
                    if Time>=durIndividualPhosphene*(phospheneInd-1)&&individualPhosphenesFlags(phospheneInd)==0
                        durIndividualPhosphene*(phospheneInd-1)
                        destRect=[screenWidth/2+visRFx(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-visRFy(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenWidth/2+visRFx(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-visRFy(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2)];
                        Screen('DrawTexture',w, masktex(phospheneInd), [], destRect);
                        Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
                        Screen('Flip', w);
                        individualPhosphenesFlags(phospheneInd)=1;
                        if phospheneInd==1
                            dasbit(Par.StimB,1);%send the trigger signal
                        end
                    end
                end
            elseif visualTrial==0&&stimFlag2==1
%                             Screen('FillRect',w,red);
%                             Screen('Flip', w);
                dasbit(Par.MicroB,1);%send the trigger signal
                pause(0.1);
                dasbit(Par.MicroB,0);
                pause(0.1);
                for electrodeSequence=1:length(setElectrodes{1});
                    sprintf('array %d, electrode %d, electrode ind %d',array(electrodeSequence),electrode(electrodeSequence),electrodeInd(electrodeSequence))
                end
                for uniqueStimInd=1:length(uniqueStimulators)
                    stimulatorInd=find(stimulatorNums==uniqueStimulators(uniqueStimInd));
                    eval(['seq_stat=stimulator',num2str(stimulatorInd),'.getSequenceStatus();'])
                    disp(['status= ' num2str(seq_stat)])
                    eval(['stimulator',num2str(stimulatorInd),'.disableTrigger;'])                 
                end
                stimFlag2=0;
%                 Screen('FillRect',w,grey);
%                 Screen('Flip', w);
            end
        end
        Screen('FillRect',w,grey);
        Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
        Screen('Flip', w);
        
        %///////// EVENT 3 REACTION TIME%%//////////////////////////////////////
        
        if Hit == 0 %subject kept fixation, subject may make an eye movement
            
            %Draw targets
            targetSize=10;%in pixels
            lightDistractors=0;
            if LRorTB==1
                displacementFactor=[-1 1 -1 1;-1 1 1 -1];%first row: left target, dot 1 x, dot 2 x, dot 1 y, dot 2 y. second row: right target
                displacementFactor2=[0 0 -1 1;-1 1 0 0];%other 2 distractors
            elseif LRorTB==2
                displacementFactor=[0 0 -1 1;-1 1 0 0];%top target, bottom target
                displacementFactor2=[-1 1 -1 1;-1 1 1 -1];%other 2 distractors
            end%             
            
            targetSize=10;%in pixels
            lightDistractors=0;
            for i=1:2
                Screen('FillOval',w,black,[screenWidth/2-targetSize+targetArrayX(i) screenHeight/2-targetSize+targetArrayY(i) screenWidth/2+targetArrayX(i) screenHeight/2+targetArrayY(i)]);
                if lightDistractors==1
                    Screen('FillOval',w,[80 80 80],[screenWidth/2-targetSize+targetArrayX(i) screenHeight/2-targetSize+targetArrayY(i) screenWidth/2+targetArrayX(i) screenHeight/2+targetArrayY(i)]);
                end
            end
            Screen('Flip', w);
            
            dasbit(Par.TargetB, 1);
            dasreset(2); %check target window enter
            refreshtracker(3) %set fix point to green
            if visualTrial==1%catch trial
                Time = 0;
                Hit = 0;
                while Time < RACT && Hit <= 0  %if no saccade made to RF, keep waiting till catch dot is presented
                    %Check for 5 ms
                    dasrun(5)
                    [Hit Time] = DasCheck;
                end           
                if Hit==2
                    Screen('FillOval',w,[0 255 0],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                    Screen('Flip', w);
                end
            elseif visualTrial==0             
                Time = 0;
                Hit = 0;
                while Time < RACT && Hit <= 0  %RACT = time to respond to microstim (reaction time)
                    %Check for 5 ms
                    dasrun(5)
                    [Hit Time] = DasCheck;
                end
                if Hit==2  
                    Screen('FillOval',w,[0 255 255],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                    Screen('Flip', w);
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
    if targetIdentity==1%if correct target selected
        behavResponse(trialNo)=targetLocation;
    elseif targetIdentity>1%if erroneous target selected
        distractorRow=targetIdentity-1;%row of selected distractor, out of all distractors
        behavResponse(trialNo)=distLocations(distractorRow);%incorrect target to which saccade was made (L: left; R: right; T: top; B: bottom)
    end
    dirName=cd;
    save([dirName,'\',date,'_mot_4targperf.mat'],'behavResponse','performance')
    
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
            if visualTrial==1%visual trial 
                fprintf('Trial %3d (visual) is correct\n',trialNo);
                visualCorrect=visualCorrect+1;
                if Par.Trlcount==1
                    lastTrials=1;
                    last200Trials=1;
                else
                    lastTrials=[lastTrials 1];
                    last200Trials=[last200Trials 1];
                end
            elseif visualTrial==0
                fprintf('Trial %3d (microstim) at %5.2f uA is correct\n',trialNo,currentAmplitude);
                microstimCorrect=microstimCorrect+1;
                numHitsElectrode=numHitsElectrode+1;%counter for a given electrode
                if Par.Trlcount==1
                    lastTrialsMicro=1;
                else
                    lastTrialsMicro=[lastTrialsMicro 1];
                end
            end
            if length(condOrder)>1
                condOrder=condOrder(2:end);
                condOrderSet=condOrderSet(2:end);
                newSubblock=0;
            elseif length(condOrder)==1
                newSubblock=1;
                subblockCount=subblockCount+1;
                if subblockCount>=8
                    newBlock=1;
                    subblockCount=0;
                end
            end
        elseif Hit == 1
            performance(trialNo)=-1;%error
            dasbit(Par.ErrorB, 1);
            Par.Errcount = Par.Errcount + 1;
            if visualTrial==1%visual trial 
                fprintf('Trial %3d (visual) is incorrect\n',trialNo);
                visualIncorrect=visualIncorrect+1;
                if Par.Trlcount==1
                    lastTrials=0;
                    last200Trials=0;
                else
                    lastTrials=[lastTrials 0];
                    last200Trials=[last200Trials 0];
                end
            elseif visualTrial==0%incorrect trial
                fprintf('Trial %3d (microstim) at %5.2f uA is incorrect\n',trialNo,currentAmplitude);
                microstimIncorrect=microstimIncorrect+1;
                numMissesElectrode=numMissesElectrode+1;%counter for a given electrode
                condInd=condInd+1;
                if Par.Trlcount==1
                    lastTrialsMicro=0;
                else
                    lastTrialsMicro=[lastTrialsMicro 0];
                end
            end
            numTrialBlockCounter=numTrialBlockCounter+1;
            if length(condOrder)>1
                newOrder2=randperm(length(condOrder));
                condOrder=condOrder(newOrder2);
%                 condOrderSet=condOrderSet(newOrder2);
                newSubblock=0;
            end
        end
        dasbit(Par.MicroB,0)
        dasbit(Par.TargetB, 0);
    end
    if falseAlarm==1
        catchFalseAlarms=catchFalseAlarms+1;
        dasbit(Par.ErrorB,1);
        fprintf('Trial %3d is a fix break\n',trialNo);
    end
    
    Screen('FillRect',w, grey);
    Screen('Flip', w);
    trialNo;
    allSampleX{trialNo}=RFx;
    allSampleY{trialNo}=RFy;
    allFixT(trialNo)=FIXT;
    allStimDur(trialNo)=stimDuration;
    allBlockNo(trialNo)=blockNo;
    allCurrentLevel{trialNo}=currentAmplitude;
    allElectrodeNum{trialNo}=electrode;
    allInstanceNum{trialNo}=instance;
    allArrayNum{trialNo}=array;
    allTargetArrivalTime(trialNo)=Time;
    allFalseAlarms(trialNo)=falseAlarm;
    allMultiCereStim(trialNo)=multiCereStim;
    allSetInd(trialNo)=setInd;
    allTrialType(trialNo)=visualTrial;
    allLRorTB(trialNo)=LRorTB;
    allTargetLocation(trialNo)=targetLocation;
    allNewPhosphenes{trialNo}=newPhosphenes;
    if Hit==2
        allHitX(trialNo)=hitX;
        allHitY(trialNo)=hitY;
        allHitRT(trialNo)=hitRT;
    else
        allHitX(trialNo)=NaN;
        allHitY(trialNo)=NaN;
        allHitRT(trialNo)=NaN;
    end
    send_serial_data(trialNo);%send trial number to NSPs via serial port
    if visualTrial==1
        save([visStimDir,'\newPhosphene_trial',num2str(trialNo)],'newPhosphenes');
    end
    dirName=cd;
    %///////////////////////INTERTRIAL AND CLEANUP
    
    %reset all bits to null
    for i = [0 1 2 3 4 5 6 7]  %Error, Stim, Saccade, Trial, Correct,
        dasbit(  i, 0);
    end
    dasclearword();
    
    if length(lastTrials)>30
        lastTrials=lastTrials(2:end);
    end
    recentPerf=mean(lastTrials);
    
    if length(lastTrialsMicro)>30
        lastTrialsMicro=lastTrialsMicro(2:end);
    end
    recentPerfMicro=mean(lastTrialsMicro);
    
    if length(last200Trials)>200
        last200Trials=last200Trials(2:end);
    end
    recentPerf200Trials=mean(last200Trials)
    
%     SCNT = {'TRIALS'};
    SCNT(2) = { ['Nv: ' num2str(visualCorrect+visualIncorrect) ' Nm: ' num2str(numHitsElectrode+numMissesElectrode)]};
%     SCNT(3) = { ['N mic: ' num2str(numHitsElectrode+numMissesElectrode) ]};
%     SCNT(3) = { ['C: ' num2str(Par.Corrcount) ] };
    SCNT(3) = { ['P vis: ' num2str(recentPerf) ] };
    SCNT(4) = { ['P mic: ' num2str(recentPerfMicro) ] };
%     SCNT(2) = { ['N: ' num2str(visHit+microstimHit+microstimMiss) ]};
%     SCNT(3) = { ['Hit: ' num2str(numHitsElectrode) ] };
%     SCNT(4) = { ['Miss: ' num2str(numMissesElectrode) ] };
%     SCNT(5) = { ['Electrode: ' num2str(electrode) ] };
    set(Hnd(1), 'String', SCNT ) %display updated numbers in GUI
    
    % Blank screen
    Screen('FillRect',w, grey);
    Screen('Flip', w);
    
    if trialNo > 0
        save(fn,'*');
    end
    pause(0.1);%adjust
end
% 
% if visualTrial==0
    %disconnect CereStim
    if exist('my_devices','var')
        for deviceInd=1:length(my_devices)
            eval(['stimulator',num2str(deviceInd),'.selectDevice(deviceInd-1);']) %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
%             temp=stimulator.isConnected;
%             if temp==1
%                 %Connect to the stimulator
                eval(['stimulator',num2str(deviceInd),'.disconnect;'])
%             end
            pause(0.05)
        end
    end
% end
Screen('Preference','SuppressAllWarnings',oldEnableFlag);