function send_serial_data(trialNo)
% Modified from Saman's script on 12/7/17 by Xing.
% Send Serial data via Matlab
% You can also Launch the SerWatch app found inside 
% C:\Program Files (x86)\Blackrock Microsystems\CerePlex Direct Windows Suite\SerWatch.exe
% To look at the serial values being received by the NSP

SAVEMatrix=double(num2str(trialNo));

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
fwrite(SerCom,SAVEMatrix,'int8');
% Close Serial
fclose(SerCom);
delete(SerCom);
clear SerCom