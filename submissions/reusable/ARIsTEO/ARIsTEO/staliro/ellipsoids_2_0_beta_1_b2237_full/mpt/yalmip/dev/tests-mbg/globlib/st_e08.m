% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_e08.gms
% Created 21-Aug-2007 18:42:07 using YALMIP R20070810

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);

% Define objective function 
objective = -(-2*x1-x2+0-(0));

% Define constraints 
F = set([]);
F=[F,-16*x1*x2<=-1];
F=[F,(-4*sqr(x1))-4*sqr(x2)<=-1];
F=[F,0<=x1<=1];
F=[F,0<=x2<=1];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective), 0.74178195949521 , 1e-2);