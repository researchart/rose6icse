% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function x = subsref( x, S, cheat )
global cvx___
try
    x = subsref( cvx___.problems( index( x ) ), S );
catch
    error( lasterr );
end

% Copyright 2012 CVX Research, Inc.
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
