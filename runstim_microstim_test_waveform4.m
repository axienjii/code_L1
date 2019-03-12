function runstim_microstim_test_waveform4(Hnd)
%Written by Xing 10/10/17
%Test microstimulation pulse timing when wait() function is used.

global Par   %global parameters
global currentAmplitude

format compact
oldEnableFlag = Screen('Preference', 'SuppressAllWarnings',1);
Screen('Preference', 'Verbosity',0);
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
rewSz=0.4;
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


Fsz = FixDotSize.*Par.PixPerDeg;
rewDotSize=0.4.*Par.PixPerDeg;

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
    save(fn,'LOG');
end

%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
Hit = 2;
Par.ESC = false; %escape has not been pressed

bipolar=1;

%Create stimulator object
stimulator = cerestim96();
desiredStimulator=14335;

my_devices = stimulator.scanForDevices
pause(0.5)
stimulatorInd=find(my_devices==desiredStimulator);
stimulator.selectDevice(stimulatorInd-1); %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
pause(0.5)
stimulator.connect;
pause(0.5)

% define a waveform
waveform_id = 1;
numPulses=50;
currentAmplitude=100;
currentAmplitude2=200;
electrode=1;
electrode2=2;

stimulator.setStimPattern('waveform',waveform_id,...
    'polarity',0,...
    'pulses',numPulses,...
    'amp1',currentAmplitude,...
    'amp2',currentAmplitude,...
    'width1',100,...
    'width2',100,...
    'interphase',60,...
    'frequency',300);
%'polarity' -	Polarity of the first phase, 0 (cathodic), 1 (anodic)
%deliver microstimulation

waveform_id_Return=2;
stimulator.setStimPattern('waveform',waveform_id_Return,...
    'polarity',1,...
    'pulses',numPulses,...
    'amp1',currentAmplitude2,...
    'amp2',currentAmplitude2,...
    'width1',100,...
    'width2',100,...
    'interphase',60,...
    'frequency',300);

stimulator.beginSequence;
if bipolar==1
    stimulator.beginGroup;
end
stimulator.autoStim(electrode,waveform_id) %Electrode #1 , Waveform #1
if bipolar==1
    %         wait(200);
    stimulator.autoStim(electrode2,waveform_id_Return) %Electrode #2 , Waveform #2
    stimulator.endGroup;
end
stimulator.endSequence;
    
while ~Par.ESC

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
    
    for i=1
        Screen('FillRect',w,red);
        Screen('Flip', w);
%         stimulator.manualStim(electrode,waveform_id)
        stimulator.play(1)
        Screen('FillRect',w,grey);
        Screen('Flip', w);
        pause(0.2)
        dasbit(6,1);
        pause(0.1);
        dasbit(6,0);
%         pause(1);
    end
end
stimulator.disconnect;

Screen('Preference','SuppressAllWarnings',oldEnableFlag);