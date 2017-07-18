% Send Serial data via Matlab
% You can also Launch the SerWatch app found inside 
% C:\Program Files (x86)\Blackrock Microsystems\CerePlex Direct Windows Suite\SerWatch.exe
% To look at the serial values being received by the NSP

%% An example on how to send the word "Example" tp the NSP via serial port
SAVEMatrix=double('Example')';

% Set Serial
SerCom = serial('COM3');
SerCom.BaudRate = 115200;
SerCom.Parity='none';
SerCom.ReadAsyncMode = 'continuous';  
SerCom.FlowControl = 'software';
%get(SerCom,'PinStatus')
SerCom.OutputBufferSize = length(SAVEMatrix)*8+128;  
% Open Serial
fopen(SerCom);

% RandMatrix = reshape(SAVEMatrix',1,[]);
fwrite(SerCom,'EXAMPLE','int8');
% Close Serial
fclose(SerCom);
delete(SerCom);
clear SerCom

%% To view the data in Matlab

openNEV 
clc
char(NEV.Data.SerialDigitalIO.UnparsedData)'