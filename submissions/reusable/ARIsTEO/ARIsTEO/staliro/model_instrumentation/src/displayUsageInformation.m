% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function displayUsageInformation( toolName )
%displayUsageInformation Gives information on how to use the tool
fprintf('\n USAGE: %s(''modelName'',''modelInitFile'', debugMode, modelDepth, doMapping, numOfProc);\n', toolName);
fprintf('Please give model name without file extension.\n');
fprintf('Please give modelInitFile required for compiling the without file extension. Only .mat file supported\n');
fprintf('debugMode = 1,2 -> debug mode ON, debugMode = 0 -> debug mode OFF \n');
fprintf('modelDepth: search depth for model blocks, -1 for all depth\n');
fprintf('doMapping = 0,1: 1 -> Do Mapping, 0 -> Do NOT map\n');
fprintf('numOfProc: number of cpu cores for mapping and scheduling analysis\n');
fprintf('Note 1: If schedTestFile is left empty, no scheduling analysis will be done.\n');
fprintf('Note 2: Make sure you run (modify if necessary) updatePath.m script.\n');
end

