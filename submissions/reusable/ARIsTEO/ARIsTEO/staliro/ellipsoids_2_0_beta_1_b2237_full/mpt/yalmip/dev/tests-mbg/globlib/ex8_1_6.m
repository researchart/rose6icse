% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Model generated from ex8_1_6.gms
% Created 18-Mar-2008 12:58:40 using YALMIP R20070810

% Setup a clean YALMIP environment 
yalmip('clear') 

% Define all variables 
x1 = sdpvar(1);
x2 = sdpvar(1);

% Define objective function 
objective = -(-(-1/(0.1+sqr(x1-4)+sqr(x2-4))-1/(0.2+sqr(x1-1)+sqr(x2-1))-1/(0.2+sqr(x1-8)+sqr(x2-8)))+0-(0));

% Define constraints 
F = set([]);
% Solve problem
sol = solvesdp([F,-100<[x1 x2]<100],objective,sdpsettings('solver','bmibnb','allownonconvex',1));
mbg_assertfalse(sol.problem)
mbg_asserttolequal(double(objective), -10.086 , 1e-2);