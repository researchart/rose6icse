% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = size( x, varargin )
y = size( cvxaff( x ), varargin{:} );

% Copyright 2012 CVX Research, Inc. 
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
