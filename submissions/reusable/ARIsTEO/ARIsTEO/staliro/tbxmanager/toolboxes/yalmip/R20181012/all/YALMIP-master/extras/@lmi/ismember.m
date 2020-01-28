% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = ismember(x,F)
% Internal class for constraint list

F = replace(F,recover(depends(F)),x);
