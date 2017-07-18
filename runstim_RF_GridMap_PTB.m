function runstim(T_Trl)
%Modified from runstim_RF_GridMap, removed purple circle that previously
%appeared upon reward delivery.

global Par   %global parameters

w=Par.w;
FixWinSizex = 1.3; %1.1
FixWinSizey = 1.3; %1.1

drawRF=0;
if drawRF
RFxloc = [ 32 32  57  57  57]+Par.HW;%adapted from the Cogent to the Psychtoolbox coordinate system
RFyloc = Par.HH-[-118 -142 -118 -142 -167];
end

rand('state',sum(clock))

%Global properties
frame = 1./85;
fixwid = 17;
targwid = 30;
Px = 0;
Py = 0;

%no of sqaures per trial
nsquares = 10;

%gridsize i.e. 9x9
GridSz = 23; %Must be an odd number, 23 will do a whole quadrant
halfgrid = (GridSz-1)./2;

%Center of the grid 
RFx = Par.HW+140;%(512/2)-100;
RFy = Par.HH+100;%-(384/2);

CheckWidth = 1;%1 (units in dva)
BarPix = CheckWidth.*Par.PixPerDeg;

Grid_x = linspace(RFx-(BarPix*halfgrid),RFx+(BarPix*halfgrid),GridSz);
Grid_y = linspace(RFy-(BarPix*halfgrid),RFy+(BarPix*halfgrid),GridSz);

%Trim ethr coordinates to remove checks that fall off the screen
% f = find(Grid_x>512 | Grid_x<-512);
f = find(Grid_x>Par.HW*2 | Grid_x<0);
Grid_x(f) = [];
% f = find(Grid_y>384 | Grid_y<-384);
f = find(Grid_y>Par.HH*2 | Grid_y<0);
Grid_y(f) = [];
%Remove upper filed stuff
f = find(Grid_y<50);
f = find(Grid_y<Par.HH);
Grid_y(f) = [];

%Grid properties
BarCol = [255 255 255];

%Tracker times
FIXT = 200; %time to fix before stim onset
BART = 150; %time to target (i.e. duration of each dot) 200
INTBAR = 50; %time between bars 50

Times = Par.Times; %copy timing structure
BG = [255/2 255/2 255/2]; %background Color
LOG.fn = 'runstim_RF_GridMap';
LOG.BG = BG;
LOG.Par = Par;
LOG.Times = Times;
LOG.Frame = frame;
LOG.FIXT = FIXT;
LOG.BART = BART;
LOG.INTBAR = INTBAR;
LOG.GridSz = GridSz;
LOG.Grid_x = Grid_x;
LOG.Grid_y = Grid_y;
LOG.CheckWidth = CheckWidth;
LOG.BarPix = BarPix;
LOG.BarCol = BarCol;
LOG.RFx = RFx;
LOG.RFy = RFy;

fixcol=[255 0 0];
secondFixcol=[255 0 255];
Fsz=4;

saveLogFile=0;
if saveLogFile==1
    mydir = 'C:\RFmapping\LOGFILES\';
    fn = input('Enter LOG file name (e.g. 20110413_B1), blank = no file\n','s');
    if isempty(fn)
        logon = 0;
    else
        logon = 1;
        fn = [mydir,'RF_GridMap_',fn];
        save(fn,'LOG')
    end
    
    %Copy the run stime
    fnrs = [fn,'_','runstim.m'];
    cfn = [mfilename('fullpath') '.m'];
    copyfile(cfn,fnrs)
end
    
z = 0;
for x = 1:length(Grid_x)
    for y = 1:length(Grid_y)
        z = z+1;
        details(z,:)= [x,y,z];
    end
end
ntrials = z;

%RAndomise each square separately 
RANDTAB = zeros(ntrials,3,nsquares);
for n = 1:nsquares
    randord = randperm(ntrials);
    RANDTAB(:,:,n) = details(randord,:);
