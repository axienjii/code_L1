function runstim_muckli_images(Hnd)
%Written by Xing 30/10/17
%Present occluded/intact images during 750-ms fixation period.

global Par   %global parameters
global trialNo
global performance
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
global allTargetArrivalTime
global visualCorrect
global visualIncorrect
global catchFalseAlarms
global hitCounter
global missCounter
global allStaircaseResponse
global condInd
global recentPerf
global lastTrials
global trialConds
global allTargetLocation
global last200Trials
global recentPerf200Trials
global allImageConds

format compact
oldEnableFlag = Screen('Preference', 'SuppressAllWarnings',1);
Screen('Preference', 'Verbosity',0);
mydir = 'C:\Users\Xing\Lick\occluder_task_logs\';
fn = input('Enter LOG file name (e.g. 20110413_B1), blank = no file\n','s');
%Copy the run_stim script
fnrs = [fn,'_','runstim.m'];
cfn = [mfilename('fullpath') '.m'];
copyfile(cfn,fnrs)
visStimDir=['C:\Users\Xing\Lick\occluder_task_logs\',fn];
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
FixWinSz =1.2;%1.5
TargWinSz = 1.2;  %CHANGE TO MAKE MORE ACCUARTE

%Fixatie kleur
red = [255 0 0];
fixcol = red;  %mag ook red zijn

%timing
PREFIXT = 1000; %time to enter fixation window
FIXT=750;
preStimDur=300;
postStimDur=300;

%REactie tijd
RACT = 600;      %reaction time 250 ms %adjust

Fsz = FixDotSize.*Par.PixPerDeg;

grey = round([255/2 255/2 255/2]);
black=[0 0 0];

LOG.fn = 'runstim_occluder';
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
visualCorrect=0;
visualIncorrect=0;
catchFalseAlarms=0;
hitCounter=0;
missCounter=0;
performance=[];
allFixT=[];
allBlockNo=[];
newBlock=1;
allTargetArrivalTime=[];
allFalseAlarms=[];
allHitX=[];
allHitY=[];
allHitRT=[];
recentPerf=NaN;
recentPerf100Trials=NaN;
subblockCount=0;
allImageConds=[];
imageCond=NaN;

trialConds=[ones(5,1) ones(5,1)*2 ones(5,1)*3 ones(5,1)*4 ones(5,1)*5 ones(5,1)*6];%stimulus conditions. 
recFinishedFlag=0;
while ~Par.ESC&&recFinishedFlag==0
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
    end
    hitX=NaN;
    hitY=NaN;
    
    %Assign code for trial identity, using sequence of random numbers
    bits = [0 2 6];
    ch = randi(length(bits),1,8);
    ident = bits(ch);
    TRLMAT(trialNo,:) = ident;
    
    %SET UP STIMULI FOR THIS TRIAL
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
    blockNo
    
    if Par.Drum && Hit ~= 2 %if drumming and this was an error trial
        %just redo with current settings
    else
        %control window setup
        WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
            0,  0, Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];   %2: target; 
        
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
        stimFlag=1;
        stimOffFlag=1;
        while Time < FIXT+preStimDur+postStimDur && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
            if Time>=preStimDur&&stimFlag==1
                imageCond=condOrder(1);
                if imageCond<=3
                    imageMatrix=imread(['C:\Users\Xing\Lick\occluder_task_logs\smithMuckli2010\image_',num2str(imageCond),'_nonocc.png']);
                elseif imageCond>3
                    imageMatrix=imread(['C:\Users\Xing\Lick\occluder_task_logs\smithMuckli2010\image_',num2str(imageCond-3),'_occ.png']);
                end
                Screen('FillRect',w,grey);
                textureIndex=Screen('MakeTexture', w, imageMatrix);
                Screen('DrawTexture', w, textureIndex);% [,sourceRect] [,destinationRect]
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                Screen('Flip', w);
                dasbit(Par.StimB, 1);
                stimFlag=0;
            end
            if Time>=FIXT+preStimDur&&stimOffFlag==1
                Screen('FillRect',w,grey);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                Screen('Flip', w);
                stimOffFlag=0;
            end
        end
        if Hit == 0 %subject kept fixation, display stimulus
            Par.Updatxy = 1;
            Screen('FillRect',w,grey);
            Screen('FillOval',w,[0 200 0],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
            Screen('Flip', w);
            dasbit(Par.TargetB, 1);
            %EXTRACT USING THE TARGETB
            Hit = 2;
        else
            Abort = true;
        end
    else
        Hit = -1; %the subject did not fixate
    end
    
    
    %///////// EVENT 2 DISPLAY TARGET(S)
    %//////////////////////////////////////
    
    Screen('FillRect',w,grey);
    Screen('Flip', w);
    targetIdentity=LPStat(6);
    LPStat();
    dirName=cd;
    
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
            fprintf('Trial %3d (visual) is correct\n',trialNo);
            visualCorrect=visualCorrect+1;
            if Par.Trlcount==1
                lastTrials=1;
                last200Trials=1;
            else
                lastTrials=[lastTrials 1];
                last200Trials=[last200Trials 1];
            end
            if length(condOrder)>1
                condOrder=condOrder(2:end);
                newSubblock=0;
            elseif length(condOrder)==1
                newSubblock=1;
                subblockCount=subblockCount+1;
                if subblockCount>=1
                    newBlock=1;
                    subblockCount=0;
                end
            end
        elseif Hit == 1
            performance(trialNo)=-1;%error
            dasbit(Par.ErrorB, 1);
            Par.Errcount = Par.Errcount + 1;
            fprintf('Trial %3d (visual) is incorrect\n',trialNo);
            visualIncorrect=visualIncorrect+1;
            if Par.Trlcount==1
                lastTrials=0;
                last200Trials=0;
            else
                lastTrials=[lastTrials 0];
                last200Trials=[last200Trials 0];
            end
            numTrialBlockCounter=numTrialBlockCounter+1;
            if length(condOrder)>1
                newOrder2=randperm(length(condOrder));
                condOrder=condOrder(newOrder2);
                newSubblock=0;
            end
        end
    end
    
    Screen('FillRect',w, grey);
    Screen('Flip', w);
    trialNo;
    allFixT(trialNo)=FIXT;
    allBlockNo(trialNo)=blockNo;
    allTargetArrivalTime(trialNo)=Time;
    allImageConds(trialNo)=imageCond;
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
    if length(lastTrials)>30
        lastTrials=lastTrials(2:end);
    end
    recentPerf=mean(lastTrials);
    
    if length(last200Trials)>200
        last200Trials=last200Trials(2:end);
    end
    recentPerf200Trials=mean(last200Trials)
    
%     SCNT = {'TRIALS'};
    SCNT(2) = { ['Nv: ' num2str(visualCorrect+visualIncorrect)]};
    SCNT(3) = { ['C vis: ' num2str(visualCorrect) ] };
    set(Hnd(1), 'String', SCNT ) %display updated numbers in GUI
    
    % Blank screen
    Screen('FillRect',w, grey);
    Screen('Flip', w);
    
    if trialNo > 0
        save(fn,'*');
    end
    if visualCorrect>330
        recFinishedFlag=1;
    end
end

Screen('Preference','SuppressAllWarnings',oldEnableFlag);