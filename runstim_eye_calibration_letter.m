function runstim_eye_calibration_letter(Hnd)
%Written by Xing 25/5/18
%Present fix spot at each of the RF centre locations for electrodes that 
%form a letter, to calibrate eye movements in degrees of visual angle per volt.

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
global allCondNo

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
allCondNo=[];

staircaseFinishedFlag=0;
trialsDesired=10;
firstTrial=1;
currentAmplitude=0;
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
    
    %define location of fixation spot
    condNo=ceil((catchHit+1)/trialsDesired);
%     xConds=[-300 0 300 -300 0 300 -300 0 300];
%     yConds=[-300 -300 -300 0 0 0 300 300 300];
%     xCond=xConds(condNo);
%     yCond=yConds(condNo);
    
    electrodeNums=[60 34 50 37 4 1 16 15 51 52 63 5 56 35 36 55 55 48 22 62];%010518_B & B
    arrayNums=[10 10 13 15 15 15 11 10 11 13 15 15 13 13 13 10 11 11 11 11];
    electrode=electrodeNums(condNo);
    array=arrayNums(condNo);
    load(['C:\Users\Xing\Lick\090817_impedance\array',num2str(array),'.mat'])
    eval(['arrayRFs=array',num2str(array),';']);
    electrodeInd=find(arrayRFs(:,8)==electrode);
    RFx=arrayRFs(electrodeInd,1);
    RFy=arrayRFs(electrodeInd,2);
        
    xCond=RFx;%locations of visual stimuli
    yCond=RFy;
    numSimPhosphenes=length(electrode);
    finalPixelCoords=[RFx' -RFy'];
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
            if phospheneCol(1)>100
                phospheneCol(1)=phospheneCol(1)+55;
            end
            if phospheneCol(2)>100
                phospheneCol(2)=phospheneCol(2)+55;
            end
            if phospheneCol(3)>100
                phospheneCol(3)=phospheneCol(3)+55;
            end
            %                                     phospheneCol=[0 0 0];
            phospheneCol=[255 255 255];
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
    
    %SET UP STIMULI FOR THIS TRIAL    
    if Par.Drum && Hit ~= 2 %if drumming and this was an error trial
        %just redo with current settings
    else
        %control window setup
        WIN = [ xCond,  yCond, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
            xCond,  yCond, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 2];  %2: target;
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
    for phospheneInd=1:numSimPhosphenes
        destRect=[screenWidth/2+xCond(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-yCond(phospheneInd)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenWidth/2+xCond(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2-yCond(phospheneInd)+ceil(diameterSimPhosphenes(phospheneInd)/2)];
        Screen('DrawTexture',w, masktex(phospheneInd), [], destRect);
%         Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
    end
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
    
    FIXT=500;%
    if Hit ~= 0  %subjects eyes are in fixation window keep fixating for FIX time
        dasreset(1);     %set test parameters for exiting fix window        
        Time = 1;
        Hit = 0;
%         disp(FIXT);
        dasbit(  Par.StimB, 1);
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
        dasbit(  Par.TargetB, 1);
        
        %///////// EVENT 3 REACTION TIME%%//////////////////////////////////////
        
        if Hit == 0 %subject kept fixation, subject may make an eye movement
            dasreset(2); %check target window  enter
            refreshtracker(3) %set fix point to green
            Time = 0;
            Hit = 0;

            while Time < RACT && Hit <= 0  %if no saccade made to RF, keep waiting till catch dot is presented
                %Check for 5 ms
                dasrun(5)
                [Hit Time] = DasCheck;
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
                response=NaN;
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
        end
        for n=1:length(ident)
            dasbit(ident(n),1);
            pause(0.05);%add a time buffer between sending of dasbits
            dasbit(ident(n),0);
            pause(0.05);%add a time buffer between sending of dasbits
        end
        if hitCounter==2%if two hits accrued
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
    
    Screen('FillRect',w, grey);
    Screen('Flip', w);
    trialNo;
    allSampleX(trialNo)=xCond;
    allSampleY(trialNo)=yCond;
    allFixT(trialNo)=FIXT;
    allStimDur(trialNo)=0;
    allBlockNo(trialNo)=blockNo;
    allTargetArrivalTime(trialNo)=Time;
    allFalseAlarms(trialNo)=0;
    if Hit==2
        allHitX(trialNo)=hitX;
        allHitY(trialNo)=hitY;
        allHitRT(trialNo)=hitRT;
    else
        allHitX(trialNo)=NaN;
        allHitY(trialNo)=NaN;
        allHitRT(trialNo)=NaN;
    end
    allCondNo(trialNo)=condNo;
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
    SCNT(3) = { ['Hit: ' num2str(catchHit) ] };
    set(Hnd(1), 'String', SCNT ) %display updated numbers in GUI
    
    % Blank screen
    Screen('FillRect',w, grey);
    Screen('Flip', w);
    
    if trialNo > 0
        save(fn,'*');
    end
    if catchHit>=trialsDesired*length(electrodeNums)%sum(logical(diff(allStaircaseResponse)))>=minNumReversals%||(numHitsElectrode/numMissesElectrode<0.1&&numHitsElectrode+numMissesElectrode>=50)||numHitsElectrode+numMissesElectrode>80%if there are min num of reversals, or the proportion of hits to misses is low after a sufficient number of trials, terminate staircase procedure
        allStaircaseResponse=[];
        staircaseFinishedFlag=1;
        numHitsElectrode=0;
        numMissesElectrode=0;
        hitCounter=0;
        missCounter=0;
    end
end

Screen('Preference','SuppressAllWarnings',oldEnableFlag);
Screen('Preference', 'Verbosity', oldLevel);