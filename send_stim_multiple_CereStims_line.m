function send_stim_multiple_CereStims_line(uniqueStimulators,currentAmplitude,electrode,stimulatorNums,stimulator,stimSequenceInd)
%Written by Xing 8/12/17
%Delivery of microstimulation pulses, either for fake triggers or real
%triggers.
numPulses=50;
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
        pause(0.03)%adjust
    end
    amplitudeFake=1;
    widthFake=44;
    intervalFake=53;
    frequencyFake=2500;
    waveform_idFake=max(waveform_id(electrodeOnStimInd))+1;
    realElectrodes=electrode{uniqueStimInd};
    possibleElectrodes=1:64;
    fakeElectrodes=setdiff(possibleElectrodes,realElectrodes);
    fakeElectrode=fakeElectrodes(1);
    stimulator(stimulatorInd).beginSequence;
    pause(0.03)%adjust
%     stimulator(stimulatorInd).beginGroup;
%     pause(0.03)%adjust
    for electrodeOnStimInd=1:length(stimSequenceInd{uniqueStimInd})%for each electrode that is controlled by a given stimulator
        if stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)>1%if it is not the first electrode in the whole sequence, add a delay using a fake waveform. The variable stimSequenceInd contains an index that is relative to the whole sequence, not just to the electrodes for a particular stimulator
            numPulsesFake=stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1;%give 1 fake pulse (400-us delay) on 2nd electrode in entire sequence; 2 pulses (800-us delay) on 3rd electrode in entire sequence, etc
            stimulator(stimulatorInd).setStimPattern('waveform',waveform_idFake,...
                'polarity',1,...
                'pulses',numPulsesFake,...
                'amp1',amplitudeFake,...
                'amp2',amplitudeFake,...
                'width1',widthFake,...
                'width2',widthFake,...
                'interphase',intervalFake,...
                'frequency',frequencyFake);
            pause(0.05)%adjust
            stimulator(stimulatorInd).autoStim(fakeElectrode,waveform_idFake) %fake waveform to introduce 400-us delay, resulting in temporal interleaving of pulses across electrodes
        end
        stimulator(stimulatorInd).autoStim(electrode{uniqueStimInd}(electrodeOnStimInd),waveform_id(electrodeOnStimInd)) %Electrode #1 , Waveform #1
        pause(0.03)%adjust
    end
%     stimulator(stimulatorInd).endGroup;
%     pause(0.03)%adjust
    stimulator(stimulatorInd).endSequence;
    pause(0.03)%adjust
    status = stimulator(stimulatorInd).getSequenceStatus();
    while status ~= 0
        status = stimulator(stimulatorInd).getSequenceStatus();
        disp(['point 11, status ',num2str(status)])
    end
    stimulator(stimulatorInd).trigger(1);%Format: 	cerestim_object.trigger(edge)
    pause(0.03)%adjust
    isconnected=stimulator(stimulatorInd).isConnected();
    pause(0.03)%adjust
    disp(['ISconnected? = ' num2str(isconnected)])
end