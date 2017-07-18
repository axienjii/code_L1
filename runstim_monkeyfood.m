function runstim_monkeyfood(Hnd)
%Written by Xing & Catherine for recording 'monkeyfood' data from Lick 27/6/17
%Present 'monkeyfood' image, and shift image from trial to trial, 25 possible offset locations.
%Use PsychToolBox to generate stimuli, instead of Cogent.

global Par   %global parameters
global recentPerf
global lastTrials
global postFixOffsetTime
global perfL
global perfR
global trialNo
global performance
global repeat
global repopulateFlag
global condsRemain
global allTrialCond
global allTargetLocations
global blockNo
global corrTrialBlockCounter
global allBlockNo
    
mydir = 'C:\Users\Xing\Lick\monkeyfood_task_logs\';
fn = input('Enter LOG file name (e.g. 20110413_B1), blank = no file\n','s');
fileLogName=fn;
%Copy the run_stim script
fnrs = [fn,'_','runstim.m'];
cfn = [mfilename('fullpath') '.m'];
copyfile(cfn,fnrs)

takeScreenshot=0;
drawImage=1;

screenWidth=Par.HW*2;
screenHeight=Par.HH*2;
screenResX=screenWidth;
screenResY=screenHeight;
w=Par.w;
FixDotSize = 0.2; 
targSize=5;
% global LPStat  %das status values
Times = Par.Times; %copy timing structure

%WINDOWS
%Fix window
FixWinSz =1.5;%1.5
TargWinSz = 4;  %CHANGE TO MAKE MORE ACCUARTE

%Fixatie kleur
red = [255 0 0];
fixcol = red;  %mag ook red zijn
targCol=[0 0 255];

%timing
PREFIXT = 1000; %time to enter fixation window
FIXT=300;
STIMDUR=500;

%REactie tijd
TARGT = 300; %time to keep fixating after target onset before fix goes green
RACT = 1500;      %reaction time

%Fix location
Fsz = FixDotSize.*Par.PixPerDeg;

%Target positions (Diagonals)
% targx = [-150 -150 150 150 -100 -100 100 100 -200 -200 200 200];
% targy = [-150 150 150 -150 -100 100 100 -100 -200 200 200 -200];

grey = [255/2 255/2 255/2];

LOG.fn = 'runstim_monkeyfood';
LOG.BG = grey;
LOG.Par = Par;
LOG.Times = Par.Times;
% LOG.Frame = frame;
LOG.PREFIXT=PREFIXT;
LOG.FIXT = FIXT;
LOG.STIMDUR = STIMDUR;
if isempty(fn)
    logon = 0;
else
    logon = 1;
    fn = [mydir,'monkeyfood_',fn];
    save(fn,'LOG')
end

