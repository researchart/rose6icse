% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function i = getIndexB(block, core, info)

i = info.startOfB + ((block - 1) * info.numOfCores) + core - 1;
end

