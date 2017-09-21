function runstim_microstim_saccade_catch15(Hnd)
%Written by Xing 15/9/17
%Deliver either monopolar or bipolar microstimulation to electrodes and
%record saccade end points. Set 'bipolar' variable to either 0 or 1 for
%monopolar or bipolar stimulation respectively.
%On some percentage of trials, deliver microstimulation (50 pulses). Monkey has to fixate for 300 ms, followed by
%an interval lasting anywhere from 0 to 400 ms. Monkey is required to make
%a saccade to RF location, and if correct saccade made, then at 100 ms, fix
%spot changes colour and reward given. On the other proportion of trials (catch trials), no microstim
%administered, and monkey is rewarded for maintaining fixation after 1000 ms.
%Time allowed to reach target reduced to maximum of 200 ms.
%This version should have equal timing of 'target on' encode, between
%monopolar and bipolar stimulation. 
%The present code, catch 15, uses stimulator.trigger() to trigger delivery
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
global allElectrodeNum
global allElectrodeNum2
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
global condInd
global chOrder
global allChOrder
global allMonoOrBipolar

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
allChOrder=[];
RFx=NaN;
RFy=NaN;
allMonoOrBipolar=[];

arrays=8:16;
stimulatorNums=[14295 14172 14173 14174 14175 14176 14294 14293 14138];%stimulator to which each array is connected
bipolar=1;%set to 0 for monopolar stimulation, set to 1 for bipolar stimulation

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
    catchTrialRand=randi(4);%25% of trials are catch trials
    if catchTrialRand<=1
        catchTrial=1;
    elseif catchTrialRand>1
        catchTrial=0;
    end
    if catchTrial==1
        currentAmplitude=0;
    elseif catchTrial==0
        currentAmplitude=goodCurrentThresholds(chOrder(condInd))*1.5;
        if currentAmplitude>210
            currentAmplitude=210;
        end
    end
    if currentAmplitude==0
        FIXT=1000;
        electrode=NaN;
        electrode2=NaN;
        instance=NaN;
        array=NaN;
        falseAlarm=0;
    elseif currentAmplitude>0
        FIXT=random('unif',300,700);%
        %select array & electrode index (sorted by lowest to highest impedance) for microstimulation
        array=goodArrays8to16(chOrder(condInd),7);%array number
        array=13;%delete this line
        array2=10;%delete this line
        electrodeInd=goodInds(chOrder(condInd));%channel number
        arrayInd=find(arrays==array);
        desiredStimulator=stimulatorNums(arrayInd);
        falseAlarm=NaN;
                
        instance=ceil(array/2);
        load(['C:\Users\Xing\Lick\090817_impedance\array',num2str(array),'.mat']);
        eval(['arrayRFs=array',num2str(array),';']);
        electrode=goodArrays8to16(chOrder(condInd),8);%channel number
        electrode=52;%delete this line
        sprintf('array %d, electrode %d, electrode ind %d',array,electrode,electrodeInd)
        RFx=goodArrays8to16(chOrder(condInd),1);
        RFy=goodArrays8to16(chOrder(condInd),2);
        
        if bipolar==1
            %select second electrode:
            returnElectrodeIsMin=1;%set to 1 to select adjacent electrode with lowest-impedance as return electrode. set to 0 to select highest-impedance adjacent electrode as return electrode
            arrayElectrodes=1:64;
            arrayElectrodes=reshape(arrayElectrodes,[8 8]);%1 to 8 in first column, 2 to 16 in second, etc
            arrayElectrodesPadded=zeros(10);
            arrayElectrodesPadded(2:9,2:9)=arrayElectrodes;%grid of 1 to 64, padded by zeros
            [rowInd colInd]=find(arrayElectrodes==electrode);
            squareElectrodes=arrayElectrodesPadded(rowInd:rowInd+2,colInd:colInd+2);%channel numbers in the 3x3 square, centred on the electrode of interest
            adjElectrodes=squareElectrodes(squareElectrodes~=0);
            adjElectrodes=adjElectrodes(find(adjElectrodes~=electrode));
            %look up and compile impedance values for adjacent electrodes:
            adjElectrodesInds=find(ismember(arrayRFs(:,8),adjElectrodes));%indices out of 64 electrodes
            adjElectrodesImp=arrayRFs(adjElectrodesInds,6);
            [minImpedance minInd]=min(adjElectrodesImp);
            [maxImpedance maxInd]=max(adjElectrodesImp);
            if returnElectrodeIsMin==1
                electrode2=adjElectrodes(minInd);
                electrodeInd2=minInd;
            elseif returnElectrodeIsMin==0
                electrode2=adjElectrodes(maxInd);
                electrodeInd2=maxInd;
            end
            sprintf('array %d, return electrode %d, return electrode ind %d',array,electrode2,electrodeInd2)
        else
            electrode2=NaN;
        end
        electrode=1;%delete these lines
        electrode2=2;
        % define a waveform
        waveform_id = 1;
        numPulses=1;%originally set to 5 pulses
        %         amplitude=50;%set current level in uA
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
        if currentAmplitude==0
            sampleX=NaN;
            sampleY=NaN;
        elseif currentAmplitude>0
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
        scanFlag=1;
        selectFlag=1;
        connectFlag=1;
        stimFlag=1;
        resetMicro=1;
        while Time < FIXT && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
            if currentAmplitude>0
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
                if Time>=170&&resetMicro==1
                    dasbit(Par.MicroB,0)
                    resetMicro=0;
                end
                currentAmplitude=100;%delete this line
                if Time>=190&&stimFlag==1
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
                    %deliver bipolar microstimulation
                    stimulator.beginSequence;
