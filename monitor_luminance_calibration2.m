function monitor_luminance_calibration2
%Modified by Xing from calibration_phase2.m on 03/07017
%
%CS100A calibration script
%Read-in phase1 luminance data and generate best-fit inverse gamma table
%Save inverse gamma table in phase2_photometry.mat

clear all;
close all;

%Xing's data:
lum=[1.1	72.8	96.1	75.7	27.6	28.9	5.1	4.0	2.0	5.4	17.7	37.7	0.0	30.5	42.6	1.1	15.2	64.5	2.8	0.7	89.2	0.0	92.1	13.4	34.1	8.0	0.2	41.0	48.6	71.0	27.6	19.3	6.4	10.9	0.0	0.3	73.5	9.3	0.8	53.9];
rgbRange=[13	209	242	222	144	150	78	72	59	85	131	177	20	163	190	52	124	216	65	39	248	0	255	118	170	98	26	183	196	229	157	137	92	111	7	33	235	105	46	203];
[rgbRangeSorted sortInd]=sort(rgbRange);
lumSorted=lum(sortInd);
indexValues=rgbRangeSorted;
luminanceMeasurements=lumSorted;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot sampled luminance values %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1); clf;
set(gcf,'PaperPositionMode','auto');
set(gcf,'Position',[30 140 800 800]);
subplot(2,2,1);
plot(indexValues,luminanceMeasurements,'+');
hold on;
xlabel('Pixel Values');
ylabel('Luminance (cd/m2)');
strTitle{1}='Sampled Luminance Function';
strTitle{2}='Phase-1 Linear CLUT';
title(strTitle);
axis([0 256 0 max(luminanceMeasurements)]);
axis('square');
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate and plot best-fit power function to sampled data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%zero-correct sampled luminance values
lums=luminanceMeasurements-luminanceMeasurements(1);
%normalize sampled luminance values
normalizedLum=lums./max(lums);
%trim zero level
pixels=indexValues(2:end);
normalizedLum=normalizedLum(2:end);

%curve fit empirical luminance values 
fitType = 2;  %extended power function
outputx = [0:255];
[extendedFit,extendedX]=FitGamma(pixels',normalizedLum',outputx',fitType);

%plot sampled luminance and curve fit results
%figure(2);clf;hold on;
subplot(2,2,2); hold on;
plot(pixels,normalizedLum,'+'); %sampled luminance
plot(outputx,extendedFit,'r');  %curve fit results
axis([0 256 0 1]);
xlabel('Pixel Values');
ylabel('Normalized Luminance');
strTitle{1}='Power Function Fit to Sampled Luminance Readings';
strTitle{2}=['Exponent = ',num2str(extendedX(1)),'; Offset = ',num2str(extendedX(2))];
title(strTitle);
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate inverse gamma corrected pixel transfer function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pixelMax = max(pixels);
%invertedInput=InvertGammaExtP(extendedX,pixelMax,normalizedLum);
%%plot inverse gamma function (pixels)
%%figure(3); clf; hold on;
%subplot(2,2,3); hold on;
%plot(pixels,invertedInput,'r+');
%axis('square');
%axis([0 pixelMax 0 pixelMax]);
%plot([0 pixelMax],[0 pixelMax],'r');
%xlabel('Pixel Values');
%ylabel('Target Pixel Values');
%strTitle{1}='Ideal vs. Inverse Gamma Correction';
%strTitle{2}=['Exponent = ',num2str(extendedX(1)),'; Offset = ',num2str(extendedX(2))];
%title(strTitle);
%hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate inverse gamma luminance function (based on curve fit above) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxLum = max(luminanceMeasurements);
luminanceRamp=[0:1/255:1];
pow=extendedX(1);
offset=extendedX(2);
invertedRamp=((maxLum-offset)*(luminanceRamp.^(1/pow)))+offset; %invert gamma w/o rounding
%normalize inverse gamma table
invertedRamp=invertedRamp./max(invertedRamp);
%plot inverse gamma function
%figure(4); clf; hold on;
subplot(2,2,3); hold on;
pels=[0:255];
plot(pels,invertedRamp,'r');
axis('square');
xlabel('Pixel Values');
ylabel('Inverse Gamma Table');
strTitle{1}='Inverse Gamma Table Function';
strTitle{2}=['for Exponent = ',num2str(extendedX(1)),'; Offset = ',num2str(extendedX(2))];
title(strTitle);
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% expand inverse gamma to full 3-channel CLUT %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inverseCLUT = repmat(invertedRamp',1,3);


rgbRange=linspace(0,1,40);
for i=1:length(rgbRange)
    ind=find(extendedFit(:,1)>=rgbRange(i));
    closestInd(i)=ind(1);
end
desiredRGB=255*extendedFit(closestInd);
subplot(2,2,4);
plot(rgbRange,desiredRGB,'r');
xlabel('calculated RGB values');
ylabel('Normalized Luminance');
save RGB_LUT.mat desiredRGB
%test to see the difference (if any) between original evenly-spaced rGB
%value and gamma-corrected values:
load('C:\Users\Xing\Lick\RGB_LUT.mat');%load LUT for gamma-corrected RGB values

RFrect= [screenWidth/2-Par.PixPerDeg/2 screenHeight/2-Par.PixPerDeg/2 screenWidth/2+Par.PixPerDeg/2 screenHeight/2+Par.PixPerDeg/2];
lumCalibration=round(linspace(0,255,40));
for i = 1:40%
    rect = [0 0 10 10];
    rectshift=RFrect+[i*10 10 i*10+10 10+10];
    Screen('FillRect',w, [lumCalibration(i) lumCalibration(i) lumCalibration(i)], rectshift);
%     rectshift=RFrect+[i*10 70 i*10+10 70+10];
    rectshift=RFrect+[i*10 40 i*10+10 40+10];
    Screen('FillRect',w, [desiredRGB(i) desiredRGB(i) desiredRGB(i)], rectshift);    
end
Screen('Flip', w);

