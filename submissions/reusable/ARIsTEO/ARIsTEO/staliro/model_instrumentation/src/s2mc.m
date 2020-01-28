% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function  [info] = s2mc(modelName, modelInitFile, debugMode, modelDepth, doMapping, numOfProc)
%model2multicore - USAGE: model2multicore('modelName', debugMode, modelDepth, doMapping, numOfProc)
%modelName: without file extension.
%debugMode = 1,2 -> debug mode ON, debugMode = 0 -> debug mode OFF.
%modelDepth: search depth for model blocks, -1 for all depth.
%doMapping = 0,1: 1 -> Do Mapping, 0 -> Do NOT map.
%numOfProc: number of cpu cores for mapping and scheduling analysis.
%schedTestFile: Output file name for using with schedmcore scheduling analysis
%Note 1: If schedTestFile is left empty, no scheduling analysis will be done.
%Note 2: Cheddar executable location can be defined in cheddarLocation before running this tool.
%Note 3: !!!! Make sure you run (modify if necessary) updatePath.m script for updating path as necessary
%!!!!! pathUpdate.m is in one upper level directory. !!!!!

toolName = 's2mc';
%% Check input arguments
fprintf('Starting...\n');
if nargin > 6
    displayUsageInformation(toolName);
    error('Too many inputs!');
elseif nargin < 1
    displayUsageInformation(toolName);
    error('No inputs given');
else %between 1 and 5
    % Check if modelName is not empty string
    if isempty(modelName)
        displayUsageInformation(toolName);
        error('\n ERROR: Please pass Simulink model name as a parameter without file extension.\n');
    elseif ~ischar(modelName)
        displayUsageInformation('s2mc');
        error('\n ERROR: Please pass Simulink model name as a parameter without file extension.\n');
    end
    if nargin > 1
        if ~ischar(modelInitFile)
            error('ERROR in modelInitFile input. It must be character without file extension\n.');
        end
    else
        modelInitFile = '';
        fprintf('! modelInitFile not given, Assuming that init file not required for compiling model.\n');
    end
    if nargin > 2 %at least debugMode is given
        if ~isnumeric(debugMode)
            displayUsageInformation(toolName);
            error('ERROR in debugMode input. It must be numeric.');
        end
    else
        debugMode = 0;
        fprintf('! debugMode not given. Taking as 0 (OFF).\n');
    end
    if nargin > 3 %at least modelDepth is given
        if ~isnumeric(modelDepth)
            displayUsageInformation(toolName);
            error('ERROR in modelDepth input. It must be numeric.');
        end
    else
        fprintf('! modelDepth not given. Taking as -1 (all depth).\n');
        modelDepth = -1;
    end
    if nargin > 4 %at least doMapping is given
        if ~isnumeric(doMapping)
            displayUsageInformation(toolName);
            error('ERROR in doMapping input. It must be numeric.');
        end
    else
        fprintf('! doMapping not given. Taking as 0 (Do not find mapping).\n');
        doMapping = 0;
    end
    if nargin > 5 %at least numOfProc is given
        if ~isnumeric(numOfProc)
            displayUsageInformation(toolName);
            error('ERROR in numOfProc input. It must be numeric.');
        end
    else
        fprintf('! numOfProc not given. Taking as 2 cores.\n');
        numOfProc = 2;
    end
end

%% Initialize data structures.
info = [];
%User inputs
info.modelName = modelName;
info.modelInitFile = modelInitFile;
info.isDebugMode = debugMode;
info.debugMode = debugMode;
info.doMapping = doMapping;
info.numOfProc = numOfProc;
info.numOfCores = numOfProc;
if modelDepth == -1
    info.desiredDepth = 100;
else
    info.desiredDepth = modelDepth;
end

info.modelSearchDepth = -1; % -1 for searching all blocks. desiredDepth is not used for search.
info.simpleConnMatrix = [];
info.cpuAssignmentArray = [];
info.mergedList = [];
info.lookUpTable = cell(0, 2);

%% Read model information
try
    [info.blockList, info.wasModelOpenedAlready] = readModelBlockInformation(info.modelName, info.modelSearchDepth);
    if (info.isDebugMode > 0)
        fprintf('Model ''%s'' is read. Name: ''%s'' total %d blocks \n', info.modelName, get_param(info.blockList{1}, 'Name'), length(info.blockList));
    end
catch
    displayUsageInformation(toolName);
    error('ERROR: Model ''%s'' could not be loaded.\nBe sure to give model name as a parameter without file extension.\n', info.modelName);
end
info.numOfBlocks = numel(info.blockList);
if info.numOfBlocks < 1
    error('ERROR in model or model has no blocks!');
end

info.handles = readBlockHandles(info.blockList);
info.parentHandles = readParentHandles(info.blockList);
info.parentIndices = getParentIndices(info.parentHandles, info.handles);
info.ancestorsList = getAncestors(info.parentIndices);
info.blockDepths = getBlockDepths(info.ancestorsList);
info.blockTypeList = readBlockTypes(info.blockList);
info = getNonVirtualSubsystems(info);
[ info, errStatus ] = extractModelData( info );
info.blockSpecialties = getBlockSpecialties(info);
info = createFullDataDependencyGraph(info);
info = determineMainBlocks(info);
info = reduceFullDataDependencyGraph(info);
info = createMainBlocksGraph(info);
if (info.wasModelOpenedAlready == 0)
    close_system(info.modelName, 0);
end

end


