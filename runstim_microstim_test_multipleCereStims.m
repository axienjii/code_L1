

clear all

%Create stimulator object
stimulator = cerestim96();
currentAmplitudeFake=1;
numPulsesFake=1;
fakeElectrode=1;
waveform_id = 1;
my_devices = stimulator.scanForDevices;
for deviceInd=1:length(my_devices)
    stimulator(deviceInd).selectDevice(deviceInd-1); %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
    temp=stimulator(deviceInd).isConnected
    if temp==0
        stimulator(deviceInd).connect;
    end
    pause(0.05)
    stimulator(deviceInd).setStimPattern('waveform',waveform_id,...
        'polarity',1,...
        'pulses',numPulsesFake,...
        'amp1',currentAmplitudeFake,...
        'amp2',currentAmplitudeFake,...
        'width1',170,...
        'width2',170,...
        'interphase',60,...
        'frequency',300);
    %'polarity' -	Polarity of the first phase, 0 (cathodic), 1 (anodic)
    %deliver monopolar microstimulation
    stimulator(deviceInd).beginSequence;
    stimulator(deviceInd).autoStim(fakeElectrode,waveform_id) %Electrode #1 , Waveform #1
    stimulator(deviceInd).endSequence;
    stimulator(deviceInd).trigger(1);%Format: 	cerestim_object.trigger(edge)
    x=stimulator(deviceInd).getSequenceStatus
% % 		edge value		type
% % 			0			trigger mode disabled
% % 			1			rising (low to high)
% % 			2			falling (high to low)
% % 			3			any transition
    stimulator(deviceInd).disableTrigger;
    stimulator(deviceInd).disconnect;
    pause(0.05)
%                     dasbit(6,0);%send the trigger signal
end