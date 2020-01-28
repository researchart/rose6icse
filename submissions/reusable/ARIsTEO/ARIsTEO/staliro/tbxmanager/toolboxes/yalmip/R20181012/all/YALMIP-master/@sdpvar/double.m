% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [sys,values] = double(varargin)
% OBSOLETE. Use VALUE instead

% New syntax
switch nargout
    case 0
        double(value(varargin{:}))
    case 1
        sys = double(value(varargin{:}));
    case 2
        [sys,values] = value(varargin{:});
        sys = double(sys);
        values = double(values);
    otherwise
        error('Too many output arguments.');
end

