function runstim_simphosphenes_make_mask2(Hnd)
%Written by Xing 4/7/17
%Generate set of 40 x 10 letter stimuli (10 letters, 40 luminance
%combinations). Use runstim_simphosphenes_make_mask1.m to generate grandMask and
%finalPixelCoords, and save in stimMask.mat.

%For simulated phosphene stimuli, read in BMP file containing bitmap
%version of target letter. Bitmap font is Sloan, and font size is 320 (the
%height and width of characters in this font are designed to be equal to
%the nominal pont size specified). Hence, the height and width of the
%original character in the bitmap file are 320 pixels, as read by imread. 
%However, the sample character is resized by imresize, to the dimensions 
%sampleSize x sampleSize. 

global Par   %global parameters
global trialNo
global behavResponse
global performance
global allTargetLetters
global distLettersAllTrials
global allSampleSize
global allSampleX
global allSampleY
global allVisualHeightResolution
global allSample
global trialsRemaining
global allTrialCond
global blockNo
global corrTrialBlockCounter
global allBlockNo
    
mydir = 'C:\Users\Xing\Lick\visual_letter_task_logs\';
fn = input('Enter LOG file name (e.g. 20110413_B1), blank = no file\n','s');
%Copy the run_stim script
fnrs = [fn,'_','runstim.m'];
cfn = [mfilename('fullpath') '.m'];
copyfile(cfn,fnrs)

takeScreenshot=0;

screenWidth=Par.HW*2;
screenHeight=Par.HH*2;
screenResX=screenWidth;
screenResY=screenHeight;
w=Par.w;
FixDotSize = 0.2; 
% global LPStat  %das status values
Times = Par.Times; %copy timing structure
distractorOn=1;
brightOppositeShape=1;

%WINDOWS
%Fix window
FixWinSz =1.5;%1.5
TargWinSz = 4;  %CHANGE TO MAKE MORE ACCUARTE

%Fixatie kleur
red = [255 0 0];
fixcol = red;  %mag ook red zijn

%timing
PREFIXT = 1000; %time to enter fixation window
FIXT=300;
STIMDUR=800;

%REactie tijd
TARGT = 400; %time to keep fixating after target onset before fix goes green (het liefst 400)
RACT = 1000;      %reaction time

%Fix location
Fsz = FixDotSize.*Par.PixPerDeg;

%Target positions (Diagonals)
% targx = [-150 -150 150 150 -100 -100 100 100 -200 -200 200 200];
% targy = [-150 150 150 -150 -100 100 100 -100 -200 200 200 -200];

grey = round([255/2 255/2 255/2]);

LOG.fn = 'runstim_stimphosphenes4';
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
    fn = [mydir,'simphosphenes4_',fn];
    save(fn,'LOG')
end

%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
Hit = 2;
Par.ESC = false; %escape has not been pressed
trialNo=0;
load('C:\Users\Xing\Lick\visual_letter_task_logs\trialsRemaining.mat');%contains list of letter conds, luminance conds, and whether or not to repeat cond on next trial
trialsRemainingOriginal=trialsRemaining;
load('C:\Users\Xing\Lick\visual_letter_task_logs\lumList.mat','lumList');%a pre-determined set of luminance values for each phosphene location
load('C:\Users\Xing\Lick\RGB_LUT.mat');%load LUT for gamma-corrected RGB values  
currentTrialIsRepeat=0;
while ~Par.ESC
    %Pretrial
    
    trialNo = trialNo+1;
    %blocks of luminance and letter conditions:
    numLetterConds=10;
    numLuminanceConds=40;
    numConds=numLetterConds*numLuminanceConds;
    if trialNo==1
        blockNo=1;
        corrTrialBlockCounter=0;%tallies the number of correct trials per block
        shuffleFlag=1;
    end
    if corrTrialBlockCounter==500
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
    
    %Assign code for trial identity, using sequence of random numbers
    bits = [0 2 6];
    ch = randi(length(bits),1,8);
    ident = bits(ch);
    TRLMAT(trialNo,:) = ident;
    %SETUP YOUR STIMULI FOR THIS TRIAL
    
    if Par.Drum && Hit ~= 2 %if drumming and this was an error trial
        %just redo with current settings
    else
        diagonalSampleSize=6;%from 1 to 7 dva, measured across the diagonal (eccentricity)
        topLeft=1;%distance from fixation spot to top-left corner of sample, measured diagonally (eccentricity)
        estimatedSampleSize = round(sqrt((diagonalSampleSize^2)/2)*Par.PixPerDeg);%randi([50 100]);%pixels [50 155]
        sampleSize=112;%a multiple of 14, the number of divisions in the letters
        stimSize = 40;%size of target letters, in pixels
        sampleX = round(sqrt((topLeft^2)/2)*Par.PixPerDeg);%randi([30 100]);%location of sample stimulus, in RF quadrant 150 230%want to try 20
        sampleY = round(sqrt((topLeft^2)/2)*Par.PixPerDeg);%randi([30 100]);%[30 140]
        
        imageArray=[];
        
        targcol=[0.75 0.75 0];
        distcol=[0.75 0.75 0];
