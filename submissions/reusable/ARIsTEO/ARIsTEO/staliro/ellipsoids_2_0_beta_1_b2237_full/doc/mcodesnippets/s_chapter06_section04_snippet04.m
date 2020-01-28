% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
crsObjVec = [];
for iInd = 1:size(indNonEmptyVec, 2)
    curTimeLimVec=[indNonEmptyVec(iInd)-1 nSteps];
     rsObj = elltool.reach.ReachDiscrete(secSys,...
         intersectEllVec(indNonEmptyVec(iInd)), ...
             dirsMat, curTimeLimVec,'isRegEnabled',true);
     crsObjVec = [crsObjVec rsObj];
end