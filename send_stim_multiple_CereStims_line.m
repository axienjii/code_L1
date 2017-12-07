function send_stim_multiple_CereStims_line(uniqueStimulators,currentAmplitude,electrode,stimulatorNums,stimulator,stimSequenceInd)
%Written by Xing 31/10/17
%Delivery of microstimulation pulses, either for fake triggers or real
%triggers.
numPulses=50;
for uniqueStimInd=1:length(uniqueStimulators)
    stimulatorInd=find(stimulatorNums==uniqueStimulators(uniqueStimInd));
    isconnected=stimulator(stimulatorInd).isConnected();
    disp(['ISconnected? = ' num2str(isconnected)])
    pause(0.05)%adjust
    
    if ~isconnected
        % compulsory step
        stimulator(stimulatorInd).connect
        pause(0.1)
    end
    waveform_id=1:length(stimSequenceInd{uniqueStimInd});
    for electrodeOnStimInd=1:length(stimSequenceInd{uniqueStimInd})%for each electrode that is controlled by a given stimulator
        currentAmplitude{uniqueStimInd}(electrodeOnStimInd)
        stimulator(stimulatorInd).setStimPattern('waveform',waveform_id(electrodeOnStimInd),...
            'polarity',1,...
            'pulses',numPulses,...
            'amp1',currentAmplitude{uniqueStimInd}(electrodeOnStimInd),...
            'amp2',currentAmplitude{uniqueStimInd}(electrodeOnStimInd),...
            'width1',170,...
            'width2',170,...
            'interphase',60,...
            'frequency',300);
        pause(0.05)%adjust
    end
    stimulator(stimulatorInd).beginSequence;
    pause(0.05)%adjust
    for electrodeOnStimInd=1:length(stimSequenceInd{uniqueStimInd})%for each electrode that is controlled by a given stimulator
        if stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)>1%if it is not the first electrode in the whole sequence, add a delay. the variable stimSequenceInd contains an index that is relative to the whole sequence, not just to the electrodes for a particular stimulator
            if electrodeOnStimInd==1%if it is the first electrode in the sequence for a given CereStim, and not the first in the whole sequence
                stimulator(stimulatorInd).wait(0.5*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1))%adjust
                disp(['electrode order = ' num2str(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd))])
                disp(['time delay (ms) = ' num2str(150*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1))])
                pause(0.05)%adjust
            elseif electrodeOnStimInd>1
                differenceBetweenElectrodes=stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-stimSequenceInd{uniqueStimInd}(electrodeOnStimInd-1);%check whether previous electrode on this CereStim occurs immediately before the current electrode, in the entire sequence of electrodes across CereStims
%                 if differenceBetweenElectrodes>1%if previous electrode (on the entire sequence across CereStims) occurred on same CereStim as present electrode, wait command is not needed. if previous electrode on this particular CereStim occurred more than 1 electrode 'ago' in the entire sequence, need wait command
                    stimulator(stimulatorInd).wait(0.5*(differenceBetweenElectrodes))%adjust
                    disp(['electrode order = ' num2str(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd))])
                    disp(['time delay (ms) = ' num2str(150*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1))])
                    pause(0.05)%adjust
%                 end
            end
        end
        stimulator(stimulatorInd).autoStim(electrode{uniqueStimInd}(electrodeOnStimInd),waveform_id(electrodeOnStimInd)) %Electrode #1 , Waveform #1
        pause(0.05)%adjust
    end
    stimulator(stimulatorInd).endSequence;
    pause(0.05)%adjust
    status = stimulator(stimulatorInd).getSequenceStatus();
    while status ~= 0
        status = stimulator(stimulatorInd).getSequenceStatus();
        disp(['point 11, status ',num2str(status)])
    end
    stimulator(stimulatorInd).trigger(1);%Format: 	cerestim_object.trigger(edge)
    pause(0.05)%adjust
    isconnected=stimulator(stimulatorInd).isConnected();
    pause(0.05)%adjust
    disp(['ISconnected? = ' num2str(isconnected)])
end