% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_z.gms
% Created 06-Aug-2007 09:13:44 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);

% Define objective function 
objective = -(-(-sqr(x1)-sqr(x2)-sqr(x3)+2*x3));

% Define constraints 
F = set([]);
F=[F,x1+x2-x3<=0];
F=[F,-x1+x2-x3<=0];
F=[F,12*x1+5*x2+12*x3<=22.8];
F=[F,12*x1+12*x2+7*x3<=17.1];
F=[F,-6*x1+x2+x3<=1.9];
F=[F,0<=x2];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective), 0, 1e-3);