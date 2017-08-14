clc
clear all
% cbmex('open')
% cbmex('open','instance',2,'inst-addr','192.168.137.128','inst-port',51001,...
%     'central-addr','192.168.137.17','central-port',51002);
%%
cbmex('open','instance',0,'inst-addr','192.168.137.128','inst-port',51001,...
    'central-addr','192.168.137.1','central-port',51002);%NSP 1
pause(0.3)
cbmex('open','instance',1,'inst-addr','192.168.137.128','inst-port',51001,...
    'central-addr','192.168.137.17','central-port',51002);%NSP 2
pause(0.3)
cbmex('open','instance',2,'inst-addr','192.168.137.128','inst-port',51001,...
    'central-addr','192.168.137.33','central-port',51002);%NSP 3
pause(0.3)
cbmex('open','instance',3,'inst-addr','192.168.137.128','inst-port',51001,...
    'central-addr','192.168.137.49','central-port',51002);%NSP 4

%% setting up the Cerestim intereface "Stimmex"
clc
% Create stimulator object
stimulator = cerestim96();
stimulator.connect();

%% define a waveform

electrode = 2;
waveform_id = 1;

stimulator.setStimPattern('waveform',waveform_id,...
    'polarity',1,...
    'pulses',1,...
    'amp1',15,...
    'amp2',15,...
    'width1',50,...
    'width2',50,...
    'interphase',200,...
    'frequency',100);


%% manual stimulation
stimulator.manualStim(electrode,waveform_id)

%% triggered stimulation
stimulator.trigger(3)

%%
clc
% green RGBA
cbmex('comment',65280,0,'Hello world','instance',0)
pause(1)
% red
cbmex('comment',255,0,'Hello world 2','instance',2)

%%
% send five pulses to analog out. 
% 145 is analog out#1 , 146 would be analog out#2 and so on 
% 0.5 Secs @30KHz (15000samples) zero,30msec 5v (16bit digital +/- 32767), range 
% repeat this 5 times.
cbmex('comment',255,0,'Stimulation start','instance',0)
cbmex('analogout',145,'sequence',[15000,0,1000,32767],'repeats',5,...
    'instance',2)
%%
%Send pulse on digital output #1, NSP 4 
cbmex('digitalout',153,1,'instance',3)
cbmex('digitalout',153,0,'instance',3)

cbmex('digitalout',153,1,'instance',2)%NSP 3
cbmex('digitalout',153,0,'instance',2)

%% How start/stop file storage
%turn on recording on NSPs such that 'master' NSP is last
% cbmex('fileconfig','c:\data\examples\datafiles',...
%     'extra comments',1,'instance',2);%duplicate command 4 times (for instances 0-3), set unique file names for each instance
clc
fileTimeStamp=datestr(now);
fileTimeStamp=strrep(fileTimeStamp,':','-');
fileTimeStamp=strrep(fileTimeStamp,' ','_');
dirname ='d:\data\examples\';
for instanceCount=0:3
    cbmex('fileconfig',[dirname fileTimeStamp '_i' num2str(instanceCount+4) '_'],...
    'extra comments',1,'instance',instanceCount);%start recording
pause(1)
end

%% here is your experiment
pause(300)

%% turn off recording in opposite order ('master' NSP first)
instanceCountBackwards=flip(0:3);
for instanceCount=1:4
    cbmex('fileconfig',[dirname fileTimeStamp '_i' num2str(instanceCountBackwards(instanceCount)+4) '_'],...
        'extra comments',0,'instance',instanceCountBackwards(instanceCount));%end recording
    pause(0.3)
end


%% comments
% red
cbmex('comment',255,0,'Hello world 2','instance',2)
pause(0.3)
cbmex('analogout',145,'sequence',[15000,0,1000,32767],'repeats',5,...
    'instance',2)
pause(3)

%% 
for instanceCount=0:3
    cbmex('close','instance',instanceCount)
end

stimulator.disconnect;