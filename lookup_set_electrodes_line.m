function [setElectrodes,setArrays]=lookup_set_electrodes_line(setInd)
%Written by Xing 27/11/17.
%Returns the desired electrodes and arrays for a given set of 4 electrodes.

switch(setInd)
    case 1
        setElectrodes=[{[8 35 26]} {[26 35 8]} {[63 48 35]} {[35 48 63]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[10 13 12]} {[12 13 10]} {[15 13 10]} {[10 13 15]}];
end