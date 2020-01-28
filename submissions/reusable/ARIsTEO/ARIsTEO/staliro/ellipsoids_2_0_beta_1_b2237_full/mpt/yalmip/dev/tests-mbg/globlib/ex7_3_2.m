% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from ex7_3_2.gms
% Created 17-Mar-2008 13:23:12 using YALMIP R20070810

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);
x4 = sdpvar(1);

% Define objective function 
objective = -(-x4+0-(0));

% Define constraints 
F = set([]);
F=[F,power(x1,4)*power(x2,4)-power(x1,4)-power(x2,4)*x3<=0];
F=[F,-x1-0.25*x4<=-1.4];
F=[F,x1-0.25*x4<=1.4];
F=[F,-x2-0.2*x4<=-1.5];
F=[F,x2-0.2*x4<=1.5];
F=[F,-x3-0.2*x4<=-0.8];
F=[F,x3-0.2*x4<=0.8];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1,'bmibnb.upper','fmincon'))
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective), 1.0899, 1e-2);