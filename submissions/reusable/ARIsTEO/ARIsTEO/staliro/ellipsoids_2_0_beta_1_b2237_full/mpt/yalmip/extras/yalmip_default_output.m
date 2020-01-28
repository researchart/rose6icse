% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function output = yalmip_default_output;
output.Primal    = [];
output.Dual      = [];
output.Slack     = [];
output.problem = 0;
output.infostr = yalmiperror(0);
output.solverinput  = [];
output.solveroutput = [];
output.solvertime   = 0;