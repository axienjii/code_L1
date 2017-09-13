%% setting up the Cerestim intereface "Stimmex"
% clc
% Create stimulator object
stimulator = cerestim96();
my_devices = stimulator.scanForDevices
pause(.3)
stimulator. selectDevice(0); %the number inside the brackets is the stimulator instance number; numbering starts from 0
pause(.5)

%Connect to the stimulator
stimulator.connect;

%% define a waveform
stimulator.setStimPattern('waveform',1,...%Define waveform 1
    'polarity',0,...%1 = AF, 2=CF
    'pulses',1,...
    'amp1',15,...
    'amp2',15,...
    'width1',50,...
    'width2',50,...
    'interphase',200,...
    'frequency',100);

%Define waveform 2 same as above but with different polarity
stimulator.setStimPattern('waveform',2,...
    'polarity',1,...%1 = AF, 2=CF
    'pulses',1,...
    'amp1',15,...
    'amp2',15,...
    'width1',50,...
    'width2',50,...
    'interphase',200,...
    'frequency',100);


%% bi-polar stimulation

display('Starting Bi-polar Stimulation');
% status(1) = stimulator.getSequenceStatus
stimulator.beginSequence;
    
stimulator.autoStim(1, 1) %Electrode #1 , Waveform #1
stimulator.autoStim(3, 2) %Electrode #3 , Waveform #2

stimulator.endSequence;
% status(2) = stimulator.getSequenceStatus

%Play our program; number of repeats
stimulator.play(1)



%% 
stimulator.disconnect
clear stimulator