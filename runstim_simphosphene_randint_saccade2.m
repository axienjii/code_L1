function runstim_simphosphene_randint_saccade2(Hnd)
%Written by Xing 17/7/17
%Present simulated phosphene, monkey has to fixate for 300 ms, followed by
%an interval lasting anywhere from 0 to 500 ms. A simulated phosphene
%appears at a location in the bottom right quadrant, and he is allowed to
%saccade to it immediately.

global Par   %global parameters
global trialNo
global behavResponse
global performance
global recentPerf
global allTargetLetters
global distLettersAllTrials
global allSampleSize
global allSampleX
global allSampleY
global allVisualHeightResolution
global allSample
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
global currentLevel    

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
% global LPStat  %das status values
Times = Par.Times; %copy timing structure
distractorOn=1;
brightOppositeShape=0;
black=[0 0 0];

%WINDOWS
%Fix window
FixWinSz =1.5;%1.5
TargWinSz = 2;  %CHANGE TO MAKE MORE ACCUARTE

%Fixatie kleur
red = [255 0 0];
fixcol = red;  %mag ook red zijn

%timing
PREFIXT = 1000; %time to enter fixation window

%REactie tijd
TARGT = 0; %time to keep fixating after target onset before fix goes green (het liefst 400)
RACT = 1500;      %reaction time

%Fix location
Fsz = FixDotSize.*Par.PixPerDeg;

%Target positions (Diagonals)
% targx = [-150 -150 150 150 -100 -100 100 100 -200 -200 200 200];
% targy = [-150 150 150 -150 -100 100 100 -100 -200 200 200 -200];


grey = round([255/2 255/2 255/2]);

LOG.fn = 'runstim_stimphosphenes6';
LOG.BG = grey;
LOG.Par = Par;
LOG.Times = Par.Times;
% LOG.Frame = frame;
LOG.PREFIXT=PREFIXT;
if isempty(fn)
    logon = 0;
else
    logon = 1;
    fn = [mydir,'simphosphenes6_',fn];
    save(fn,'LOG')
end

%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
Hit = 2;
Par.ESC = false; %escape has not been pressed
trialNo=0;
%first recording session:
load('C:\Users\Xing\Lick\trialsRemainingSacc.mat');%contains list of letter conds, luminance conds, and whether or not to repeat cond on next trial
trialsRemainingOriginal=trialsRemainingSacc;
%for subsequent recording seesions, load in trials remaining from previous
%day:
% load('C:\Users\Xing\Lick\visual_letter_task_logs\simphosphenes6_20170711_B1.mat','trialsRemaining','trialsRemainingOriginal')

% load('C:\Users\Xing\Lick\visual_letter_task_logs\lumList.mat','lumList');%a pre-determined set of luminance values for each phosphene location
% load('C:\Users\Xing\Lick\RGB_LUT.mat');%load LUT for gamma-corrected RGB values  
currentTrialIsRepeat=0;
while ~Par.ESC
    %Pretrial
    trialNo = trialNo+1;
    if isempty(trialsRemaining)
        trialsRemaining=trialsRemainingOriginal;
        emptyTrialsRemainingFlag=1;
    end
    %blocks of luminance and letter conditions:
    numLetterConds=10;
    numLuminanceConds=40;
    numConds=numLetterConds*numLuminanceConds;
    if trialNo==1
        blockNo=1;
        corrTrialBlockCounter=0;%tallies the number of correct trials per block
        shuffleFlag=1;
    end
    if corrTrialBlockCounter==50
        blockNo=blockNo+1;
        corrTrialBlockCounter=0;%reset counter for correct trials for each block
    end
    if shuffleFlag==1
        permInd=randperm(size(trialsRemaining,1));
        trialsRemaining=trialsRemaining(permInd,:);
    end
    letterCond=trialsRemaining(1,1);
    lumCond=trialsRemaining(1,2);
    if currentTrialIsRepeat==1
        repeatNext=0;
    else
        repeatNext=trialsRemaining(1,3);
    end
    allTrialCond(trialNo,:)=trialsRemaining(1,:);%store conditions
    
    %Assign code for trial identity, using sequence of random numbers
    bits = [0 2 6];
    ch = randi(length(bits),1,8);
    ident = bits(ch);
    TRLMAT(trialNo,:) = ident;
    %SET UP YOUR STIMULI FOR THIS TRIAL
    
    FIXT=random('unif',300,800);%1000,2300
    stimDuration=randi([120 150]);
    if Par.Drum && Hit ~= 2 %if drumming and this was an error trial
        %just redo with current settings
    else
        %randomization of shape        
        sampleSize = randi([5 10]);%pixels
        sampleX = randi([40 180]);%location of sample stimulus, in RF quadrant 150 230
        sampleY = randi([40 180]);
        finalPixelCoordsAll=[sampleX sampleY]
        
        %control window setup
        WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
            sampleX,  -sampleY, Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];   %2: target; 
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
        
    if mod(blockNo,2)==1
        blockType=1;%visually presented simulated phosphene
    else
        blockType=2;%microstimulation block
    end
