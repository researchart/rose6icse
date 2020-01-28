% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function test_mpt_norm_repeated

% As simple as it gets...
yalmip('clear')
sdpvar u0
x0 = sdpvar(2,1);

bounds(x0,-2,2);
bounds(u0,-2,2);
x1 = [0.1 0.2;0.3 0.4]*x0 + [0.5;0.6]*u0
F = set([]);
F = F + set(norm(x1,1) < norm(x0,1));
F = F +  set(-2<x0<2);
F = F +  set(-2<x1<2);
F = F +  set(-2<u0<2);
obj = norm(x0,1);
[sol,dgn,VV,JJ] = solvemp(F, obj, [], x0)

mbg_asserttrue(length(sol) == 4);
mbg_asserttrue(dgn.problem == 0);

assign(x0,[1;1])
mbg_asserttolequal(double(JJ),2,1e-5);

yalmip('clear')
sdpvar u0 u1
x0 = sdpvar(2,1);
x1 = sdpvar(2,1);
x2 = sdpvar(2,1);
bounds(x0,-2,2);
bounds(x1,-2,2);
bounds(x2,-2,2);
bounds(u0,-2,2);
bounds(u1,-2,2);
%x1 = [0.1 0.2;0.3 0.4]*x0 + [0.5;0.6]*u0
F = set(x1 ==[0.1 0.2;0.3 0.4]*x0 + [0.5;0.6]*u0);
F = F + set(x2 ==[0.1 0.2;0.3 0.4]*x1 + [0.5;0.6]*u1);
F = F + set(norm(x1,1) < norm(x0,1));
F = F + set(norm(x2,1) < norm(x1,1));
F = F +  set(-2<x0<2);
F = F +  set(-2<x1<2);
F = F +  set(-2<x2<2);
F = F +  set(-2<u0<2);
obj = norm(x0,1)+norm(x1,1);
sol = solvemp(F, obj, [], x0)
mbg_asserttrue(length(sol) == 6);

yalmip('clear')
sdpvar u0 u1
x0 = sdpvar(2,1);
x1 = sdpvar(2,1);
x2 = sdpvar(2,1);
bounds(x0,-2,2);
bounds(x1,-2,2);
bounds(x2,-2,2);
bounds(u0,-2,2);
bounds(u1,-2,2);
F = set(x1 ==[0.1 0.2;0.3 0.4]*x0 + [0.5;0.6]*u0);
F = F + set(x2 ==[0.1 0.2;0.3 0.4]*x1 + [0.5;0.6]*u1);
F = F + set(norm(x2,1) < norm(x1,1));
F = F + set(norm(x1,1) < norm(x0,1));
F = F +  set(-2<x0<2);
F = F +  set(-2<x1<2);
F = F +  set(-2<x2<2);
F = F +  set(-2<u0<2);
obj = norm(x0,1)+norm(x1,1);
sol = solvemp(F, obj, [], x0)
mbg_asserttrue(length(sol) == 6);