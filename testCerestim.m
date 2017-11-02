%% Defining object
clc
clear all

stimulator(1) = cerestim96();
% stimulator(2) = cerestim96();

%%
    % define a waveform
    waveform_id = 1;
    electrode = 1 ; 
    numPulses=50;%originally set to 5 pulses
    desiredStimulator = 14293;
    
    my_devices = stimulator(1).scanForDevices
%     my_devices = stimulator(2).scanForDevices
    
    %% possible bug !!! 
    stimulatorInd=find(my_devices==desiredStimulator);
    stimulator(1).selectDevice(stimulatorInd-1) %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
%     stimulator(2).selectDevice(stimulatorInd-1)
    
%%

        stimulator(1).selectDevice(stimulatorInd-1) %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1


for i=1:5
        disp(['iteration= ']); i
        

        pause(0.5)
        
        % compulsory step
%         stimulator(1).connect 

        isconnected=stimulator(1).isConnected();
        disp(['ISconnected? = ' num2str(isconnected)])
        
        if ~isconnected
            % compulsory step
            stimulator(1).connect
        end
        
        seq_stat=stimulator(1).getSequenceStatus();
        disp(['status= ' num2str(seq_stat)])
        
%% now set the waveform parameters for the REAL Stimulation trains:   

        stimulator(1).setStimPattern('waveform',waveform_id,...
            'polarity',1,...
            'pulses',numPulses+i,...
            'amp1',150,...
            'amp2',150,...
            'width1',170,...
            'width2',170,...
            'interphase',60,...
            'frequency',300);
       
        
        %% possible bug
        
        stimulator(1).beginSequence;
        stimulator(1).wait(10);%add an offset of 1 ms to train on second electrode
        stimulator(1).beginGroup;
        stimulator(1).autoStim(electrode,waveform_id) %Electrode #1 , Waveform #1
        stimulator(1).endGroup;
        stimulator(1).endSequence;
        
        %  bug related to program a stimulator left in trigger
        stimulator(1).trigger(3);%Format: 	cerestim_object.trigger(edge)
        
         pause(.25)
        
         % to fix the error use the following line but also manually
         % restart the Cetrstim
         
        stimulator(1).disableTrigger;
        
%         % You can leave the Cerestim always connected if the SELECT DEVICE
%         % fucntion is not used
        %         stimulator(1).disconnect 
   
    %%
    pause(.25)
    
    isconnected=stimulator(1).isConnected();
        disp(['ISconnected? = ' num2str(isconnected)])
end


