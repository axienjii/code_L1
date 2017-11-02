clc
clear all

    % define a waveform
    waveform_id = 1;
    electrode = 1 ; 

    numPulses=50;%originally set to 5 pulses
   

    %% Create stimulator object
    stimulator = cerestim96();
    
    
    desiredStimulator = 14293
    
    my_devices = stimulator.scanForDevices
    stimulatorInd=find(my_devices==desiredStimulator);
    stimulator.selectDevice(stimulatorInd-1) %the number inside the brackets is the stimulator instance number; numbering starts from 0 instead of from 1
    
    %Connect to the stimulator
    temp=stimulator.isConnected();
    if temp==0
        stimulator.connect
    end
            
 %% now set the waveform parameters for the REAL Stimulation trains:        
        stimulator.setStimPattern('waveform',waveform_id,...
            'polarity',1,...
            'pulses',numPulses,...
            'amp1',150,...
            'amp2',150,...
            'width1',170,...
            'width2',170,...
            'interphase',60,...
            'frequency',300);
       
        %'polarity' -	Polarity of the first phase, 0 (cathodic), 1 (anodic)
%%

stimulator.beginSequence;
    stimulator.wait(100);%add an offset of 1 ms to train on second electrode 
    stimulator.beginGroup;
    stimulator.autoStim(electrode,waveform_id) %Electrode #1 , Waveform #1
    stimulator.endGroup;
stimulator.endSequence;
    
stimulator.trigger(1);%Format: 	cerestim_object.trigger(edge)
% 		edge value		type
% 			0			trigger mode disabled
% 			1			rising (low to high)
% 			2			falling (high to low)
% 			3			any transition

%%   
%         if exist('my_devices','var')
%             if length(my_devices)>0
%                 stimulator.disconnect
%             end
%             pause(0.05)
%         end
    
    

%% 
    