function runstim_simphosphene_2phosphenes_4targets(Hnd)
%Written by Xing for training Lick 9/9/16
%Present two simulated phosphenes, task is to report their relative positions.
%Use PsychToolBox to generate stimuli, instead of Cogent.

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
brightOppositeShape=0;
black=[0 0 0];

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
        
        sampleSize = randi([40 120]);%pixels
        sampleX = randi([40 100]);%location of sample stimulus, in RF quadrant 150 230
        sampleY = randi([40 100]);
        
        targetArrayX=[-200 200 0 0];
        targetArrayY=[0 0 -200 200];
        targetArrayYTracker=[0 0 200 -200];%difference between Cogent and PTB
        targetLocations='LRTB';
        %set target & distractor locations
        targetLocation=randi([1 4],1);%select target location
%         if repeat==1
%             if ~isempty(repeatTargetLocation)
%                 targetLocation=repeatTargetLocation;
%             end
%             repeat=0;
%         end
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
        
    spacing=randi([15 50]);%pixels
    if targetLocation==1
        finalPixelCoords=[sampleX-spacing/2 sampleY-spacing/2;sampleX+spacing/2 sampleY+spacing/2];
    elseif targetLocation==2
        finalPixelCoords=[sampleX+spacing/2 sampleY-spacing/2;sampleX-spacing/2 sampleY+spacing/2];
    end
    if targetLocation==3
        finalPixelCoords=[sampleX sampleY-spacing/2;sampleX sampleY+spacing/2];
    elseif targetLocation==4
        finalPixelCoords=[sampleX-spacing/2 sampleY;sampleX+spacing/2 sampleY];
    end
    numSimPhosphenes=2;
    jitterLocation=0;
    if jitterLocation==1
%         finalPixelCoords=finalPixelCoords+random('unid',floor(spacing/2),[1,numSimPhosphenes]);%randomise position of phosphene within each 'pixel'
%         finalPixelCoords2=random('unid',floor(spacing/2),[1,numSimPhosphenes]);
        maxJitterSize=10;
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
    
    % We create a Luminance+Alpha matrix for use as transparency mask:
    % Layer 1 (Luminance) is filled with luminance value 'gray' of the
    % background.
    numSimPhosphenes
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
        FIXT=random('unif',300,650);%1000,2300
        disp(FIXT);
        stim_on_flag=0;
        stimDuration=randi([120 160]);%ms
        while Time < FIXT && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
            if Time>FIXT-stimDuration&&stim_on_flag==0
                % Draw image for current frame:
%                 phospheneTrial=randi(4)
%                 if phospheneTrial<4
                    %draw two simulated phosphenes simultaneously (later, vary
                    %timing, duration, frequency)
                    for phospheneInd=1:numSimPhosphenes
                        destRect=[screenWidth/2+sampleX+finalPixelCoords(phospheneInd,1)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2+sampleY+finalPixelCoords(phospheneInd,2)-ceil(diameterSimPhosphenes(phospheneInd)/2) screenWidth/2+sampleX+finalPixelCoords(phospheneInd,1)+ceil(diameterSimPhosphenes(phospheneInd)/2) screenHeight/2+sampleY+finalPixelCoords(phospheneInd,2)+ceil(diameterSimPhosphenes(phospheneInd)/2)];
                        Screen('DrawTexture',w, masktex(phospheneInd), [], destRect);
                        Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
                    end
                    Screen('Flip', w);
%                 end
                stim_on_flag=1;
            end
        end
        Screen('FillRect',w,grey);
        Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
        Screen('Flip', w);
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
            
            %Draw targets
            targetSize=10;%in pixels
            lightDistractors=1;
            displacementFactor=[-1 1 -1 1;-1 1 1 -1;0 0 -1 1;-1 1 0 0];%4 targets
            distcol=0;
            for i=1:4%targetLocation
                targcol=black;
                if lightDistractors==1
                    if i==1||i==2
                        if targetLocation==3||targetLocation==4
                            targcol=[distcol distcol distcol];
                        end
                    end
                    if i==3||i==4
                        if targetLocation==1||targetLocation==2
                            targcol=[distcol distcol distcol];
                        end
                    end
                end
                Screen('FillOval',w,targcol,[screenWidth/2-targetSize+targetArrayX(i)+targetSize*displacementFactor(i,1) screenHeight/2-targetSize+targetArrayY(i)+targetSize*displacementFactor(i,3) screenWidth/2+targetArrayX(i)+targetSize*displacementFactor(i,1) screenHeight/2+targetArrayY(i)+targetSize*displacementFactor(i,3)]);
                Screen('FillOval',w,targcol,[screenWidth/2-targetSize+targetArrayX(i)+targetSize*displacementFactor(i,2) screenHeight/2-targetSize+targetArrayY(i)+targetSize*displacementFactor(i,4) screenWidth/2+targetArrayX(i)+targetSize*displacementFactor(i,2) screenHeight/2+targetArrayY(i)+targetSize*displacementFactor(i,4)]);
            end
%             Screen('FillOval',w,targcol,[screenWidth/2-targetSize+targetArrayX(targetLocation)+targetSize*displacementFactor(targetLocation,1) screenHeight/2-targetSize+targetArrayX(targetLocation)+targetSize*displacementFactor(targetLocation,3) screenWidth/2+targetArrayY(targetLocation)+targetSize*displacementFactor(targetLocation,1) screenHeight/2+targetArrayY(targetLocation)+targetSize*displacementFactor(targetLocation,3)]);
%             Screen('FillOval',w,targcol,[screenWidth/2-targetSize+targetArrayX(targetLocation)+targetSize*displacementFactor(targetLocation,2) screenHeight/2-targetSize+targetArrayX(targetLocation)+targetSize*displacementFactor(targetLocation,4) screenWidth/2+targetArrayY(targetLocation)+targetSize*displacementFactor(targetLocation,2) screenHeight/2+targetArrayY(targetLocation)+targetSize*displacementFactor(targetLocation,4)]);
            
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
        behavResponse(trialNo)=targetLocation;
        performance(trialNo)=1;%hit
    elseif targetIdentity>1%if erroneous target selected
        distractorRow=targetIdentity-1;%row of selected distractor, out of all distractors
        behavResponse(trialNo)=distLocations(distractorRow);%incorrect target to which saccade was made (L: left; R: right; T: top; B: bottom)
        performance(trialNo)=-1;%error
    end
    dirName=cd;
    save([dirName,'\',date,'_2phos_4targperf.mat'],'behavResponse','performance')
    
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
            repeatTargetLocation=targetLocation;
        end
        if length(lastTrials)>30
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
%     SCNT(4) = { ['P: ' num2str(recentPerf) ] };
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
    
end   

