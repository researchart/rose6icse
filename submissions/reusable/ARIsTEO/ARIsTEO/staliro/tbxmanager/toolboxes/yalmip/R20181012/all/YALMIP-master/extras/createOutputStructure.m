% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function output = createOutputStructure(Primal,Dual,Slack,problem,infostr,solverinput,solveroutput,solvertime)

% Standard interface 
output.Primal      = Primal;
output.Dual        = Dual;
output.Slack       = [];
output.problem     = problem;
output.infostr     = infostr;
output.solverinput = solverinput;
output.solveroutput= solveroutput;
output.solvertime  = solvertime;