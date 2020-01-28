% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = cvx_isconstant( x, full ) %#ok
error( nargchk( 1, 2, nargin ) ); %#ok
if nargin == 1,
    y = true;
else
    y = true( size( x ) );
end

% Copyright 2012 CVX Research, Inc.
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
