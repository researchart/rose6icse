% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_e01.gms
% Created 21-Aug-2007 18:41:04 using YALMIP R20070810

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);

% Define objective function 
objective = -(x1+x2+0-(0));

% Define constraints 
F = set([]);
F=[F,x1*x2<=4];
F=[F,0<=x1<=6];
F=[F,0<=x2<=4];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective), -6.66667, 1e-2);