function monitor_luminance_calibration
% rgbRange=round(linspace(0,255,40));
% rgbRange=rgbRange(randperm(length(rgbRange)));

rgbRange=[13	209	242	222	144	150	78	72	59	85	131	177	20	163	190	52	124	216	65	39	248	0	255	118	170	98	26	183	196	229	157	137	92	111	7	33	235	105	46	203];
% for i=1:length(rgbRange)
%     Screen('FillRect',w,[rgbRange(i) rgbRange(i) rgbRange(i)]);
%     Screen('Flip', w);
%     rgbRange(i)
%     pause;
% end
lum=[1.1	72.8	96.1	75.7	27.6	28.9	5.1	4.0	2.0	5.4	17.7	37.7	0.0	30.5	42.6	1.1	15.2	64.5	2.8	0.7	89.2	0.0	92.1	13.4	34.1	8.0	0.2	41.0	48.6	71.0	27.6	19.3	6.4	10.9	0.0	0.3	73.5	9.3	0.8	53.9];
[rgbRangeSorted sortInd]=sort(rgbRange);
lumSorted=lum(sortInd);
figure;
plot(rgbRangeSorted,lumSorted);