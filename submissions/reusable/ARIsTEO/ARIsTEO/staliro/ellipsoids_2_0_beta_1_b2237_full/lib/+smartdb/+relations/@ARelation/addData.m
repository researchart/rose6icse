% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function addData(self,varargin)
% ADDDATA - adds a set of field values to existing data in a form of new
%           tuples
%
% Input:
%   regular:
%      self:ARelation [1,1] - class object
%
self.addDataAlongDimInternal(1,varargin{:});