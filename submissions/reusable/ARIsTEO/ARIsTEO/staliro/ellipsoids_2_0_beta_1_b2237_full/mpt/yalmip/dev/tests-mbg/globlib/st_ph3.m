% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_ph3.gms
% Created 06-Aug-2007 09:30:04 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);
x4 = sdpvar(1);
x5 = sdpvar(1);
x6 = sdpvar(1);

% Define objective function 
objective = -(-(6*x1-3*sqr(x1)-2*sqr(x3)+4*x3-1.5*sqr(x4)+3*x4-sqr(x5)+2*x5)+0-(0));

% Define constraints 
F = set([]);
F=[F,6*x1+x2+9*x4+3*x5+5*x6<=96];
F=[F,x1+7*x3+6*x4+2*x5+2*x6<=72];
F=[F,5*x1+4*x2+x3+3*x4+8*x5<=84];
F=[F,9*x1+x2+2*x4+7*x5+6*x6<=100];
F=[F,2*x1+6*x4+3*x5+9*x6<=80];
F=[F,0<=x1];
F=[F,0<=x2];
F=[F,0<=x3];
F=[F,0<=x4];
F=[F,0<=x5];
F=[F,0<=x6];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective),-420.2348  , 1e-2);