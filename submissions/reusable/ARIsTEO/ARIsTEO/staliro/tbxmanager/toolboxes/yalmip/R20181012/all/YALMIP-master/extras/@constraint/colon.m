% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = colon(F,tag)
% COLON Overloaded

% Allows the syntax (x>=0):Tag in order to give names/descriptions to
% constraints

for i = 1:length(F.ConstraintID)
    F.tag{i} = tag;
end
	