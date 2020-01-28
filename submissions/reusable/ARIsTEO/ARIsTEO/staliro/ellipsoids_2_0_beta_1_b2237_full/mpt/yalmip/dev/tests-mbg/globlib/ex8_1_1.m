% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from ex8_1_1.gms
% Created 28-Jul-2007 19:11:42 using YALMIP R20070725

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);

% Define objective function 
objective = -(-(cos(x1)*sin(x2)-x1/(1+sqr(x2))));

% Define constraints 
F = set([]);
F=[F,-1<=x1<=2];
F=[F,-1<=x2<=1];

% Solve problem
sol = solvesdp(F,objective,sdpsettings('solver','bmibnb','allownonconvex',1));
