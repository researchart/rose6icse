% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from ex4_1_6.gms
% Created 28-Jul-2007 18:53:56 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);

% Define objective function 
objective = -(-(POWER(x1,6)-15*POWER(x1,4)+27*sqr(x1))-(250));

% Define constraints 
F = set([]);
F=[F,-5<=x1<=5];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));

mbg_assertfalse(sol.problem);
mbg_asserttolequal(double(objective), 7, 1e-2);