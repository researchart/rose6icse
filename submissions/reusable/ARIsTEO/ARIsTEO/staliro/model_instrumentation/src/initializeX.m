% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [integerVector, lb, ub, f, info] = initializeX( infoIn )

info = infoIn;
info.startOfB = 1;
info.startOfD = info.startOfB + (numOfBlocks(info) * info.numOfCores);
info.startOfS = info.startOfD + (((numOfBlocks(info) - 1) * numOfBlocks(info)) / 2);
info.optimIndex = info.startOfS + numOfBlocks(info);
info.lengthOfX = info.optimIndex;

integerVector = 1:info.startOfS - 1;

lb = zeros(info.lengthOfX, 1);
ub = ones(info.lengthOfX, 1);

lb(info.optimIndex) = max(info.bestFinish(:));
ub(info.optimIndex) = info.deadline;

lb(getIndexS(1:numOfBlocks(info), info), 1) = info.bestStart(1:numOfBlocks(info));
ub(getIndexS(1:numOfBlocks(info), info), 1) = info.worstStart(1:numOfBlocks(info));

f = zeros(info.lengthOfX, 1);
if info.optimize == 1
    f(info.optimIndex) = 1; % We want to minimize maximum of finish times for leaf blocks.
end
end

