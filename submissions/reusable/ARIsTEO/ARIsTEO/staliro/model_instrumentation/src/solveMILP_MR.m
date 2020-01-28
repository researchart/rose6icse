% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [solverOutputs, assignmentArr, info] = solveMILP_MR(infoIn, solver, isReport)
%solveMILP_MR - Formulates the MILP problem and solves using MILP solver
% * return value x is the optimized vector for variables.
% * return value assignmentArr is an array where each element gives the core
% to which the corresponding block is mapped
% - numOfCores: number of cores
% - inConnMatrix: connection matrix where rows (i) are source blocks, columns (j) are
% destination blocks and value at (i,j) is the number of bytes from i to j.
% - txCostMatrix: Similar to inConnMatrix but value at (i,j) is wcet at
% transmitter side for communicating from i to j.
% - rxCostMatrix: Similar to inConnMatrix but value at (i,j) is wcet at
% receiver side for communicating from i to j.
% - deadline: Overall aimed deadline for finishing execution of all blocks
% - wcet: Array of worst case execution times. (wcet(i) : wcet of block i)
% - maxVal: A large value like 1000000 for eliminating rule checks that are
% irrelevant.
% - semSize: Size of a semaphore structure in bytes
% - alignmentSize: Needed byte alignment size. (Typically 4)
% - totalSharedMem: Total available shared memory in bytes
% - blockList: Cell array of block names. (blocklist{i}: name of block(i))
% blockList parameter which is used to give names of blocks in the report
% is optional.

%% Prepare MILP formulation required data
try
    info = infoIn;

    if nargin > 1
        info.solver = solver;
    else
        info.solver = 'intlinprog';
    end
    if nargin < 3
        isReport = 0;
    end
    
    info.startOfB = 0;
    info.startOfD = 0;
    info.startOfS = 0;
    info.lengthOfX = 0;
    info.forceOrder = 0;
    info.B = -1 * ones(info.numOfMainBlocks, info.numOfCores);
    info.mergedList = cell(info.numOfMainBlocks, 1);
    info.connMatrix = info.mainBlocksGraph;
    for i = 1:info.numOfMainBlocks
        info.mergedList{i} = i;
    end
    
    if info.debugMode > 0
        save('solveMILPEnter.mat');
    end
    
    %[solveMilpGlobal.connMatrix, cyclesRemoved] =
    %removeCycles(solveMilpGlobal.connMatrix, solveMilpGlobal.debugMode, solveMilpGlobal.txCostMatrix, solveMilpGlobal.rxCostMatrix);
    %info.dependencyMatrix = findDependencies(info.connMatrix);
    %if info.doMerge > 0
    %    info = doAllMergeMILP(info);
    %end
    info = generateExecutionRanges_mr(info);
    if info.debugMode > 0
        save('solveMILPMerged.mat');
    end
catch
    error('ERROR: solveMILP failed in preparing MILP formulation required data.');
end

%% Formulate MILP problem
try
    [prob, info] = formulateMILP_MR(info);
    if info.debugMode > 0
        save('solveMILPProb.mat');
    end
    if info.debugMode > 0
        info.rule = printFormulation_mr(prob, info);
     %   fprintf('Max time = %g, deadline = %g\n', sum(info.wcet(1:end)), info.deadline);
    end
catch
    error('ERROR: solveMILP failed in formulating MILP problem.');
end

%% Solve MILP Problem
try
    if isReport == 1
        startTime = clock
    end
    success = 0;
    try
        if strcmp(info.solver, 'intlinprog') == 1
            [x,fval,exitflag,output] = intlinprog(prob);
            if exitflag > 0
                success = 1;
            end
        else %Opti Toolbox
            milpopts = optiset('solver', 'scip');
            milpopts.maxtime = 18000;
            milpopts.tolrfun = milpopts.tolrfun * 10;
            milpopts.maxnodes = 1000000;
            milpopts.maxiter = 1000000;
            info.optiProblem = opti('f', prob.f, 'ineq', prob.Aineq, prob.bineq, ...
                'eq', prob.Aeq, prob.beq, 'bounds', prob.lb, prob.ub, ...
                'xtype', prob.intcon, 'Solver', info.solver, 'options',milpopts);
            [x,fval,exitflag,output] = solve(info.optiProblem);
            if exitflag >= 0
                success = 1;
            end
        end
        solverOutputs.x = x;
        solverOutputs.fval = fval;
        solverOutputs.exitflag = exitflag;
        solverOutputs.output = output;
    catch
        fprintf('ERROR : Solver returned error !!!\n');
        solverOutputs.x = 0;
        solverOutputs.fval = 0;
        solverOutputs.exitflag = -1;
        solverOutputs.output = [];
    end
    if info.debugMode > 0
        save('solveMILPProb2.mat');
    end
catch
    error('ERROR: solveMILP failed in solving MILP problem.');
end
%% Report outputs of MILP solver
try
    if isReport == 1
        endTime = clock;
        fprintf('########## SUMMARY ##########\n');
        startTime
        endTime
        elapsedTime = etime(endTime, startTime)
    end
    %Uncomment following block only after doing necessary updates for multi
    %rate case
    if success == 1
        assignmentArr = getCoreMapping(x, info);
        if ~isempty(info.blockList) % blockList is supplied
            %giveBlockNames = 1;
            % ReadX and plotX should be modified to read block names taking
            % mergedList into account. giveBlockNames is disabled until this is
            % fixed.
            giveBlockNames = 0;
        else % blockList is not supplied
            giveBlockNames = 0;
        end
        if nargin > 3
            if isReport == 1
                readX(x, giveBlockNames, info);
                plotX(x, assignmentArr, giveBlockNames, info);
            end
        end
    else
        fprintf('Solution could not be found (%s exit code: %d)\n', info.solver, exitflag);
        assignmentArr = zeros(1, info.numOfBlocks);
    end
    
    if info.debugMode > 0
        save('solveMILPExit.mat');
    end
catch ME
    msgString = getReport(ME);
    error('ERROR: solveMILP failed in reporting outputs. : %s', msgString);
end
end

