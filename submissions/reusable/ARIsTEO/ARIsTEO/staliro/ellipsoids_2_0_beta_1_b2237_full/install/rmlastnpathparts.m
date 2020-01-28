% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function pathStr=rmlastnpathparts(pathStr,nPartsToRemove)
ind=regexp(pathStr,filesep);
nPartsInTotal=length(ind);
if nPartsToRemove>0
    pathStr=pathStr(1:(ind(nPartsInTotal-nPartsToRemove+1)-1));
end
    