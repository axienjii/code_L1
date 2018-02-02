function runstim_fixtraining_letters_simphosphenes2(Hnd)
%Written by Xing for training Lick 9/9/16
%Present letters in the Sloan font (extended version from Denis Pelli) in
%the form of simulated phosphenes.
%Use PsychToolBox to generate stimuli, instead of Cogent.

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
global perfL
global perfR
global trialNo
global behavResponse
global performance
global repeat
global repeatStim
global repeatTargetLocation
    
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

%REactie tijd
TARGT = 150; %time to keep fixating after target onset before fix goes green (het liefst 400)
RACT = 3000;      %reaction time

%Fix location
Fsz = FixDotSize.*Par.PixPerDeg;

%Target positions (Diagonals)
% targx = [-150 -150 150 150 -100 -100 100 100 -200 -200 200 200];
% targy = [-150 150 150 -150 -100 100 100 -100 -200 200 200 -200];

grey = [255/2 255/2 255/2];

%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
Hit = 2;
Par.ESC = false; %escape has not been pressed
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
        sampleSize = randi([40 100]);%pixels
        stimSize = 40;%size of target letters, in pixels
        sampleX = randi([10 60]);%location of sample stimulus, in RF quadrant 150 230
        sampleY = randi([10 60]);
        
        a=100;%sample colours
        b=255;
        c=0;
        d=255;
        sampcol=[a+(b-a).*rand(1,1) a+(b-a).*rand(1,1) c+(d-c).*rand(1,1)];
        targcol=[0.75 0.75 0];
        distcol=[0.75 0.75 0];
        targcol=targcol.*255;
        distcol=distcol.*255;
        targetArrayX=[-200 200 0 0];
        targetArrayY=[0 0 -200 200];
        targetArrayYTracker=[0 0 200 -200];%difference between Cogent and PTB
        allLetters=['EIXT';'OUKV';'SDAZ';'LNYH'];
        allLetters=['IIII';'OOOO';'AAAA';'LLLL'];
        %set target & distractor locations
        targetLocation=randi([1 4],1);%select target location
        targetLetterNum=randi([1 4],1);%select target letter
        targetLetter=allLetters(targetLocation,targetLetterNum)
        if repeat==1
            targetLetter=repeatStim
            targetLocation=repeatTargetLocation;
            repeat=0;
        end
        stimInd=1:size(allLetters,1);
        distInd=stimInd(stimInd~=targetLocation);
        for distCount=1:length(targetArrayX)-1
            distx(distCount) = targetArrayX(distInd(distCount));
            disty(distCount) = targetArrayY(distInd(distCount));
            distyTracker(distCount) = targetArrayYTracker(distInd(distCount));%difference between Cogent and PTB
            distTemp=randi([1 4],1);%select distractor letter
            distLetters(distCount)=allLetters(distInd(distCount),distTemp)
        end    
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
    visualHeightResolution=randi([4 6]);%number of subdivisions in the image height
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
        numSimPhosphenes=randi([10 20]);%set number of simulated phosphenes/channels comprising visual shape
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
        finalPixelCoords=finalPixelCoords+random('unid',visualPixSize,[numSimPhosphenes,2]);%randomise position of phosphene within each 'pixel'
    end
    
    %randomly set sizes of 'phosphenes'
    maxDiameter=20;%pixels
    minDiameter=10;%pixels
    diameterSimPhosphenes=random('unid',maxDiameter-minDiameter+1,[numSimPhosphenes,1]);
    diameterSimPhosphenes=diameterSimPhosphenes+minDiameter-1;
    %factor in scaling of RF sizes across cortex:
    sizeScaling=0;
    if sizeScaling==1
        singleQuadrant=1;
        %when stimulus location is confined to a single quadrant, the size of
        %phosphenes are expected to range from approximately 11.5 to 36 pixels in diameter.
        diameterSimPhosphenes=diameterSimPhosphenes.*finalPixelCoords(:,1)*2/max(finalPixelCoords(:,1));
        diameterSimPhosphenes=diameterSimPhosphenes.*finalPixelCoords(:,2)*2/max(finalPixelCoords(:,2));
        if singleQuadrant==1
            diameterSimPhosphenes=diameterSimPhosphenes/max(diameterSimPhosphenes)*(36-11.5)+11.5;
        end
    end
    radiusSimPhosphenes=diameterSimPhosphenes/2;
    
    grandMask=uint8(ones(visualWidth+ceil(max(diameterSimPhosphenes))+visualPixSize,visualHeight+ceil(max(diameterSimPhosphenes))+visualPixSize,2) * 255/2);
    grandMask(:,:,1)=grey(1);
    grandMask(:,:,2)=grey(1);
    grandMask(:,:,3)=grey(1);
    grandMask(:,:,4)=0;
    % We create a Luminance+Alpha matrix for use as transparency mask:
    % Layer 1 (Luminance) is filled with luminance value 'gray' of the
    % background.
    phospheneStyle=randi(3);
    for phospheneInd=1:numSimPhosphenes
        ms=floor(radiusSimPhosphenes(phospheneInd));        
        [x,y]=meshgrid(-ms:ms, -ms:ms);
        
        % Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
        % mask.        
        xsd=ms/2.0;
        ysd=ms/2.0;
        maskblob=uint8(round(exp(-((x/xsd).^2)-((y/ysd).^2))*255));
        xCoords=finalPixelCoords(phospheneInd,1):finalPixelCoords(phospheneInd,1)+2*ms;
        yCoords=finalPixelCoords(phospheneInd,2):finalPixelCoords(phospheneInd,2)+2*ms;   
        grandMask(xCoords,yCoords,4)=max(grandMask(xCoords,yCoords,4),maskblob);
        phospheneRegion=maskblob~=0;
        if phospheneStyle==1%bright, pretty spots of light
            phospheneCol=randi(40,[1 3]);
            for rbgIndex=1:3
                newPhosphene=phospheneRegion*phospheneCol(rbgIndex);
                grandMask(xCoords,yCoords,rbgIndex)=grandMask(xCoords,yCoords,rbgIndex)+(uint8(newPhosphene));
            end
        elseif phospheneStyle==2%coloured blocks and blobs
            phospheneCol=randi(100,[1 3]);
            for rbgIndex=1:3
                newPhosphene=phospheneRegion*phospheneCol(rbgIndex);
                grandMask(xCoords,yCoords,rbgIndex)=(grandMask(xCoords,yCoords,rbgIndex)+uint8(newPhosphene))/2;
            end
        elseif phospheneStyle==3%dark phosphenes
            phospheneCol=randi(255,[1 3]);
            for rbgIndex=1:3
                newPhosphene=phospheneRegion*phospheneCol(rbgIndex);
                grandMask(xCoords,yCoords,rbgIndex)=grandMask(xCoords,yCoords,rbgIndex).*0.5+(uint8(newPhosphene)).*0.5;
            end
        end
    end
    % Build a single transparency mask texture
    %masktex=Screen('MakeTexture', w, maskblob);
    masktex=Screen('MakeTexture', w, grandMask);

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
        FIXT=random('unif',400,500);%1000,2300
        disp(FIXT);
        stim_on_flag=0;
        while Time < FIXT && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
            if Time>floor(FIXT/2)&&stim_on_flag==0
                % Draw image for current frame:
                sampleCoords=[screenResX*3/4-size(grandMask,1)/2 screenResY*3/4-size(grandMask,2)/2];
                destRect=[screenWidth/2+sampleX screenHeight/2+sampleY screenWidth/2+sampleX+visualWidth screenHeight/2+sampleY+visualHeight];
                
                %draw text
                Screen('TextSize',w,sampleSize);
                Screen('TextFont',w,'Sloan');
                Screen('TextStyle',w,0);
