s = serial('COM3');
set(s,'BaudRate',115200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
trialNo=23;
fopen(s);
for i=500:570
fprintf(s,'%1.0f',i);
pause(0.2)
end
% fprintf(s,'*IDN?')
% out = fscanf(s);
fclose(s);
delete(s)
clear s

get(s,'BaudRate')