% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sys = flatten(sys)

% Go from an internal format which is hierarchical and performs better
% when adding many constraint objects.
sys = flatten(lmi(sys));