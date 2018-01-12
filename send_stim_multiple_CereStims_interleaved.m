function send_stim_multiple_CereStims_interleaved(uniqueStimulators,currentAmplitude,electrode,stimulatorNums,stimulator,stimSequenceInd)
%Written by Xing 11/12/17
%Delivery of microstimulation pulses, either for fake triggers or real
%triggers.
for uniqueStimInd=1:length(uniqueStimulators)
    stimulatorInd=find(stimulatorNums==uniqueStimulators(uniqueStimInd));
    isconnected=stimulator(stimulatorInd).isConnected();
    disp(['ISconnected? = ' num2str(isconnected)])
    pause(0.03)%adjust
    
    if ~isconnected
        % compulsory step
        stimulator(stimulatorInd).connect
        pause(0.03)
    end
    waveform_id=1:length(stimSequenceInd{uniqueStimInd});
    stimulator(stimulatorInd).beginSequence;
    pause(0.03)%adjust
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
                'width1',170,...
                'width2',170,...
                'interphase',60,...
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
    pause(0.03)%adjust
    status = stimulator(stimulatorInd).getSequenceStatus();
    while status ~= 0
        status = stimulator(stimulatorInd).getSequenceStatus();
        disp(['point 11, status ',num2str(status)])
    end
%     stimulator(stimulatorInd).trigger(1);%Format: 	cerestim_object.trigger(edge)
%     pause(0.03)%adjust
    isconnected=stimulator(stimulatorInd).isConnected();
    pause(0.03)%adjust
    disp(['ISconnected? = ' num2str(isconnected)])
end