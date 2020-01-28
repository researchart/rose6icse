% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function disp( x, prefix )
if nargin < 2,
    prefix = '';
end
disp( [ prefix, 'cvx ', cvx_class( x, true, true, true ), ' expression (', type( x ), ')' ] );
dual = getdual( x );
if ~isempty( dual ),
    disp( [ prefix, '   tied to dual variable: ', dual.subs ] );
end

% Copyright 2012 CVX Research, Inc.
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
