% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function socp1

X = sdpvar(3,3);
x = sdpvar(3,1);
obj = trace(X)+sum(x);
F = set(X>0) + set(cone(x(2:end),x(1))) + set(trace(X)==x(1)+2*x(2)+3*x(3)+4)+set(X(1,3)==8);

sol1  = solvesdp(F,obj);
obj1 = double(obj);
p1   = checkset(F);

sol2 = solvesdp(F,obj,sdpsettings('dualize',1));
obj2 = double(obj);
p2   = checkset(F);

mbg_asserttolequal(sol1.problem,0);
mbg_asserttolequal(sol2.problem,0);
mbg_asserttolequal(obj1,obj2, 1e-5);
mbg_asserttolequal(min(p1),0, 1e-5);
mbg_asserttolequal(min(p2),0, 1e-5);