% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function milp

rand('seed',1234);

a = [1 2 3 4 5 6]';
t = (0:0.02:2*pi)';
x = [sin(t) sin(2*t) sin(3*t) sin(4*t) sin(5*t) sin(6*t)];
y = x*a+(-4+8*rand(length(x),1));

a_hat = intvar(6,1);

residuals = y-x*a_hat;
bound = sdpvar(length(residuals),1);
F = set(-bound <= residuals <= bound);
ops = sdpsettings('solver','bnb');

% Test QP
obj = sum(bound);
sol = solvesdp(F,obj,ops);
mbg_asserttolequal(sol.problem,0);
mbg_asserttolequal(double(obj), 6.168422746718130e+002, 1e-5);

