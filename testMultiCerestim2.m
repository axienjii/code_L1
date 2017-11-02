%% Defining object
clc
clear all

stimulator(1) = cerestim96();
stimulator(2) = cerestim96();
stimulator(3) = cerestim96();
% stimulator(4) = cerestim96();
% stimulator(5) = cerestim96();

%%
% define a waveform
waveform_id = 1;
electrode = 1 ;
numPulses=50;%originally set to 5 pulses
desiredStimulators = [14293 65338 14175];

% my_devices = stimulator(1).scanForDevices
% my_devices = stimulator(2).scanForDevices
my_devices = stimulator(3).scanForDevices

%% possible bug !!!
for deviceInd=1:length(my_devices)
    stimulatorInd=find(my_devices==desiredStimulators(deviceInd));
    stimulator(deviceInd).selectDevice(stimulatorInd-1) %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
end
%%

for i=1:length(my_devices)
    for j=1:5
        i
        disp(['iteration= ' num2str(j)]);
        %these two lines do not work within this loop:
%         stimulatorInd=find(my_devices==desiredStimulators(deviceInd));
%         stimulator(deviceInd).selectDevice(stimulatorInd-1) %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1

        pause(0.5)
        
        % compulsory step
%         stimulator(1).connect 

        isconnected=stimulator(i).isConnected();
        disp(['ISconnected? = ' num2str(isconnected)])
        
        if ~isconnected
            % compulsory step
            stimulator(i).connect
        end
        
        seq_stat=stimulator(i).getSequenceStatus();
        disp(['status= ' num2str(seq_stat)])
        
%% now set the waveform parameters for the REAL Stimulation trains:   

        stimulator(i).setStimPattern('waveform',waveform_id,...
            'polarity',1,...
            'pulses',numPulses+i+j,...
            'amp1',150,...
            'amp2',150,...
            'width1',170,...
            'width2',170,...
            'interphase',60,...
            'frequency',300);
       
        
        %% possible bug
        
        stimulator(i).beginSequence;
        stimulator(i).wait(10*i);%add an offset of 1 ms to train on second electrode
        stimulator(i).beginGroup;
        stimulator(i).autoStim(electrode,waveform_id) %Electrode #1 , Waveform #1
        stimulator(i).endGroup;
        stimulator(i).endSequence;
        
        %  bug related to program a stimulator left in trigger
        stimulator(i).trigger(3);%Format: 	cerestim_object.trigger(edge)
        
         pause(.25)
        
         % to fix the error use the following line but also manually
         % restart the Cetrstim
    end
end
for i=1:length(my_devices)
        stimulator(i).disableTrigger;
        
        % You can leave the Cerestim always connected if the SELECT DEVICE
        % fucntion is not used
        
%       stimulator(1).disconnect 
   
    %%
        pause(.25)
    
        isconnected=stimulator(i).isConnected();
        disp(['ISconnected? = ' num2str(isconnected)])
end


