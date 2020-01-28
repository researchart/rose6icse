% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function test_robust_2

yalmip('clear')

Anominal = [0 1 0;0 0 1;0 0 0];
B = [0;0;1];
Q = eye(3)
R = 1;

alpha = sdpvar(1)
A = double2sdpvar(Anominal);
A(1,3) = alpha;

%We have now created a parameterized system, and can proceed as before.
Y = sdpvar(3,3);
L = sdpvar(1,3);

F = set(Y >=0);
F = F + set([-A*Y-B*L + (-A*Y-B*L)' Y L';Y inv(Q) zeros(3,1);L zeros(1,3) inv(R)] > 0)

F = F + set(-0.1 <= alpha <= 0.1);

sol = solverobust(F,-trace(Y),[],alpha)

K = double(L)*inv(double(Y))

mbg_asserttolequal(sol.problem, 0, 1e-5);
mbg_asserttolequal(K -   [-1.3674   -2.9158   -2.6670], 0, 1e-3);


alpha = sdpvar(1)
A = double2sdpvar(Anominal);
A(1,3) = alpha;

L0 = sdpvar(1,3);
L1 = sdpvar(1,3);
L = L0 + alpha*L1;

Y0 = sdpvar(3,3);
Y1 = sdpvar(3,3);
Y = Y0 + alpha*Y1;

F = set(Y >=0);
F = F + set([-A*Y-B*L + (-A*Y-B*L)' Y L';Y inv(Q) zeros(3,1);L zeros(1,3) inv(R)] > 0)
F = F + set(-0.1 <= alpha <= 0.1);
sol = solverobust(F,-trace(Y),[],alpha)

mbg_asserttolequal(sol.problem, 0, 1e-5);
Y0 = double(Y0);
Y1 = double(Y1);
mbg_asserttolequal(max([trace(Y0-0.1*trace(Y1)) trace(Y0+0.1*trace(Y1))]),2.3319, 1e-3);
