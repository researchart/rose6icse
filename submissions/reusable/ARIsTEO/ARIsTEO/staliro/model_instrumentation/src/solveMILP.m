% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [solverOutputs, assignmentArr, solveMilpGlobal] = solveMILP(problem, solver, debugMode, isReport)
%solveMILP - Formulates the MILP problem and solves using intlinprog()
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
    solveMilpGlobal.info = problem.info;
    solveMilpGlobal.isMultiRate = 0;
    solveMilpGlobal.numOfCores = problem.numberOfCores;
    solveMilpGlobal.connMatrix = problem.connMatrix;
    solveMilpGlobal.delayConn = problem.delayConn;
    solveMilpGlobal.sameCoreBlocks = problem.sameCoreBlocks;
    solveMilpGlobal.txCostMatrix = problem.txCostMatrix;
    solveMilpGlobal.rxCostMatrix = problem.rxCostMatrix;
    solveMilpGlobal.deadline = problem.deadline;
    solveMilpGlobal.wcet = problem.wcet;
    solveMilpGlobal.maxVal = problem.maxVal;
    solveMilpGlobal.semSize = problem.semSize;
    solveMilpGlobal.alignmentSize = problem.alignmentSize;
    solveMilpGlobal.totalSharedMemory = problem.totalSharedMem;
    solveMilpGlobal.doMerge = problem.doMerge;
    solveMilpGlobal.optimize = problem.optimize;
    if isfield(problem, 'blockList')
        solveMilpGlobal.blockList = problem.blockList;
    else
        solveMilpGlobal.blockList = [];
    end
    if nargin > 2
        solveMilpGlobal.debugMode = debugMode;
    else
        solveMilpGlobal.debugMode = 0;
    end
    if nargin > 1
        solveMilpGlobal.solver = solver;
    else
        solveMilpGlobal.solver = 'intlinprog';
    end
    if nargin < 4
        isReport = 0;
    end
    
    solveMilpGlobal.mergedList = cell(numOfBlocks(solveMilpGlobal), 1);
    for i = 1:numOfBlocks(solveMilpGlobal)
        solveMilpGlobal.mergedList{i} = i;
    end
    solveMilpGlobal.startOfB = 0;
    solveMilpGlobal.startOfD = 0;
    solveMilpGlobal.startOfS = 0;
    solveMilpGlobal.lengthOfX = 0;
    solveMilpGlobal.forceOrder = problem.forceOrder;
    solveMilpGlobal.B = -1 * ones(numOfBlocks(solveMilpGlobal), solveMilpGlobal.numOfCores);
    solveMilpGlobal.D = -1 * ones(numOfBlocks(solveMilpGlobal), numOfBlocks(solveMilpGlobal));
    
    if solveMilpGlobal.debugMode > 0
        save('solveMILPEnter.mat');
    end
    
    %[solveMilpGlobal.connMatrix, cyclesRemoved] =
    %removeCycles(solveMilpGlobal.connMatrix, solveMilpGlobal.debugMode, solveMilpGlobal.txCostMatrix, solveMilpGlobal.rxCostMatrix);
    solveMilpGlobal.dependencyMatrix = findDependencies(solveMilpGlobal.connMatrix);
    if solveMilpGlobal.doMerge > 0
        solveMilpGlobal = doAllMergeMILP(solveMilpGlobal);
    end
    [solveMilpGlobal.bestStart, solveMilpGlobal.bestFinish, solveMilpGlobal.worstStart, solveMilpGlobal.worstFinish ] = generateExecutionRanges(solveMilpGlobal);
    if solveMilpGlobal.debugMode > 0
        save('solveMILPMerged.mat');
    end
catch
    error('ERROR: solveMILP failed in preparing MILP formulation required data.');
end

%% Formulate MILP problem
try
    [prob, solveMilpGlobal] = formulateMILP(solveMilpGlobal);
    if solveMilpGlobal.debugMode > 0
        save('solveMILPProb.mat');
    end
    if solveMilpGlobal.debugMode > 0
        rule = printFormulation(prob, solveMilpGlobal);
        fprintf('Max time = %g, deadline = %g\n', sum(solveMilpGlobal.wcet(1:end)), solveMilpGlobal.deadline);
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
        if strcmp(solveMilpGlobal.solver, 'intlinprog') == 1
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
            optiProblem = opti('f', prob.f, 'ineq', prob.Aineq, prob.bineq, 'eq', prob.Aeq, prob.beq, 'bounds', prob.lb, prob.ub, 'xtype', prob.intcon, 'Solver', solveMilpGlobal.solver, 'options',milpopts);
            [x,fval,exitflag,output] = solve(optiProblem);
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
    if solveMilpGlobal.debugMode > 0
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
    if success == 1
        assignmentArr = getCoreMapping(x, solveMilpGlobal);
        if ~isempty(solveMilpGlobal.blockList) % blockList is supplied
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
                readX(x, giveBlockNames, solveMilpGlobal);
                plotX(x, assignmentArr, giveBlockNames, solveMilpGlobal);
            end
        end
    else
        fprintf('Solution could not be found (%s exit code: %d)\n', solveMilpGlobal.solver, exitflag);
        assignmentArr = zeros(1, numOfBlocks(solveMilpGlobal));
    end
    
    if solveMilpGlobal.debugMode > 0
        save('solveMILPExit.mat');
    end
catch
    error('ERROR: solveMILP failed in reporting outputs.');
end
end

