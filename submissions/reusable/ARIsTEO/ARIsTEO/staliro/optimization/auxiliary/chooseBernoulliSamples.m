% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [sample, sampleWeight] = chooseBernoulliSamples(inpRanges,subDivs,distrib)

[nInputs, ~] = size(inpRanges); %% How many control inputs?
sample = zeros(nInputs,1);
sampleWeight = 1.0;
for i = 1:nInputs
   n = subDivs(i,1); %% how many subdivisions for the i^th input
   [sample(i,1), sProb] = sampleFromDistribution(distrib(i,:)',inpRanges(i,1),inpRanges(i,2),n); %% draw a sample
   sampleWeight = sProb * sampleWeight;

end


end
