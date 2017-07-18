function runstim_simphosphenes5(Hnd)
%Written by Xing 4/7/17
%Present smaller subset of letters in the Sloan font (extended version from Denis Pelli) in
%the form of simulated phosphenes, during simultaneous recording from 1000 channels.
%Stimulus set is already pre-generated, and is loaded in from .mat files.
%Specifically written for task in which 10 letters (8 familiar, 2
%unfamiliar) are presented. Phosphene locations, sizes, and densities were
%constant between stimuli and trial. Each stimulus was composed of
%phosphenes that had a particular combination of luminance values. Across
%presentations of all 40 stimuli per letter, for each phosphene location,
%all 40 luminance values were covered. However, the luminance of each
%phosphene was independent of the luminance of the other phosphenes.

global Par   %global parameters
global trialNo
global behavResponse
global performance
global allTargetLetters
global distLettersAllTrials
global allSampleSize
global allSampleX
global allSampleY
global allVisualHeightResolution
global allSample
global trialsRemaining
global allTrialCond
global blockNo
global corrTrialBlockCounter
global allBlockNo

mydir = 'C:\Users\Xing\Lick\visual_letter_task_logs\';
fn = input('Enter LOG file name (e.g. 20110413_B1), blank = no file\n','s');
%Copy the run_stim script
fnrs = [fn,'_','runstim.m'];
cfn = [mfilename('fullpath') '.m'];
copyfile(cfn,fnrs)

takeScreenshot=0;

screenWidth=Par.HW*2;
screenHeight=Par.HH*2;
screenResX=screenWidth;
screenResY=screenHeight;
w=Par.w;
FixDotSize = 0.2;
% global LPStat  %das status values
Times = Par.Times; %copy timing structure
distractorOn=1;
brightOppositeShape=1;

%WINDOWS
%Fix window
FixWinSz =1.5;%1.5
TargWinSz = 4;  %CHANGE TO MAKE MORE ACCUARTE

%Fixatie kleur
red = [255 0 0];
fixcol = red;  %mag ook red zijn

%timing
PREFIXT = 1000; %time to enter fixation window
FIXT=300;
STIMDUR=800;

%REactie tijd
TARGT = 400; %time to keep fixating after target onset before fix goes green (het liefst 400)
RACT = 1000;      %reaction time

%Fix location
Fsz = FixDotSize.*Par.PixPerDeg;

%Target positions (Diagonals)
% targx = [-150 -150 150 150 -100 -100 100 100 -200 -200 200 200];
% targy = [-150 150 150 -150 -100 100 100 -100 -200 200 200 -200];

grey = round([255/2 255/2 255/2]);

LOG.fn = 'runstim_stimphosphenes5';
LOG.BG = grey;
LOG.Par = Par;
LOG.Times = Par.Times;
% LOG.Frame = frame;
LOG.PREFIXT=PREFIXT;
LOG.FIXT = FIXT;
LOG.STIMDUR = STIMDUR;
if isempty(fn)
    logon = 0;
else
    logon = 1;
    fn = [mydir,'simphosphenes5_',fn];
    save(fn,'LOG')
end

%////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
Hit = 2;
Par.ESC = false; %escape has not been pressed
trialNo=0;
%first recording session:
load('C:\Users\Xing\Lick\visual_letter_task_logs\trialsRemaining.mat');%contains list of letter conds, luminance conds, and whether or not to repeat cond on next trial
trialsRemainingOriginal=trialsRemaining;
%for subsequent recording seesions, load in trials remaining from previous
%day:
% load('C:\Users\Xing\Lick\visual_letter_task_logs\simphosphenes5_20170507_B2.mat','trialsRemaining','trialsRemainingOriginal')
% load('C:\Users\Xing\Lick\visual_letter_task_logs\simphosphenes5_2017040717_B1.mat','trialsRemaining','trialsRemainingOriginal')

