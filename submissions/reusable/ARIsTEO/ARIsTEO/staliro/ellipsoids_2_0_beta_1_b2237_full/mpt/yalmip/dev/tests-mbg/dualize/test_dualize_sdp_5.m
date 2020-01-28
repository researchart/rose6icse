% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sdp5

A = randn(3,3);A = -A*A';
P = sdpvar(3,3);
t = sdpvar(1,1);
y = sdpvar(1,1);
F = set(A'*P+P*A < -eye(3));
F = F + set(P > A*A') + set(P(3,3)>0) + set(t+y > 7) + set(P(2,2)>4)+set(P(1,1:2)>t) + set(t>12)+set(t>-12);
obj = trace(P)+y;

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