% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = addleftfactor(X,L)
if ~isempty(X.midfactors)
    for i = 1:length(X.midfactors)
        try
            X.leftfactors{i} = L*X.leftfactors{i};
        catch
            1
        end
    end
end
X = cleandoublefactors(X);
X = flushmidfactors(X);
