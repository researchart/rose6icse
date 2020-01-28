% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function integer( varargin )

%INTEGER Declares an integer variable.
%   INTEGER VARIABLE x
%   where x is a valid MATLAB variable name, declares a scalar variable for
%   the current CVX problem, and constraints it so that it can assume only
%   integral values.
%
%   INTEGER VARIABLE x(SZ), where SZ is a size vector, declares an array of
%   size SZ and constrains each element to be integral. Structure modifiers
%   such as "symmetric", "toeplitz", etc. are also permitted.
%
%   INTEGER VARIABLES x y(SZ) z ... can be used to declare multiple integer 
%   variables. Note however that structure modifiers are not permitted in
%   this case.
%
%   Obviously, integer variables are NOT convex. Problems with integer 
%   variables can only be handled by solvers with explicit support for
%   them; in particular, neither of the free solvers SeDuMi nor SDPT3
%   provide integer support.
%
%   Examples:
%      integer variable x
%      integer variable x(100)
%
%   See also BINARY, VARIABLE, VARIABLES.

if nargin < 2 || ~iscellstr( varargin ),
    error( 'Syntax: integer variable <variable>   or   integer variables <variables>' );
elseif strcmpi( varargin{1}, 'variable' ),
    evalin( 'caller', sprintf( '%s ', 'variable', varargin{2:end}, ' integer' ) );
elseif strcmpi( varargin{1}, 'variables' ),
    for k = 2 : nargin,
        evalin( 'caller', sprintf( '%s ', 'variable', varargin{k}, ' integer' ) );
    end
else
    error( 'Syntax: integer variable <variable>   or   integer variables <variables>' );
end

% Copyright 2012 CVX Research, Inc.
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
