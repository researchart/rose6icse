% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_ph13.gms
% Created 06-Aug-2007 09:31:26 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);
x3 = sdpvar(1);

% Define objective function 
objective = -(-(x1-0.5*sqr(x1)-0.5*sqr(x2)+x2-0.5*sqr(x3)+x3)+0-(0));

% Define constraints 
F = set([]);
F=[F,x1<=4];
F=[F,x2<=4];
F=[F,x3<=4];
F=[F,2*x1+3*x2+4*x3<=35];
F=[F,2*x1+3*x2-4*x3<=19];
F=[F,2*x1-3*x2+4*x3<=23];
F=[F,-2*x1+3*x2+4*x3<=27];
F=[F,2*x1-3*x2-4*x3<=7];
F=[F,-2*x1-3*x2+4*x3<=15];
F=[F,-2*x1+3*x2-4*x3<=11];
F=[F,0<=x1];
F=[F,0<=x2];
F=[F,0<=x3];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective),-11.2813 , 1e-2);