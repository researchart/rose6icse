% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = cvx_s_upper_triangular( m, n )
%CVX_S_UPPER_TRIANGULAR Upper triangular matrices.
y = cvx_s_banded( m, n, 0, n );

% Copyright 2012 CVX Research, Inc. 
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