%                 Screen('DrawText',w,targetLetter,screenWidth/2-sampleSize/2+sampleX,screenHeight/2-sampleSize/2-sampleY,sampcol);
%                 Screen('FillRect',w,sampcol,destRect);%background rectangle for sample letter
                % Overdraw -- and therefore alpha-blend -- with gaussian alpha mask
                Screen('DrawTexture',w, masktex, [], destRect);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
                Screen('Flip', w);
                stim_on_flag=1;
            end
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
            turn_off_stim=1;
            if turn_off_stim==1
                Screen('FillRect',w,grey);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                Screen('Flip', w);
            end
        end
        
        %///////// EVENT 3 TARGET ONSET, REACTION TIME%%//////////////////////////////////////
        
        if Hit == 0 %subject kept fixation, subject may make an eye movement
            
            %Draw target
            estimatedTargetLetterSize=stimSize;%in pixels
            Screen('TextSize',w,stimSize);
            Screen('TextStyle',w,0);
            for i=1:size(allLetters,1)-1
                Screen('DrawText',w,distLetters(i),screenWidth/2-estimatedTargetLetterSize/2+distx(i),screenHeight/2-estimatedTargetLetterSize/2+disty(i),distcol);
            end            
            Screen('DrawText',w,targetLetter,screenWidth/2-estimatedTargetLetterSize/2+targetArrayX(targetLocation),screenHeight/2-estimatedTargetLetterSize/2+targetArrayY(targetLocation),targcol);
            if brightOppositeShape==1