%                     stimulator2.beginSequence;
                    if bipolar==1
                        stimulator.beginGroup;
%                         stimulator2.beginGroup;
                    end
                    stimulator.autoStim(electrode,waveform_id) %Electrode #1 , Waveform #1
                    if bipolar==1
%                         stimulator2.autoStim(electrode2,waveform_id_Return) %Electrode #2 , Waveform #2
                        stimulator.endGroup;
%                         stimulator2.endGroup;
                    end
                    stimulator.endSequence;
%                     stimulator2.endSequence;
                    stimulator.trigger(2);
%                     stimulator2.trigger(1);%Format: 	cerestim_object.trigger(edge)
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
                    if bipolar==1
                        stimulator2.beginGroup;
                    end
                    stimulator2.autoStim(electrode,waveform_id) %Electrode #1 , Waveform #1
                    if bipolar==1
                        stimulator2.endGroup;
                    end
                    stimulator2.endSequence;
                    stimulator2.trigger(2);
                    stimFlag=0;
                end
            end
        end
        if currentAmplitude==0&&Hit==1%catch trial
            falseAlarm=1;
        end
    else
        Hit = -1; %the subject did not fixate
    end
    
    
    %///////// EVENT 2 DISPLAY TARGET(S)
    %//////////////////////////////////////
    if Hit == 0 %subject kept fixation, display stimulus
        if currentAmplitude==0%catch trial
            %do nothing
        elseif currentAmplitude>0
    Screen('FillRect',w,red);
    Screen('Flip', w);
%             dasbit(Par.MicroB,0);
            pause(0.1);
            dasbit(Par.MicroB,1);
            pause(0.1);
            dasbit(Par.MicroB,0);
            pause(0.1);
            dasbit(Par.MicroB,1);
            pause(0.1);
            dasbit(Par.MicroB,0);
            pause(0.1);
            dasbit(Par.MicroB,1);
            pause(0.1);
%             dasbit(Par.MicroB,0);
%             dasbit(Par.MicroB,1);
    Screen('FillRect',w,grey);
    Screen('Flip', w);
        end
        
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
%     dasbit(Par.TargetB, 1);
    if currentAmplitude>0   
        if stimulator.isConnected
            stimulator.disableTrigger;
        end
        if stimulator2.isConnected
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
                condInd=condInd+1;
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
        if hitCounter==2%if two hits accrued
            currentInd=currentInd-1;%decrease current
            allStaircaseResponse=[allStaircaseResponse 1];
        elseif missCounter==2%if two misses accrued
            currentInd=currentInd+1;%increase current
            allStaircaseResponse=[allStaircaseResponse 0];
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
    allSampleX(trialNo)=RFx;
    allSampleY(trialNo)=RFy;
    allFixT(trialNo)=FIXT;
    allStimDur(trialNo)=stimDuration;
    allBlockNo(trialNo)=blockNo;
    allCurrentLevel(trialNo)=currentAmplitude;
    allElectrodeNum{trialNo}=electrode;
    allElectrodeNum2{trialNo}=electrode2;
    allInstanceNum{trialNo}=instance;
    allArrayNum{trialNo}=array;
    allTargetArrivalTime(trialNo)=Time;
    allFalseAlarms(trialNo)=falseAlarm;
    allChOrder=chOrder(condInd);
    allMonoOrBipolar(trialNo)=bipolar;
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
    if currentAmplitude>0
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
end

Screen('Preference','SuppressAllWarnings',oldEnableFlag);