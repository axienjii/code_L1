function send_stim_multiple_CereStims_sepobj(uniqueStimulators,currentAmplitude,electrode,stimulatorNums,stimulator1,stimulator2,stimulator3,stimSequenceInd)
%Written by Xing 31/10/17
%Delivery of microstimulation pulses, either for fake triggers or real
%triggers.
numPulses=45;
for uniqueStimInd=1:length(uniqueStimulators)
    stimulatorInd=find(stimulatorNums==uniqueStimulators(uniqueStimInd));
    eval(['isconnected=stimulator',num2str(stimulatorInd),'.isConnected();'])
    disp(['ISconnected? = ' num2str(isconnected)])
    pause(0.1)%adjust
    
    if ~isconnected
        % compulsory step
        eval(['stimulator',num2str(stimulatorInd),'.connect'])
        pause(0.5)
    end
    waveform_id=1:length(stimSequenceInd{uniqueStimInd});
    electrodeOnStimInd=1;
    currentAmplitude{uniqueStimInd}(electrodeOnStimInd)
    switch stimulatorInd
        case 1
            stimulator1.setStimPattern('waveform',waveform_id(electrodeOnStimInd),...
                'polarity',1,...
                'pulses',numPulses,...
                'amp1',currentAmplitude{uniqueStimInd}(electrodeOnStimInd),...
                'amp2',currentAmplitude{uniqueStimInd}(electrodeOnStimInd),...
                'width1',170,...
                'width2',170,...
                'interphase',60,...
                'frequency',300);
            pause(0.3)%adjust
            stimulator1.beginSequence;
            pause(0.1)%adjust
            for electrodeOnStimInd=1:length(stimSequenceInd{uniqueStimInd})%for each electrode that is controlled by a given stimulator
                if stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)>1%if it is not the first electrode in the whole sequence, add a delay. the variable stimSequenceInd contains an index that is relative to the whole sequence, not just to the electrodes for a particular stimulator
                    stimulator1.wait(150*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1))%adjust
                    disp(['electrode order = ' num2str(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd))])
                    disp(['time delay (ms) = ' num2str(150*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1))])
                    pause(0.1)%adjust
                end
                stimulator1.autoStim(electrode{uniqueStimInd}(electrodeOnStimInd),waveform_id(electrodeOnStimInd)) %Electrode #1 , Waveform #1
                pause(0.1)%adjust
            end
            stimulator1.endSequence;
            pause(0.1)%adjust
            status = stimulator1.getSequenceStatus();
            while status ~= 0
                status = stimulator1.getSequenceStatus();
                disp(['point 11, status ',num2str(status)])
            end
            stimulator1.trigger(1);%Format: 	cerestim_object.trigger(edge)
            pause(0.1)%adjust
            isconnected=stimulator1.isConnected();
            pause(0.1)%adjust
            disp(['ISconnected? = ' num2str(isconnected)])
            
        case 2
            stimulator2.setStimPattern('waveform',waveform_id(electrodeOnStimInd),...
                'polarity',1,...
                'pulses',numPulses,...
                'amp1',currentAmplitude{uniqueStimInd}(electrodeOnStimInd),...
                'amp2',currentAmplitude{uniqueStimInd}(electrodeOnStimInd),...
                'width1',170,...
                'width2',170,...
                'interphase',60,...
                'frequency',300);
            pause(0.3)%adjust
            stimulator2.beginSequence;
            pause(0.1)%adjust
            for electrodeOnStimInd=1:length(stimSequenceInd{uniqueStimInd})%for each electrode that is controlled by a given stimulator
                if stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)>1%if it is not the first electrode in the whole sequence, add a delay. the variable stimSequenceInd contains an index that is relative to the whole sequence, not just to the electrodes for a particular stimulator
                    stimulator2.wait(150*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1))%adjust
                    disp(['electrode order = ' num2str(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd))])
                    disp(['time delay (ms) = ' num2str(150*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1))])
                    pause(0.1)%adjust
                end
                stimulator2.autoStim(electrode{uniqueStimInd}(electrodeOnStimInd),waveform_id(electrodeOnStimInd)) %Electrode #1 , Waveform #1
                pause(0.1)%adjust
            end
            stimulator2.endSequence;
            pause(0.1)%adjust
            status = stimulator2.getSequenceStatus();
            while status ~= 0
                status = stimulator2.getSequenceStatus();
                disp(['point 11, status ',num2str(status)])
            end
            stimulator2.trigger(1);%Format: 	cerestim_object.trigger(edge)
            pause(0.1)%adjust
            isconnected=stimulator2.isConnected();
            pause(0.1)%adjust
            disp(['ISconnected? = ' num2str(isconnected)])
            
        case 3
            stimulator3.setStimPattern('waveform',waveform_id(electrodeOnStimInd),...
                'polarity',1,...
                'pulses',numPulses,...
                'amp1',currentAmplitude{uniqueStimInd}(electrodeOnStimInd),...
                'amp2',currentAmplitude{uniqueStimInd}(electrodeOnStimInd),...
                'width1',170,...
                'width2',170,...
                'interphase',60,...
                'frequency',300);
            pause(0.3)%adjust
            stimulator3.beginSequence;
            pause(0.1)%adjust
            for electrodeOnStimInd=1:length(stimSequenceInd{uniqueStimInd})%for each electrode that is controlled by a given stimulator
                if stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)>1%if it is not the first electrode in the whole sequence, add a delay. the variable stimSequenceInd contains an index that is relative to the whole sequence, not just to the electrodes for a particular stimulator
                    stimulator3.wait(150*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1))%adjust
                    disp(['electrode order = ' num2str(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd))])
                    disp(['time delay (ms) = ' num2str(150*(stimSequenceInd{uniqueStimInd}(electrodeOnStimInd)-1))])
                    pause(0.1)%adjust
                end
                stimulator3.autoStim(electrode{uniqueStimInd}(electrodeOnStimInd),waveform_id(electrodeOnStimInd)) %Electrode #1 , Waveform #1
                pause(0.1)%adjust
            end
            stimulator3.endSequence;
            pause(0.1)%adjust
            status = stimulator3.getSequenceStatus();
            while status ~= 0
                status = stimulator3.getSequenceStatus();
                disp(['point 11, status ',num2str(status)])
            end
            stimulator3.trigger(1);%Format: 	cerestim_object.trigger(edge)
            pause(0.1)%adjust
            isconnected=stimulator3.isConnected();
            pause(0.1)%adjust
            disp(['ISconnected? = ' num2str(isconnected)])
    end
end
