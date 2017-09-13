clear all

%Range of amps
amps = 1:1:200;
%Let's assume that a given electrode has a threshold 
threshold = 50;
%with some variability
threshstd = 20;
%And the probability the monkey says 'yes' is given by a cumalative
%gaussian
probyes = normcdf(amps,threshold,threshstd);
figure,plot(amps,probyes)

%What is the 0.75 correct point?
realthresh = find(probyes>=0.75,1,'first');

%Quest parameters
tGuess = log10(100);
tGuessSd = log10(50);
pThreshold = 0.75;
beta = log10(3);
delta = 0.01;
gamma = 0;

%simulate 40 trials
ntrials = 40;
nreps = 10;

%Initialize thresholds
currentthresh = zeros(nreps,ntrials);
intensity = zeros(nreps,ntrials);
    
for reps = 1:nreps
    %Set up Quest for this rep
    q = QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);
    for n = 1:40
        
        %Get Quest's suggested intensity
        intensity(reps,n) = round(10.^QuestQuantile(q));
        
        if intensity(reps,n) > 200
            intensity(reps,n) = 200;
        end
        if intensity(reps,n)<1
            intensity(reps,n) = 1;
        end
        
        %Read out the monkey's probabilistic response
        correct = rand(1)<probyes(intensity(reps,n));
        
        %Update Quest
        q=QuestUpdate(q,log10(intensity(reps,n)),correct);
        currentthresh(reps,n) = 10.^QuestMean(q);
    end
end

figure,subplot(1,2,1),errorbar(1:ntrials,mean(currentthresh),std(currentthresh))
hold on,line([1 ntrials],[realthresh realthresh]),xlim([0 ntrials+1])
subplot(1,2,2),errorbar(1:ntrials,mean(intensity),std(intensity)),xlim([0 ntrials+1])