load('C:\Users\Xing\Lick\visual_letter_task_logs\lumList.mat','lumList');%a pre-determined set of luminance values for each phosphene location
load('C:\Users\Xing\Lick\RGB_LUT.mat');%load LUT for gamma-corrected RGB values
currentTrialIsRepeat=0;
emptyTrialsRemainingFlag=0;
while emptyTrialsRemainingFlag==0
    for trialTestInd=1:100
        %Pretrial
        
        trialNo = trialNo+1;
        if isempty(trialsRemaining)
            %         trialsRemaining=trialsRemainingOriginal;
            emptyTrialsRemainingFlag=1;
        end
        %blocks of luminance and letter conditions:
        numLetterConds=10;
        numLuminanceConds=40;
        numConds=numLetterConds*numLuminanceConds;
        if trialNo==1
            blockNo=1;
            corrTrialBlockCounter=0;%tallies the number of correct trials per block
            shuffleFlag=1;
        end
        if corrTrialBlockCounter==500
            blockNo=blockNo+1;
            corrTrialBlockCounter=0;%reset counter for correct trials for each block
        end
        if shuffleFlag==1
            permInd=randperm(size(trialsRemaining,1));
            trialsRemaining=trialsRemaining(permInd,:);
        end
        letterCond=trialsRemaining(1,1);
        lumCond=trialsRemaining(1,2);
        if currentTrialIsRepeat==1
            repeatNext=0;
        else
            repeatNext=trialsRemaining(1,3);
        end
        allTrialCond(trialNo,:)=trialsRemaining(1,:);%store conditions
        
        %Assign code for trial identity, using sequence of random numbers
        bits = [0 2 6];
        ch = randi(length(bits),1,8);
        ident = bits(ch);
        TRLMAT(trialNo,:) = ident;
        %SETUP YOUR STIMULI FOR THIS TRIAL
        
        if Par.Drum && Hit ~= 2 %if drumming and this was an error trial
            %just redo with current settings
        else
            diagonalSampleSize=6;%from 1 to 7 dva, measured across the diagonal (eccentricity)
            topLeft=1;%distance from fixation spot to top-left corner of sample, measured diagonally (eccentricity)
            estimatedSampleSize = round(sqrt((diagonalSampleSize^2)/2)*Par.PixPerDeg);%randi([50 100]);%pixels [50 155]
            sampleSize=112;%a multiple of 14, the number of divisions in the letters
            stimSize = 40;%size of target letters, in pixels
            sampleX = round(sqrt((topLeft^2)/2)*Par.PixPerDeg);%randi([30 100]);%location of sample stimulus, in RF quadrant 150 230%want to try 20
            sampleY = round(sqrt((topLeft^2)/2)*Par.PixPerDeg);%randi([30 100]);%[30 140]
            
            imageArray=[];
            
            targcol=[0.75 0.75 0];
            distcol=[0.75 0.75 0];
            %         distcol=[0.6 0.6 0];
            targcol=targcol.*255;
            distcol=distcol.*255;
            targetArrayX=[-200 200 0 0];
            targetArrayY=[0 0 -200 200];
            targetArrayYTracker=[0 0 200 -200];%difference between Cogent and PTB
            allLetters=['IT';'UV';'AS';'LY'];
            %set target & distractor locations
            if mod(letterCond,4)==1
                targetLocation=1;%select target location
            elseif mod(letterCond,4)==2
                targetLocation=2;
            elseif mod(letterCond,4)==3
                targetLocation=3;
            elseif mod(letterCond,4)==0
                targetLocation=4;
            end
            if letterCond<=length(allLetters(:))
                targetLetter=allLetters(letterCond);
            elseif letterCond==length(allLetters(:))+1%novel letters
                targetLetter='J';
            elseif letterCond==length(allLetters(:))+2
                targetLetter='P';
            end
            stimInd=1:size(allLetters,1);
            distInd=stimInd(stimInd~=targetLocation);
            for distCount=1:length(targetArrayX)-1
                distx(distCount) = targetArrayX(distInd(distCount));
                disty(distCount) = targetArrayY(distInd(distCount));
                distyTracker(distCount) = targetArrayYTracker(distInd(distCount));%difference between Cogent and PTB
                distTemp=randi([1 size(allLetters,2)],1);%select distractor letter
                distLetters(distCount)=allLetters(distInd(distCount),distTemp);
            end
            if letterCond<=length(allLetters(:))%familiar letters
                if targetLocation==1||targetLocation==2
                    oppositeShape=1;
                else
                    oppositeShape=3;
                end
                oppositeLetter=distLetters(oppositeShape);
                %control window setup
                WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
                    targetArrayX(targetLocation),  targetArrayYTracker(targetLocation), Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];   %2: target;
                for distCount=1:length(targetArrayX)-1
                    WIN = [WIN;distx(distCount),  distyTracker(distCount), Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 1];%1: error
                end
            elseif letterCond>length(allLetters(:))%a mathematical symbol, not a letter
                WIN = [ 0,  0, Par.PixPerDeg*FixWinSz, Par.PixPerDeg*FixWinSz, 0; ... %Fix
                    targetArrayX(targetLocation),  targetArrayYTracker(targetLocation), Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];   %2: target;
                for distCount=1:length(targetArrayX)-1
                    WIN = [WIN;distx(distCount),  distyTracker(distCount), Par.PixPerDeg*TargWinSz, Par.PixPerDeg*TargWinSz, 2];%rewarded at all target lcoations
                end
                oppositeLetter=targetLetter;
            end
            Par.WIN = WIN';
        end
        Hit=randi(2);
        %///////// POSTTRIAL AND REWARD //////////////////////////////////////
        if Hit ~= 0
            removeFromList=0;
            if currentTrialIsRepeat==1%if a response was made and this was one of two consecutively repeated trials
                currentTrialIsRepeat=0;
                removeFromList=1;
                shuffleFlag=0;
            end
            if Hit == 2
                dasbit(  Par.CorrectB, 1);
                Par.Corrcount = Par.Corrcount + 1; %log correct trials
                if repeatNext==0
                    removeFromList=1;
                end
                if length(trialsRemaining)>1
                    if removeFromList==1
                        trialsRemaining=trialsRemaining(2:end,:);%remove complete, not-repeated trial from list
                    end
                    %             else
                    %                 trialsRemaining=trialsRemainingOriginal;
                end
                shuffleFlag=0;
                corrTrialBlockCounter=corrTrialBlockCounter+1;
                
            elseif Hit == 1
                dasbit(  Par.ErrorB, 1);
                Par.Errcount = Par.Errcount + 1;
                %in wrong target window
                if repeatNext==0
                    removeFromList=0;
                    shuffleFlag=1;
                end
                if length(trialsRemaining)>1
                    if removeFromList==1
                        trialsRemaining=trialsRemaining(2:end,:);%remove complete, not-repeated trial from list
                    end
                    %             else
                    %                 trialsRemaining=trialsRemainingOriginal;
                end
            end
            if repeatNext==1
                repeatNext=0;
                currentTrialIsRepeat=1;
                removeFromList=0;
                shuffleFlag=0;
            end
