% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [prob, info] = formulateMILP( infoIn )

info = infoIn;

[intcon, lb, ub, f, info] = initializeX(info);

try
    [Aeq, beq] = addRule1(info);
catch
    fprintf('Error in adding Rule #1\n');
end
try
    [Anew, bnew, info] = addRule7(info);
    Aeq = [Aeq; Anew];
    beq = [beq; bnew];
catch
    fprintf('Error in adding Rule #7\n');
end
try
    [Anew, bnew, info] = addRule9(info);
    Aeq = [Aeq; Anew];
    beq = [beq; bnew];
catch
    fprintf('Error in adding Rule #9\n');
end

% [A, b] = addRule2(deadline, wcet, milpConnMatrix);
% [Anew, bnew] = addRule3(wcet, maxVal, milpConnMatrix, txCostMatrix, rxCostMatrix);
try
    [A, b] = addRule6(info);
catch
    fprintf('Error in adding Rule #6\n');
end
try
    [Anew, bnew] = addRule3(info);
    A = [A; Anew];
    b = [b; bnew];
catch
    fprintf('Error in adding Rule #3\n');
end
try
    [Anew, bnew] = addRule4(info);
    A = [A; Anew];
    b = [b; bnew];
catch
    fprintf('Error in adding Rule #4\n');
end
try
    [Anew, bnew] = addRule5(info);
    A = [A; Anew];
    b = [b; bnew];
catch
    fprintf('Error in adding Rule #5\n');
end
if info.optimize == 1
    try
        [Anew, bnew] = addRule8(info);
        A = [A; Anew];
        b = [b; bnew];
    catch
        fprintf('Error in adding Rule #8\n');
    end
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
prob.options = optimoptions('intlinprog', 'MaxTime', 10000, 'CutGenMaxIter', 50, 'HeuristicsMaxNodes', 5000, 'RootLPMaxIter', 1e7, 'LPMaxIter', 1e7, 'TolInteger', 1e-6);
prob.solver = 'intlinprog';
end

