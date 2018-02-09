function runstim_microstim_line_low_vs_high_current_setselection(Hnd)
%Written by Xing 6/2/18
%Checks current amplitudes that would be delivered when values of 1.5 and
%2.5 are used as multiplication factors and minimum value of 30 uA is
%imposed.
%Present 2 targets for multiple-phosphene task. Many different electrode sets (each with 2 groups of horizontally or vertically oriented electrodes)
%Current amplitude is varied- either set as a multiple of 1.5 or 2.5 times
%the current threshold.
%Delivery of microstimulation pulses, with 2 possible stimulation sequences and patterns.

global Par   %global parameters
global trialNo
global behavResponse
global performance
global allSampleX
global allSampleY
global allSetInd
global allFixT
global allStimDur
global blockNo
global newBlock
global numTrialBlockCounter
global allBlockNo
global allHitX
global allHitY
global allHitRT
global allCurrentLevel
global allElectrodeNum
global allInstanceNum
global allArrayNum
global allTargetArrivalTime
global visualCorrect
global microstimCorrect
global microstimIncorrect
global visualIncorrect
global catchFalseAlarms
global numHitsElectrode
global numMissesElectrode
global electrodeInd
global hitCounter
global missCounter
global allStaircaseResponse
global missesAtMaxCurrent
global condInd
global allMultiCereStim
global recentPerf
global recentPerfMicro
global lastTrials
global lastTrialsMicro
global allTrialType
global trialConds
global allLRorTB
global allTargetLocation
global last200Trials
global recentPerf200Trials
global allNewPhosphenes
global allStimPattern
global allCondCurrent

%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
Hit = 2;
Par.ESC = false; %escape has not been pressed
trialNo=0;
microstimHit=0;
microstimMiss=0;
numHitsElectrode=0;
numMissesElectrode=0;
visualCorrect=0;
visualIncorrect=0;
catchFalseAlarms=0;
hitCounter=0;
missCounter=0;
allStaircaseResponse=[];
allCurrentLevel=[];
allCurrentLevel2=[];
missesAtMaxCurrent=0;
performance=[];
allSampleX=[];
allSampleY=[];
allFixT=[];
allStimDur=[];
allBlockNo=[];
newBlock=1;
allElectrodeNum=[];
allElectrodeNum2=[];
allInstanceNum=[];
allInstanceNum2=[];
allArrayNum=[];
allArrayNum2=[];
allTargetArrivalTime=[];
allFalseAlarms=[];
allHitX=[];
allHitY=[];
allHitRT=[];
allChOrder=[];
RFx=NaN;
RFy=NaN;
RFx2=NaN;
RFy2=NaN;
allMultiCereStim=[];
allTrialType=[];
allSetInd=[];
recentPerf=NaN;
recentPerfMicro=NaN;
recentPerf100Trials=NaN;
subblockCount=0;
newPhosphenes=[];
allNewPhosphenes=[];
allCondCurrent=[];
allStimPattern=[];

% trialConds=[1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2;1:12 1:12];%trial conditions. Target conds in first row: for TB trials, 1: target is above; 2: target is below
% trialConds=[1 1 1 1 2 2 2 2;1 2 1 2 1 2 1 2;];%trial conditions. Target
% conds in first row: for TB trials, 1: target is above; 2: target is
% below. stimPattern in second row (conds 1 or 2). current multiplication
% factor in third row (multiply current threshold by 1.5 or 2.5)
trialConds=[1 1 1 1 2 2 2 2;1 2 1 2 1 2 1 2;1 1 2 2 1 1 2 2];%trial conditions. Target conds in first row: for TB trials, 1: target is above; 2: target is below
% trialConds=[1 1 2 2;1:2 1:2];%trial conditions. Target conds in first row: for TB trials, 1: target is above; 2: target is below
%index of set of electrodes to use, in second row: 1 to 4
arrays=8:16;
stimulatorNums=[14295 65372 65377 65374 65375 65376 65493 65494 65338];%stimulator to which each array is connected

load('C:\Users\Xing\Lick\currentThresholdChs72.mat');%increased threshold for electrode 51, array 10 from 48 to 108, adjusted thresholds on all 4 electrodes

visualTrial=0;%adjust
imposeMinimum=30;%set minimum current level
LRorTB=2;
setInd=15;%adjust

