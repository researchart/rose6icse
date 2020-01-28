% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from st_e10.gms
% Created 21-Aug-2007 18:42:11 using YALMIP R20070810

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);

% Define objective function 
objective = -(-(power(x2,2)-7*x2)+12*x1+0-(0));

% Define constraints 
F = set([]);
F=[F,-2*power(x1,4)-x2==-2];
F=[F,0<=x1<=2];
F=[F,0<=x2<=3];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective),-16.73889315852095 , 1e-2);