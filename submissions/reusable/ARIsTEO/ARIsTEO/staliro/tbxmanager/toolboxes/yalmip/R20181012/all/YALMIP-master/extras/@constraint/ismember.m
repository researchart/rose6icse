% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = ismember(x,F)
% Internal class for constraint list

F = lmi(F);
F = ismember(x,F);

