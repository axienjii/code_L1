
trialsRemainingCol1=[];%letter condition
trialsRemainingCol2=[];%luminance condition
for i=1:10
    trialsRemainingCol1=[trialsRemainingCol1;repmat(i,40,1);];
    trialsRemainingCol2=repmat([1:40]',10,1);
end
trialsRemaining=[trialsRemainingCol1 trialsRemainingCol2];
trialsRemaining=repmat(trialsRemaining,4,1);
trialsRemaining(:,3)=0;%trials that should have a correct response
trialsRemaining(1:400,3)=1;%trials that should be repeated and could have a correct or incorrect response
save('C:\Users\Xing\Lick\trialsRemaining.mat','trialsRemaining')

numSimPhosphenes=14*14;
lumConds=40;
for phospheneLoc=1:numSimPhosphenes
    lumList(phospheneLoc,:)=randperm(40);%stored with phosphene luminance in rows, stimulus condition in columns
end
save('C:\Users\Xing\Lick\lumList.mat','lumList')

%create proper LUT after measuring monitor luminance and performing gamma
%correction
lumCalibration=round(linspace(0,255,40));