%             for n=1:length(ident)
%                 dasbit(ident(n),1)
%                 pause(0.05);%add a time buffer between sending of dasbits
%                 dasbit(ident(n),0)
%                 pause(0.05);%add a time buffer between sending of dasbits
%             end
        end
                
        allTargetLetters(trialNo)=targetLetter;
        if Hit==2%if correct target selected
            performance(trialNo)=1;%hit
        elseif Hit==1%if erroneous target selected
            if letterCond<=length(allLetters(:))
                performance(trialNo)=-1;%error
            elseif letterCond>length(allLetters(:))
                performance(trialNo)=1;%for novel letters, responses to all targets are correct
            end
        end
        trialNo
        distLettersAllTrials(trialNo,1:length(distLetters))=distLetters;
        allSampleSize(trialNo)=sampleSize;
        allSampleX(trialNo)=sampleX;
        allSampleY(trialNo)=sampleY;
        %     allVisualHeightResolution(trialNo)=visualHeightResolution;
        %     allSample{trialNo}=grandMask;
        allBlockNo(trialNo)=blockNo;
        dirName=cd;
        %     if mod(trialNo,10)==0
        %         save([mydir,'\',date,'_',fileLogName,'_perf.mat'],'behavResponse','performance','distLettersAllTrials','allTargetLetters','allSampleSize','allSampleX','allSampleY','allVisualHeightResolution','allSample')
        %     end
        if takeScreenshot==1&&~isempty(imageArray)
            %     if takeScreenshot==1&&Hit == 2&&~isempty(imageArray)
            dirName=cd;
            folderName=[dirName,'\test\',date];
            if ~exist(folderName,'dir')
                mkdir(folderName);
            end
            imageName=[folderName,'\sample_trial',num2str(trialNo),'.jpg'];
            imwrite(imageArray,imageName)%imwrite is a Matlab function, not a PTB-3 function
        end
        %///////////////////////INTERTRIAL AND CLEANUP
        
        %reset all bits to null
        for i = [0 1 2 3 4 5 6 7]  %Error, Stim, Saccade, Trial, Correct,
            dasbit(  i, 0);
        end
        
        SCNT = {'TRIALS'};
        SCNT(2) = { ['N: ' num2str(Par.Trlcount) ]};
        SCNT(3) = { ['C: ' num2str(Par.Corrcount) ] };
        SCNT(4) = { ['E: ' num2str(Par.Errcount) ] };
        set(Hnd(1), 'String', SCNT ) %display updated numbers in GUI
                
        if trialNo > 0
            save(fn,'*')
        end
    end   %WHILE_NOT_ESCAPED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


