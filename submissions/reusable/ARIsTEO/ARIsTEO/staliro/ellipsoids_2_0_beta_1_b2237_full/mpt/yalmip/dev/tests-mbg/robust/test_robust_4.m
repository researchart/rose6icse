% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function test_robust_4

sdpvar t1 t2

A = [-1 1+t1+t2*0.1;0 -2 + 0.9*t1];
P1 = sdpvar(2,2);
P2 = sdpvar(2,2);

P = P1*t1 + P2*t2;

C = [A'*P + P*A < -eye(2), P>0, t1+t2 == 1, t1>0, t2>0, uncertain([t1 t2])]

sol = solvesdp(C,trace(P),sdpsettings('robust.polya',1));

mbg_assertfalse(sol.problem);
mbg_asserttolequal(max([double(trace(P1)) double(trace(P2))]), 1.8203, 1e-2);


return
sdpvar t1 t2
A = [0 1 -0.1*t1 + 0.1*t2;0 0 1;0 0 0];
B = [0;0;1];
Q=eye(3);
R=1;

Y1 = sdpvar(3,3);
Y2 = sdpvar(3,3);
Y = Y1*t1 + Y1*t2;

L1 = sdpvar(1,3);
L2 = sdpvar(1,3);

L = L1*t1 + L2*t2;

F = [Y >= 0];
F = [F, [-A*Y-B*L + (-A*Y-B*L)' Y L';Y inv(Q) zeros(3,1);L zeros(1,3) inv(R)] > 0]
F = [F, t1 + t2 == 1, t1 > 0, t2 > 0, uncertain([t1 t2])];
solvesdp(F,-trace(Y),sdpsettings('robust.polya',1))
% 
