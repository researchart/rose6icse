% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function test_logic_nzz_1

x = sdpvar(4,1);
sol = solvesdp(set(-10 < x < 10) + set(nnz(x)==3),(x-2)'*(x-2))
mbg_asserttrue(sol.problem == 0);
mbg_asserttrue(norm(sort(double(x))-sort([2;2;2;0])) < 1e-3)

sol = solvesdp(set(-10 < x < 10) + set(nnz(x)<=3),(x-2)'*(x-2))
mbg_asserttrue(sol.problem == 0);
mbg_asserttrue(norm(sort(double(x))-sort([2;2;2;0])) < 1e-3)



sdpvar x y z
sol = solvesdp(set(200>[x y z] > -20) + set(nnz([x;y;z] == 3) >= 2),2*x+y+z);
mbg_asserttrue(sol.problem == 0);
mbg_asserttrue(norm(double([x y z] - [-20 3 3])) < 1e-3)
