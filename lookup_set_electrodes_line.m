function [setElectrodes,setArrays]=lookup_set_electrodes_line(setInd)
%Written by Xing 27/11/17.
%Returns the desired electrodes and arrays for a given set of electrodes.

switch(setInd)
    case 1
        setElectrodes=[{[8 35 26]} {[26 35 8]} {[50 28 35 55]} {[63 48 40 35]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[10 13 12]} {[12 13 10]} {[12 12 13 11]} {[15 13 10 10]}];
    case 2
        setElectrodes=[{[8 35 26]} {[26 35 8]} {[40 12 30 49]} {[40 21 13 61]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[10 13 12]} {[12 13 10]} {[12 14 14 15]} {[8 16 14 12]}];
    case 3
        setElectrodes=[{[8 35 26]} {[26 35 8]} {[10 47 53 24]} {[32 55 46 57]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[10 13 12]} {[12 13 10]} {[12 13 13 11]} {[13 13 10 10]}];
    case 4
        setElectrodes=[{[8 35 26]} {[26 35 8]} {[37 62 20 18]} {[38 55 58 59]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[10 13 12]} {[12 13 10]} {[10 10 10 11]} {[13 10 10 10]}];
    case 5
        setElectrodes=[{[8 35 26]} {[26 35 8]} {[41 20 29 56]} {[39 17 34 19]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[10 13 12]} {[12 13 10]} {[12 12 12 13]} {[16 9 12 9]}];
end