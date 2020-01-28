% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from mathopt1.gms
% Created 24-Jul-2007 13:38:40 using YALMIP R20070523

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);

% Define objective function 
objective = -(-(10*sqr(sqr(x1)-x2)+sqr((-1)+x1)));

% Define constraints 
F = set([]);
F=[F,x1-x1*x2==0];
F=[F,3*x1+4*x2<=25];
F=[F,-10<=x1<=20];
F=[F,-15<=x2<=20];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective),0 , 1e-2);