A = imread('C:\Users\Xing\Lick\stim_image\monkeyfood.jpg');
%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
Hit = 2;
Par.ESC = false; %escape has not been pressed
TRL = 0;
while ~Par.ESC
    %Pretrial
    if isempty(trialNo)
        trialNo=1;
    else
        trialNo=trialNo+1;
    end
    if isempty(repeat)
        repeat=0;
    end
    
    TRL = TRL+1;
    
    %blocks of attention conditions:
    %attend in: 1; attend out: 2
    if TRL==1
        blockNo=1;
        corrTrialBlockCounter=0;%tallies the number of correct trials per block
        attendCondFirstBlock=randi(2);
        attendIn=attendCondFirstBlock;
    end
    if corrTrialBlockCounter==52
        blockNo=blockNo+1;
        corrTrialBlockCounter=0;%reset counter for correct trials for each block
        if attendIn==1%swap the attention condition
            attendIn=2;
        elseif attendIn==2
            attendIn=1;
        end
    end
    
    %determine sequence of conditions, randomly permute remaining ones    
    if corrTrialBlockCounter<2
        trialCond=randi(25);
    else
        if trialNo==1
            repopulateFlag=1;
        end
        if repopulateFlag==1
            condsRemain=[1:25 1:25];
        end
        permInd=randperm(length(condsRemain));
        condsRemain=condsRemain(permInd);
        trialCond=condsRemain(1);
    end    
    %Assign code for trial identity, using sequence of random numbers
    bits = [0 2 6];
    ch = randi(length(bits),1,8);
    ident = bits(ch);
    TRLMAT(trialNo,:) = ident;
    %SETUP YOUR STIMULI FOR THIS TRIAL
    
    if Par.Drum && Hit ~= 2 %if drumming and this was an error trial
        %just redo with current settings
    else
        %randomization of shape
        bias=0.4;
        if isempty(perfL)
            perfL=0.7;
        end
        if isempty(perfR)
            perfR=0.7;
        end
        if mean(perfL)-mean(perfR)>bias
            shape=0;
        elseif mean(perfR)-mean(perfL)>bias
            shape=1;
        end
        spacing = 40;
        xPos=ceil(trialCond/5);
        yPos=mod(trialCond,5);%following Matlab convention, conditions are arranged:
        if yPos ==0
            yPos=5;
        end
        %1 6 11 16 21
        %2 7 12 17 22
        %3 8 13 18 23
        %4 9 14 19 24
        %5 10 15 20 25
        xCoords=round(-spacing*2:spacing:spacing*2);
        yCoords=round(-spacing*2:spacing:spacing*2);
        condOffsetX=xCoords(xPos);%for a 5 x 5 grid of possible RF offset locations
        condOffsetY=yCoords(yPos);        
        
        %saccade locations:
        if attendIn==1
            targetCoords=[658 433;629 464;670 464;609 496;649 496;679 496;635 522;665 522;740 538;782 538];
        elseif attendIn==2
            targetCoords=[371 256;397 256;371 282;403 282;356 313;388 313;417 313;364 356;411 354;444 333];
        end
        targetCoords=targetCoords+repmat([condOffsetX,condOffsetY],10,1);
        imageArray=[];
        randloc = randi(10);
        targetLocation = targetCoords(randloc,:);
        targetArrayYTracker=[0 0 200 -200];%difference between Cogent and PTB
        %set target location
        %control window setup
        WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
            targetLocation(1)-screenWidth/2, -targetLocation(2)+screenHeight/2, Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];   %2: target; 
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
   
%     A(:,:,4)=0.5;
%     shape=imresize(originalOutline,[visualHeight,visualWidth]);

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
        disp(FIXT);
        stim_on_flag=0;
        while Time < FIXT+STIMDUR && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
            if Time>FIXT&&stim_on_flag==0
                % Draw image for current frame:
                scale=0.5;
                sizeX = size(A,2)*scale;
                sizeY = size(A,1)*scale;
                shiftImgX = -38+condOffsetX;
                shiftImgY = 13+condOffsetY;  
                RFx=139;
                RFy=103;
                destRect=[screenWidth/2+shiftImgX-sizeX/2 screenHeight/2+shiftImgY-sizeY/2 screenWidth/2+shiftImgX-sizeX/2+sizeX screenHeight/2+shiftImgY-sizeY/2+sizeY];
                RFrect= [screenWidth/2-Par.PixPerDeg/2+RFx screenHeight/2-Par.PixPerDeg/2+RFy screenWidth/2+Par.PixPerDeg/2+RFx screenHeight/2+Par.PixPerDeg/2+RFy];
                %draw image
                textureIndex=Screen('MakeTexture',w,A);
                if drawImage==1
                    Screen('DrawTexture',w, textureIndex, [], destRect);
                end
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
                
