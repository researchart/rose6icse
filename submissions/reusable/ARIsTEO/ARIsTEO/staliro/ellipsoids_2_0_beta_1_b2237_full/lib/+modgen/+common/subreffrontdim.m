% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function resArray=subreffrontdim(inpArray,curInd)
resArray=inpArray(curInd,:);
newSizeVec=size(inpArray);
newSizeVec(1)=size(resArray,1);
resArray=reshape(inpArray(curInd,:),newSizeVec);