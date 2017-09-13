%% setting up the Cerestim intereface "Stimmex"
clc
% Create stimulator object
stimulator = cerestim96()
my_devices = stimulator.scanForDevices;
stimulator. selectDevice(0)

stimulator.connect; 

%% dcefine a waveform
stimulator.setStimPattern('waveform',1,...%Define waveform 1
    'polarity',0,...%0=CF, 1=AF
    'pulses',1,...
    'amp1',15,...
    'amp2',15,...
    'width1',50,...
    'width2',50,...
    'interphase',200,...
    'frequency',100);
%%
%Define waveform 2 same as above but with different polarity
stimulator.setStimPattern('waveform',2,...
    'polarity',1,...%0=CF, 1=AF
    'pulses',1,...
    'amp1',15,...
    'amp2',15,...
    'width1',50,...
    'width2',50,...
    'interphase',200,...
    'frequency',100);


%% bi-polar stimulation

display('Starting Bi-polar Stimulation');
stimulator.beginSequence;
    
stimulator.autoStim(1, 1); %Electrode #1 , Waveform #1
stimulator.autoStim(3, 2); %Electrode #3 , Waveform #2

stimulator.endSequence;

%Play our program; number of repeats
stimulator.play(1);

pause(5)


%% 
stimulator.disconnect;
clear stimulator