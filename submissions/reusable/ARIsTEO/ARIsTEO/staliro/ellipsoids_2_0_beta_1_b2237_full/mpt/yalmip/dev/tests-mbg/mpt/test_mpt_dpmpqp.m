% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function testmpdpqp

yalmip('clear')

% Model data
A = [2 -1;1 0];
B = [1;0];
C = [0.5 0.5];
nx = 2; % Number of states
nu = 1; % Number of inputs

% Prediction horizon
N = 5;
% States x(k), ..., x(k+N)
x = sdpvar(repmat(nx,1,N),repmat(1,1,N));
% Inputs u(k), ..., u(k+N) (last one not used) u = sdpvar(repmat(nu,1,N),repmat(1,1,N));
u = sdpvar(repmat(nu,1,N),repmat(1,1,N));

J{N} = 0;
F = set([]);
for k = N-1:-1:1

    % Feasible region
    F = set(-1 < u{k}     < 1);
    F = F + set(-1 < C*x{k}   < 1);
    F = F + set(-5 < x{k}     < 5);
    F = F + set(-1 < C*x{k+1} < 1);
    F = F + set(-5 < x{k+1}   < 5);
    % Dynamics
    F = F + set(x{k+1} == A*x{k}+B*u{k});
    % Cost in value iteration
    %  obj = obj + x{k}'*x{k} + u{k}'*u{k}
    obj = x{k}'*x{k} + u{k}'*u{k} + J{k+1};
    % Solve one-step problem
    [sol{k},diagnost{k},Uz{k},J{k},Optimizer{k}] = solvemp(F,obj,sdpsettings('solver','mpt'),x{k},u{k});    
end

assign(x{k},[1;0.5])
mbg_asserttrue(diagnost{1}.problem == 0);
mbg_asserttolequal(double(J{k}),3.82456140350877,1e-5);
mbg_asserttolequal(double(Optimizer{k}),-1,1e-5);

assign(x{k},[0.5;1])
mbg_asserttolequal(double(J{k}), 1.6140350,1e-5);

assign(x{k},[0;1.9])
mbg_asserttolequal(double(J{k}), 8.755,1e-5);

assign(x{k},[-0.1;-1.85])
mbg_asserttolequal(double(J{k}),  6.61825,1e-5);


