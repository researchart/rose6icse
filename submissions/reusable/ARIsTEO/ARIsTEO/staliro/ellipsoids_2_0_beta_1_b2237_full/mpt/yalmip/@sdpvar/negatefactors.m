% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = negatefactors(X,L)
if ~isempty(X.midfactors)
    for i = 1:length(X.midfactors)
        X.leftfactors{i} = -X.leftfactors{i};
    end
end
