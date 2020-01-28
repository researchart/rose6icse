% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_phex.gms
% Created 06-Aug-2007 09:29:41 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);

% Define objective function 
objective = -(-(-sqr(x1)-4*sqr(x2))+0-(0));

% Define constraints 
F = set([]);
F=[F,x1+x2<=10];
F=[F,x1+5*x2<=22];
F=[F,-3*x1+2*x2<=2];
F=[F,-x1-4*x2<=-4];
F=[F,x1-2*x2<=4];
F=[F,0<=x1];
F=[F,0<=x2];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective), -85, 1e-2);