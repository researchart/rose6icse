% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = extractConstraints(F,type)

if ~isempty(F)
    if isa(type,'cell')
        answer = is(F,type{1});
        for i = 2:length(type)
            answer = answer | is(F,type{i});
        end
        F = F(find(answer));
    else
        F = F(find(is(F,type)));
    end
end