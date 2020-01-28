% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [integerVector, lb, ub, f, info] = initializeX_MR( infoIn )

info = infoIn;

numOfAllBlocks = numel(info.blocksInHyperPeriod);

numOfIndependentPairs = numel(find(info.independencyGraph));
numOfPreemptionPairs = numel(find(info.preemptionGraph));
info.startOfB = 1;
info.startOfD = info.startOfB + info.numOfMainBlocks * info.numOfCores;
info.startOfP = info.startOfD + numOfIndependentPairs;
info.startOfS = info.startOfP + numOfPreemptionPairs;
info.optimIndex = info.startOfS + numOfAllBlocks;
info.lengthOfX = info.optimIndex;
info.D = -1 * ones(numOfIndependentPairs);

integerVector = 1:info.startOfS - 1;

lb = zeros(info.lengthOfX, 1);
ub = ones(info.lengthOfX, 1);

%lb(info.optimIndex) = max(info.bestFinish(:));
ub(info.optimIndex) = info.hyperPeriod;

%lb(getIndexS(1:numOfBlocks(info), info), 1) = info.bestStart(1:info.numOfMainBlocks);
ub(info.startOfS:info.startOfS + numOfAllBlocks-1, 1) = info.hyperPeriod;

f = zeros(info.lengthOfX, 1);
if info.optimize == 1
    f(info.optimIndex) = 1; % We want to minimize maximum of finish times for leaf blocks.
end
end