%     if blockType==1
        visualWidth=sampleSize;%in pixels
        visualHeight=visualWidth;%in pixels
        
        %randomly set sizes of 'phosphenes'
        maxDiameter=7;%pixels
        minDiameter=2;%pixels
        numSimPhosphenes=1;
        diameterSimPhosphenes=random('unid',maxDiameter-minDiameter+1,[numSimPhosphenes,1]);
        diameterSimPhosphenes=diameterSimPhosphenes+minDiameter-1;
        %factor in scaling of RF sizes across cortex:
        sizeScaling=0;
        if sizeScaling==1
            singleQuadrant=1;
            %when stimulus location is confined to a single quadrant, the size of
            %phosphenes are expected to range from approximately 11.5 to 36 pixels in diameter.
            diameterSimPhosphenes=diameterSimPhosphenes.*finalPixelCoordsAll(:,1)*2/max(finalPixelCoordsAll(:,1));
            diameterSimPhosphenes=diameterSimPhosphenes.*finalPixelCoordsAll(:,2)*2/max(finalPixelCoordsAll(:,2));
            if singleQuadrant==1
                diameterSimPhosphenes=diameterSimPhosphenes/max(diameterSimPhosphenes)*(36-11.5)+11.5;
            end
        end
        radiusSimPhosphenes=diameterSimPhosphenes/2;
        
        % We create a Luminance+Alpha matrix for use as transparency mask:
        % Layer 1 (Luminance) is filled with luminance value 'gray' of the
        % background.
        for phospheneInd=1:numSimPhosphenes
            newPhosphene=[];
            ms=floor(radiusSimPhosphenes(phospheneInd));
            [x,y]=meshgrid(-ms:ms, -ms:ms);
            
            % Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
            % mask.
            xsd=ms/2.0;
            ysd=ms/2.0;
            maskblob=uint8(round(exp(-((x/xsd).^2)-((y/ysd).^2))*255));
            phospheneRegion=maskblob~=0;
            phospheneStyle=randi(2);%mixture of dark and light phosphenes
            if phospheneStyle==1%light phosphenes
                phospheneCol=randi(127,[1 3])+127;
                for rbgIndex=1:3
                    newPhosphene(:,:,rbgIndex)=uint8(phospheneRegion*phospheneCol(rbgIndex));
                end
            elseif phospheneStyle==2%dark phosphenes
                phospheneCol=randi(100,[1 3]);
                for rbgIndex=1:3
                    newPhosphene(:,:,rbgIndex)=uint8(phospheneRegion*phospheneCol(rbgIndex));
                end
            end
            newPhosphene(:,:,4)=maskblob;
            masktex(phospheneInd)=Screen('MakeTexture', w, newPhosphene);
        end
        % Build a single transparency mask texture
        %masktex=Screen('MakeTexture', w, maskblob);
%     else
%         
%     end
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
    %prepare simulated phosphene
    for phospheneInd=1:numSimPhosphenes
        destRect=[screenWidth/2+finalPixelCoordsAll(phospheneInd,1)-visualWidth/2 screenHeight/2+finalPixelCoordsAll(phospheneInd,2)-visualHeight/2 screenWidth/2+finalPixelCoordsAll(phospheneInd,1)+visualWidth/2 screenHeight/2+finalPixelCoordsAll(phospheneInd,2)+visualHeight/2];
        Screen('DrawTexture',w, masktex(phospheneInd), [], destRect);
        Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
    end
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
        while Time < FIXT && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
        end
        if Hit ~= 0 %eye has left fixation too early
            %possibly due to eye overshoot, give subject another chance
            dasreset( 0 );
            Time = 1;
            Hit = 0;
            while Time < PREFIXT && Hit == 0
                dasrun(5)
                [Hit Time] = DasCheck; %retrieve position values and plot on Control display
            end
            if Hit ~= 0  %subjects eyes are in fixation window keep fixating for FIX time
                dasreset( 1 );  %test for exiting fix window
                
                Time = 1;
                Hit = 0;
                while Time < FIXT && Hit == 0
                    %Check for 10 ms
                    dasrun(5)
                    [Hit Time] = DasCheck;
                end
            else
                Hit = -1; %the subject did not fixate
            end
            disp('2nd chance')
        end
    else
        Hit = -1; %the subject did not fixate
    end
              
    
    %///////// EVENT 2 DISPLAY TARGET(S) //////////////////////////////////////
    if Hit == 0 %subject kept fixation, display stimulus
        
