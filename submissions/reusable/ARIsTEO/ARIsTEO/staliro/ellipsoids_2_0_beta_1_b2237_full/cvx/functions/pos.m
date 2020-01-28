% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = pos( x )

% POS    Positive part.
%    POS(X) = MAX(X,0). X must be real.
%
%    Disciplined convex programming information:
%        POS(X) is convex and nondecreasing in X. Thus when used in CVX
%        expressions, X must be convex (or affine).

error( nargchk( 1, 1, nargin ) ); %#ok
if ~isreal( x ),

	error( 'Argument must be real.' );
	
else

	y = max( x, 0 );

end

% Copyright 2012 CVX Research, Inc. 
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