end



%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
Hit = 2;
%timing
PREFIXT = Times.ToFix; %time to enter fixation window
%Windows (fix and target)
WIN = [0 0 Par.PixPerDeg.*FixWinSizex Par.PixPerDeg.*FixWinSizey 0];
Par.WIN = WIN';
Par.ESC = false; %escape has not been pressed
TRL = 0;
STM = 0;
while ~Par.ESC
    
    
    %Make the word bit
    Word = RANDTAB(1,3,1);
    
    %Word bit = direction
    dasword(Word);
    
    TRL = TRL+1;
    TRLMAT(TRL,1:2) = [STM+1,Word];
    for n = 1:nsquares
        TRLMAT(TRL,n+2) = RANDTAB(1,1,n);
        TRLMAT(TRL,n+7) = RANDTAB(1,2,n);
    end
    

    %/////////////////////////////////////////////////////////////////////
    %START THE TRIAL
    %set control window positions and dimensions
    refreshtracker(1) %for your control display
    SetWindowDas      %for the dascard
    Abort = false;    %whether subject has aborted before end of trial
    
    
    %///////// EVENT 0 START FIXATING //////////////////////////////////////
    Par.Updatxy = 1;
    Screen('FillRect',w,BG);
    Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
    Screen('Flip', w);
%     cgellipse(Px,Py,fixwid,fixwid,[1,0,0],'f') %the red fixation dot on the screen
%     cgflip(BG(1), BG(2), BG(3))
    
    dasreset(0)
    
    %subject has to start fixating central dot
    Par.SetZero = false; %set key to false to remove previous presses
    Par.Updatxy = 1; %centering key is enabled
    Time = 1;
    Hit = 0;
    while Time < PREFIXT && Hit == 0
        dasrun(5)
        [Hit Time] = DasCheck; %retrieve position values and plot on Control display
    end
    
    %///////// EVENT 1 KEEP FIXATING or REDO  ////////////////////////////////////
    Par.Updatxy = 1;
    if Hit ~= 0  %subjects eyes are in fixation window keep fixating for FIX time
        dasreset(1);     %test for exiting fix window
        
        Time = 1;
        Hit = 0;
        while Time < FIXT && Hit == 0
            %Check for 5 ms
            dasrun(5)
            %or just pause for 5ms?
            [Hit Time] = DasCheck;
        end
        
        if Hit ~= 0 %eye has left fixation to early
            %possibly due to eye overshoot, give another chance
            dasreset(0)
            Time = 1;
            Hit = 0;
            while Time < PREFIXT && Hit == 0
                dasrun(5)
                [Hit Time] = DasCheck; %retrieve position values and plot on Control display
            end
            if Hit ~= 0  %subjects eyes are in fixation window keep fixating for FIX time
                dasreset(1);     %test for exiting fix window
                
                Time = 1;
                Hit = 0;
                while Time < FIXT && Hit == 0
                    %Check for 5 ms
                    dasrun(5)
                    %                     dasrun(5)
                    [Hit Time] = DasCheck;
                end
            else
                Hit = -1; %the subject did not fixate
            end
        end
        
    else
        Hit = -1; %the subject did not fixate
    end
    
    dasclearword
    %///////// EVENT 2 DISPLAY STIMULUS //////////////////////////////////////
    if Hit == 0 %subject kept fixation, display stimulus
        
        Par.Updatxy = 1;
        logupdate = 1;
        for n = 1:nsquares
            
            xpos = RANDTAB(1,1,n);
            ypos = RANDTAB(1,2,n);
            wordbit = RANDTAB(1,3,n);
            %Word bit = direction
            dasword(wordbit);
            
            Time = 0;
            dasreset(1);
            stimbitdone = 0;
            while Time < BART && Hit == 0  %Keep fixating till target onset
                
%                 cgellipse(Px,Py,fixwid,fixwid,[1,0,0],'f') %the red fixation dot on the screen
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
                %                 Flip up the grid thing
                if drawRF
