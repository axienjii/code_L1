function [setElectrodes,setArrays]=lookup_set_electrodes_motion(setInd)
%Written by Xing 25/10/17.
%Returns the desired electrodes and arrays for a given set of 4 electrodes.

switch(setInd)
    case 1
%         setElectrodes=[{[55 42 26]} {[26 42 55]} {[63 48 35]} {[35 48 63]}];%first row: set 1, LRTB; second row: set 2, LRTB
%         setArrays=[{[11 13 12]} {[12 13 11]} {[15 13 10]} {[10 13 15]}];
        setElectrodes=[{[8 35 26]} {[26 35 8]} {[63 48 35]} {[35 48 63]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[10 13 12]} {[12 13 10]} {[15 13 10]} {[10 13 15]}];
%         setElectrodes=[{[55 26]} {[26 55]} {[15 42]} {[42 15]}];%first row: set 1, LRTB; second row: set 2, LRTB
%         setArrays=[{[11 12]} {[12 11]} {[15 10]} {[10 15]}];
%         setElectrodes=[{[55 26]} {[26 55]} {[34 42]} {[42 34]}];%first row: set 1, LRTB; second row: set 2, LRTB
%         setArrays=[{[11 12]} {[12 11]} {[13 10]} {[10 13]}];
%         setElectrodes=[{[35 26]} {[26 35]} {[15 34]} {[34 15]}];%first row: set 1, LRTB; second row: set 2, LRTB
%         setArrays=[{[13 12]} {[12 13]} {[15 13]} {[13 15]}];
end