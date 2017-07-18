function runstim_simphosphene_randint_saccade(Hnd)
%Written by Xing 14/7/17
%Present simulated phosphene, monkey has to fixate for 300 ms, followed by
%an interval lasting anywhere from 0 to 500 ms. A simulated phosphene
%appears at a location in the bottom right quadrant, and he is allowed to
%saccade to it immediately.

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
TargWinSz = 6;  %CHANGE TO MAKE MORE ACCUARTE

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
        FIXT=random('unif',300,800);%1000,2300
        stimDuration=randi([120 150]);
        disp(FIXT);
        stim_on_flag=0;
        while Time < FIXT && Hit== 0
            %Check for 10 ms
            dasrun(5)
            [Hit Time] = DasCheck; %retrieve eye channel buffer and events, plot eye motion,
        end
    else
        Hit = -1; %the subject did not fixate
    end
              
    %draw simulated phosphene
    for phospheneInd=1:numSimPhosphenes
        destRect=[screenWidth/2+finalPixelCoordsAll(phospheneInd,1)-visualWidth/2 screenHeight/2+finalPixelCoordsAll(phospheneInd,2)-visualHeight/2 screenWidth/2+finalPixelCoordsAll(phospheneInd,1)+visualWidth/2 screenHeight/2+finalPixelCoordsAll(phospheneInd,2)+visualHeight/2];
        Screen('DrawTexture',w, masktex(phospheneInd), [], destRect);
        Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
    end
    Screen('Flip', w);
    
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
            turn_off_stim=0;
            if turn_off_stim==1
                Screen('FillRect',w,grey);
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
                Screen('Flip', w);
            end
        end
        
        %///////// EVENT 3 TARGET ONSET, REACTION TIME%%//////////////////////////////////////
        
        if Hit == 0 %subject kept fixation, subject may make an eye movement
            
            %Draw targets
            Screen('FillRect',w,grey);
            Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
            targCol=[123 123 123];
            targCol=randi(2,[1 3])+126;
            targCol=grey;
            for phospheneInd=1:numSimPhosphenes
                destRect=[screenWidth/2+finalPixelCoordsAll(phospheneInd,1)-visualWidth/2 screenHeight/2+finalPixelCoordsAll(phospheneInd,2)-visualHeight/2 screenWidth/2+finalPixelCoordsAll(phospheneInd,1)+visualWidth/2 screenHeight/2+finalPixelCoordsAll(phospheneInd,2)+visualHeight/2];
                Screen('FillOval',w,targCol,destRect);%target
            end
            Screen('Flip', w);
            pause(0.3);
            Screen('FillRect',w,grey);
            Screen('FillOval',w,[0 0 255],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);
            targCol=randi(2,[1 3])+125;
            targCol=grey;
            for phospheneInd=1:numSimPhosphenes
                destRect=[screenWidth/2+finalPixelCoordsAll(phospheneInd,1)-visualWidth/2 screenHeight/2+finalPixelCoordsAll(phospheneInd,2)-visualHeight/2 screenWidth/2+finalPixelCoordsAll(phospheneInd,1)+visualWidth/2 screenHeight/2+finalPixelCoordsAll(phospheneInd,2)+visualHeight/2];
                Screen('FillOval',w,targCol,destRect);%target
            end
%             for phospheneInd=1:numSimPhosphenes
%                 destRect=[screenWidth/2+finalPixelCoordsAll(phospheneInd,1)-visualWidth/2 screenHeight/2+finalPixelCoordsAll(phospheneInd,2)-visualHeight/2 screenWidth/2+finalPixelCoordsAll(phospheneInd,1)+visualWidth/2 screenHeight/2+finalPixelCoordsAll(phospheneInd,2)+visualHeight/2];
%                 Screen('DrawTexture',w, masktex(phospheneInd), [], destRect);
%             end
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
%     if targetIdentity==1%if correct target selected
%         behavResponse(trialNo)=targetLocation;
%         performance(trialNo)=1;%hit
%     elseif targetIdentity>1%if erroneous target selected
%         distractorRow=targetIdentity-1;%row of selected distractor, out of all distractors
%         behavResponse(trialNo)=distLocations(distractorRow);%incorrect target to which saccade was made (L: left; R: right; T: top; B: bottom)
%         performance(trialNo)=-1;%error
%     end
    dirName=cd;
%     save([dirName,'\test\',date,'_perf.mat'],'behavResponse','performance')
    
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
    Time = Lasttime;
    while Time < Times.InterTrial + Lasttime
        %              pause(0.005)
        dasrun(5)
        [hit Time] = DasCheck;
    end
    
end   

