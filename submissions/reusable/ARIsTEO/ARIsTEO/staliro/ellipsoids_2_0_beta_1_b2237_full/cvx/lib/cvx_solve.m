% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function cvx_solve( presolve )
global cvx___
prob = evalin( 'caller', 'cvx_problem', '[]' );
if ~isa( prob, 'cvxprob' ),
    error( 'No cvx problem exists in this scope.' );
else
    if nargin < 1 || presolve, eliminate( prob ); end
    solve( prob, cvx___.quiet );
    assignin( 'caller', 'cvx_status', prob.status );
    assignin( 'caller', 'cvx_optval', prob.result );
end

% Copyright 2012 CVX Research, Inc.
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
