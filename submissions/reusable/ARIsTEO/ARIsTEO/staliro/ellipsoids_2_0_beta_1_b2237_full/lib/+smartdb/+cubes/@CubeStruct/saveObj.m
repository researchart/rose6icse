% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function s=saveObj(obj)
% SAVEOBJ- transforms given CubeStruct object into structure containing 
%          internal representation of object properties
%
% Input:
%   regular:
%     self: CubeStruct [nDim1,...,nDim2]
%
%
% Output:
%   regular:
%     SObjectData: struct [n1,...,n_k] - structure containing an internal
%        representation of the specified object
s=obj.saveObjInternal();