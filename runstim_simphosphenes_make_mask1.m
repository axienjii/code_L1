function runstim_simphosphenes_make_mask1(Hnd)
%Written by Xing 4/7/17
%Generate grandMask template with alpha levels, save the variables grandMask and
%finalPixelCoords in stimMask.mat. After this, use runstim_simphosphenes_make_mask2.m 
%to generate set of 40 x 10 letter stimuli (10 letters, 40 luminance
%combinations).  

%For simulated phosphene stimuli, read in BMP file containing bitmap
%version of target letter. Bitmap font is Sloan, and font size is 320 (the
%height and width of characters in this font are designed to be equal to
%the nominal pont size specified). Hence, the height and width of the
%original character in the bitmap file are 320 pixels, as read by imread. 
%However, the sample character is resized by imresize, to the dimensions 
%sampleSize x sampleSize. 

global Par   %global parameters
global recentPerf
global lastTrials
global postFixOffsetTime
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
    
    grandMask=uint8(ones(visualWidth+ceil(max(diameterSimPhosphenes))+visualPixSize,visualHeight+ceil(max(diameterSimPhosphenes))+visualPixSize,2) * 255/2);
    grandMask2=uint8(ones(visualWidth+ceil(max(diameterSimPhosphenes))+visualPixSize,visualHeight+ceil(max(diameterSimPhosphenes))+visualPixSize,2) * 255/2);
    grandMask(:,:,1)=grey(1);
    grandMask(:,:,2)=grey(1);
    grandMask(:,:,3)=grey(1);
    grandMask(:,:,4)=255;%0
    % We create a Luminance+Alpha matrix for use as transparency mask:
    % Layer 1 (Luminance) is filled with luminance value 'gray' of the
    % background.
    for phospheneInd=1:numSimPhosphenes
        ms=floor(radiusSimPhosphenes(phospheneInd));        
        [x,y]=meshgrid(-ms:ms, -ms:ms);
        
        % Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
        % mask.        
        xsd=ms/2;%2.0;
        ysd=ms/2;
        maskblob=uint8(round(exp(-((x/xsd).^2)-((y/ysd).^2))*255));
        xCoords=finalPixelCoords(phospheneInd,1):finalPixelCoords(phospheneInd,1)+2*ms;
        yCoords=finalPixelCoords(phospheneInd,2):finalPixelCoords(phospheneInd,2)+2*ms; 
        grandMask(xCoords,yCoords,4)=min(grandMask(xCoords,yCoords,4),255-maskblob);%max(grandMask(xCoords,yCoords,4),maskblob);
        
        %monitor calibrations yield LUT, 'desiredRGB'
        lumCalibration=round(linspace(0,255,40));
        for rgbInd=1:3
            grandMask2(xCoords,yCoords,rgbInd)=desiredRGB(lumList(phospheneInd,lumCond));%luminances under mask
        end
    end
    % Build a single transparency mask texture
    %masktex=Screen('MakeTexture', w, maskblob);
    masktex=Screen('MakeTexture', w, grandMask);
    masktex2=Screen('MakeTexture', w, grandMask2);

    destRect=[screenWidth/2+sampleX screenHeight/2+sampleY screenWidth/2+sampleX+visualWidth screenHeight/2+sampleY+visualHeight];
    Screen('DrawTexture',w, masktex2, [], destRect);
    Screen('DrawTexture',w, masktex, [], destRect);
    Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
    Screen('Flip', w);
    %insert breakpoint here and check locations, then save:
% save('C:\Users\Xing\Lick\visual_letter_task_logs\stimMask_new.mat','grandMask','finalPixelCoords')
end