function generate_saccade_conds
%Written by Xing 17/7/17
%List of saccade target conditions for microstimulation trials. For initial
%sessions, there are only 1 or 2 saccade locations. For later sessions,
%there are more saccade locations

trialsRemainingSaccCol1=[];%saccade location condition
trialsRemainingSaccCol2=[];%current level condition
for i=1:10
    trialsRemainingSaccCol1=[trialsRemainingSaccCol1;repmat(i,10,1);];
    trialsRemainingSaccCol2=repmat([1:10]',10,1);
end
trialsRemainingSacc=[trialsRemainingSaccCol1 trialsRemainingSaccCol2];
trialsRemainingSacc=repmat(trialsRemainingSacc,5,1);
trialsRemainingSacc(:,3)=0;%trials that should have a correct response
% trialsRemaining(1:400,3)=1;%trials that should be repeated and could have a correct or incorrect response
save('C:\Users\Xing\Lick\trialsRemainingSacc.mat','trialsRemainingSacc')
