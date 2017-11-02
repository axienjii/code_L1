function runstim_microstim_saccade_catch58(Hnd)
%Written by Xing 5/10/17
%Present 4 targets for 2-phosphene task. 8 trials per subblock. 5 subblocks per block (8*5 = 40 trials). Balanced
%number of LR vs TB trials, as well as target locations.
%Partially visual trials and partially
%microstim trials. For microstim trials, deliver monopolar microstimulation to electrodes and
%record saccade end points. Set 'multiCereStim' variable to either 0 or 1 for
%microstimulation involving more than 1 CereStim.
%On some percentage of trials, deliver microstimulation (50 pulses). Monkey has to fixate for 300 ms, followed by
%an interval lasting anywhere from 0 to 400 ms. 
%Time allowed to reach target reduced to maximum of 200 ms.
%Since the previous code, catch 15, the script uses stimulator.trigger() to trigger delivery
%of stimulation. This occurs when dasbit(MicroB,1) is sent via the 7th
%output pin to the Trigger input port on the CereStim. Additionally, the
%sync pulses are sent from the CereStim Sync Pulse output via BNC cables to the 
%analog inputs on instance 1.

global Par   %global parameters
global trialNo
global behavResponse
global performance
global allSampleX
global allSampleY
global allSetInd
global allFixT
global allStimDur
global trialsRemaining
global allTrialCond
global blockNo
global newBlock
global corrTrialBlockCounter
global numTrialBlockCounter
global allBlockNo
global allHitX
global allHitY
global allHitRT
global allCurrentLevel
global allCurrentLevel2
global allElectrodeNum
global allElectrodeNum2
global allInstanceNum
global allInstanceNum2
global allArrayNum
global allArrayNum2
global allTargetArrivalTime
global currentAmplitude
global currentAmplitude2
global visualCorrect
global microstimCorrect
global microstimIncorrect
global visualIncorrect
global catchFalseAlarms
global numHitsElectrode
global numMissesElectrode
global electrodeInd
global electrodeInd2
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

trialConds=[1 1 1 1 2 2 2 2;1 1 2 2 1 1 2 2];%trial conditions. Target conds in first row: for TB trials, 1: target is above; 2: target is below
%LR vs TB conds in second row: 1: LR; 2: TB
arrays=8:16;
stimulatorNums=[14295 14172 14173 14174 14175 14176 14294 14293 14138];%stimulator to which each array is connected
stimulatorNums=[14295 14172 14173 65374 14175 14176 65494 65493 65338];%stimulator to which each array is connected

multiCereStim=1;%set to 1 for stimulation involving more than 1 CereStim
blockedDesign=1;%set to 1 to implement blocked design

load('C:\Users\Xing\Lick\currentThresholdChs35.mat');%increased threshold for electrode 51, array 10 from 48 to 108, adjusted thresholds on all 4 electrodes
staircaseFinishedFlag=0;%remains 0 until 40 reversals in staircase procedure have occured, at which point it is set to 1

%Create stimulator object
stimulator = cerestim96();
stimulator2 = cerestim96();
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
        condOrderLRTB=trialConds(2,newOrder);
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
%     visualTrialRand=1;%1: visual trials; 2: microstim trials
%     if blockedDesign==1
%         if mod(blockNo,2)==1
%             visualTrialRand=1;
%         elseif mod(blockNo,2)==0
%             visualTrialRand=2;
%         end
%     end
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
    condOrderLRTB
    blockNo
    visualTrial=0;%adjust
    numTargets=2;
    
    if visualTrial==1
        currentAmplitude=0;
        currentAmplitude2=0;
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
    setElectrodes=[28 53 62 49;27 50 15 58;41 23 38 35;38 62 15 49];%first row: set 1, LRTB; second row: set 2, LRTB
    setArrays=[12 13 15 13;12 13 15 13;12 12 16 12;16 15 15 13];
%     setInd=1;
    setInd=randi(4);
