% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [cin, ceq] = feasability_constr(x, ha, n,locHis, tt, B)

x0 = x(1:n); % initial continuous state of system, in X0
% [tau1,..,tauN, t* = tau_{N+1}]
% note teh index shift: tau(1) is when we enter loc1, tau(i) is when we
% enter loci.
tau = x(n+1:end-1);
v = x(end); % slack variable
    
N = length(tau)-1;

cin=[];
% duplicate last entry: this allows us to treat the unsafe set as one last
% location whose guard we're trying to enter
locHis = [locHis locHis(end)];

% x0 \in X0
C0 = [eye(n); -eye(n)];
g0 = [ha.init(:,2); -ha.init(:,1)];
cin = C0*x0-g0;
% ith constraint = entering ith location through Gammai
% =  s_{gamma i-1}(tau_i-tau_{i-1}) \in Gamma_i
I = eye(n);
cloc = locHis(1);    % leaving cloc...
nloc = locHis(2);    % and entering nloc through Gamma1
A0 = ha.loc(cloc).A;
b0 = ha.loc(cloc).b;
M0 = expm(A0*tau(1));
c0 = A0\((expm(A0*tau(1))-I)*b0);
c0p = c0;
% to avoid indexing horror, put first iteration here
C1 = ha.guards(cloc, nloc).A;
g1 = ha.guards(cloc, nloc).b;
cin = [cin; C1*(M0*x0+c0p)-g1-v*ones(length(g1),1)];
prevM = M0;
prevcp = c0p;
% display(['x0 = ',num2str(x0')])
% display(['t = ',num2str(tau')])
% display(['X0: ',num2str(cin(end))])

for i=2:N
    cloc = locHis(i);    % leaving cloc...
    nloc = locHis(i+1);  % and entering nloc through Gammai
    C_nloc = ha.guards(cloc, nloc).A;
    g_nloc = ha.guards(cloc, nloc).b;
    A_cloc = ha.loc(cloc).A;
    b_cloc = ha.loc(cloc).b;
    multiplier = expm(A_cloc*(tau(i)-tau(i-1)));
    c_cloc = A_cloc\((multiplier-I)*b_cloc);  
    M_cloc = multiplier*prevM;
    c_cloc_p = multiplier*prevcp + c_cloc;
    cin = [cin; C_nloc*(M_cloc*x0+c_cloc_p)-g_nloc-v*ones(length(g_nloc),1)];
    prevM = M_cloc;
    prevcp = c_cloc_p;    
%     display([num2str(cloc),'-',num2str(nloc),': ',num2str(cin(end))])
end
% i=N+1 means we are in the location of B, making a 'transition' into B (or
% Pc, or B^U, ...etc)
i=N+1;
cloc = locHis(i);    % leaving cloc...
nloc = locHis(i+1);  % and entering nloc through Gammai
C_nloc = B.A;
g_nloc = B.b;
A_cloc = ha.loc(cloc).A;
b_cloc = ha.loc(cloc).b;
multiplier = expm(A_cloc*(tau(i)-tau(i-1)));
c_cloc = A_cloc\((multiplier-I)*b_cloc);
M_cloc = multiplier*prevM;
c_cloc_p = multiplier*prevcp + c_cloc;
cin = [cin; C_nloc*(M_cloc*x0+c_cloc_p)-g_nloc-v*ones(length(g_nloc),1)];
% display(['B: ',num2str(cin(end-length(g_nloc)+1:end)')])

% timing constraint: 0 <= tau1<=...<=tauN<=t*<=tt
T = [-1 zeros(1,N)
    eye(N) [zeros(N-1,1); -1]
    zeros(1,N)  1];
for i=2:N+1
    T(i,i) = -1;
end
cin=[cin
    T*tau-[zeros(N+1,1);tt]-v*ones(N+2,1)];

ceq=[];