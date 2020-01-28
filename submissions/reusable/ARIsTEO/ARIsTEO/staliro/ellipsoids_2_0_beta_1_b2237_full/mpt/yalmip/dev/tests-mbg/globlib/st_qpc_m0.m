% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_qpc-m0.gms
% Created 21-Aug-2007 18:36:53 using YALMIP R20070810

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);

% Define objective function 
objective = -(-(2*x1-x1*x1-x2*x2+4*x2)+0-(0));

% Define constraints 
F = set([]);
F=[F,x1-4*x2>=-8];
F=[F,-3*x1+x2>=-9];
F=[F,0<=x1];
F=[F,0<=x2];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective), -5, 1e-2);