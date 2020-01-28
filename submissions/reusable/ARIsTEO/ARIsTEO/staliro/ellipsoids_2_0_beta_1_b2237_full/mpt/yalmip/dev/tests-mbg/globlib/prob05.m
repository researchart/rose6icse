% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from prob05.gms
% Created 24-Jul-2007 13:49:10 using YALMIP R20070523

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);

% Define objective function 
objective = -(-2*x1-x2);

% Define constraints 
F = set([]);
F=[F,-16*x1*x2<=-1];
F=[F,(-4*sqr(x1))-4*sqr(x2)<=-1];
F=[F,0.001<=x1<=1];
F=[F,0.001<=x2<=1];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective),0.7418 , 1e-2);