%                 for i = 1:5%during testing, plot all RF centre locations for reference
%                     for j = 1:5
%                         RFrectshift = RFrect;
%                         RFrectshift([1 3]) = RFrectshift([1 3])+(i-3)*spacing;
%                         RFrectshift([2 4]) = RFrectshift([2 4])+(j-3)*spacing;
%                         Screen('FillRect',w, [0 250 250], RFrectshift);
%                     end
%                 end
%                 Screen('FillRect',w, [0 0 250], RFrect);%plot RF centre for reference
                if drawImage==0
                    for testSacInd=1:10%during testing, plot all saccade locations for easy visualisation
                        Screen('FillOval',w,[0 0 0],[targetCoords(testSacInd,1)-targSize/2 targetCoords(testSacInd,2)-targSize/2 targetCoords(testSacInd,1)+targSize targetCoords(testSacInd,2)+targSize]);%fixspot
                    end
                end
                Screen('Flip', w);   
                
                if takeScreenshot==1
                    imageArray = Screen('GetImage', w, [0 0 screenResX screenResY]);
                end
                stim_on_flag=1;
            end
        end
        turn_off_stim=0;
        if turn_off_stim==1
            Screen('FillRect',w,grey);
            Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
            Screen('Flip', w);
        end
    else
        Hit = -1; %the subject did not fixate
    end
    
    %///////// EVENT 2 DISPLAY TARGET(S) //////////////////////////////////////
    if Hit == 0 %subject kept fixation, display stimulus
        
        Par.Trlcount = Par.Trlcount + 1;  %counts total number of trials for this session
        dasbit(  Par.StimB, 1);
        
        dasreset(1); %test for exiting fix window
        refreshtracker(2)
        Time = 0;
        while Time < TARGT  && Hit == 0  %Keep fixating till target onset
            if TARGT - Time < 5
                dasrun(5)
                %don't plot any more, so we immediately break from loop
                Hit = LPStat(1);
                break
            else
                %Check for 5 ms
                dasrun(5)
                %get hit time and plot eye motion
                [Hit Time] = DasCheck;
            end     
        end
        
        %///////// EVENT 3 TARGET ONSET, REACTION TIME%%//////////////////////////////////////
        
        if Hit == 0 %subject kept fixation, subject may make an eye movement
            
            %Draw target
            Screen('FillRect',w,grey);
            if drawImage==1
                Screen('DrawTexture',w, textureIndex, [], destRect);
            end
            Screen('FillOval',w,targCol,[targetLocation(1)-targSize/2 targetLocation(2)-targSize/2 targetLocation(1)+targSize targetLocation(2)+targSize]);%fixspot
            Screen('Flip', w);
            
            dasbit(Par.TargetB, 1);
            dasreset(2); %check target window  enter
            refreshtracker(3) %set fix point to green
            
            if isempty(postFixOffsetTime)
                postFixOffsetTime=100;
            end
            if isempty(recentPerf)
                recentPerf=0.7;
            end
            if recentPerf>=0.8&&lastTrials(end)==1
                postFixOffsetTime=postFixOffsetTime-5;
            elseif recentPerf<=0.6&&lastTrials(end)==0
                postFixOffsetTime=postFixOffsetTime+5;
            end
            if postFixOffsetTime<0
                postFixOffsetTime=0;
            end
            if postFixOffsetTime>100
                postFixOffsetTime=100;
            end
                
            dasbit(Par.TargetB, 0);
            Time = 0;
            while Time < RACT && Hit <= 0  %RACT = time to respond (reaction time)
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
    
    targetIdentity=LPStat(6);%1 is target, 2 onwards is distractor
    LPStat()
    %///////// POSTTRIAL AND REWARD //////////////////////////////////////
    if Hit ~= 0 && ~Abort %has entered a target window (false or correct)
        
        HP = line('XData', Par.ZOOM *LPStat(2), 'YData', Par.ZOOM *LPStat(3));
        set(HP, 'Marker', '+', 'MarkerSize', 20, 'MarkerEdgeColor', 'm')
        
        if Hit == 2 &&LPStat(5) < Times.Sacc %correct target, give juice  
            Screen('FillRect',w,grey);
            Screen('DrawTexture',w, textureIndex, [], destRect);
            Screen('Flip', w); 
            dasbit(  Par.CorrectB, 1);
            pause(0.1);
            dasbit(  Par.RewardB, 1);
            dasjuice(5.1);
            Par.Corrcount = Par.Corrcount + 1; %log correct trials
            % beep
            
            pause(Par.RewardTime) %RewardTime is in seconds
            
            dasjuice(0.0);
            dasbit(  Par.RewardB, 0);
            tic
            pause(0.3)
            % Blank screen
            Screen('FillRect',w, grey);
            Screen('Flip', w);
            toc
            if Par.Trlcount==1
                lastTrials=1;
            else
                lastTrials=[lastTrials 1];
                if sign(1)==1
                    perfR=[perfR 1];
                elseif sign(1)==-1
                    perfL=[perfL 1];
                end
            end
            performance(trialNo)=1;%hit
            for n=1:length(ident)
                dasbit(ident(n),1)
                pause(0.05);%add a time buffer between sending of dasbits
                dasbit(ident(n),0)
                pause(0.05);%add a time buffer between sending of dasbits
            end   
            if length(condsRemain)>1
                condsRemain=condsRemain(2:end);
                repopulateFlag=0;
            else
                condsRemain=[];
                repopulateFlag=1;
            end
            corrTrialBlockCounter=corrTrialBlockCounter+1;
            
        elseif Hit == 1
            dasbit(  Par.ErrorB, 1);
            Par.Errcount = Par.Errcount + 1;
            %in wrong target window
            if Par.Trlcount==1
                lastTrials=0;
            else
                lastTrials=[lastTrials 0];
                if sign(1)==1
                    perfR=[perfR 0];
                elseif sign(1)==-1
                    perfL=[perfL 0];
                end
            end
            performance(trialNo)=-1;%error
        end
        if length(lastTrials)>6
            lastTrials=lastTrials(end-5:end);
        end
        if length(perfR)>10
            perfR=perfR(end-9:end);
        end
        if length(perfL)>10
            perfL=perfL(end-9:end);
        end
        recentPerf=mean(lastTrials);
        %keep following eye motion to plot complete saccade
        for i = 1:2   %keep targoff for 50ms
            dasrun(5) %not time critical, add some time to follow eyes
            %dasrun 5);
            DasCheck; %keep following eye motion
        end
        %         %Save_eyetrace( I )
        %         display([ num2str(Hit) ' reactiontime: ' num2str(LPStat(5))  ' saccadetime: ' num2str(LPStat(6))]);
        %         disp(['stimulus-target duration: ' num2str((FS - FO)*1000) ' ms ']);  %check timing of target onset
    end
    
    [hit Lasttime] = DasCheck;
    
    allTargetLocations(trialNo,:)=targetLocation;%store coords of saccade target
    allTrialCond(trialNo)=trialCond;%store condition number, from 1 to 25
    allBlockNo(trialNo)=blockNo;
    dirName=cd;
