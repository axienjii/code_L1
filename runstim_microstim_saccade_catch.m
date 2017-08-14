function runstim_microstim_saccade_catch(Hnd)
%Written by Xing 17/7/17
%On 50% of trials, present simulated phosphene. Monkey has to fixate for 300 ms, followed by
%an interval lasting anywhere from 0 to 500 ms. A simulated phosphene
%appears at a location in the bottom right quadrant, and he is allowed to
%saccade to it immediately. If no saccade made, catch dot is still presented 
%at 800 ms, but not rewarded. On the other 50% of trials, no simulated
%phosphene present, and catch dot presented at end of full 800-ms period.
%No microstim administered.
%Time allowed to reach target reduced to maximum of 250 ms.

global Par   %global parameters
global trialNo
global behavResponse
global performance
global recentPerf
global blockPerf
global allSampleSize
global allSampleX
global allSampleY
global allFixT
global allStimDur
global trialsRemaining
global allTrialCond
global blockNo
global allBlockType
global corrTrialBlockCounter
global allBlockNo
global allHitX
global allHitY
global allHitRT
global allCurrentLevel    
global allMaskTex
global allElectrodeNum
global allInstanceNum
global allArrayNum
global allTargetArrivalTime

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
RACT = 200;      %reaction time

%Fix location
Fsz = FixDotSize.*Par.PixPerDeg;

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
    save(fn,'LOG')
end

% %Create stimulator object
% stimulator = cerestim96()
% 
% my_devices = stimulator.scanForDevices
% pause(.3)
% stimulator. selectDevice(0); %the number inside the brackets is the stimulator instance number; numbering starts from 0
% pause(.5)
% 
% %Connect to the stimulator
% stimulator.connect;

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
    blockLength=10;
    if trialNo==1
        blockNo=1;
        corrTrialBlockCounter=0;%tallies the number of correct trials per block
        shuffleFlag=1;
        hitRT=NaN;
    end
    if corrTrialBlockCounter>=blockLength
        blockNo=blockNo+1;
        corrTrialBlockCounter=0;%reset counter for correct trials for each block
        blockPerf=[];
    end
    if mod(blockNo,2)==1
        blockType=1;%visually presented simulated phosphene
    else
        blockType=2;%microstimulation block
    end
    blockType=1;%no microstim in this paradigm
    catchTrial=randi(2)-1;
    if blockType==2
        if length(blockPerf)>=blockLength&&mean(blockPerf)<0.2%if performance indicates that microstimulation was not detected
            blockNo=blockNo+1;
            corrTrialBlockCounter=0;%reset counter for correct trials for each block
            blockPerf=[];
        end
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
    hitX=NaN;
    hitY=NaN;
    
    %Assign code for trial identity, using sequence of random numbers
    bits = [0 2 6];
    ch = randi(length(bits),1,8);
    ident = bits(ch);
    TRLMAT(trialNo,:) = ident;
    
    %SET UP STIMULI FOR THIS TRIAL    
    if catchTrial==1
        FIXT=1000;
    elseif catchTrial==0
        FIXT=random('unif',300,800);%1000,2300
    end
    stimDuration=randi([120 150]);
    
    if blockType==1
        sampleSize = randi([5 10]);%pixels
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
        electrode=NaN;%no stimulation occurred
        instance=NaN;
        amplitude=NaN;
        array=NaN;
    elseif blockType==2
        %select electrode for microstimulation
%         electrodeInd = 1;
%         temp=randi(4);%To randomly select one of the channels on a given array
%         array13chs=[1 2 5 6];
%         electrodeInd=array13chs(temp);
        
%         temp=randi(4);
%         array1chs=[3 4 9 10];
%         electrodeInd=array1chs(temp);
        
        electrodeInd=randi(7);%randomly select one of the 7 channels