%     if set==2
%         diagonal=randi(2);
%         if diagonal==1%bottom coordinate used for diagonals.
%             diagonalInds=[1 4;2 4];%first row: left and bottom; second row: right and bottom
%         elseif diagonal==2%top coordinate used for diagonals. 
%             diagonalInds=[3 2;3 1];%first row: top and right; second row: top and left
%         end
%     end
    %specify array & electrode index (sorted by lowest to highest impedance) for microstimulation
    LRorTB=condOrderLRTB(1);%2 targets, 1: left and right; 2: top and bottom
    LRorTB=2;
    targetLocation=condOrder(1);
%     targetLocation=2;
    twoPairs=1;
    if twoPairs==1
        if LRorTB==1
            targetArrayX=[-200 200];
            targetArrayY=[0 0];
            targetArrayYTracker=[0 0];
            targetLocations='LR';
            if targetLocation==1
                array=setArrays(setInd,3);%use top coordinate
                array2=setArrays(setInd,2);
                electrode=setElectrodes(setInd,3);
                electrode2=setElectrodes(setInd,2);
%                 array=setArrays(setInd,1);%use bottom coordinate
%                 array2=setArrays(setInd,4);
%                 electrode=setElectrodes(setInd,1);
%                 electrode2=setElectrodes(setInd,4);
            elseif targetLocation==2
                array=setArrays(setInd,3);%use top coordinate
                array2=setArrays(setInd,1);
                electrode=setElectrodes(setInd,3);
                electrode2=setElectrodes(setInd,1);
