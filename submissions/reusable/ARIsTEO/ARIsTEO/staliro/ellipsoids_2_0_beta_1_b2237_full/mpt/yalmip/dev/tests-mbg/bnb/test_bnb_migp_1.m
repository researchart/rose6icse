% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function migp

x = sdpvar(7,1);

% Data
a     = ones(7,1);
alpha = ones(7,1);
beta  = ones(7,1);
gamma = ones(7,1);
f = [1 0.8 1 0.7 0.7 0.5 0.5]';
e = [1 2 1 1.5 1.5 1 2]';
Cout6 = 10;
Cout7 = 10;

% Model
C = alpha+beta.*x;
A = sum(a.*x);
P = sum(f.*e.*x);
R = gamma./x;

D1 = R(1)*(C(4));
D2 = R(2)*(C(4)+C(5));
D3 = R(3)*(C(5)+C(7));
D4 = R(4)*(C(6)+C(7));
D5 = R(5)*(C(7));
D6 = R(6)*Cout6;
D7 = R(7)*Cout7;

% Constraints
F = set(x > 1) + set(P < 20) + set(A < 100);

% Objective
D = max([(D1+D4+D6),(D1+D4+D7),(D2+D4+D6),(D2+D4+D7),(D2+D5+D7),(D3+D5+D6),(D3+D7)]);

% Solve integer problem
ops = sdpsettings('solver','bnb','verbose',1);
sol = solvesdp(F+set(integer(x)),D,ops);

mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(x),[ 2     3     3     3     2     3     3]', 1e-3);
mbg_asserttolequal(double(D),8+1/3, 1e-3);