%                     cgrect(min(Grid_x), min(Grid_y), BarPix,BarPix,BarCol)
%                     cgrect(min(Grid_x), max(Grid_y), BarPix,BarPix,BarCol)
%                     cgrect(max(Grid_x), min(Grid_y), BarPix,BarPix,BarCol)
%                     cgrect(max(Grid_x), max(Grid_y), BarPix,BarPix,BarCol)
                    for r = 1:length(RFxloc)
%                         cgellipse(RFxloc(r),RFyloc(r),20,20,[1,0,1],'f')
                        Screen('FillOval',w,fixcol,[RFxloc(r)-Fsz/2 RFyloc(r)-Fsz/2 RFxloc(r)+Fsz/2 RFyloc(r)+Fsz/2]);%fixspot
                    end
                end
                Screen('FillRect',w,BarCol,[Grid_x(xpos)-BarPix,Grid_y(ypos)-BarPix,Grid_x(xpos)+BarPix,Grid_y(ypos)+BarPix]);
                Screen('Flip', w);
%                 cgrect(Grid_x(xpos),Grid_y(ypos),BarPix,BarPix,BarCol)
%                 cgflip(BG(1), BG(2), BG(3))
                
                if ~stimbitdone
                    %USE STIMULUS BIT FOR EXTRACTION
                    dasbit(Par.StimB, 1);
                    stimbitdone = 1;
                end
                
                %Check for 5 ms
                dasrun(5)
                [Hit Time] = DasCheck;
                
            end
            
            %IS he still fixating
            if Hit
                break
            end
            
            Time = 0;
            dasreset(1);
            targbitdone = 0;
            while Time < INTBAR && Hit == 0  %Keep fixating till target onset
                cgellipse(Px,Py,fixwid,fixwid,[1,0,0],'f') %the red fixation dot on the screen
                Screen('FillOval',w,fixcol,[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%fixspot
                if drawRF
%                     cgrect(min(Grid_x), min(Grid_y), BarPix,BarPix,BarCol)
%                     cgrect(min(Grid_x), max(Grid_y), BarPix,BarPix,BarCol)
%                     cgrect(max(Grid_x), min(Grid_y), BarPix,BarPix,BarCol)
%                     cgrect(max(Grid_x), max(Grid_y), BarPix,BarPix,BarCol)
                    for r = 1:length(RFxloc)
%                         cgellipse(RFxloc(r),RFyloc(r),20,20,[1,0,1],'f')
                        Screen('FillOval',w,secondFixcol,[RFxloc(r)-Fsz/2 RFyloc(r)-Fsz/2 RFxloc(r)+Fsz/2 RFyloc(r)+Fsz/2]);%fixspot
                    end
                end
                Screen('Flip', w);
%                 cgflip(BG(1), BG(2), BG(3))
                
                if ~targbitdone
                    %This means it was a successful fixation, we should
                    %extract using the target bit
                    STM = STM+1;
                    STMMAT(STM,:) = [TRL,Word,xpos,ypos,Grid_x(xpos),Grid_y(ypos)];
                    dasbit(Par.TargetB, 1);
                    targbitdone = 1;
                end
                %Check for 5 ms
                dasrun(5)
                [Hit Time] = DasCheck;
            end
            
            if Hit
                break
            end
            
            
            dasclearword
            dasbit(Par.StimB, 0);
            dasbit(Par.TargetB, 0);
        end
        
        %///////// EVENT 3 TARGET ONSET, REACTION TIME
        %//////////////////////////////////////
        Par.Updatxy = 1;
        if Hit == 0 %subject kept fixation, subject may make an eye movement
            postStimDur=200;%time between mapping stimuli and fix offset, in ms
            pause(postStimDur/1000);
            Screen('FillOval',w,[BG(1) BG(2) BG(3)],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%remove fixspot
            Screen('FillOval',w,[0 0 255],[Par.HW-Fsz/2 Par.HH-Fsz/2 Par.HW+Fsz Par.HH+Fsz]);%remove fixspot
%             cgellipse(0,0,targwid,targwid,[BG(1) BG(2) BG(3)],'f') %the red fixation dot on the screen
%             cgellipse(0,0,targwid,targwid,[0.6,0.2,0.6],'f') %the red fixation dot on the screen
            
            if drawRF
%                 cgrect(min(Grid_x), min(Grid_y), BarPix,BarPix,BarCol)
%                 cgrect(min(Grid_x), max(Grid_y), BarPix,BarPix,BarCol)
%                 cgrect(max(Grid_x), min(Grid_y), BarPix,BarPix,BarCol)
%                 cgrect(max(Grid_x), max(Grid_y), BarPix,BarPix,BarCol)
                       for r = 1:length(RFxloc)
                        Screen('FillOval',w,secondFixcol,[RFxloc(r)-Fsz/2 RFyloc(r)-Fsz/2 RFxloc(r)+Fsz/2 RFyloc(r)+Fsz/2]);%fixspot
%                         cgellipse(RFxloc(r),RFyloc(r),20,20,[1,0,1],'f')
                    end
            end
            Screen('Flip', w);
%             cgflip(BG(1), BG(2), BG(3))
            Hit = 2;
        else
            Abort = true;
        end
        
        %END EVENT 3
    else
        Abort = true;
    end
    %END EVENT 2
    
    %///////// POSTTRIAL AND REWARD //////////////////////////////////////
    if Hit ~= 0 && ~Abort %has entered a target window (false or correct)
        
        dasbit( Par.CorrectB, 1);
        dasbit( Par.RewardB, 1);
        dasjuice(5.1);
        Par.Corrcount = Par.Corrcount + 1;
        pause(Par.RewardTime) %RewardTime is in seconds
        dasjuice(0.0);
        
        %Update randomisation
        RANDTAB(1,:,:) = [];
        [sz1,sz2,sz3] = size(RANDTAB);
        if ~(sz1)
            RANDTAB = zeros(ntrials,3,nsquares);
            for n = 1:nsquares
                randord = randperm(ntrials);
                RANDTAB(:,:,n) = details(randord,:);
            end
            [sz1,sz2,sz3] = size(RANDTAB);
        end
        
        
        %keep following eye motion
        dasrun(5)
        DasCheck; %keep following eye motion
        
    end
    
    
    %///////////////////////INTERTRIAL AND CLEANUP
    
    %reset all bits to null
    for i = [0 1 2 3 4 5 6 7]  %Error, Stim, Saccade, Trial, Correct,
        dasbit( i, 0);
    end
    dasclearword
    
    %Par.Trlcount = Par.Trlcount + 1;  %counts total number of trials for this session
    %tracker('update_trials', gcbo, [], guidata(gcbo)) %displays number of trials, corrects and errors
    Par.Trlcount = Par.Trlcount + 1;  %counts total number of trials for this session
    SCNT = {'TRIALS'};
    SCNT(2) = { ['N: ' num2str(Par.Trlcount) ]};
    SCNT(3) = { ['C: ' num2str(Par.Corrcount) ] };
    SCNT(4) = { ['E: ' num2str(Par.Errcount) ] };
    set(T_Trl, 'String', SCNT ) %display updated numbers in GUI
    
    [Hit T] = DasCheck;
    cgflip(BG(1), BG(2), BG(3))
    %  pause( Times.InterTrial/1000 ) %pause is called with seconds
    %Times.InterTrial is in ms
    
    %         while Time < Times.InterTrial + T
    %             % dasrun(5)
    %             dasrun(5)
    %             [Hit Time] = DasCheck;
    %         end
    if saveLogFile==1
        if TRL > 0
            save(fn,'*')
        end
    end
end   %WHILE_NOT_ESCAPED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
