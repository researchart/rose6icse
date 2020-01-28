% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sys = dual(X)
%DUAL Extract dual variable
%   
%   Z = DUAL(F)     Returns the dual variable for the constraint F
% 
%   See also SOLVESDP, DUALIZE
  
sys = dual(lmi(X));