%                 drawLetter(targcol,distx(oppositeShape),disty(oppositeShape),stimSize,distLetters(oppositeShape))
                Screen('DrawText',w,distLetters(oppositeShape),screenWidth/2-estimatedTargetLetterSize/2+distx(oppositeShape),screenHeight/2-estimatedTargetLetterSize/2+disty(oppositeShape),targcol);
            end
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
                
            Time = 0;
            while Time < RACT && Hit <= 0  %RACT = time to respond (reaction time)
                %Check for 5 ms
                dasrun(5)
                [Hit Time] = DasCheck;
                if Time>postFixOffsetTime  
%                     Screen('FillRect',w,grey);
%                     Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
%                     Screen('Flip', w);
%                     cgdrawsprite(targetsSprite,0,0)
%                     cgellipse(Px,Py,Fsz,Fsz,grey,'f')
%                     cgflip
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
    
    targetIdentity=LPStat(6);%1 is target, 2 onwards is distractor
    LPStat()
    if targetIdentity==1%if correct target selected
        behavResponse(trialNo)=targetLetter;
        performance(trialNo)=1;%hit
    elseif targetIdentity>1%if erroneous target selected
        distractorRow=targetIdentity-1;%row of selected distractor, out of all distractors
        behavResponse(trialNo)=distLetters(distractorRow);%incorrect letter to which saccade was made
        performance(trialNo)=-1;%error
    end
    distLettersAllTrials(trialNo,:)=distLetters;
    dirName=cd;
    save([dirName,'\',date,'_perf.mat'],'behavResponse','performance','distLettersAllTrials')
    
    %///////// POSTTRIAL AND REWARD //////////////////////////////////////
    if Hit ~= 0 && ~Abort %has entered a target window (false or correct)
        
        HP = line('XData', Par.ZOOM *LPStat(2), 'YData', Par.ZOOM *LPStat(3));
        set(HP, 'Marker', '+', 'MarkerSize', 20, 'MarkerEdgeColor', 'm')
        
        if Hit == 2 &&LPStat(5) < Times.Sacc %correct target, give juice   
            dasbit(  Par.CorrectB, 1);
            dasbit(  Par.RewardB, 1);
            dasjuice(5.1);
            Par.Corrcount = Par.Corrcount + 1; %log correct trials
            % beep
            
            pause(Par.RewardTime) %RewardTime is in seconds
            
            dasjuice(0.0);
            dasbit(  Par.RewardB, 0);
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
            repeat=1;
            repeatStim=targetLetter;
            repeatTargetLocation=targetLocation;
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
        for i = 1:10   %keep targoff for 50ms
            dasrun(5) %not time critical, add some time to follow eyes
            %dasrun 5);
            DasCheck; %keep following eye motion
        end
        %         %Save_eyetrace( I )
        %         display([ num2str(Hit) ' reactiontime: ' num2str(LPStat(5))  ' saccadetime: ' num2str(LPStat(6))]);
        %         disp(['stimulus-target duration: ' num2str((FS - FO)*1000) ' ms ']);  %check timing of target onset
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
    
    SD = dasgetnoise();
    SD = SD./Par.PixPerDeg;
    set(Hnd(2), 'String', SD )
    
    % Blank screen
    Screen('FillRect',w, grey);
    Screen('Flip', w);
%     cgpencol(grey,grey,grey) %clear background before flipping
%     cgrect
%     cgflip(grey,grey,grey)
    %pause( Times.InterTrial/1000 ) %pause is called with seconds
    %Times.InterTrial is in ms
    Time = Lasttime;
    while Time < Times.InterTrial + Lasttime
        %              pause(0.005)
        dasrun(5)
        [hit Time] = DasCheck;
    end
    
end   %WHILE_NOT_ESCAPED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     % Break out of loop on mouse click
%     takeScreenshot=0;
%     if takeScreenshot==1
%         imageArray = Screen('GetImage', w, [0 0 screenResX screenResY]);
%         %imwrite is a Matlab function, not a PTB-3 function
%         if outlineShapes==1
%             if numberShapes==1
%                 if patternShapes==1
%                     imageName=['D:\code\1000_electrodes\screenshot_',patternName,'.jpg'];
%                 else
%                     imageName=['D:\code\1000_electrodes\screenshot_',num2str(numberShapeNames(targetShape-sizeNonOutlines-length(outlineShapeNames))),'.jpg'];
%                 end
%             else
%                 imageName=['D:\code\1000_electrodes\screenshot_',outlineShapeNames{targetShape-sizeNonOutlines},'.jpg'];
%             end
%         elseif outlineShapes==0
%             imageName=['D:\code\1000_electrodes\screenshot_',solidShapeNames{targetShape},'.jpg'];
%         end
%         imwrite(imageArray,imageName)
%     end