%         if blockType==1
            %draw simulated phosphene
            Screen('Flip', w);
%         else
%             %deliver microstimulation
%             
%         end
        dasbit(  Par.TargetB, 1);
        tic
                
        %///////// EVENT 3 TARGET ONSET, REACTION TIME%%//////////////////////////////////////
        
        if Hit == 0 %subject kept fixation, subject may make an eye movement
                      
            dasreset(2); %check target window  enter
            refreshtracker(3) %set fix point to green
            
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
    dirName=cd;
%     save([dirName,'\test\',date,'_perf.mat'],'behavResponse','performance')
    
    %///////// POSTTRIAL AND REWARD //////////////////////////////////////
    if Hit ~= 0 && ~Abort %has entered a target window (false or correct)
        Screen('FillRect',w, grey);
        Screen('Flip', w);
        
        HP = line('XData', Par.ZOOM *LPStat(2), 'YData', Par.ZOOM *LPStat(3));
        set(HP, 'Marker', '+', 'MarkerSize', 20, 'MarkerEdgeColor', 'm')
        
        removeFromList=0;
        if currentTrialIsRepeat==1%if a response was made and this was one of two consecutively repeated trials
            currentTrialIsRepeat=0;
            removeFromList=1;
            shuffleFlag=0;
        end
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
            if repeatNext==0
                removeFromList=1;    
            end
            if length(trialsRemaining)>1
                if removeFromList==1
                    trialsRemaining=trialsRemaining(2:end,:);%remove complete, not-repeated trial from list
                end
            else
                trialsRemaining=trialsRemainingOriginal;
            end
            shuffleFlag=0;
            corrTrialBlockCounter=corrTrialBlockCounter+1; 
            
        elseif Hit == 1
            dasbit(  Par.ErrorB, 1);
            Par.Errcount = Par.Errcount + 1;
            performance(trialNo)=-1;%error
            %in wrong target window
            if repeatNext==0
                removeFromList=0;    
                shuffleFlag=1;   
            end
            if length(trialsRemaining)>1
                if removeFromList==1
                    trialsRemaining=trialsRemaining(2:end,:);%remove complete, not-repeated trial from list
                end
            else
                trialsRemaining=trialsRemainingOriginal;
            end            
        end
        if repeatNext==1
            repeatNext=0;
            currentTrialIsRepeat=1;
            removeFromList=0;
            shuffleFlag=0;
        end
        for n=1:length(ident)
            dasbit(ident(n),1)
            pause(0.05);%add a time buffer between sending of dasbits
            dasbit(ident(n),0)
            pause(0.05);%add a time buffer between sending of dasbits
        end
    end
    
    [hit Lasttime] = DasCheck;
    
    trialNo
    allSampleSize(trialNo)=sampleSize;
    allSampleX(trialNo)=sampleX;
    allSampleY(trialNo)=sampleY;
    allFixT(trialNo)=FIXT;
    allStimDur(trialNo)=stimDuration;
    allBlockNo(trialNo)=blockNo;
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
    
    SCNT = {'TRIALS'};
    SCNT(2) = { ['N: ' num2str(Par.Trlcount) ]};
    SCNT(3) = { ['C: ' num2str(Par.Corrcount) ] };
    SCNT(4) = { ['E: ' num2str(Par.Errcount) ] };
    set(Hnd(1), 'String', SCNT ) %display updated numbers in GUI

    % Blank screen
    Screen('FillRect',w, grey);
    Screen('Flip', w);
    
    if trialNo > 0
        save(fn,'*')
    end
end   

