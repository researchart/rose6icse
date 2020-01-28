% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% hydisc2m used for converting a cell of hydis objects to an array of
% hybrid objects

% (C) 2013 by Bardh Hoxha
% Last update: 2013.08.05

function out = hydisc2m(varargin)
out = hydis;
for ii = 1:size(varargin{1},2)
    out = [out varargin{1}{ii}];
end
end


