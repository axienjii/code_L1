function send_stim_multiple_CereStims_interleaved_12(uniqueStimulators,currentAmplitude,electrode,stimulatorNums,stimulator,stimSequenceInd,stimPattern,pulsesPerMiniTrain,numRepeats)
%Written by Xing 8/1/18
%Delivery of microstimulation pulses, with 12 possible stimulation sequences and patterns.
%Uses 'mini trains' of pulses, in which pulses are not distributed evenly
%throughout entire stimulation period, but occur in 'blocks' or
%'sub-trains,' which alternate between electrode sets A and B.
%Electrode set A refers to pair of electrodes that is stimulated first,
%i.e. electrodes 1 and 4 in spatial coordinates.
%Electrode set B refers to pair of electrodes that is stimulated second,
%i.e. electrodes 2 and 3 in spatial coordinates.
width1=170;
width2=170;
interphase=60;
if stimPattern>2&&stimPattern<11
    tic
    for uniqueStimInd=1:length(uniqueStimulators)
        stimulatorInd=find(stimulatorNums==uniqueStimulators(uniqueStimInd));
        isconnected=stimulator(stimulatorInd).isConnected();
        disp(['ISconnected? = ' num2str(isconnected)])
        pause(0.01)%adjust
        
        if ~isconnected
            % compulsory step
            stimulator(stimulatorInd).connect
            pause(0.01)
        end
        waveform_id=1:length(stimSequenceInd{uniqueStimInd});
        originalFrequency=300;
        durationPerPulseSet=1000/originalFrequency;%time during which a pulse should be delivered on each of the desired electrodes (i.e. 1 cycle of pulses across the desired electrodes)
        numElectrodes=0;
        for ind=1:length(electrode)
            numElectrodes=numElectrodes+numel(electrode{ind});
        end
        durationPerElectrode=durationPerPulseSet/numElectrodes%time between onset of pulses across electrodes
        programmedFrequency=floor(1000/durationPerElectrode);%in ms
        setA=[];
        setB=[];
        for electrodeOnStimInd=1:length(stimSequenceInd{uniqueStimInd})%for each electrode that is controlled by a given stimulator
            if stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)==1||stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)==4
                setA=[setA electrodeOnStimInd];
            end
            if stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)==2||stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)==3
                setB=[setB electrodeOnStimInd];
            end
        end
        if ~isempty(setA)
            for electrodeOnStimInd=1:length(setA)%for each electrode that is controlled by a given stimulator
                currentAmplitude{uniqueStimInd}(setA(electrodeOnStimInd))
                sqstatus = stimulator(stimulatorInd).getSequenceStatus;
                times = 0;
                while sqstatus ~= 0 || times < 5
                    sqstatus = stimulator(stimulatorInd).getSequenceStatus;
                    times = times + 1;
                    pause(0.05);
                end
                if times == 5
                    disp('Stimulator status is wrong');
                end
                stimulator(stimulatorInd).setStimPattern('waveform',waveform_id(setA(electrodeOnStimInd)),...
                    'polarity',1,...
                    'pulses',pulsesPerMiniTrain,...
                    'amp1',currentAmplitude{uniqueStimInd}(setA(electrodeOnStimInd)),...
                    'amp2',currentAmplitude{uniqueStimInd}(setA(electrodeOnStimInd)),...
                    'width1',width1,...
                    'width2',width2,...
                    'interphase',interphase,...
                    'frequency',originalFrequency);%2209 Hz possible, 2210 Hz not possible
                pause(0.01)
            end
        end
        if ~isempty(setB)
            for electrodeOnStimInd=1:length(setB)%for each electrode that is controlled by a given stimulator
                currentAmplitude{uniqueStimInd}(setB(electrodeOnStimInd))
                stimulator(stimulatorInd).setStimPattern('waveform',waveform_id(setB(electrodeOnStimInd)),...
                    'polarity',1,...
                    'pulses',pulsesPerMiniTrain,...
                    'amp1',currentAmplitude{uniqueStimInd}(setB(electrodeOnStimInd)),...
                    'amp2',currentAmplitude{uniqueStimInd}(setB(electrodeOnStimInd)),...
                    'width1',width1,...
                    'width2',width2,...
                    'interphase',interphase,...
                    'frequency',originalFrequency);%2209 Hz possible, 2210 Hz not possible
                pause(0.01)
            end
        end
        stimulator(stimulatorInd).beginSequence;
        pause(0.01)%adjust
        for repeatInd=1:numRepeats
            if ~isempty(setA)
                stimulator(stimulatorInd).beginGroup;
                pause(0.01)%adjust
                for electrodeOnStimInd=1:length(setA)%for each electrode that is controlled by a given stimulator
                    stimulator(stimulatorInd).autoStim(electrode{uniqueStimInd}(setA(electrodeOnStimInd)),waveform_id(setA(electrodeOnStimInd))) %Electrode #1 , Waveform #1
                    pause(0.01)
                end
                stimulator(stimulatorInd).endGroup;
                pause(0.01)
                if isempty(setB)%if first set of electrodes not followed by a second set on same CereStim
                    stimulator(stimulatorInd).wait(ceil(1000/originalFrequency*pulsesPerMiniTrain))%0.4 ms multiplied by number of pulses per mini-train
                    pause(0.01)
                end
            end
            if ~isempty(setB)
                if isempty(setA)%if second set of electrodes not preceded by first set on same CereStim
                    stimulator(stimulatorInd).wait(ceil(1000/originalFrequency*pulsesPerMiniTrain))%0.4 ms multiplied by number of pulses per mini-train
                    pause(0.01)
                end
                stimulator(stimulatorInd).beginGroup;
                pause(0.01)
                for electrodeOnStimInd=1:length(setB)%for each electrode that is controlled by a given stimulator
                    stimulator(stimulatorInd).autoStim(electrode{uniqueStimInd}(setB(electrodeOnStimInd)),waveform_id(setB(electrodeOnStimInd))) %Electrode #1 , Waveform #1
                    pause(0.01)
                end
                stimulator(stimulatorInd).endGroup;
                pause(0.01)
            end
        end
        stimulator(stimulatorInd).endSequence;
        pause(0.01)%adjust
        status = stimulator(stimulatorInd).getSequenceStatus();
        while status ~= 0
            status = stimulator(stimulatorInd).getSequenceStatus();
            disp(['point 11, status ',num2str(status)])
        end
        stimulator(stimulatorInd).trigger(1);%Format: 	cerestim_object.trigger(edge)
        pause(0.01)%adjust
        isconnected=stimulator(stimulatorInd).isConnected();
        pause(0.1)%adjust
        disp(['ISconnected? = ' num2str(isconnected)])
    end
    toc
