function runstim_microstim_saccade_catch16(Hnd)
%Written by Xing 21/9/17
%2-phosphene task, 2 targets. Partially visual trials and partially
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
global allCurrentLevel2
global allElectrodeNum
global allElectrodeNum2
global allInstanceNum
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
global currentInd
global allStaircaseResponse
global missesAtMaxCurrent
global condInd
global chOrder
global allChOrder
global allMultiCereStim

format compact
oldEnableFlag = Screen('Preference', 'SuppressAllWarnings',1);
Screen('Preference', 'Verbosity',0);
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
TargWinSz = 4;  %CHANGE TO MAKE MORE ACCUARTE

%Fixatie kleur
red = [255 0 0];
fixcol = red;  %mag ook red zijn

%timing
PREFIXT = 1000; %time to enter fixation window

%REactie tijd
TARGT = 0; %time to keep fixating after target onset before fix goes green (het liefst 400)
RACT = 2500;      %reaction time 250 ms %adjust

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
visHit=0;
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
allChOrder=[];
RFx=NaN;
RFy=NaN;
RFx2=NaN;
RFy2=NaN;
allMultiCereStim=[];

arrays=8:16;
stimulatorNums=[14295 14172 14173 14174 14175 14176 14294 14293 14138];%stimulator to which each array is connected
multiCereStim=1;%set to 1 for stimulation involving more than 1 CereStim

load('C:\Users\Xing\Lick\currentThresholdChs.mat');
chOrder=originalChOrder;
condInd=1;
staircaseFinishedFlag=0;%remains 0 until 40 reversals in staircase procedure have occured, at which point it is set to 1

%Create stimulator object
stimulator = cerestim96();
stimulator2 = cerestim96();
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
    catchTrialRand=randi(2);%50% of trials are visual trials %delete this line
%     catchTrialRand=2;%1: visual trials; 2: microstim trials
    if catchTrialRand<=1
        catchTrial=1;
    elseif catchTrialRand>1
        catchTrial=0;
    end
    if catchTrial==1
        currentAmplitude=0;
        electrode=NaN;
        electrode2=NaN;
        instance=NaN;
        array=NaN;
        falseAlarm=0;
    elseif catchTrial==0
        % define a waveform
        waveform_id = 1;
        numPulses=1;%originally set to 5 pulses
        %         amplitude=50;%set current level in uA
    end
    FIXT=random('unif',300,700);%on both visual and microstim trials, time during which monkey is required to fixate, before two dots appear
    
    %specify array & electrode index (sorted by lowest to highest impedance) for microstimulation
    LRorTB=randi(2);%2 targets, 1: left and right; 2: top and bottom
    LRorTB=2;
    targetLocation=randi([1 2],1);%select target location
