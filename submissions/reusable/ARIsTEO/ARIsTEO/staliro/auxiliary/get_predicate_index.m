% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% get_predicate_index
% Given a predicate name it returns the predicate index in the predicate 
% structure.
%
% USAGE
% idx = get_predicate_index(str,pred)
%
% INPUTS
% str - the predicate name as a string 
% pred = the predicate structure (for fields see dp_taliro)
%
% OUTPUTS
% idx - the index in the predicate structure
%       If the predicate is not found, then idx = [];
%
% See also: dp_taliro, fw_taliro

% (C) Georgios Fainekos - ASU
% Last update: 2012.09.15

function idx = get_predicate_index(str,pred)

idx = [];
for i = 1:length(pred)
    if strcmp(str,pred(i).str)
        idx = i;
        return
    end
end

end