% 6.08013139448369 -57.5683516819474 64.2938056246091 2.48621643476278 26.5206999998666 11 12 40
% 55.8767850062012 -71.0350415565651 115.291652293049 4.45828331263410 14.5465563836931 12 12 23
% 16.2653274701236 -55.3786060950071 94.9056131349569 3.66996311441011 22.2097227018053 12 12 39
% 41.3215783139404 -76.5363300227501 117.935898439498 4.56053528174669 10.2883544245231 12 12 59
% 43.8921276022195 -67.5797536766718 90.2963097249265 3.49172314588600 3.09015541764014 13 12 21
% 12.9473896446797 -71.2883775745738 88.0788761683683 3.40597585347189 9.48521707458857 13 12 41
% 29.5742455300091 -73.4272655105649 107.264035444527 4.14785849414840 4.06545223931962 16 12 6

        switch electrodeInd
            case 1
                electrode=40;
                RFx=6.1;
                RFy=-57.6;
                array=12;
                instance=6;
                %SNR 27, impedance 11
            case 2
                electrode=23;
                RFx=55.9;
                RFy=-71.0;
                array=12;
                instance=6;
                %SNR 15, impedance 12
            case 3
                electrode=39;
                RFx=16.3;
                RFy=-55.4;
                array=12;
                instance=6;
                %SNR 22, impedance 12
            case 4
                electrode=59;
                RFx=41.3;
                RFy=-76.5;
                array=12;
                instance=6;
                %SNR 10, impedance 12
            case 5
                electrode=21;
                RFx=12.9;
                RFy=-71.2;
                array=12;
                instance=6;
                %SNR 3, impedance 13
            case 6
                electrode=41;
                RFx=29.6;
                RFy=-73.4;
                array=12;
                instance=6;
                %SNR 9, impedance 13
            case 7
                electrode=6;
                RFx=126.2;
                RFy=-96.3;
                array=12;
                instance=6;
                %SNR 4, impedance 16
        end
        
        % define a waveform
        waveform_id = 1;
        amplitude=50;%set current level in uA
        stimulator.setStimPattern('waveform',waveform_id,...
            'polarity',0,...
            'pulses',5,...
            'amp1',amplitude,...
            'amp2',amplitude,...
            'width1',170,...
            'width2',170,...
            'interphase',60,...
            'frequency',200);
        %'polarity' -	Polarity of the first phase, 0 (cathodic), 1 (anodic)
    end
    
    if Par.Drum && Hit ~= 2 %if drumming and this was an error trial
        %just redo with current settings
    else
        %randomization of shape
        if blockType==1
            sampleX = randi([40 180]);%location of sample stimulus, in RF quadrant 150 230
            sampleY = randi([40 180]);
        elseif blockType==2
            sampleX = RFx;%location of sample stimulus, in RF quadrant 150 230
            sampleY = -RFy;
        end
        finalPixelCoordsAll=[sampleX sampleY];
        eccentricity=sqrt(sampleX^2+sampleY^2);
        if eccentricity<Par.PixPerDeg
            TargWinSz = 1;
        elseif eccentricity<2*Par.PixPerDeg
            TargWinSz = 1.5;
        elseif eccentricity<3*Par.PixPerDeg
            TargWinSz = 2;
        elseif eccentricity<4*Par.PixPerDeg
            TargWinSz = 2.5;
        elseif eccentricity<5*Par.PixPerDeg
            TargWinSz = 3;
        elseif eccentricity<6*Par.PixPerDeg
            TargWinSz = 3.5;
        elseif eccentricity<7*Par.PixPerDeg
            TargWinSz = 4;
        end
        if catchTrial==1
            TargWinSz = 2;
        end
        %control window setup
        if catchTrial==0
            WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
                sampleX,  -sampleY, Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];   %2: target;
            Par.WIN = WIN';
        elseif catchTrial==1
            WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
                0,  -catchDotY, Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];   %2: target;
            Par.WIN = WIN';
        end
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
    %prepare simulated phosphene, if that is not a catch trial
    if catchTrial==0
        for phospheneInd=1:numSimPhosphenes
            destRect=[screenWidth/2+finalPixelCoordsAll(phospheneInd,1)-visualWidth/2 screenHeight/2+finalPixelCoordsAll(phospheneInd,2)-visualHeight/2 screenWidth/2+finalPixelCoordsAll(phospheneInd,1)+visualWidth/2 screenHeight/2+finalPixelCoordsAll(phospheneInd,2)+visualHeight/2];
            Screen('DrawTexture',w, masktex(phospheneInd), [], destRect);
            Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
        end
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
        if blockType==1
            if catchTrial==0
                %draw simulated phosphene
                Screen('Flip', w);
            elseif catchTrial==1
%                 Screen('FillOval',w,[0 0 255],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot turns blue
                Screen('FillOval',w,[0 255 0],[Par.HW-Fsz/2 Par.HH-Fsz/2+catchDotY Par.HW+Fsz Par.HH+Fsz+catchDotY]);%green catch dot
                Screen('Flip', w);
            end
        elseif blockType==2
            %deliver microstimulation
            stimulator.manualStim(electrode,waveform_id)
            if length(my_devices>1)
                %disconnect CereStim
                stimulator.disconnect;
            end
        end
        dasbit(  Par.TargetB, 1);
        tic
                
        %///////// EVENT 3 REACTION TIME%%//////////////////////////////////////
        
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
    
    targetIdentity=LPStat(6);
    LPStat();
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
            dasbit(ident(n),1);
            pause(0.05);%add a time buffer between sending of dasbits
            dasbit(ident(n),0);
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
    allBlockType(trialNo)=blockType;
    allCurrentLevel(trialNo)=amplitude;
    allMaskTex{trialNo}=newPhosphene;
    allElectrodeNum{trialNo}=electrode;
    allInstanceNum{trialNo}=instance;
    allArrayNum{trialNo}=array;
    allTargetArrivalTime(trialNo)=Time;
    if Hit==2
        allHitX(trialNo)=hitX;
        allHitY(trialNo)=hitY;
        allHitRT(trialNo)=hitRT;
        blockPerf=[blockPerf 1];%correct saccade made
    else
        allHitX(trialNo)=NaN;
        allHitY(trialNo)=NaN;
        allHitRT(trialNo)=NaN;
        blockPerf=[blockPerf 0];%target not reached
    end
    recentPerf=mean(blockPerf)
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
% if length(my_devices==1)
%     %disconnect CereStim
%     stimulator.disconnect;
% end