%     targetLocation=2;
    twoPairs=1;
    if twoPairs==1
        if LRorTB==1
            targetArrayX=[-200 200];
            targetArrayY=[0 0];
            targetArrayYTracker=[0 0];
            targetLocations='LR';
        elseif LRorTB==2
            targetArrayX=[0 0];
            targetArrayY=[-200 200];
            targetArrayYTracker=[200 -200];
            targetLocations='TB';
            if targetLocation==1
                array=13;%delete this line
                array2=11;%delete this line
                electrode=50;%delete these lines
                electrode2=55;
            elseif targetLocation==2
                array=13;%delete this line
                array2=10;%delete this line
                electrode=32;%delete these lines
                electrode2=57;
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
    load(['C:\Users\Xing\Lick\090817_impedance\array',num2str(array),'.mat']);
    eval(['arrayRFs=array',num2str(array),';']);
    %         electrode=goodArrays8to16(chOrder(condInd),8);%channel number
    RFx=goodArrays8to16(electrodeInd,1);
    RFy=goodArrays8to16(electrodeInd,2);
    RFx2=goodArrays8to16(electrodeInd2,1);
    RFy2=goodArrays8to16(electrodeInd2,2);
    
    visRFx=[RFx RFx2];%locations of visual stimuli
    visRFy=[RFy RFy2];
    if catchTrial==1%visual trial
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
        maxDiameter=10;%pixels
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
                phospheneCol=[0 0 0];
                for rbgIndex=1:3
                    newPhosphene(:,:,rbgIndex)=uint8(phospheneRegion*phospheneCol(rbgIndex));
                end
            elseif phospheneStyle==2%dark phosphenes
                phospheneCol=randi(100,[1 3]);
                phospheneCol=[0 0 0];
                for rbgIndex=1:3
                    newPhosphene(:,:,rbgIndex)=uint8(phospheneRegion*phospheneCol(rbgIndex));
                end
            end
            newPhosphene(:,:,4)=maskblob;
            masktex(phospheneInd)=Screen('MakeTexture', w, newPhosphene);
        end
    elseif catchTrial==0
        currentAmplitude=goodCurrentThresholds(electrodeInd)*1.5;
        if currentAmplitude>210
            currentAmplitude=210;
        end
        currentAmplitude2=goodCurrentThresholds(electrodeInd2)*1.5;
        if currentAmplitude2>210
            currentAmplitude2=210;
        end
    end
    
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
        for distCount=1:length(targetArrayX)-1
            WIN = [WIN;distx(distCount),  disty(distCount), Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 1];%1: error
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
        scanFlag=1;
        selectFlag=1;
        connectFlag=1;
        stimFlag=1;
        resetMicro=1;
        prepStimFlag=1;
        while Time < FIXT && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
            if catchTrial==0
                if scanFlag==1%scan for devices immediately
                    my_devices = stimulator.scanForDevices;
                    scanFlag=0;
                end
                if Time>=50&&selectFlag==1%after a 50-ms interval, select device
                    stimulatorInd=find(my_devices==desiredStimulator);
                    stimulatorInd2=find(my_devices==desiredStimulator2);
                    stimulator.selectDevice(stimulatorInd-1); %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
                    stimulator2.selectDevice(stimulatorInd2-1); %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
                    selectFlag=0;
                end
                if Time>=150&&connectFlag==1%after a 150-ms interval, connect to device
                    %Connect to the stimulator
                    temp=stimulator.isConnected;
                    if temp==0
                        stimulator.connect;
                    end
                    temp=stimulator2.isConnected;
                    if temp==0
                        stimulator2.connect;
                    end
                    connectFlag=0;
                end
                if Time>=170&&stimFlag==1
                    stimulator.setStimPattern('waveform',waveform_id,...
                        'polarity',1,...
                        'pulses',numPulses,...
                        'amp1',currentAmplitude,...
                        'amp2',currentAmplitude,...
                        'width1',170,...
                        'width2',170,...
                        'interphase',60,...
                        'frequency',300);
                    %'polarity' -	Polarity of the first phase, 0 (cathodic), 1 (anodic)
                    waveform_id_Return=2;
                    stimulator.setStimPattern('waveform',waveform_id_Return,...
                        'polarity',0,...
                        'pulses',numPulses,...
                        'amp1',currentAmplitude,...
                        'amp2',currentAmplitude,...
                        'width1',170,...
                        'width2',170,...
                        'interphase',60,...
                        'frequency',300);
                    %deliver monopolar microstimulation
                    stimulator.beginSequence;
                    if multiCereStim==1
                        stimulator.beginGroup;
                    end
                    stimulator.autoStim(electrode,waveform_id) %Electrode #1 , Waveform #1
                    if multiCereStim==1
                        stimulator.endGroup;
                    end
                    stimulator.endSequence;
                    stimulator.trigger(1);%Format: 	cerestim_object.trigger(edge)
                    % 		edge value		type
                    % 			0			trigger mode disabled
                    % 			1			rising (low to high)
                    % 			2			falling (high to low)
                    % 			3			any transition
                    
                    %other stimulator:
                    stimulator2.setStimPattern('waveform',waveform_id,...
                        'polarity',0,...
                        'pulses',numPulses,...
                        'amp1',currentAmplitude,...
                        'amp2',currentAmplitude,...
                        'width1',170,...
                        'width2',170,...
                        'interphase',60,...
                        'frequency',300);
                    %'polarity' -	Polarity of the first phase, 0 (cathodic), 1 (anodic)
                    waveform_id_Return=2;
                    stimulator2.setStimPattern('waveform',waveform_id_Return,...
                        'polarity',1,...
                        'pulses',numPulses,...
                        'amp1',currentAmplitude,...
                        'amp2',currentAmplitude,...
                        'width1',170,...
                        'width2',170,...
                        'interphase',60,...
                        'frequency',300);
                    stimulator2.beginSequence;
                    if multiCereStim==1
                        stimulator2.beginGroup;
                    end
                    stimulator2.autoStim(electrode,waveform_id) %Electrode #1 , Waveform #1
                    if multiCereStim==1
                        stimulator2.endGroup;
                    end
                    stimulator2.endSequence;
                    stimulator2.trigger(1);
                    stimFlag=0;
                end
            end
            if Time>=FIXT-25&&prepStimFlag==1%send the first 'pre-trigger' signal
                dasbit(Par.MicroB,0);
                pause(0.1);
                dasbit(Par.MicroB,1);
                pause(0.1);
                prepStimFlag=0;
            end
        end
        if catchTrial==1&&Hit==1%catch trial
            falseAlarm=1;
        end
    else
        Hit = -1; %the subject did not fixate
    end
    
    
    %///////// EVENT 2 DISPLAY TARGET(S)
    %//////////////////////////////////////
    if Hit == 0 %subject kept fixation, display stimulus
        if catchTrial==1%visual trial
            %draw two simulated phosphenes simultaneously (later, vary
            %timing, duration, frequency)
            for phospheneInd=1:numSimPhosphenes
                destRect=[screenWidth/2+visRFx(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-visRFy(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenWidth/2+visRFx(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-visRFy(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2)];
                Screen('DrawTexture',w, masktex(phospheneInd), [], destRect);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
            end
            Screen('Flip', w);
            pause(0.2);%0.01
            Screen('FillRect',w,grey);
            Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
            Screen('Flip', w);
        elseif catchTrial==0
%             Screen('FillRect',w,red);
%             Screen('Flip', w);
            dasbit(Par.MicroB,0);%send the second, 'real trigger' signal
            pause(0.1);
            dasbit(Par.MicroB,1);
            pause(0.1);
            sprintf('array %d, electrode %d, electrode ind %d',array,electrode,electrodeInd)
            sprintf('array %d, electrode %d, electrode ind %d',array2,electrode2,electrodeInd2)
%             Screen('FillRect',w,grey);
%             Screen('Flip', w);
        end
        
        %///////// EVENT 3 REACTION TIME%%//////////////////////////////////////
        
        if Hit == 0 %subject kept fixation, subject may make an eye movement
            
            %Draw targets
            targetSize=10;%in pixels
            lightDistractors=0;
%             displacementFactor=[-1 1 -1 1;-1 1 1 -1;0 0 -1 1;-1 1 0 0];%4 targets
%             if LRorTB==1
%                 displacementFactor=[-1 1 -1 1;-1 1 1 -1];%first row: left target, dot 1 x, dot 2 x, dot 1 y, dot 2 y. second row: right target
%             elseif LRorTB==2
                displacementFactor=[0 0 -1 1;-1 1 0 0];%top target, bottom target
%             end
            for i=1:2
                if i==targetLocation
                    col=black;
                else
                    col=black;
%                     col=[30 30 30];
%                     col=[120 120 120];
                end
                Screen('FillOval',w,col,[screenWidth/2-targetSize+targetArrayX(i)+targetSize*displacementFactor(i,1) screenHeight/2-targetSize+targetArrayY(i)+targetSize*displacementFactor(i,3) screenWidth/2+targetArrayX(i)+targetSize*displacementFactor(i,1) screenHeight/2+targetArrayY(i)+targetSize*displacementFactor(i,3)]);
                Screen('FillOval',w,col,[screenWidth/2-targetSize+targetArrayX(i)+targetSize*displacementFactor(i,2) screenHeight/2-targetSize+targetArrayY(i)+targetSize*displacementFactor(i,4) screenWidth/2+targetArrayX(i)+targetSize*displacementFactor(i,2) screenHeight/2+targetArrayY(i)+targetSize*displacementFactor(i,4)]);
            end
%             for i=targetLocation
%                 Screen('FillOval',w,black,[screenWidth/2-targetSize+targetArrayX(i)+targetSize*displacementFactor(i,1) screenHeight/2-targetSize+targetArrayY(i)+targetSize*displacementFactor(i,3) screenWidth/2+targetArrayX(i)+targetSize*displacementFactor(i,1) screenHeight/2+targetArrayY(i)+targetSize*displacementFactor(i,3)]);
%                 Screen('FillOval',w,black,[screenWidth/2-targetSize+targetArrayX(i)+targetSize*displacementFactor(i,2) screenHeight/2-targetSize+targetArrayY(i)+targetSize*displacementFactor(i,4) screenWidth/2+targetArrayX(i)+targetSize*displacementFactor(i,2) screenHeight/2+targetArrayY(i)+targetSize*displacementFactor(i,4)]);
%             end
            
%             if brightOppositeShape==1
%                 Screen('FillOval',w,black,[screenWidth/2-targetSize+distx(oppositeShape) screenHeight/2-targetSize+disty(oppositeShape) screenWidth/2+distx(oppositeShape) screenHeight/2+disty(oppositeShape)]);
%             end
%             Screen('FillOval',w,black,[screenWidth/2-targetSize+targetArrayX(targetLocation) screenHeight/2-targetSize+targetArrayY(targetLocation) screenWidth/2+targetArrayX(targetLocation) screenHeight/2+targetArrayY(targetLocation)]);
            Screen('FillOval',w,[0 0 255],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%change fix spot colour to blue
            Screen('Flip', w);
            
            dasbit(Par.TargetB, 1);
            dasreset(2); %check target window enter
            refreshtracker(3) %set fix point to green
            if catchTrial==1%catch trial
                Time = 0;
                Hit = 0;
                while Time < RACT && Hit <= 0  %if no saccade made to RF, keep waiting till catch dot is presented
                    %Check for 5 ms
                    dasrun(5)
                    [Hit Time] = DasCheck;
                end                
                Screen('FillOval',w,[0 255 0],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                Screen('Flip', w);
            elseif catchTrial==0             
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
%     dasbit(Par.TargetB, 1);
    if catchTrial==0   
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
            if catchTrial==1%visual trial 
                fprintf('Trial %3d (visual) is correct\n',trialNo);
                visualCorrect=visualCorrect+1;
            elseif catchTrial==0
                fprintf('Trial %3d (microstim) at %5.2f uA is correct\n',trialNo,currentAmplitude);
                microstimCorrect=microstimCorrect+1;
                numHitsElectrode=numHitsElectrode+1;%counter for a given electrode
                condInd=condInd+1;
            end
        elseif Hit == 1
            if catchTrial==1%visual trial 
                fprintf('Trial %3d (visual) is incorrect\n',trialNo);
                visualIncorrect=visualIncorrect+1;
            elseif catchTrial==0%miss trial
                dasbit(Par.ErrorB, 1);
                Par.Errcount = Par.Errcount + 1;
                performance(trialNo)=-1;%error
                fprintf('Trial %3d (microstim) at %5.2f uA is incorrect\n',trialNo,currentAmplitude);
                microstimIncorrect=microstimIncorrect+1;
                numMissesElectrode=numMissesElectrode+1;%counter for a given electrode
                condInd=condInd+1;
            end
        end
        if condInd>length(chOrder)
            condInd=1;
        end
        dasbit(Par.MicroB,0)
        dasbit(Par.TargetB, 0);
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
    allElectrodeNum{trialNo}=electrode;
    allElectrodeNum2{trialNo}=electrode2;
    allInstanceNum{trialNo}=instance;
    allArrayNum{trialNo}=array;
    allArrayNum2{trialNo}=array2;
    allTargetArrivalTime(trialNo)=Time;
    allFalseAlarms(trialNo)=falseAlarm;
    allChOrder=chOrder(condInd);
    allMultiCereStim(trialNo)=multiCereStim;
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
    dirName=cd;
    %///////////////////////INTERTRIAL AND CLEANUP
    
    %reset all bits to null
    for i = [0 1 2 3 4 5 6 7]  %Error, Stim, Saccade, Trial, Correct,
        dasbit(  i, 0);
    end
    dasclearword();
    if catchTrial==0
        %disconnect CereStim
        if exist('my_devices','var')
            if length(my_devices)>1
                stimulator.disconnect;
                stimulator2.disconnect;
            end
            pause(0.05)
        end
    end
    
    SCNT = {'TRIALS'};
    %     SCNT(2) = { ['N: ' num2str(Par.Trlcount) ]};
    %     SCNT(3) = { ['C: ' num2str(Par.Corrcount) ] };
    %     SCNT(4) = { ['E: ' num2str(Par.Errcount) ] };
    SCNT(2) = { ['N: ' num2str(visHit+microstimHit+microstimMiss) ]};
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
end

Screen('Preference','SuppressAllWarnings',oldEnableFlag);