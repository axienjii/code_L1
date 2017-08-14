function sync_pulse_resting_state(Hnd)
%Written by Xing 18/7/17
%Send sequence of pulses on randomly chosen pins to digital input ports on
%NSPs. Allows post-hoc synchronization of data across NSPs.

global pulseNo
    
fn = input('Enter LOG file name (e.g. 20110413_B1), blank = no file\n','s');
%Copy the run_stim script
fnrs = [fn,'_','runstim.m'];
cfn = [mfilename('fullpath') '.m'];
copyfile(cfn,fnrs)

%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
ESC = false; %escape has not been pressed
pulseNo=0;

while ~ESC
    %Send sync pulse and record in NEV events files
    
    pulseNo = pulseNo+1
    %Assign code for trial identity, using sequence of random numbers
    bit = randi(8)-1;%0 to 7
    allBits(pulseNo)=bit;
    dasbit(bit,1);%set signal to high value
    pause(0.5);%add a time buffer between sending of bits
    dasbit(bit,0);%set signal to low value
    pause(0.5);%add a time buffer between sending of bits
    
    if pulseNo > 0
        mydir = 'C:\Users\Xing\Lick\resting_state\';
        path = [mydir,'sync_pulse_resting_state_',fn];
        save(path,'*');
    end
end   %WHILE_NOT_ESCAPED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


