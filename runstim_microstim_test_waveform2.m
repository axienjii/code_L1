function runstim_microstim_saccade_catch11(Hnd)
%Written by Xing 5/9/17
%Based on previously measured current threshold values, deliver
%microstimulation to electrodes and record saccade end points.
%On 50% of trials, deliver microstimulation (10 pulses). Monkey has to fixate for 300 ms, followed by
%an interval lasting anywhere from 0 to 400 ms. Monkey is required to make
%a saccade to RF location, and if correct saccade made, then at 100 ms, fix
%spot changes colour and reward given. On the other 50% of trials, no microstim
%administered, and monkey is rewarded for maintaining fixation after 1000 ms.
%Time allowed to reach target reduced to maximum of 200 ms.
%This version should have equal timing between stimulation and catch
%trials, unlike catch10 where mictostim trials lasted 100 ms longer.

global Par   %global parameters
global trialNo
global behavResponse
global performance
global allSampleX
global allSampleY
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
global allCurrentLevel
global allElectrodeNum
global allInstanceNum
global allArrayNum
global allTargetArrivalTime
global currentAmplitude
global visualHit
global microstimHit
global microstimMiss
global catchHit
global catchFalseAlarms
global numHitsElectrode
global numMissesElectrode
global electrodeInd
global hitCounter
global missCounter
global currentInd
global allStaircaseResponse
global missesAtMaxCurrent
global condInd
global chOrder
global allChOrder

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

%REactie tijd
TARGT = 0; %time to keep fixating after target onset before fix goes green (het liefst 400)
RACT = 250;      %reaction time 250 ms

Fsz = FixDotSize.*Par.PixPerDeg;
rewDotSize=0.4.*Par.PixPerDeg;

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
    save(fn,'LOG');
end

%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
Hit = 2;
Par.ESC = false; %escape has not been pressed
trialNo=0;
catchHit=0;
microstimHit=0;
microstimMiss=0;
numHitsElectrode=0;
numMissesElectrode=0;
catchFalseAlarms=0;
hitCounter=0;
missCounter=0;
allStaircaseResponse=[];
allCurrentLevel=[];
missesAtMaxCurrent=0;
performance=[];
allSampleX=[];
allSampleY=[];
allFixT=[];
allStimDur=[];
allBlockNo=[];
allElectrodeNum=[];
allInstanceNum=[];
allArrayNum=[];
allTargetArrivalTime=[];
allFalseAlarms=[];
allHitX=[];
allHitY=[];
allHitRT=[];
allChOrder=[];
RFx=NaN;
RFy=NaN;

arrays=8:16;
stimulatorNums=[14295 14172 14173 14174 14175 14176 14294 14293 14138];%stimulator to which each array is connected

load('C:\Users\Xing\Lick\currentThresholdChs.mat');
chOrder=originalChOrder;
condInd=1;
staircaseFinishedFlag=0;%remains 0 until 40 reversals in staircase procedure have occured, at which point it is set to 1
bipolar=1;

%Create stimulator object
stimulator = cerestim96();
while ~Par.ESC&&staircaseFinishedFlag==0
    catchTrial=randi(2)-1%0 or 1. Randomly determined on each trial
    if catchTrial==1
        currentAmplitude=0;
    elseif catchTrial==0
        currentAmplitude=goodCurrentThresholds(chOrder(condInd))*1.5;
        if currentAmplitude>210
            currentAmplitude=210;
        end
    end
    %select array & electrode index (sorted by lowest to highest impedance) for microstimulation
    array=goodArrays8to16(chOrder(condInd),7);%array number
    electrodeInd=goodInds(chOrder(condInd));%channel number
    arrayInd=find(arrays==array);
    desiredStimulator=stimulatorNums(arrayInd);
    desiredStimulator=14295;
    
    % define a waveform
    waveform_id = 1;
    numPulses=50;%originally set to 5 pulses
    numPulses=20;%originally set to 5 pulses
    %         amplitude=50;%set current level in uA
    
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
    
    currentAmplitude=100;
    currentAmplitude2=100;
    electrode=33;
    electrode2=34;
    
    my_devices = stimulator.scanForDevices;
    pause(0.5)
    stimulatorInd=find(my_devices==desiredStimulator);
    stimulator.selectDevice(stimulatorInd-1); %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
    pause(0.5)
    stimulator.connect;
    pause(0.5)

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
        stimulator.autoStim(electrode2,waveform_id_Return) %Electrode #2 , Waveform #2
        stimulator.endGroup;
    end
    stimulator.endSequence;
    
    for i=1:2000
        Screen('FillRect',w,red);
        Screen('Flip', w);
%         stimulator.manualStim(electrode,waveform_id)
        stimulator.play(1)
        Screen('FillRect',w,grey);
        Screen('Flip', w);
        pause(0.2)
    end
end

Screen('Preference','SuppressAllWarnings',oldEnableFlag);