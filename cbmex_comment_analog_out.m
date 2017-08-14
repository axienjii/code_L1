clc
clear all
% cbmex('open')
% cbmex('open','instance',2,'inst-addr','192.168.137.128','inst-port',51001,...
%     'central-addr','192.168.137.17','central-port',51002);
%%
cbmex('open','instance',0,'inst-addr','192.168.137.128','inst-port',51001,...
    'central-addr','192.168.137.1','central-port',51002);%NSP 1
cbmex('open','instance',1,'inst-addr','192.168.137.128','inst-port',51001,...
    'central-addr','192.168.137.17','central-port',51002);%NSP 2
cbmex('open','instance',2,'inst-addr','192.168.137.128','inst-port',51001,...
    'central-addr','192.168.137.33','central-port',51002);%NSP 3
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
% 145 is anaolog out#1 , 146 would be analog out#2 and so on 
% 0.5 Secs @30KHz (15000samples) zero,30msec 5v (16bit digital +/- 32767), range 
% repeat this 5 times.
cbmex('comment',255,0,'Stimulation start','instance',2)
cbmex('analogout',145,'sequence',[15000,0,1000,32767],'repeats',5,...
    'instance',0)

%% How start/stop file storage

% cbmex('fileconfig','c:\data\examples\datafiles',...
%     'extra comments',1,'instance',2);%duplicate command 4 times (for instances 0-3), set unique file names for each instance
fileTimeStamp=datestr(now);
fileTimeStamp=strrep(fileTimeStamp,':','-');
fileTimeStamp=strrep(fileTimeStamp,' ','_');
dirname ='d:\data\examples\';
clc
cbmex('fileconfig',[dirname fileTimeStamp '_i0'],...
    'extra comments',1,'instance',0);%instance 0
pause(0.3)
cbmex('fileconfig',[dirname fileTimeStamp '_i1'],...
    'extra comments',1,'instance',1);
pause(0.3)
cbmex('fileconfig',[dirname,fileTimeStamp,'_i2'],...
    'extra comments',1,'instance',2);
pause(0.3)
cbmex('fileconfig',[dirname,fileTimeStamp,'_i3'],...
    'extra comments',1,'instance',3);

% here is your experiment
pause(300)

for instanceCount=0:3
cbmex('fileconfig',[dirname fileTimeStamp '_i' num2str(instanceCount)],...
    'extra comments',0,'instance',0);
pause(0.3)
end
cbmex('fileconfig',[dirname fileTimeStamp '_i1'],...
    'extra comments',0,'instance',1);
pause(0.3)
cbmex('fileconfig',[dirname,fileTimeStamp,'_i2'],...
    'extra comments',0,'instance',2);
pause(0.3)
cbmex('fileconfig',[dirname,fileTimeStamp,'_i3'],...
    'extra comments',0,'instance',3);


%% comments
% red
cbmex('comment',255,0,'Hello world 2','instance',2)
pause(0.3)
cbmex('analogout',145,'sequence',[15000,0,1000,32767],'repeats',5,...
    'instance',2)
pause(3)

%%


%% 
cbmex('close','instance',0)
cbmex('close','instance',1)
cbmex('close','instance',2)
cbmex('close','instance',3)

stimulator.disconnect;