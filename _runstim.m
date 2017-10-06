function runstim_CheckSNR(T_Trl)


global Par   %global parameters
% global LPStat  %das status values

FixWinSizex = 1.3; 
FixWinSizey = 1.3;

%Plot marker at RF loc
% RFon = 0;
% 
% cgflip(0.5,0.5,0.5)
% cgflip(0.5,0.5,0.5)
% cgrect(45,-140,100,100,[1,1,1])
% cgflip(0.5,0.5,0.5)
% pause

rand('state',sum(clock))

%Global properties -assumes 85Hz
frame = 1./85;

%Dot sizes
FixDotSize = 0.3;
FixPix = Par.PixPerDeg.*FixDotSize;
TargSz = 0.3.*Par.PixPerDeg;
Px = 0;
Py = 0;

%Make a checkerboard sprite
checksz = 1.*Par.PixPerDeg;
Grid_x = -800:checksz:800;
Grid_y = -650:checksz:650;
drawon = 1;
cgmakesprite(1,1600,1300,[0,0,0])
cgsetsprite(1)
for y = 1:length(Grid_y)
    drawon = 1-drawon;
    for x = 1:length(Grid_x)
        drawon = 1-drawon;
        if drawon
            cgrect(Grid_x(x),Grid_y(y),checksz,checksz,[1,1,1])
        end
    end
end
cgsetsprite(0)

        

%Tracker times
FIXT = 400; %time to fix before stim onset
TARGT = 400; %800 %time to target
STIMT = TARGT; %This is irrelevent for this stimulus, we keep in just for form's sake
%TARGT is the exposure time of the RF mapping bar


Times = Par.Times; %copy timing structure
BG = [0.5 0.5 0.5]; %background Color

%Create log file
LOG.fn = 'runstim_RFauto';
LOG.BG = BG;
LOG.Par = Par;
LOG.Times = Times;
LOG.Frame = frame;
LOG.FIXT = FIXT;
LOG.TARGT = TARGT;
LOG.STIMT = STIMT;
LOG.ScreenX = 1024;
LOG.Screeny = 768;

mydir = 'C:\Users\Xing\Lick\RF_mapping_logs\';
fn = input('Enter LOG file name (e.g. 20110413_B1), blank = no file\n','s');
if isempty(fn)
    logon = 0;
else
    logon = 1;
    fn = [mydir,'CheckSNR_',fn];
    save(fn,'LOG')
end

%Copy the run stime
fnrs = [fn,'_','runstim.m'];
cfn = [mfilename('fullpath') '.m'];
copyfile(cfn,fnrs)


%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
Hit = 2;
TZ = 0;
%timing
PREFIXT = Times.ToFix; %time to enter fixation window

%Windows (fix and target)
WIN = [0 0 Par.PixPerDeg.*FixWinSizex Par.PixPerDeg.*FixWinSizey 0];
Par.WIN = WIN';
Par.ESC = false; %escape has not been pressed

while ~Par.ESC
    %Pretrial
    
     dasword(1);

    %/////////////////////////////////////////////////////////////////////
    %START THE TRIAL
    %set control window positions and dimensions
    refreshtracker(1) %for your control display
    SetWindowDas      %for the dascard
    Abort = false;    %whether subject has aborted before end of trial

    %///////// EVENT 0 START FIXATING //////////////////////////////////////
    Par.Updatxy = 1;
    cgellipse(Px,Py,FixPix,FixPix,[1,0,0],'f') %the red fixation dot on the screen
    cgflip(BG(1), BG(2), BG(3))

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
            dasreset(0);
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

    %///////// EVENT 2 DISPLAY STIMULUS //////////////////////////////////////
    if Hit == 0 %subject kept fixation, display stimulus
        Par.Updatxy = 1;

        dasreset(1); %test for exiting fix window
        Time = 0;
        cgdrawsprite(1,randi(round(2*Par.PixPerDeg)),randi(round(2*Par.PixPerDeg)))
        cgellipse(Px,Py,FixPix,FixPix,[1,0,0],'f') %the red fixation dot on the screen
        cgflip(BG(1), BG(2), BG(3));
        dasbit(Par.StimB, 1);
        while Time < TARGT && Hit == 0  %Keep fixating till target onset
            %Check for 5 ms
            dasrun(5)
            [Hit Time] = DasCheck;
        end


        %///////// EVENT 3 TARGET ONSET, REACTION TIME //////////////////////////////////////
        Par.Updatxy = 1;
        if Hit == 0 %subject kept fixation
            cgellipse(0,0,TargSz,TargSz,[0.6,0.2,0.6],'f') %the red fixation dot on the screen
            cgflip(BG(1), BG(2), BG(3))
            dasbit(Par.TargetB, 1);
            %EXTRACT USING THE TARGETB
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

%         if Par.Mouserun
%             HP = line('XData', Par.ZOOM * (LPStat(3) + Par.MOff(1)), 'YData', Par.ZOOM * (LPStat(4) + Par.MOff(2)), 'EraseMode','none');
%         else
%             HP = line('XData', Par.ZOOM * LPStat(3), 'YData', Par.ZOOM * LPStat(4), 'EraseMode','none');
%         end
%         set(HP, 'Marker', '+', 'MarkerSize', 20, 'MarkerEdgeColor', 'm')
        
        if Hit == 2

%             dasbit(Par.MicroB, 1);
%             dasbit(Par.CorrectB, 1);
            dasbit(Par.RewardB, 1);
            dasjuice(5.1);
            Par.Corrcount = Par.Corrcount + 1;

            pause(Par.RewardTime) %RewardTime is in seconds

             dasjuice(0.0);
            dasbit(Par.RewardB, 0);
        else
            Hit = 0;
        end

        %keep following eye motion
        dasrun(5)
        DasCheck; %keep following eye motion

    end
    %///////////////////////INTERTRIAL AND CLEANUP

%     display([ num2str(Hit) '  ' num2str(LPStat(6)) '  ' num2str(LPStat(7))  '  ' num2str(Time - LPStat(7)) ]);

    %reset all bits to null
    for i = [0 1 2 3 4 5 6 7]  %Error, Stim, Saccade, Trial, Correct,
        dasbit(i, 0);
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
    %      cgrect(465,-370,50,50,[1,1,1])
    cgflip(BG(1), BG(2), BG(3))
    %  pause( Times.InterTrial/1000 ) %pause is called with seconds
    %Times.InterTrial is in ms

    
    if TZ > 0
        save(fn,'LOG')
    end
end   %WHILE_NOT_ESCAPED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
