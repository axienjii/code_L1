function stim_code2
% stimulator = cerestim96();
% my_devices = stimulator.scanForDevices;
% stimulator. selectDevice(3);

% selectDevice method, Selects a CereStim 96 Stimulator out of all the stimulators plugged
% into the computer
% Format: cerestim_object.selectDevice(index)
% Inputs:
% index: The stimulator index according to the list of serial numbers
% obtained from cerestim96.scanForDevices() call


%% 

clear all; 
close all;
clc;

%%
clc
%Create stimulator object
stimulator = cerestim96()

my_devices = stimulator.scanForDevices
pause(.3)
for i=0:10
% stimulator. selectDevice(5); 
stimulator.selectDevice(0); 
% the number inside the brackets is the stimulator instance number

pause(.5)
%Connect to the stimulator
stimulator.connect;

%% define a waveform

electrode = 34;
waveform_id = 1;
amplitude=50;%set current level in uA

stimulator.setStimPattern('waveform',waveform_id,...
    'polarity',0,...
    'pulses',5,...
    'amp1',amplitude,...
    'amp2',amplitude,...
    'width1',170,...
    'width2',170,...
    'interphase',60,...
    'frequency',200);

%% manual stimulation
stimulator.manualStim(electrode,waveform_id)

%% triggered stimulation
% stimulator.trigger(3)

stimulator.disconnect;
end