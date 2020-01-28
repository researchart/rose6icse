% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function dependencyMatrix = findDependencies(connMatrix)

try
    dependencyMatrix = zeros(length(connMatrix));
    accessMatrix = connMatrix;
    stepCount = 1;
    while ~isempty(find(accessMatrix, 1)) && stepCount < length(connMatrix)
        for m = 1:length(connMatrix)
            dest = find(accessMatrix(m, 1:end));
            for d = 1:length(dest)
                dependencyMatrix(m, dest(d)) = 1;
            end
        end
        
        stepCount = stepCount + 1;
        accessMatrix = accessMatrix * connMatrix;
    end
catch
    error('ERROR: findDependencies failed!');
end
end
