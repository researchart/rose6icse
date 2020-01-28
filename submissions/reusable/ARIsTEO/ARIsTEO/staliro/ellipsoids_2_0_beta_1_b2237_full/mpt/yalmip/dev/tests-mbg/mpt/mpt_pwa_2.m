% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function mpt_pwa_2

% Data
A = [2 -1;1 0];nx = 2;
B = [1;0];nu = 1;
C = [0.5 0.5];

% Prediction horizon
N = 4;

% States x(k), ..., x(k+N)
x = sdpvar(repmat(nx,1,N),repmat(1,1,N));

% Inputs u(k), ..., u(k+N) (last one not used)
u = sdpvar(repmat(nu,1,N),repmat(1,1,N));

% Binary for PWA selection
d = binvar(2,1);

% Compare
sysStruct.A{1} = A;
sysStruct.B{1} = B;
sysStruct.C{1} = C;
sysStruct.D{1} = [0];
sysStruct.A{2} = A;
sysStruct.B{2} = B*pi;
sysStruct.C{2} = C;
sysStruct.D{2} = [0];
sysStruct.guardX{1} = [-1 0];
sysStruct.guardU{1} = [0];
sysStruct.guardC{1} = [0];
sysStruct.guardX{2} = [1 0];
sysStruct.guardU{2} = [0];
sysStruct.guardC{2} = [0];

%set constraints on output
sysStruct.ymin    =   -1;
sysStruct.ymax    =    1;

%set constraints on input
sysStruct.umin    =   -1;
sysStruct.umax    =   1;

sysStruct.xmin    =   [-5;-5];
sysStruct.xmax    =   [5;5];

probStruct.norm=1;
probStruct.Q=eye(2);
probStruct.R=1;
probStruct.N=N-1;
probStruct.P_N=zeros(2);
probStruct.subopt_lev=0;
probStruct.y0bounds=1;
probStruct.Tconstraint=0;
ctrl=mpt_control(sysStruct,probStruct)

% Online
obj = 0;
F = set([]);
dd = [];
for k = N-1:-1:1
    
    bounds(x{k},-5,5);
    bounds(u{k},-1,1);
    bounds(x{k+1},-5,5);
    
    % Feasible region
    F = F + set(-1 < u{k}     < 1);
    F = F + set(-1 < C*x{k}   < 1);
    F = F + set(-5 < x{k}     < 5);
    F = F + set(-1 < C*x{k+1} < 1);
    F = F + set(-5 < x{k+1}   < 5);

    % PWA Dynamics
    d = binvar(2,1);dd = [dd;d];
    F = F + set(implies(d(1),x{k+1} == (A*x{k}+B*u{k})));
    F = F + set(implies(d(2),x{k+1} == (A*x{k}+pi*B*u{k})));
    F = F + set(implies(d(1),x{k}(1) > 0));
    F = F + set(implies(d(2),x{k}(1) < 0));
    F = F + set(sum(d) == 1); 
    obj = obj + norm([x{k};u{k}],1);
end
mpsol{k} = solvemp(F,obj,sdpsettings('debug',1),x{k},u{k});
mpsol{1} = mpt_removeOverlaps(mpsol{1})
mbg_asserttolequal(mpt_isPWAbigger(mpsol{1},ctrl),0);
