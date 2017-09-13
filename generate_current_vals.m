function generate_current_vals
maxCurrent=100;
currentVal=maxCurrent;
currentVals=maxCurrent;

impedance=38;%kOhms, electrode 38 on array 13
while currentVal>1
    currentVals=[currentVals currentVal*0.9];
    currentVal=currentVal*0.9;
end
finalCurrentVals=unique(round(currentVals));
finalCurrentVals=finalCurrentVals(19:end);
voltages=finalCurrentVals/1000000*impedance*1000;
%generate list of current amplitude conditions:
catchTrials=zeros(1,length(finalCurrentVals));
finalCurrentVals=[catchTrials finalCurrentVals];
save('C:\Users\Xing\Lick\finalCurrentVals','finalCurrentVals')


maxCurrent=115;
currentVal=maxCurrent;
currentVals=maxCurrent;

impedance=38;%kOhms, electrode 38 on array 13
%generate list of current amplitude conditions:
while currentVal>1
    currentVals=[currentVals currentVal*0.9];
    currentVal=currentVal*0.9;
end
finalCurrentVals2=unique(round(currentVals));
finalCurrentVals2=finalCurrentVals2(20:end);
voltages=finalCurrentVals2/1000000*impedance*1000;
finalCurrentVals=finalCurrentVals2;
save('C:\Users\Xing\Lick\finalCurrentVals3','finalCurrentVals')


maxCurrent=140;
currentVal=maxCurrent;
currentVals=maxCurrent;

impedance=38;%kOhms, electrode 38 on array 13
%generate list of current amplitude conditions:
while currentVal>1
    currentVals=[currentVals currentVal*0.9];
    currentVal=currentVal*0.9;
end
finalCurrentVals2=unique(round(currentVals));
finalCurrentVals2=finalCurrentVals2(20:end);
voltages=finalCurrentVals2/1000000*impedance*1000;
finalCurrentVals=finalCurrentVals2;
save('C:\Users\Xing\Lick\finalCurrentVals4','finalCurrentVals')


maxCurrent=140;
currentVal=maxCurrent;
currentVals=maxCurrent;

impedance=38;%kOhms, electrode 38 on array 13
%generate list of current amplitude conditions:
while currentVal>1
    currentVals=[currentVals currentVal*0.9];
    currentVal=currentVal*0.9;
end
finalCurrentVals2=unique(round(currentVals));
voltages=finalCurrentVals2/1000000*impedance*1000;
finalCurrentVals=finalCurrentVals2;
save('C:\Users\Xing\Lick\finalCurrentVals5','finalCurrentVals')


maxCurrent=240;
currentVal=maxCurrent;
currentVals=maxCurrent;

impedance=38;%kOhms, electrode 38 on array 13
%generate list of current amplitude conditions:
while currentVal>1
    currentVals=[currentVals currentVal*0.9];
    currentVal=currentVal*0.9;
end
finalCurrentVals2=unique(round(currentVals));
voltages=finalCurrentVals2/1000000*impedance*1000;
finalCurrentVals=finalCurrentVals2;
save('C:\Users\Xing\Lick\finalCurrentVals6','finalCurrentVals')


maxCurrent=210;
currentVal=maxCurrent;
currentVals=maxCurrent;

impedance=38;%kOhms, electrode 38 on array 13
%generate list of current amplitude conditions:
while currentVal>1
    currentVals=[currentVals currentVal*0.9];
    currentVal=currentVal*0.9;
end
finalCurrentVals2=unique(round(currentVals));
voltages=finalCurrentVals2/1000000*impedance*1000;
finalCurrentVals=finalCurrentVals2;
save('C:\Users\Xing\Lick\finalCurrentVals7','finalCurrentVals')


maxCurrent=210;
currentVal=maxCurrent;
currentVals=maxCurrent;

impedance=38;%kOhms, electrode 38 on array 13
%generate list of current amplitude conditions:
while currentVal>1
    currentVals=[currentVals currentVal*0.8];
    currentVal=currentVal*0.8;
end
finalCurrentVals2=unique(round(currentVals));
voltages=finalCurrentVals2/1000000*impedance*1000;
finalCurrentVals=finalCurrentVals2;
save('C:\Users\Xing\Lick\finalCurrentVals8','finalCurrentVals')