% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function nElems=getNElems(self)
% GETNELEMS - returns a number of elements in a given object
% Input:
%   regular:
%      self: 
% 
% Output:
%   nElems:double[1, 1] - number of elements in a given object
nElems=self.getNElemsInternal();