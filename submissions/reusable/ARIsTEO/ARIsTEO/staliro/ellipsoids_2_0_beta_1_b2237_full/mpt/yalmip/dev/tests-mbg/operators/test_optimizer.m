% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function test_optimizer

% Tests a regression bug that made expandmodel flawed. Basically, when
% optmizer generates the model, it constraints the parametric variables to
% pi. However, these constraints can not be used to tighten the model since
% they are completely artificial.

yalmip('clear')
sdpvar x u r
constraints = [abs(x + u - r)>=0.01];
constraints = [constraints, -5<= x <=5, -1 <= u <= 1];
constraints = [constraints, -5<= r <=5];
objective = u;
controller = optimizer(constraints, objective,sdpsettings('verbose',1),[x;r],u);
[u,sol]=controller{[2;3]}

mbg_asserttrue(sol == 0);
mbg_asserttolequal(u,-1,1e-4);
