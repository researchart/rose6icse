% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function y = cvx_s_lower_hessenberg( m, n )
%CVX_S_LOWER_HESSENBERG Lower Hessenberg matrices.
y = cvx_s_banded( m, n, m, 1 );

% Copyright 2012 CVX Research, Inc. 
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
