% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function z = eq( x, y )
if ~isa( x, class( y ) )
    error( 'cvxprob objects may only be compared to each other.' );
else
    z = cvx_id( x ) == cvx_id( y );
end

% Copyright 2012 CVX Research, Inc.
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
