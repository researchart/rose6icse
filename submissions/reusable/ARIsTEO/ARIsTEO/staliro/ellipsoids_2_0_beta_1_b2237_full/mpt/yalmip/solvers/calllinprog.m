% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function output = calllinprog(interfacedata)

% Author Johan L�fberg 
% $Id: calllinprog.m,v 1.6 2005-05-07 13:53:20 joloef Exp $

% Standard input interface
options = interfacedata.options;
F_struc = interfacedata.F_struc;
c       = interfacedata.c;
K       = interfacedata.K;
Q       = interfacedata.Q;
lb      = interfacedata.lb;
ub      = interfacedata.ub;

showprogress('Calling LINPROG',options.showprogress);

if isempty(F_struc)
    Aeq = [];
    beq = [];
    A = [];
    b = [];
else
    Aeq = -F_struc(1:1:K.f,2:end);
    beq = F_struc(1:1:K.f,1);        
    A =-F_struc(K.f+1:end,2:end);
    b = F_struc(K.f+1:end,1);   
end
solvertime = clock; 

switch options.verbose
case 0
    options.linprog.Display = 'off';
case 1
    options.linprog.Display = 'final';
otherwise
    options.linprog.Display = 'iter';
end

if isfield(options.linprog,'LargeScale')
    if ~isequal(options.linprog.LargeScale,'on')
        Q = full(Q);
        c = full(c);
        A = full(A);
        b = full(b);
        Aeq = full(Aeq);
        beq = full(beq);
    end
end

if options.savedebug
    ops = options.linprog;
    save linprogdebug c A b Aeq beq lb ub ops
end

[x,fmin,flag,output,lambda] = linprog(c, A, b, Aeq, beq, lb, ub, [],options.linprog);
solvertime = etime(clock,solvertime);
problem = 0;

% Internal format for duals
D_struc = [lambda.eqlin;lambda.ineqlin];

% Check, currently not exhaustive...
if flag==0
    problem = 3;
else
    if flag>0
        problem = 0;
    else
        if isempty(x)
            x = repmat(nan,length(c),1);
        end
        if any((A*x-b)>sqrt(eps)) | any( abs(Aeq*x-beq)>sqrt(eps))
            problem = 1; % Likely to be infeasible
        else
            if c'*x<-1e10 % Likely unbounded
                problem = 2;
            else          % Probably convergence issues
                problem = 5;
            end
        end
    end
end
infostr = yalmiperror(problem,'LINPROG');       

% Save all data sent to solver?
if options.savesolverinput
    solverinput.A = A;
    solverinput.b = b;
    solverinput.Aeq = Aeq;
    solverinput.beq = beq;
    solverinput.c = c;
    solverinput.options = options.linprog;
else
    solverinput = [];
end

% Save all data from the solver?
if options.savesolveroutput
    solveroutput.x = x;
    solveroutput.fmin = fmin;
    solveroutput.flag = flag;
    solveroutput.output=output;
else
    solveroutput = [];
end

% Standard interface 
output.Primal      = x(:);
output.Dual        = D_struc;
output.Slack       = [];
output.problem     = problem;
output.infostr     = infostr;
output.solverinput = solverinput;
output.solveroutput= solveroutput;
output.solvertime  = solvertime;