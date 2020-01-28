% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function AConstraint = assignschur(AConstraint,thecompiler,varargin)
AConstraint = flatten(AConstraint);
AConstraint.clauses{1}.schurfun  = thecompiler;
AConstraint.clauses{1}.schurdata = varargin;