%         distcol=[0.6 0.6 0];
        targcol=targcol.*255;
        distcol=distcol.*255;
        targetArrayX=[-200 200 0 0];
        targetArrayY=[0 0 -200 200];
        targetArrayYTracker=[0 0 200 -200];%difference between Cogent and PTB
        allLetters=['IT';'UV';'AS';'LY'];
        %set target & distractor locations
        if mod(letterCond,4)==1
            targetLocation=1;%select target location
        elseif mod(letterCond,4)==2
            targetLocation=2;
        elseif mod(letterCond,4)==3
            targetLocation=3;
        elseif mod(letterCond,4)==0
            targetLocation=4;
        end
        if letterCond<=length(allLetters(:))
            targetLetter=allLetters(letterCond);
        elseif letterCond==length(allLetters(:))+1%novel letters
            targetLetter='J';
        elseif letterCond==length(allLetters(:))+2
            targetLetter='P';            
        end
        targetLetter='Q';
        stimInd=1:size(allLetters,1);
        distInd=stimInd(stimInd~=targetLocation);
        for distCount=1:length(targetArrayX)-1
            distx(distCount) = targetArrayX(distInd(distCount));
            disty(distCount) = targetArrayY(distInd(distCount));
            distyTracker(distCount) = targetArrayYTracker(distInd(distCount));%difference between Cogent and PTB
            distTemp=randi([1 size(allLetters,2)],1);%select distractor letter
            distLetters(distCount)=allLetters(distInd(distCount),distTemp)
        end
        if letterCond<=length(allLetters(:))%familiar letters
            if targetLocation==1||targetLocation==2
                oppositeShape=1;
            else
                oppositeShape=3;
            end
            oppositeLetter=distLetters(oppositeShape)
            %control window setup
            WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
                targetArrayX(targetLocation),  targetArrayYTracker(targetLocation), Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];   %2: target;
            for distCount=1:length(targetArrayX)-1
                WIN = [WIN;distx(distCount),  distyTracker(distCount), Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 1];%1: error
            end
        elseif letterCond>length(allLetters(:))%a mathematical symbol, not a letter
            WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
                targetArrayX(targetLocation),  targetArrayYTracker(targetLocation), Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];   %2: target;
            for distCount=1:length(targetArrayX)-1
                WIN = [WIN;distx(distCount),  distyTracker(distCount), Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];%rewarded at all target lcoations
            end
            oppositeLetter=targetLetter;
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
        
    visualWidth=sampleSize;%in pixels
    visualHeight=visualWidth;%in pixels
    visualHeightResolution=10;%number of subdivisions in the image height
    numSimPhosphenes=visualHeightResolution*visualHeightResolution;
    visualPixSize=floor(visualHeight/visualHeightResolution);
    visualWidthResolution=floor(visualWidth/visualPixSize);%each visual 'pixel' is a square- hence number of columns (in image width) follows automatically from that specified by visualPixSize
    if visualHeight/visualHeightResolution~=floor(visualHeight/visualHeightResolution)
        sprintf('Image height is not a multiple of visual pixel size; last row will be discarded');
    end
    if visualWidth/visualWidthResolution~=floor(visualWidth/visualWidthResolution)
        sprintf('Image width is not a multiple of visual pixel size; last column will be discarded');
    end
    
    letterPath=['C:\Users\Xing\letters\',targetLetter,'.bmp'];
    originalOutline=imread(letterPath);
    shape=imresize(originalOutline,[visualHeight,visualWidth]);
            
%     shape=ones(visualHeight,visualWidth);
    %determine which visual image 'pixels' are eligible to contain 'phosphenes'
    listVisualStim=[];
    visualStim=zeros(visualHeightResolution,visualWidthResolution);
    for i=1:visualHeightResolution
        for j=1:visualWidthResolution
            pixelImage=shape(1+(i-1)*visualPixSize:i*visualPixSize,1+(j-1)*visualPixSize:j*visualPixSize);%extract image 'bitmap' for a given 'pixel'
            if sum(pixelImage(:))/(visualPixSize^2)>=0.5
                visualStim(i,j)=1;%possible location for a 'phosphene'
                listVisualStim=[listVisualStim;i j];
            end
        end
    end
    numVisLocations=size(listVisualStim,1);%tally number of 'pixels' available for positioning of 'phosphenes'
    
    degradeVisualStim=0;
    if degradeVisualStim==1%do not generate simulated phosphene at every possible pixel location, but only at a subset of locations
        numSimPhosphenes=randi([10 200]);%set number of simulated phosphenes/channels comprising visual shape
        pixels=random('unid',numVisLocations,[numSimPhosphenes,1]);%randomly select the pixels at which simulated phosphenes will be visually presented, out of the set of possible locations
        pixels=sort(pixels);
        finalPixelList=listVisualStim(pixels,:);%get final pixel locations
    elseif degradeVisualStim==0
        numSimPhosphenes=numVisLocations;
        finalPixelList=listVisualStim;
    end
    finalPixelCoords=(finalPixelList-1)*visualPixSize+floor(0.5*visualPixSize);%calculate coordinates of selected pixel locations
    jitterLocation=1;
    if jitterLocation==1
%         finalPixelCoords=finalPixelCoords+random('unid',visualPixSize,[numSimPhosphenes,2]);%randomise position of phosphene within each 'pixel'
        finalPixelCoords=finalPixelCoords+random('unid',5,[numSimPhosphenes,2]);%randomise position of phosphene within each 'pixel'
    end
    
    %randomly set sizes of 'phosphenes'
    maxDiameter=8;%pixels
    minDiameter=8;%pixels
    diameterSimPhosphenes=random('unid',maxDiameter-minDiameter+1,[numSimPhosphenes,1]);
    diameterSimPhosphenes=diameterSimPhosphenes+minDiameter-1;
    %factor in scaling of RF sizes across cortex:
    sizeScaling=0;
    if sizeScaling==1
        diameterSimPhosphenes=diameterSimPhosphenes.*finalPixelCoords(:,1)*2/max(finalPixelCoords(:,1));
        diameterSimPhosphenes=diameterSimPhosphenes.*finalPixelCoords(:,2)*2/max(finalPixelCoords(:,2));
        singleQuadrant=0;
        %when stimulus location is confined to a single quadrant, the size of
        %phosphenes are expected to range from approximately 11.5 to 36 pixels in diameter.
        if singleQuadrant==1
            diameterSimPhosphenes=diameterSimPhosphenes/max(diameterSimPhosphenes)*(36-11.5)+11.5;
        end
    end
    radiusSimPhosphenes=diameterSimPhosphenes/2;
    
%         save('C:\Users\Xing\Lick\visual_letter_task_logs\stimMask.mat','grandMask','finalPixelCoords');
       load('C:\Users\Xing\Lick\visual_letter_task_logs\stimMask.mat');
        allLetters=['IT';'UV';'AS';'LY';'JP'];
        for letterInd=1:10                
            targetLetter=allLetters(letterInd);
            targetLetter='Q';
            letterPath=['C:\Users\Xing\letters\',targetLetter,'.bmp'];
            originalOutline=imread(letterPath);
            shape=imresize(originalOutline,[visualHeight,visualWidth]);
            
            %     shape=ones(visualHeight,visualWidth);
            %determine which visual image 'pixels' are eligible to contain 'phosphenes'
            listVisualStim=[];
            visualStim=zeros(visualHeightResolution,visualWidthResolution);
            for i=1:visualHeightResolution
                for j=1:visualWidthResolution
                    pixelImage=shape(1+(i-1)*visualPixSize:i*visualPixSize,1+(j-1)*visualPixSize:j*visualPixSize);%extract image 'bitmap' for a given 'pixel'
                    if sum(pixelImage(:))/(visualPixSize^2)>=0.5
                        visualStim(i,j)=1;%possible location for a 'phosphene'
                        listVisualStim=[listVisualStim;i j];
                    end
                end
            end
            numVisLocations=size(listVisualStim,1);%tally number of 'pixels' available for positioning of 'phosphenes'

            for lumCond=1:40
                grandMask2=uint8(ones(visualWidth+ceil(max(diameterSimPhosphenes))+visualPixSize,visualHeight+ceil(max(diameterSimPhosphenes))+visualPixSize,3) * 255/2);
                for phospheneInd=1:numVisLocations
                    ms=floor(radiusSimPhosphenes(phospheneInd));
                    phosphene100Ind=sub2ind([visualHeightResolution,visualHeightResolution],listVisualStim(phospheneInd,1),listVisualStim(phospheneInd,2));%index of phosphene within entire grid
                    xCoords=finalPixelCoords(phosphene100Ind,1):finalPixelCoords(phosphene100Ind,1)+2*ms;
                    yCoords=finalPixelCoords(phosphene100Ind,2):finalPixelCoords(phosphene100Ind,2)+2*ms;
                    %monitor calibrations yield LUT, 'desiredRGB'
                    lumCalibration=round(linspace(0,255,40));
                    for rgbInd=1:3
                        for xInd=1:length(xCoords)
                            for yInd=1:length(yCoords)
                                if grandMask2(xCoords(xInd),yCoords(yInd),rgbInd)==128%avoid artefacts when guassians overlap slightly
                                    if grandMask(xCoords(xInd),yCoords(yInd),4)~=255
                                        grandMask2(xCoords(xInd),yCoords(yInd),rgbInd)=desiredRGB(lumList(phosphene100Ind,lumCond));%luminances under mask
                                    end
                                end
                            end
                        end
                    end
                end
                
%                 for rgbInd=1:4
%                     grandMask(:,:,rgbInd)=grandMask(:,:,rgbInd)';
%                 end
                masktex=Screen('MakeTexture', w, grandMask);
                masktex2=Screen('MakeTexture', w, grandMask2);
                destRect=[screenWidth/2+sampleX screenHeight/2+sampleY screenWidth/2+sampleX+visualWidth screenHeight/2+sampleY+visualHeight];
                Screen('DrawTexture',w, masktex2, [], destRect);
                Screen('DrawTexture',w, masktex, [], destRect);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
                Screen('Flip', w);
                grandMasks2letter{lumCond}=grandMask2;
            end
%                 save(['C:\Users\Xing\Lick\visual_letter_task_logs\unique_letter_stimuli2\stimMasks_',targetLetter,'.mat'],'grandMasks2letter','finalPixelCoords');
        end
    end
    % Build a single transparency mask texture
    %masktex=Screen('MakeTexture', w, maskblob);
    masktex=Screen('MakeTexture', w, grandMask);
    masktex2=Screen('MakeTexture', w, grandMask2);

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
                sampleCoords=[screenResX*3/4-size(grandMask,1)/2 screenResY*3/4-size(grandMask,2)/2];
                destRect=[screenWidth/2+sampleX screenHeight/2+sampleY screenWidth/2+sampleX+visualWidth screenHeight/2+sampleY+visualHeight];
                
                %draw phosphene letter
                Screen('DrawTexture',w, masktex2, [], destRect);
                Screen('DrawTexture',w, masktex, [], destRect);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
                Screen('Flip', w);
                
                if takeScreenshot==1
                    imageArray = Screen('GetImage', w, [0 0 screenResX screenResY]);
                end
                stim_on_flag=1;
            end
        end
        turn_off_stim=1;
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
        tic
        
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
            estimatedTargetLetterSize=stimSize;%in pixels
            Screen('TextFont',w,'Sloan');
            Screen('TextSize',w,stimSize);
            Screen('TextStyle',w,0);
            if letterCond<=length(allLetters(:))%familiar letters
                for i=1:size(allLetters,1)-1
                    Screen('DrawText',w,distLetters(i),screenWidth/2-estimatedTargetLetterSize/2+distx(i),screenHeight/2-estimatedTargetLetterSize/2+disty(i),distcol);
                end
            elseif letterCond>length(allLetters(:))%unfamiliar letters
                for i=1:size(allLetters,1)-1
                    Screen('DrawText',w,targetLetter,screenWidth/2-estimatedTargetLetterSize/2+distx(i),screenHeight/2-estimatedTargetLetterSize/2+disty(i),targcol);
                end
            end
            Screen('DrawText',w,targetLetter,screenWidth/2-estimatedTargetLetterSize/2+targetArrayX(targetLocation),screenHeight/2-estimatedTargetLetterSize/2+targetArrayY(targetLocation),targcol);
            if brightOppositeShape==1
                if letterCond<=length(allLetters(:))
                    Screen('DrawText',w,distLetters(oppositeShape),screenWidth/2-estimatedTargetLetterSize/2+distx(oppositeShape),screenHeight/2-estimatedTargetLetterSize/2+disty(oppositeShape),targcol);
                end
            end
            Screen('Flip', w);
            
            dasbit(Par.TargetB, 1);
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
    %///////// POSTTRIAL AND REWARD //////////////////////////////////////
    if Hit ~= 0 && ~Abort %has entered a target window (false or correct)
        Screen('FillRect',w, grey);
        Screen('Flip', w);
        
        HP = line('XData', Par.ZOOM *LPStat(2), 'YData', Par.ZOOM *LPStat(3));
        set(HP, 'Marker', '+', 'MarkerSize', 20, 'MarkerEdgeColor', 'm')
        if repeatNext==1
            repeatNext=0;
            currentTrialIsRepeat=1;
            removeFromList=0;
            shuffleFlag=0;
        end
        if currentTrialIsRepeat==1%if a response was made and this was one of two consecutively repeated trials
            currentTrialIsRepeat=0;
            removeFromList=1;
            shuffleFlag=0;
        end
        if Hit == 2 &&LPStat(5) < Times.Sacc %correct target, give juice   
            dasbit(  Par.CorrectB, 1);
            dasbit(  Par.RewardB, 1);
            dasjuice(5.1);
            Par.Corrcount = Par.Corrcount + 1; %log correct trials
            % beep
            
            pause(Par.RewardTime) %RewardTime is in seconds
            
            dasjuice(0.0);
            dasbit(  Par.RewardB, 0);
            for n=1:length(ident)
                dasbit(ident(n),1)
                pause(0.01);%add a time buffer between sending of dasbits
                dasbit(ident(n),0)
                pause(0.01);%add a time buffer between sending of dasbits
            end  
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
        %keep following eye motion to plot complete saccade
        for i = 1:10   %keep targoff for 50ms
            dasrun(5) %not time critical, add some time to follow eyes
            %dasrun 5);
            DasCheck; %keep following eye motion
        end
    end
    
    if Hit ~= 2  %error response
        %add pause when subject makes error
        for i = 1:round(Times.Err/5)   %keep targoff for Times.Err ms
            %                  pause(0.005)
            dasrun(5)
            DasCheck;
        end
        
    end                       %Times.Err is in ms
    [hit Lasttime] = DasCheck;
    
    allTargetLetters(trialNo)=targetLetter;
    if targetIdentity==1%if correct target selected
        behavResponse(trialNo)=targetLetter;
        performance(trialNo)=1;%hit
    elseif targetIdentity>1%if erroneous target selected
        distractorRow=targetIdentity-1;%row of selected distractor, out of all distractors
        behavResponse(trialNo)=distLetters(distractorRow);%incorrect letter to which saccade was made
        if letterCond<=length(allLetters(:))
            performance(trialNo)=1;%for novel letters, responses to all targets are correct
        else
            performance(trialNo)=-1;%error
        end
    end
    trialNo
    distLettersAllTrials(trialNo,1:length(distLetters))=distLetters;
    allSampleSize(trialNo)=sampleSize;
    allSampleX(trialNo)=sampleX;
    allSampleY(trialNo)=sampleY;
    allVisualHeightResolution(trialNo)=visualHeightResolution;
    allSample{trialNo}=grandMask;
    allTrialCond(trialNo,:)=trialsRemaining(1,:);%store condition number, from 1 to 25
    allBlockNo(trialNo)=blockNo;
    dirName=cd;
%     if mod(trialNo,10)==0
%         save([mydir,'\',date,'_',fileLogName,'_perf.mat'],'behavResponse','performance','distLettersAllTrials','allTargetLetters','allSampleSize','allSampleX','allSampleY','allVisualHeightResolution','allSample')
%     end
    if takeScreenshot==1&&~isempty(imageArray)
%     if takeScreenshot==1&&Hit == 2&&~isempty(imageArray)
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
    
    % Blank screen
    Screen('FillRect',w, grey);
    Screen('Flip', w);
    Time = Lasttime;
    while Time < Times.InterTrial + Lasttime
        %              pause(0.005)
        dasrun(5)
        [hit Time] = DasCheck;
    end
    
    if trialNo > 0
        save(fn,'*')
    end
end   %WHILE_NOT_ESCAPED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


