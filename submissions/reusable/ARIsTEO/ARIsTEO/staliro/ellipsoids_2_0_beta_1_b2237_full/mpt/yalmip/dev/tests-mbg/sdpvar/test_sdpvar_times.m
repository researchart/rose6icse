% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function test_sdpvar_times

sdpvar x y
mbg_asserttolequal(double(isequal([x*x x*x;x*x x*x],x.*[x x;x x])),1)
mbg_asserttolequal(double(isequal([x*x x*x;x*x x*x],[x x;x x].*x)),1)
mbg_asserttolequal(double(isequal([x*y x*y;x*y x*y],[x x;x x].*y)),1)
mbg_asserttolequal(double(isequal([x*y x*y;x*y x*y],y.*[x x;x x])),1)
