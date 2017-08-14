function check_stimrec_channels_RF_locs
%Written by xing 20/7/17
%Plot the RF centres of channels that were selected for simultaneous
%microstimulation and recording.
figure;hold on
for electrodeInd=1:10
    switch electrodeInd
        case 1
            electrode=34;
            RFx=101.4;
            RFy=-87.2;
            array=13;
            %candidate channels for simultaneous stimulation and recording:
            % instance 7, array 13, electrode 34: RF x, RF y, size (pix), size (dva):
            %[101.373182692835,-87.1965720730945,30.6314285392835,1.18450541719806]
            %SNR 20.7, impedance 13
            %record from 25, 26, 27
        case 2
            electrode=35;
            RFx=101.4;
            RFy=-86.9;
            array=13;
            % instance 7, array 13, electrode 35: RF x, RF y, size (pix), size (dva):
            %[101.419820931771,-86.8574476383865,38.9826040277579,1.50744212233355]
            %SNR 20.8, impedance 13
            %record from 26, 27, 28
        case 3
            electrode=38;
            RFx=37.6;
            RFy=-44.1;
            array=1;
            %SNR 6.5, impedance 38
        case 4
            electrode=36;
            RFx=40.5;
            RFy=-44.7;
            array=1;
            %SNR 12, impedance 58
        case 5
            electrode=37;
            RFx=112.9;
            RFy=-71.3;
            array=13;
            %SNR 23.5, impedance 33
        case 6
            electrode=38;
            RFx=112.9;
            RFy=-71.3;
            array=13;
            %SNR 23.6, impedance 33
        case 7
            electrode=27;
            RFx=120.9;
            RFy=-130.7;
            array=9;
            %SNR 8.3, impedance 43
        case 8
            electrode=26;
            RFx=119.7;
            RFy=-114.9;
            array=9;
            %SNR 8.6, impedance 52
        case 9
            electrode=37;
            RFx=31.6;
            RFy=-63.3;
            array=1;
            %SNR 6.1, impedance 40
        case 10
            electrode=34;
            RFx=27.5;
            RFy=-22.4;
            array=1;
            %SNR 2.0, impedance 43
    end
    plot(RFx,RFy,'ko');
end