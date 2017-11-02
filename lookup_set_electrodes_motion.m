function [setElectrodes,setArrays]=lookup_set_electrodes_motion(setInd)
%Written by Xing 25/10/17.
%Returns the desired electrodes and arrays for a given set of 4 electrodes.

switch(setInd)
    case 1
        setElectrodes=[{29} {38} {63} {40}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{12} {13} {15} {10}];
        setElectrodes=[{[63 40 29 38]} {[63 40 29 38]} {[63 40 29 38 63]} {[63 40 29 38 63]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[15 10 12 13]} {[15 10 12 13]} {[15 10 12 13 15]} {[15 10 12 13 15]}];
        setElectrodes=[{[63 40 29 38 63]} {[63 40 29 38 63]} {[63 40 46 38 63]} {[63 40 46 38 63]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[ {[15 10 12 13 15]} {[15 10 12 13 15]} {[15 10 15 13 15]} {[15 10 15 13 15]}];
        setElectrodes=[{[63 40 29 38 63]} {[63 40 29 38 63]} {[63 40 38 38 40]} {[63 40 38 38 40]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[ {[15 10 12 13 15]} {[15 10 12 13 15]} {[15 10 16 13 8]} {[15 10 16 13 8]}];
        setElectrodes=[{[63 40 29 38 63]} {[63 40 29 38 63]} {[38 40 63 29 38]} {[38 40 63 29 38]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[ {[15 10 12 13 15]} {[15 10 12 13 15]} {[13 8 15 12 16]} {[13 8 15 12 16]}];
%         setElectrodes=[{[63 40 29]} {[63 40 29]} {[38 40 63]} {[38 40 63]}];%first row: set 1, LRTB; second row: set 2, LRTB
%         setArrays=[ {[15 10 12]} {[15 10 12]} {[13 8 15]} {[13 8 15]}];
end