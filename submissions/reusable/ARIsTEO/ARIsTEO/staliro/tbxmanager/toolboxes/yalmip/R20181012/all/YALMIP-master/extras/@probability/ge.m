% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function ChanceConstraint = gt(P,level)
if isa(P,'double') & isa(level,'probability')
    error('Currently only supports p(F) >= level')
end
if level < 0 | level > 1
    error('The confidence level must be between 0 and 1');
end
ChanceConstraint = chanceconstraint(lmi(P.Constraint),level);

