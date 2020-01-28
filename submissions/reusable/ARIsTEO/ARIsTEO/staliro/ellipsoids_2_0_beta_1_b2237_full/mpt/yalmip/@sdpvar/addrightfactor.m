% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function X = addrightfactor(X,R)
if ~isempty(X.midfactors)
    for i = 1:length(X.midfactors)
        X.rightfactors{i} = X.rightfactors{i}*R;
    end
end
X = cleandoublefactors(X);
X = flushmidfactors(X);