function send_stim_multiple_CereStims_line(uniqueStimulators,currentAmplitude,electrode,isFake,stimulatorNums,stimulator,stimSequenceInd)
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
%     numPulses=1;%adjust
end
for uniqueStimInd=1:length(uniqueStimulators)
    stimulatorInd=find(stimulatorNums==uniqueStimulators(uniqueStimInd));
    isconnected=stimulator(stimulatorInd).isConnected();
    disp(['ISconnected? = ' num2str(isconnected)])
    pause(0.1)%adjust
    
    if ~isconnected
        % compulsory step
        stimulator(stimulatorInd).connect
        pause(0.5)
    end
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
            pause(0.1)%adjust
            status = stimulator(stimulatorInd).getSequenceStatus();
            while status ~= 0
                status = stimulator(stimulatorInd).getSequenceStatus();
                disp(['point 4, status ',num2str(status)])
            end
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
            pause(0.3)%adjust
        end
    end
    stimulator(stimulatorInd).beginSequence;
    pause(0.1)%adjust
    if isFake==1
        stimulator(stimulatorInd).autoStim(electrode,waveform_id) %Electrode #1 , Waveform #1
        pause(0.1)%adjust
    elseif isFake==0
        for electrodeOnStimInd=1:length(stimSequenceInd{uniqueStimInd})%for each electrode that is controlled by a given stimulator
            stimulator(stimulatorInd).autoStim(electrode{uniqueStimInd}(electrodeOnStimInd),waveform_id(electrodeOnStimInd)) %Electrode #1 , Waveform #1
            pause(0.1)%adjust
        end
    end
    stimulator(stimulatorInd).endSequence;
    pause(0.1)%adjust
    status = stimulator(stimulatorInd).getSequenceStatus();
    while status ~= 0
        status = stimulator(stimulatorInd).getSequenceStatus();
        disp(['point 11, status ',num2str(status)])
    end
    stimulator(stimulatorInd).trigger(1);%Format: 	cerestim_object.trigger(edge)
    pause(0.1)%adjust
    isconnected=stimulator(stimulatorInd).isConnected();
    pause(0.1)%adjust
    disp(['ISconnected? = ' num2str(isconnected)])
end
%     if stimulatorInd==3
%         dasbit(1,1);
%         pause(0.1)
%         dasbit(1,0);
%         pause(0.1)
%     end