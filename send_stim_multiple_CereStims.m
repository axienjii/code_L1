function send_stim_multiple_CereStims(uniqueStimulators,currentAmplitude,electrode,isFake,stimulatorNums,stimulator,stimSequenceInd)
%Written by Xing 31/10/17
%Delivery of microstimulation pulses, either for fake triggers or real
%triggers.
if isFake==1
    currentAmplitude=1;
    waveform_id=1;
    numPulses=1;
    electrode=1;
else
    numPulses=45;
end
for uniqueStimInd=1:length(uniqueStimulators)
    stimulatorInd=find(stimulatorNums==uniqueStimulators(uniqueStimInd));
    isconnected=stimulator(stimulatorInd).isConnected();
    disp(['ISconnected? = ' num2str(isconnected)])
    
    if ~isconnected
        % compulsory step
        stimulator(stimulatorInd).connect
        pause(0.5)
    end
    seq_stat=stimulator(stimulatorInd).getSequenceStatus();
    disp(['status= ' num2str(seq_stat)])
    if isFake==1
            stimulator(stimulatorInd).setStimPattern('waveform',waveform_id,...
                'polarity',1,...
                'pulses',numPulses,...
                'amp1',currentAmplitude,...
                'amp2',currentAmplitude,...
                'width1',170,...
                'width2',170,...
                'interphase',60,...
                'frequency',300);
    elseif isFake==0
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
        end
    end
    
%     stimulator(stimulatorInd).beginSequence;
%     if isFake==1
%         stimulator(stimulatorInd).autoStim(electrode,waveform_id) %Electrode #1 , Waveform #1
%     elseif isFake==0
%         for electrodeOnStimInd=1:length(stimSequenceInd{uniqueStimInd})%for each electrode that is controlled by a given stimulator
%             if stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)>1%if it is not the first electrode in the whole sequence, add a delay. the variable stimSequenceInd contains an index that is relative to the whole sequence, not just to the electrodes for a particular stimulator
%                 stimulator(stimulatorInd).wait(150*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1))%adjust
%                 150*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1)
%             end
%             stimulator(stimulatorInd).autoStim(electrode{uniqueStimInd}(electrodeOnStimInd),waveform_id(electrodeOnStimInd)) %Electrode #1 , Waveform #1
%         end
%     end
%     stimulator(stimulatorInd).endSequence;

stimulator(stimulatorInd).beginSequence;
        stimulator(stimulatorInd).wait(10);%add an offset of 1 ms to train on second electrode
        stimulator(stimulatorInd).beginGroup;
        stimulator(stimulatorInd).autoStim(electrode{uniqueStimInd}(electrodeOnStimInd),waveform_id(electrodeOnStimInd)) %Electrode #1 , Waveform #1
        stimulator(stimulatorInd).endGroup;
        stimulator(stimulatorInd).endSequence;
    
    stimulator(stimulatorInd).trigger(1);%Format: 	cerestim_object.trigger(edge)
    isconnected=stimulator(stimulatorInd).isConnected();
    disp(['ISconnected? = ' num2str(isconnected)])
end