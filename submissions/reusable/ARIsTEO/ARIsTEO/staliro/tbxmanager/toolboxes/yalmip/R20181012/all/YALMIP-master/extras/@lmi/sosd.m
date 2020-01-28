% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [h,parvar,Q,v] = sosd(X)
% SOSD    Returns sum-of-squares decomposition (if available)

if ~is(X,'sos')
    error('SOS decompositions are only available for SOS objects');
else
   [h,parvar,Q,v] = sosd(sdpvar(X));
end