function send_stim_multiple_CereStims_no_wait(uniqueStimulators,currentAmplitude,electrode,stimulatorNums,stimulator,stimSequenceInd)
%Written by Xing 05/12/17
%Delivery of microstimulation pulses, across multiple electrodes simultaneously.
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
    stimulator(stimulatorInd).beginGroup;
    pause(0.05)%adjust
    for electrodeOnStimInd=1:length(stimSequenceInd{uniqueStimInd})%for each electrode that is controlled by a given stimulator
        stimulator(stimulatorInd).autoStim(electrode{uniqueStimInd}(electrodeOnStimInd),waveform_id(electrodeOnStimInd)) %Electrode #1 , Waveform #1
        pause(0.05)%adjust
    end
    stimulator(stimulatorInd).endGroup;
    pause(0.05)%adjust
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