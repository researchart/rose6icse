% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function test_sort

x = sdpvar(4,1);
z = sdpvar(4,1);

[y,loc] = sort(x);

w = randn(4,1);

sol = solvesdp(set(-100 < x < 100)+set(z == y),norm(x-w,1));

mbg_asserttrue(sol.problem == 0);
mbg_asserttolequal(norm(sort(w)-double(z)),0,1e-4);


A = ones(20,5);
b = (1:20)';
x = sdpvar(5,1);
e = b-A*x;
F = set(mean(x) == median(x)) + set(-100 <= x <= 100);
sol = solvesdp(F,norm(e,1));
mbg_asserttrue(sol.problem == 0);
mbg_asserttolequal(mean(double(x)),2.2,1e-4);