elseif stimPattern>=11%pulse trains are interleaved, alternating between electrodes one pulse at a time
    for uniqueStimInd=1:length(uniqueStimulators)
        stimulatorInd=find(stimulatorNums==uniqueStimulators(uniqueStimInd));
        isconnected=stimulator(stimulatorInd).isConnected();
        disp(['ISconnected? = ' num2str(isconnected)])
        pause(0.01)%adjust
        
        if ~isconnected
            % compulsory step
            stimulator(stimulatorInd).connect
            pause(0.01)
        end
        waveform_id=1:length(stimSequenceInd{uniqueStimInd});
        stimulator(stimulatorInd).beginSequence;
        pause(0.01)%adjust
        originalFrequency=300;
        durationPerPulseSet=1000/originalFrequency;%time during which a pulse should be delivered on each of the desired electrodes (i.e. 1 cycle of pulses across the desired electrodes)
        numElectrodes=0;
        for ind=1:length(electrode)
            numElectrodes=numElectrodes+numel(electrode{ind});
        end
        durationPerElectrode=durationPerPulseSet/numElectrodes%time between onset of pulses across electrodes
        programmedFrequency=floor(1000/durationPerElectrode);%in ms
        for electrodeOnStimInd=1:length(stimSequenceInd{uniqueStimInd})%for each electrode that is controlled by a given stimulator
            currentAmplitude{uniqueStimInd}(electrodeOnStimInd)
            stimulator(stimulatorInd).setStimPattern('waveform',waveform_id(electrodeOnStimInd),...
                'polarity',1,...
                'pulses',1,...
                'amp1',currentAmplitude{uniqueStimInd}(electrodeOnStimInd),...
                'amp2',currentAmplitude{uniqueStimInd}(electrodeOnStimInd),...
                'width1',width1,...
                'width2',width2,...
                'interphase',interphase,...
                'frequency',programmedFrequency);%2209 Hz possible, 2210 Hz not possible
            pause(0.01)
            if stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)>1%if it is not the first electrode in the whole sequence, add a delay. the variable stimSequenceInd contains an index that is relative to the whole sequence, not just to the electrodes for a particular stimulator
                if electrodeOnStimInd==1%if it is the first electrode in the sequence for a given CereStim, and not the first in the whole sequence
                    stimulator(stimulatorInd).wait(durationPerElectrode*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1))%adjust
                    disp(['electrode order = ' num2str(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd))])
                    disp(['time delay (ms) = ' num2str(durationPerElectrode*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1))])
                    pause(0.01)%adjust
                elseif electrodeOnStimInd>1
                    differenceBetweenElectrodes=stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-stimSequenceInd{uniqueStimInd}(electrodeOnStimInd-1);%check whether previous electrode on this CereStim occurs immediately before the current electrode, in the entire sequence of electrodes across CereStims
                    if differenceBetweenElectrodes>1%if previous electrode (on the entire sequence across CereStims) occurred on same CereStim as present electrode, wait command is not needed. if previous electrode on this particular CereStim occurred more than 1 electrode 'ago' in the entire sequence, need wait command
                        stimulator(stimulatorInd).wait(durationPerElectrode*(differenceBetweenElectrodes-1))%adjust
                        disp(['electrode order = ' num2str(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd))])
                        disp(['time delay (ms) = ' num2str(durationPerElectrode*(differenceBetweenElectrodes-1))])
                        pause(0.01)%adjust
                    end
                end
            end
            stimulator(stimulatorInd).autoStim(electrode{uniqueStimInd}(electrodeOnStimInd),waveform_id(electrodeOnStimInd)) %Electrode #1 , Waveform #1
            pause(0.01)
            addDuration=0;
            addDurationFlag=0;
            if electrodeOnStimInd==length(stimSequenceInd{uniqueStimInd})%if it is the last electrode in the sequence for a given CereStim
                if stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)~=numElectrodes%and if it is not the last electrode in the entire sequence
                    addDuration=addDuration+durationPerElectrode*(numElectrodes-stimSequenceInd{uniqueStimInd}(electrodeOnStimInd));
                    addDurationFlag=1;
                end
                if durationPerPulseSet>durationPerElectrode*numElectrodes%if it is the last electrode in the sequence for a particular CereStim, and there should be an interval before the next set of pulses
                    addDuration=addDuration+durationPerPulseSet-durationPerElectrode*numElectrodes;
                    addDurationFlag=1;
                end
                if addDurationFlag==1
                    stimulator(stimulatorInd).wait(ceil(addDuration))%add time buffer to end of stimulation instructions for this particular CereStim, before next set of pulses begins
                    pause(0.01)%adjust
                end
            end
        end
        stimulator(stimulatorInd).endSequence;
        pause(0.01)%adjust
        status = stimulator(stimulatorInd).getSequenceStatus();
        while status ~= 0
            status = stimulator(stimulatorInd).getSequenceStatus();
            disp(['point 11, status ',num2str(status)])
        end
        %     stimulator(stimulatorInd).trigger(1);%Format: 	cerestim_object.trigger(edge)
        %     pause(0.03)%adjust
        isconnected=stimulator(stimulatorInd).isConnected();
        pause(0.01)%adjust
        disp(['ISconnected? = ' num2str(isconnected)])
    end
end