%specify array & electrode index (sorted by lowest to highest impedance) for microstimulation
[setElectrodes,setArrays]=lookup_set_electrodes_line(setInd);
for targetLocation=1:2
    for stimPattern=1:2
        for condCurrent=1:2
            if LRorTB==1
                targetArrayX=[-200 200];
                targetArrayY=[0 0];
                targetArrayYTracker=[0 0];
                targetLocations='LR';
                if targetLocation==1
                    array=setArrays{1};
                    electrode=setElectrodes{1};
                elseif targetLocation==2
                    array=setArrays{2};
                    electrode=setElectrodes{2};
                end
            elseif LRorTB==2
                targetArrayX=[0 0];
                targetArrayY=[-200 200];
                targetArrayYTracker=[200 -200];
                targetLocations='BT';
                if targetLocation==1
                    array=setArrays{3};
                    electrode=setElectrodes{3};
                elseif targetLocation==2
                    array=setArrays{4};
                    electrode=setElectrodes{4};%check these assignments
                end
            end
            electrode=electrode([1:2 4:5]);%4-phosphene line task- use first two and last two electrodes only
            array=array([1:2 4:5]);
            if stimPattern==1
                electrode=electrode([1 4]);%only stimulate on outermost 2 electrodes
                array=array([1 4]);
            end
            if stimPattern==2
                electrode=electrode([2 3]);%only stimulate on innermost 2 electrodes
                array=array([2 3]);
            end
            if stimPattern>2
                if mod(stimPattern,2)==0%instead of sequence with stimulation on outermost two first, stimulate on innermost two first
                    electrode=electrode([2 1 4 3]);
                    array=array([2 1 4 3]);
                end
            end
            desiredStimulator=[];
            stimSequenceInd=[];
            electrodeInd=[];
            arrayInd=[];
            for electrodeSequence=1:length(electrode)
                electrodeIndtemp1=find(goodArrays8to16(:,8)==electrode(electrodeSequence));%matching channel number
                electrodeIndtemp2=find(goodArrays8to16(:,7)==array(electrodeSequence));%matching array number
                electrodeInd(electrodeSequence)=intersect(electrodeIndtemp1,electrodeIndtemp2);%channel number
                arrayInd(electrodeSequence)=find(arrays==array(electrodeSequence));
                desiredStimulator(electrodeSequence)=stimulatorNums(arrayInd(electrodeSequence));
                instance(electrodeSequence)=ceil(array(electrodeSequence)/2);
                load(['C:\Users\Xing\Lick\090817_impedance\array',num2str(array(electrodeSequence)),'.mat']);
                eval(['arrayRFs=array',num2str(array(electrodeSequence)),';']);
                RFx(electrodeSequence)=goodArrays8to16(electrodeInd(electrodeSequence),1);
                RFy(electrodeSequence)=goodArrays8to16(electrodeInd(electrodeSequence),2);
            end
            uniqueStimulators=unique(desiredStimulator)%identify stimulators that are needed
            ind=[];
            for iArrangeStimulators=1:length(uniqueStimulators)
                ind(iArrangeStimulators)=find(uniqueStimulators(iArrangeStimulators)==stimulatorNums);
            end
            [dummy indStims]=sort(ind);
            uniqueStimulators=uniqueStimulators(indStims);
            for uniqueStimInd=1:length(uniqueStimulators)
                [dummy tempInd]=find(desiredStimulator==uniqueStimulators(uniqueStimInd));%identify at which point in sequence the stimulator should be activated
                stimSequenceInd{uniqueStimInd}=tempInd;
                electrodeSequenceInd{uniqueStimInd}=electrode(tempInd);%identify at which point in sequence the stimulator should be activated
                arraySequenceInd{uniqueStimInd}=array(tempInd);%identify at which point in sequence the stimulator should be activated
            end
            falseAlarm=NaN;
            
            visRFx=RFx;%locations of visual stimuli
            visRFy=RFy;
            numSimPhosphenes=length(electrode);
            if visualTrial==1%visual trial
            elseif visualTrial==0
                %set the waveform parameters for the real stimulation trains:
                for electrodeSequence=1:length(electrode)
                    if condCurrent==1
                        currentAmplitude(electrodeSequence)=goodCurrentThresholds(electrodeInd(electrodeSequence))*1.5;%adjust
                    elseif condCurrent==2
                        currentAmplitude(electrodeSequence)=goodCurrentThresholds(electrodeInd(electrodeSequence))*2.5;%adjust
                    end
                    if currentAmplitude(electrodeSequence)>210
                        currentAmplitude(electrodeSequence)=210;
                    end
                    if ~isempty(imposeMinimum)
                        if currentAmplitude(electrodeSequence)<imposeMinimum
                            currentAmplitude(electrodeSequence)=imposeMinimum;
                        end
                    end
                end
                currentAmplitude
                for uniqueStimInd=1:length(uniqueStimulators)
                    [dummy tempInd]=find(desiredStimulator==uniqueStimulators(uniqueStimInd));%identify at which point in sequence the stimulator should be activated
                    currentAmplitudeSequenceInd{uniqueStimInd}=currentAmplitude(tempInd);%identify at which point in sequence the stimulator should be activated
                end
            end
        end
    end
end