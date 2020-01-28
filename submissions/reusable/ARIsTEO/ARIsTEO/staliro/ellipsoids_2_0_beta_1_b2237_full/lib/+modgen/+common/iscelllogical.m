% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function isOk=iscelllogical(value)
if iscell(value)
    if isempty(value)
        isOk=false;
    else
        isOk=all(reshape(cellfun('islogical',value),[],1));
    end
else
    isOk=false;
end