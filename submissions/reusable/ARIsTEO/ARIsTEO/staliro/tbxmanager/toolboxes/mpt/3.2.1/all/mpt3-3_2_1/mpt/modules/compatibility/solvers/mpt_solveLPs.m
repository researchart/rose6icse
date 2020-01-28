% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [xopt,fval,lambda,exitflag,how]=mpt_solveLPs(f,A,B,Aeq,Beq,x0,lpsolver)

[xopt,fval,lambda,exitflag,how]=mpt_solveLP(f,A,B,Aeq,Beq);