%     save([mydir,'\',date,'_',fileLogName,'_perf.mat'],'performance','allTrialCond','allTargetLocations','allBlockNo')
    if takeScreenshot==1&&Hit == 1&&~isempty(imageArray)
        dirName=cd;
        folderName=[dirName,'\test\',date];
        if ~exist(folderName,'dir')
            mkdir(folderName);
        end
        imageName=[folderName,'\sample_trial',num2str(trialNo),'.jpg'];
        imwrite(imageArray,imageName)%imwrite is a Matlab function, not a PTB-3 function
    end
    %///////////////////////INTERTRIAL AND CLEANUP
    
    %reset all bits to null
    for i = [0 1 2 3 4 5 6 7]  %Error, Stim, Saccade, Trial, Correct,
        dasbit(  i, 0);
    end
    
    SCNT = {'TRIALS'};
    SCNT(2) = { ['N: ' num2str(Par.Trlcount) ]};
    SCNT(3) = { ['C: ' num2str(Par.Corrcount) ] };
    SCNT(4) = { ['E: ' num2str(Par.Errcount) ] };
    set(Hnd(1), 'String', SCNT ) %display updated numbers in GUI
    
    SD = dasgetnoise();
    SD = SD./Par.PixPerDeg;
    set(Hnd(2), 'String', SD )
    
    Time = Lasttime;
    while Time < Times.InterTrial + Lasttime
        %              pause(0.005)
        dasrun(5)
        [hit Time] = DasCheck;
    end
    
    if TRL > 0
        save(fn,'*')
    end
end   %WHILE_NOT_ESCAPED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


