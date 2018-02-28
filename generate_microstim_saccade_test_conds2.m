function generate_microstim_saccade_test_conds2
%Written by Xing 7/9/17
%Generate mat file containing electrode indices and current threshold levels, which
%is loaded into runstim_microstim_saccade_catch10.m, in order to deliver
%microstimulation to electrodes in random order, at suprathreshold levels.
%Goal is to then check saccade end points for correlations with RF
%coordinates.
%Updated version on 28/2/18, with newly acquired impedance readings, in
%effort to increase number of channels on which stimulation is carried out.

initialCurrent=50;%if threshold has not previously been obtained for a particular channel, start with this value, in uA
load('C:\Users\Xing\Lick\currentThresholdChs83.mat')
goodArraysNew=[];
goodCurrentThresholdsNew=[];
goodArrays8to16New=[];
for arrayInd=8:16    
    load(['C:\Users\Xing\Lick\280218_impedance\array',num2str(arrayInd),'.mat']);
    eval(['arrayTemp=array',num2str(arrayInd),';']);
    lowImpInds=find(arrayTemp(:,6)<=150);
    goodChsNew=arrayTemp(lowImpInds,:);
    temp1=find(goodArrays8to16(:,7)==arrayInd);
    goodChsOld=goodArrays8to16(temp1,:);
    goodChsAll=[goodChsOld;goodChsNew];
    goodCurrentThresholdsAll=[goodCurrentThresholds(temp1,:);zeros(length(goodChsNew),1)];
    uniqueChs=unique(goodChsAll(:,8));
    for uniqueChInd=1:length(uniqueChs)
        ind=find(goodChsAll(:,8)==uniqueChs(uniqueChInd));
        if length(ind)>1%if the channel appears in both the old and the new sets, keep the threshold value that was previously obtained, and remove the duplicate entry (from the new set)
            uniqueChThresholds=goodCurrentThresholdsAll(ind);
            removeInd=find(uniqueChThresholds==0);
            goodChsAll(ind(removeInd),:)=[];
            goodCurrentThresholdsAll(ind(removeInd),:)=[];
        end
    end
    goodArrays8to16New=[goodArrays8to16New;goodChsAll];%compile across arrays
    goodCurrentThresholdsNew=[goodCurrentThresholdsNew;goodCurrentThresholdsAll];
end
save('C:\Users\Xing\Lick\280218_impedance\currentThresholdChs84.mat','goodArrays8to16New','goodCurrentThresholdsNew')