%                 array=setArrays(setInd,2);%use bottom coordinate
%                 array2=setArrays(setInd,4);
%                 electrode=setElectrodes(setInd,2);
%                 electrode2=setElectrodes(setInd,4);
            end
        elseif LRorTB==2
            targetArrayX=[0 0];
            targetArrayY=[-200 200];
            targetArrayYTracker=[200 -200];
            targetLocations='BT';
            if targetLocation==1
                array=setArrays(setInd,1);
                array2=setArrays(setInd,2);
                electrode=setElectrodes(setInd,1);
                electrode2=setElectrodes(setInd,2);
            elseif targetLocation==2
                array=setArrays(setInd,3);
                array2=setArrays(setInd,4);
                electrode=setElectrodes(setInd,3);
                electrode2=setElectrodes(setInd,4);
            end
        end
    end
    electrodeIndtemp1=find(goodArrays8to16(:,8)==electrode);%matching channel number
    electrodeIndtemp2=find(goodArrays8to16(:,7)==array);%matching array number
    electrodeInd=intersect(electrodeIndtemp1,electrodeIndtemp2);%channel number
    
    electrodeIndtemp1=find(goodArrays8to16(:,8)==electrode2);%matching channel number
    electrodeIndtemp2=find(goodArrays8to16(:,7)==array2);%matching array number
    electrodeInd2=intersect(electrodeIndtemp1,electrodeIndtemp2);%channel number
    
    arrayInd=find(arrays==array);
    desiredStimulator=stimulatorNums(arrayInd);
    arrayInd2=find(arrays==array2);
    desiredStimulator2=stimulatorNums(arrayInd2);
    falseAlarm=NaN;
            
    instance=ceil(array/2);
    instance2=ceil(array2/2);
    load(['C:\Users\Xing\Lick\090817_impedance\array',num2str(array),'.mat']);
    eval(['arrayRFs=array',num2str(array),';']);
    RFx=goodArrays8to16(electrodeInd,1);
    RFy=goodArrays8to16(electrodeInd,2);
    RFx2=goodArrays8to16(electrodeInd2,1);
    RFy2=goodArrays8to16(electrodeInd2,2);
    
    visRFx=[RFx RFx2];%locations of visual stimuli
    visRFy=[RFy RFy2];
    if visualTrial==1%visual trial
        finalPixelCoords=[RFx -RFy;RFx2 -RFy2];
        numSimPhosphenes=2;
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
        currentAmplitude=goodCurrentThresholds(electrodeInd)*1.5;%adjust
        if currentAmplitude>210
            currentAmplitude=210;
        end
        currentAmplitude2=goodCurrentThresholds(electrodeInd2)*1.5;%adjust
        if currentAmplitude2>210
            currentAmplitude2=210;
        end
        currentAmplitude
        currentAmplitude2
        if exist('stimulator','var')
            if stimulator.isConnected
                stimulator.disconnect;
            end
        end
        if exist('stimulator2','var')
            if stimulator2.isConnected
                stimulator2.disconnect;
            end
        end
        my_devices = stimulator.scanForDevices;
        stimulatorInd=find(my_devices==desiredStimulator);
        stimulatorInd2=find(my_devices==desiredStimulator2);
        if stimulatorInd==stimulatorInd2
            sameStimulator=1;
        else
            sameStimulator=0;
        end
        stimulator.selectDevice(stimulatorInd-1); %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
        if sameStimulator==0
            stimulator2.selectDevice(stimulatorInd2-1); %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
        end
        %Connect to the stimulator
        temp=stimulator.isConnected;
        if temp==0
            stimulator.connect;
        end
        if sameStimulator==0
            temp=stimulator2.isConnected;
            if temp==0
                stimulator2.connect;
            end
        end
        
        %send initializing trigger (no current)
        currentAmplitudeFake=1;
        numPulsesFake=1;
        stimulator.setStimPattern('waveform',waveform_id,...
            'polarity',1,...
            'pulses',numPulsesFake,...
            'amp1',currentAmplitudeFake,...
            'amp2',currentAmplitudeFake,...
            'width1',170,...
            'width2',170,...
            'interphase',60,...
            'frequency',300);
        %'polarity' -	Polarity of the first phase, 0 (cathodic), 1 (anodic)
        %deliver monopolar microstimulation
        stimulator.beginSequence;
        if sameStimulator==1
            stimulator.beginGroup;
        end
        stimulator.autoStim(electrode,waveform_id) %Electrode #1 , Waveform #1
        if sameStimulator==1
            stimulator.autoStim(electrode2,waveform_id) %Electrode #2 , Waveform #1
            stimulator.endGroup;
        end
        stimulator.endSequence;
        stimulator.trigger(1);%Format: 	cerestim_object.trigger(edge)
        % 		edge value		type
        % 			0			trigger mode disabled
        % 			1			rising (low to high)
        % 			2			falling (high to low)
        % 			3			any transition
        
        if sameStimulator==0
            %other stimulator:
            stimulator2.setStimPattern('waveform',waveform_id,...
                'polarity',0,...
                'pulses',numPulsesFake,...
                'amp1',currentAmplitudeFake,...
                'amp2',currentAmplitudeFake,...
                'width1',170,...
                'width2',170,...
                'interphase',60,...
                'frequency',300);
            %'polarity' -	Polarity of the first phase, 0 (cathodic), 1 (anodic)
            stimulator2.beginSequence;
            temporallyOffset=0;
            if temporallyOffset==1%if individual pulses on the two trains should be interleaved but non-simultaneous
                stimulator2.wait(1.65);%add an offset of 1.65 ms to train on second electrode
            end
            if multiCereStim==1
                stimulator2.beginGroup;
            end
            stimulator2.autoStim(electrode2,waveform_id) %Electrode #2 , Waveform #1
            if multiCereStim==1
                stimulator2.endGroup;
            end
            stimulator2.endSequence;
            stimulator2.trigger(1);
        end
        dasbit(Par.MicroB,0);
        pause(0.1);
        dasbit(Par.MicroB,1);
        pause(0.1);
        dasbit(Par.MicroB,0);%send the first half of the second, 'real trigger' signal
        pause(0.1);
        dasbit(Par.MicroB,1);
        pause(0.1);
        dasbit(Par.MicroB,0);
        pause(0.1);
        
        %now set the waveform parameters for the real stimulation trains:        
        stimulator.setStimPattern('waveform',waveform_id,...
            'polarity',1,...
            'pulses',numPulses,...
            'amp1',currentAmplitude,...
            'amp2',currentAmplitude,...
            'width1',170,...
            'width2',170,...
            'interphase',60,...
            'frequency',300);
        if sameStimulator==0
            %other stimulator:
            stimulator2.setStimPattern('waveform',waveform_id,...
                'polarity',0,...
                'pulses',numPulses,...
                'amp1',currentAmplitude2,...
                'amp2',currentAmplitude2,...
                'width1',170,...
                'width2',170,...
                'interphase',60,...
                'frequency',300);
            %'polarity' -	Polarity of the first phase, 0 (cathodic), 1 (anodic)
        end
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
            distractArrayYTracker=[200 -200];
            distLocations=[distLocations 'TB'];
        elseif LRorTB==2
            distractArrayX=[-200 200];
            distractArrayY=[0 0];
            distractArrayYTracker=[0 0];
            distLocations=[distLocations 'LR'];
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
        FIXT2=400;
        stimFlag2=1;
        while Time < FIXT2 && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
            if visualTrial==1&&stimFlag2==1%visual trial
                %draw two simulated phosphenes simultaneously (later, vary
                %timing, duration, frequency)
                for phospheneInd=1:numSimPhosphenes
                    destRect=[screenWidth/2+visRFx(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-visRFy(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenWidth/2+visRFx(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-visRFy(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2)];
                    Screen('DrawTexture',w, masktex(phospheneInd), [], destRect);
                    Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
                end
                Screen('Flip', w);
                pause(0.1);%to match with delay imposed by dasbit during microstim trials
                Screen('FillRect',w,grey);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                Screen('Flip', w);
                stimFlag2=0;
            elseif visualTrial==0&&stimFlag2==1
                %             Screen('FillRect',w,red);
                %             Screen('Flip', w);
                dasbit(Par.MicroB,1);%send the second half of the second, 'real trigger' signal
                pause(0.1);
                sprintf('array %d, electrode %d, electrode ind %d',array,electrode,electrodeInd)
                sprintf('array %d, electrode %d, electrode ind %d',array2,electrode2,electrodeInd2)
                stimFlag2=0;
                %             Screen('FillRect',w,grey);
                %             Screen('Flip', w);
            end
        end
        
        %///////// EVENT 3 REACTION TIME%%//////////////////////////////////////
        
        if Hit == 0 %subject kept fixation, subject may make an eye movement
            
            %Draw targets
            targetSize=10;%in pixels
            lightDistractors=0;
%             displacementFactor=[-1 1 -1 1;-1 1 1 -1;0 0 -1 1;-1 1 0 0];%4 targets
            if LRorTB==1
                displacementFactor=[-1 1 -1 1;-1 1 1 -1];%first row: left target, dot 1 x, dot 2 x, dot 1 y, dot 2 y. second row: right target
                displacementFactor2=[0 0 -1 1;-1 1 0 0];%other 2 distractors
            elseif LRorTB==2
                displacementFactor=[0 0 -1 1;-1 1 0 0];%top target, bottom target
                displacementFactor2=[-1 1 -1 1;-1 1 1 -1];%other 2 distractors
            end
            col=black;
            for i=1:2
                Screen('FillOval',w,col,[screenWidth/2-targetSize+targetArrayX(i)+targetSize*displacementFactor(i,1) screenHeight/2-targetSize+targetArrayY(i)+targetSize*displacementFactor(i,3) screenWidth/2+targetArrayX(i)+targetSize*displacementFactor(i,1) screenHeight/2+targetArrayY(i)+targetSize*displacementFactor(i,3)]);
                Screen('FillOval',w,col,[screenWidth/2-targetSize+targetArrayX(i)+targetSize*displacementFactor(i,2) screenHeight/2-targetSize+targetArrayY(i)+targetSize*displacementFactor(i,4) screenWidth/2+targetArrayX(i)+targetSize*displacementFactor(i,2) screenHeight/2+targetArrayY(i)+targetSize*displacementFactor(i,4)]);
            end
            if numTargets==4
                for i=1:2
                    %                 colDist=[110 110 110];
                    Screen('FillOval',w,col,[screenWidth/2-targetSize+distractArrayX(i)+targetSize*displacementFactor2(i,1) screenHeight/2-targetSize+distractArrayY(i)+targetSize*displacementFactor2(i,3) screenWidth/2+distractArrayX(i)+targetSize*displacementFactor2(i,1) screenHeight/2+distractArrayY(i)+targetSize*displacementFactor2(i,3)]);
                    Screen('FillOval',w,col,[screenWidth/2-targetSize+distractArrayX(i)+targetSize*displacementFactor2(i,2) screenHeight/2-targetSize+distractArrayY(i)+targetSize*displacementFactor2(i,4) screenWidth/2+distractArrayX(i)+targetSize*displacementFactor2(i,2) screenHeight/2+distractArrayY(i)+targetSize*displacementFactor2(i,4)]);
                end
            end
            Screen('FillOval',w,[0 0 255],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%change fix spot colour to blue
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
%     dasbit(Par.TargetB, 1);
    if visualTrial==0   
        temp=stimulator.isConnected;
        if temp
            stimulator.disableTrigger;
        end
        temp2=stimulator2.isConnected;
        if temp2
            stimulator2.disableTrigger;
        end
    end
    
    targetIdentity=LPStat(6);
    LPStat();
    if targetIdentity==1%if correct target selected
        behavResponse(trialNo)=targetLocation;
    elseif targetIdentity>1%if erroneous target selected
        distractorRow=targetIdentity-1;%row of selected distractor, out of all distractors
        behavResponse(trialNo)=distLocations(distractorRow);%incorrect target to which saccade was made (L: left; R: right; T: top; B: bottom)
    end
    dirName=cd;
    save([dirName,'\',date,'_2phos_4targperf.mat'],'behavResponse','performance')
    
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
                condOrderLRTB=condOrderLRTB(2:end);
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
                condOrderLRTB=condOrderLRTB(newOrder2);
                newSubblock=0;
            end
        end
        dasbit(Par.MicroB,0)
        dasbit(Par.TargetB, 0);
%         for n=1:length(ident)
%             dasbit(ident(n),1);
%             pause(0.05);%add a time buffer between sending of dasbits
%             dasbit(ident(n),0);
%             pause(0.05);%add a time buffer between sending of dasbits
%         end
    end
    if falseAlarm==1
        catchFalseAlarms=catchFalseAlarms+1;
        dasbit(Par.ErrorB,1);
        fprintf('Trial %3d is a fix break\n',trialNo);
    end
    
    Screen('FillRect',w, grey);
    Screen('Flip', w);
    trialNo;
    allSampleX(trialNo)=RFx;
    allSampleY(trialNo)=RFy;
    allFixT(trialNo)=FIXT;
    allStimDur(trialNo)=stimDuration;
    allBlockNo(trialNo)=blockNo;
    allCurrentLevel(trialNo)=currentAmplitude;
    allCurrentLevel2(trialNo)=currentAmplitude2;
    allElectrodeNum(trialNo)=electrode;
    allElectrodeNum2(trialNo)=electrode2;
    allInstanceNum(trialNo)=instance;
    allInstanceNum2(trialNo)=instance2;
    allArrayNum(trialNo)=array;
    allArrayNum2(trialNo)=array2;
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
    if visualTrial==0
        %disconnect CereStim
        if exist('my_devices','var')
            if length(my_devices)>1
                stimulator.disconnect;
                stimulator2.disconnect;
            end
            pause(0.05)
        end
    end
    
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
end

Screen('Preference','SuppressAllWarnings',oldEnableFlag);