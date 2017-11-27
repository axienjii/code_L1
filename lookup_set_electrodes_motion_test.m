function [setElectrodes,setArrays]=lookup_set_electrodes_motion(setInd)
%Written by Xing 25/10/17.
%Returns the desired electrodes and arrays for a given set of 4 electrodes.

switch(setInd)
    case 1
        setElectrodes=[{[55 42 26]} {[26 42 55]} {[42 34 63]} {[63 34 42]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[ {[11 13 12]} {[12 13 11]} {[10 13 15]} {[15 13 10]}];
end