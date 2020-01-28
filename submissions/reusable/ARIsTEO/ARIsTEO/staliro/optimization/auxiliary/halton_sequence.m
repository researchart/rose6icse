% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function r = halton_sequence ( dim_num, n, step, seed, leap, base )
%% was originally I4_TO_HALTON_SEQUENCE: N elements of an DIM_NUM-dimensional Halton sequence.
%
%  Author:John Burkardt
%

dim_num = floor ( dim_num );
n = floor ( n );
step = floor ( step );
seed(1:dim_num) = floor ( seed(1:dim_num) );
leap(1:dim_num) = floor ( leap(1:dim_num) );
base(1:dim_num) = floor ( base(1:dim_num) );
r(1:dim_num,1:n) = 0.0;

for i = 1: dim_num
    
    seed2(1:n) = seed(i) + step * leap(i) : leap(i) : ...
        seed(i) + ( step + n - 1 ) * leap(i);
    
    base_inv = 1.0 / base(i);
    
    while ( any ( seed2 ~= 0 ) )
        digit(1:n) = mod ( seed2(1:n), base(i) );
        r(i,1:n) = r(i,1:n) + digit(1:n) * base_inv;
        base_inv = base_inv / base(i);
        seed2(1:n) = floor ( seed2(1:n) / base(i) );
    end
end