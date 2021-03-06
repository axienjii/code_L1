function [setElectrodes,setArrays]=lookup_set_electrodes_line(setInd)
%Written by Xing 27/11/17.
%Returns the desired electrodes and arrays for a given set of electrodes.

switch(setInd)
    case 1
        setElectrodes=[{[]} {[]} {[50 28 35 55]} {[63 48 40 35]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[]} {[]} {[12 12 13 11]} {[15 13 10 10]}];
        setElectrodes=[{[]} {[]} {[1 28 35 55]} {[63 48 40 35]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[]} {[]} {[8 12 13 11]} {[15 13 10 10]}];
    case 2
        setElectrodes=[{[]} {[]} {[40 12 30 49]} {[40 21 13 61]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[]} {[]} {[12 14 14 15]} {[8 16 14 12]}];
    case 3
        setElectrodes=[{[]} {[]} {[10 47 53 24]} {[32 55 46 57]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[]} {[]} {[12 13 13 11]} {[13 13 10 10]}];
    case 4
        setElectrodes=[{[]} {[]} {[37 62 20 18]} {[38 55 58 59]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[]} {[]} {[10 10 10 11]} {[13 10 10 10]}];
    case 5
        setElectrodes=[{[]} {[]} {[41 20 29 56]} {[39 17 34 19]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[]} {[]} {[12 12 12 13]} {[16 9 12 9]}];
    case 6
        setElectrodes=[{[]} {[]} {[2 57 47 61 53]} {[22 27 13 21 61]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[]} {[]} {[12 12 13 13 13]} {[16 16 14 12 12]}];
    case 7
        setElectrodes=[{[]} {[]} {[52 28 34 35 55]} {[45 30 28 23 37]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[]} {[]} {[12 12 13 13 13]} {[8 16 14 12 12]}];
    case 8
        setElectrodes=[{[]} {[]} {[40 7 43 48 55]} {[38 47 39 35 27]}];%first row: set 1, LRTB; second row: set 2, LRTB
        setArrays=[{[]} {[]} {[16 16 8 15 15]} {[16 16 14 12 9]}];
    case 9
        setElectrodes=[{[]} {[]} {[40 64 22 19 62]} {[40 50 12 44 26]}];%151217_B4 & B5
        setArrays=[{[]} {[]} {[16 16 16 8 15]} {[16 16 12 9 9]}];
    case 10
        setElectrodes=[{[]} {[]} {[50 61 21 27 46]} {[7 64 61 58 2]}];%151217_B6 & B7?
        setArrays=[{[]} {[]} {[16 16 16 8 15]} {[16 16 16 14 12]}];
    case 11 
        setElectrodes=[{[]} {[]} {[39 47 16 32 49]} {[40 21 13 20 61]}];%151217_B8 & B9?
        setArrays=[{[]} {[]} {[12 14 14 14 15]} {[8 16 14 12 12]}];
    case 12 
        setElectrodes=[{[]} {[]} {[50 36 28 35 55]} {[63 48 26 40 35]}];%151217_B10 & B11?
        setArrays=[{[]} {[]} {[12 12 12 13 11]} {[15 13 13 10 10]}];
    case 13 
        setElectrodes=[{[]} {[]} {[45 44 50 15 7]} {[44 19 27 32 28]}];%181217_B11 & B12
        setArrays=[{[]} {[]} {[8 8 8 15 15]} {[8 8 8 14 12]}];
    case 14 
        setElectrodes=[{[]} {[]} {[33 5 23 29 56]} {[37 39 33 64 9]}];%191217_B4 & B10
        setArrays=[{[]} {[]} {[12 12 12 12 13]} {[16 12 12 9 9]}];
    case 15 
        setElectrodes=[{[]} {[]} {[59 29 24 31 38]} {[15 12 15 29 58]}];%191217_B11 & B12
        setArrays=[{[]} {[]} {[14 14 12 13 13]} {[16 16 14 14 12]}];
    case 16 
        setElectrodes=[{[]} {[]} {[10 28 47 34 13]} {[56 51 39 43 36]}];%191217_B13 & B14
        setArrays=[{[]} {[]} {[12 12 13 13 13]} {[13 13 10 10 10]}];
    case 17 
        setElectrodes=[{[]} {[]} {[27 33 49 51 55]} {[49 31 52 46 51]}];%191217_B15 & B16
        setArrays=[{[]} {[]} {[12 13 13 13 11]} {[15 13 13 10 10]}];
    case 18 
        setElectrodes=[{[]} {[]} {[46 32 15 22 3]} {[32 53 47 58 59]}];%191217_B17 & B18
        setArrays=[{[]} {[]} {[10 10 10 10 11]} {[13 13 10 10 10]}];
    case 19 
        setElectrodes=[{[]} {[]} {[40 44 12 28 31]} {[63 61 47 58 43]}];%201217_B2 & B4?
        setArrays=[{[]} {[]} {[12 14 14 14 14]} {[16 16 14 14 12]}];
    case 20 
        setElectrodes=[{[]} {[]} {[39 45 47 54 32]} {[15 53 12 29 59]}];%201217_B & B?
        setArrays=[{[]} {[]} {[12 14 14 14 14]} {[16 14 14 14 12]}];
    case 21
        setElectrodes=[{[]} {[]} {[17 58 13 20 30]} {[22 63 13 21 44]}];%201217_B & B?
        setArrays=[{[]} {[]} {[9 14 14 14 14]} {[16 14 14 12 12]}];
    case 22
        setElectrodes=[{[]} {[]} {[39 63 30 40 63]} {[50 27 32 29 33]}];%201217_B & B?
        setArrays=[{[]} {[]} {[16 16 16 15 15]} {[8 8 14 12 13]}];
    case 23
        setElectrodes=[{[]} {[]} {[21 29 48 22 38]} {[20 63 22 20 52]}];%201217_B & B?
        setArrays=[{[]} {[]} {[12 12 13 13 13]} {[16 14 12 12 12]}];
    case 24
        setElectrodes=[{[]} {[]} {[40 64 22 19 62]} {[40 50 12 44 26]}];%030118_B4 & B6
        setArrays=[{[]} {[]} {[16 16 16 8 15]} {[16 16 12 9 9]}];
    case 25 
        setElectrodes=[{[]} {[]} {[50 61 21 27 46]} {[7 64 61 58 2]}];%030118_B10 & B11
        setArrays=[{[]} {[]} {[16 16 16 8 15]} {[16 16 16 14 12]}];
    case 26
        setElectrodes=[{[]} {[]} {[39 47 16 32 49]} {[40 21 13 20 61]}];%030118_B14 & B15
        setArrays=[{[]} {[]} {[12 14 14 14 15]} {[8 16 14 12 12]}];
    case 27
        setElectrodes=[{[]} {[]} {[50 36 28 35 55]} {[63 48 26 40 35]}];%030118_B19 & B20
        setArrays=[{[]} {[]} {[12 12 12 13 11]} {[15 13 13 10 10]}];
    case 28
        setElectrodes=[{[]} {[]} {[45 44 50 15 7]} {[44 19 27 32 28]}];%030118_B23 & B24
        setArrays=[{[]} {[]} {[8 8 8 15 15]} {[8 8 8 14 12]}];
    case 29
        setElectrodes=[{[]} {[]} {[40 47 56 24 21]} {[22 52 38 29 57]}];%040118_B17 & B19
        setArrays=[{[]} {[]} {[10 10 10 10 11]} {[13 13 10 10 10]}];
    case 30
        setElectrodes=[{[]} {[]} {[43 62 21 20 18]} {[38 55 56 62 34]}];%040118_B21 & B23?
        setArrays=[{[]} {[]} {[10 10 10 10 11]} {[13 10 10 10 11]}];
    case 31
        setElectrodes=[{[]} {[]} {[41 13 22 30 12]} {[35 34 48 47 1]}];%190118_B & B?
        setArrays=[{[]} {[]} {[12 12 12 12 13]} {[16 12 9 9 9]}];
    case 32
        setElectrodes=[{[]} {[]} {[34 42 26 41 60]} {[57 43 40 6 1]}];%190118_B & B?
        setArrays=[{[]} {[]} {[12 12 12 13 13]} {[16 16 14 12 12]}];
    case 33
        setElectrodes=[{[]} {[]} {[42 45 0 20 18]} {[12 38 0 29 57]}];%190118_B & B?
        setArrays=[{[]} {[]} {[10 10 0 10 11]} {[13 10 0 10 10]}];
    case 34
        setElectrodes=[{[]} {[]} {[41 13 22 23 12]} {[35 34 48 47 1]}];%260218_B & B?
        setArrays=[{[]} {[]} {[12 12 12 12 13]} {[16 12 9 9 9]}];
    case 35
        setElectrodes=[{[]} {[]} {[34 42 26 58 60]} {[57 43 40 6 1]}];%260218_B & B?
        setArrays=[{[]} {[]} {[12 12 12 13 13]} {[16 16 14 12 12]}];
%     case 31%dummy condition, for testing purposes
%         setElectrodes=[{[]} {[]} {[43 26 21 52 21]} {[38 45 56 7 34]}];%
%         setArrays=[{[]} {[]} {[10 9 10 12 16]} {[13 8 10 15 11]}];
%     case 31
%         setElectrodes=[{[]} {[]} {[]} {[]}];%0118_B & B?
%         setArrays=[{[]} {[]} {[]} {[]}];
%     case 
%         setElectrodes=[{[]} {[]} {[]} {[]}];%0118_B & B?
%         setArrays=[{[]} {[]} {[]} {[]}];
end