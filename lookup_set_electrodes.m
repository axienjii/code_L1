function [setElectrodes,setArrays]=lookup_set_electrodes(setInd)
%Written by Xing 25/10/17.
%Returns the desired electrodes and arrays for a given set of 4 electrodes.

switch(setInd)
    case 1
        setElectrodes=[29 38 63 40];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[12 13 15 10];
    case 2
        setElectrodes=[46 46 40 61];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[16 15 8 12];
    case 3
        setElectrodes=[50 55 63 44];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[16 11 14 12];%replaced second electrode (e27 on a8) with that from set 5
    case 4
        setElectrodes=[37 20 32 51];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[10 10 13 10];
    case 5
        setElectrodes=[28 53 62 49];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[12 13 15 13];
    case 6
        setElectrodes=[27 50 15 34];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[12 13 15 13];
    case 7
        setElectrodes=[41 23 38 35];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[12 12 16 12];
    case 8
        setElectrodes=[38 62 15 49];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[16 15 15 13];
%     case 5
%         setElectrodes=[42 55 13 45];%first row: set 1, LRTB; second row: set 2, LRTB
%         setArrays=[13 11 13 10];
%     case 6
%         setElectrodes=[45 18 56 29];%first row: set 1, LRTB; second row: set 2, LRTB
%         setArrays=[10 11 13 10];
%     case 7
%         setElectrodes=[27 51 11 43];%first row: set 1, LRTB; second row: set 2, LRTB
%         setArrays=[12 13 13 10];
%     case 8
%         setElectrodes=[25 35 45 37];%first row: set 1, LRTB; second row: set 2, LRTB
%         setArrays=[12 13 8 12];
    case 9
        setElectrodes=[52 52 48 47];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[12 13 15 13];
    case 10
        setElectrodes=[12 23 45 50];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[12 12 16 12];
    case 11
        setElectrodes=[35 22 40 41];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[12 13 15 13];
end