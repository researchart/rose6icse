% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [prob, info] = formulateMILP_MR( infoIn )

info = infoIn;

[intcon, lb, ub, f, info] = initializeX_MR(info);

try
    %addRule1_mr : Every block must be assigned to a single core.
    [Aeq, beq] = addRule1_mr(info);
catch
    fprintf('Error in adding Rule #1\n');
end
% try
%     [Anew, bnew, info] = addRule7(info);
%     Aeq = [Aeq; Anew];
%     beq = [beq; bnew];
% catch
%     fprintf('Error in adding Rule #7\n');
% end
% try
%     [Anew, bnew, info] = addRule9(info);
%     Aeq = [Aeq; Anew];
%     beq = [beq; bnew];
% catch
%     fprintf('Error in adding Rule #9\n');
% end

% [A, b] = addRule2(deadline, wcet, milpConnMatrix);
% [Anew, bnew] = addRule3(wcet, maxVal, milpConnMatrix, txCostMatrix, rxCostMatrix);
A = [];
b = [];
try
    %addRule2_mr : Start time of each block must be larger than its firing time
    % and finish time must be less than or equal to deadline
    [A, b] = addRule2_mr(info);
catch
    fprintf('Error in adding Rule #2\n');
end
try
    %addRule3_mr : If there is a dependency from i to j execution of j cannot
    [Anew, bnew] = addRule3_mr(info);
    A = [A; Anew];
    b = [b; bnew];
catch
    fprintf('Error in adding Rule #3\n');
end
try
    %addRule4_mr : If there is no dependency from i to j execution of j cannot
    [Anew, bnew] = addRule4_mr(info);
    A = [A; Anew];
    b = [b; bnew];
catch
    fprintf('Error in adding Rule #4\n');
end
try
    %addRule5_mr : Preemption constraint 1. Blocks must either finish before
    [Anew, bnew] = addRule5_mr(info);
    A = [A; Anew];
    b = [b; bnew];
catch
    fprintf('Error in adding Rule #5\n');
end

try
    %addRule6_mr : Total memory needed for semaphores and communication
    [Anew, bnew] = addRule6_mr(info);
    A = [A; Anew];
    b = [b; bnew];
catch
    fprintf('Error in adding Rule #6\n');
end

EPSILON = 0.00001;

prob.intcon = double(intcon);
prob.Aineq = A;
prob.bineq = b + EPSILON;
prob.Aeq = Aeq;
prob.beq = beq;
prob.lb = lb;
prob.ub = ub;
prob.f = f;
% following settings are used when intlinprog is used as solver. Ignored
% otherwise.
prob.options = optimoptions('intlinprog', 'MaxTime', 10000, ...
    'CutGenMaxIter', 50, 'HeuristicsMaxNodes', 5000, ...
    'RootLPMaxIter', 1e7, 'LPMaxIter', 1e7, 'TolInteger', 1e-6);
prob.solver = 'intlinprog';
end

