% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ independencyGraph ] = findIndependentPairs( numOfBlocks, graphsList, blocksList )
%findIndependentPairs Find independent block pairs in each graph
%in graphsList

independencyGraph = zeros(numOfBlocks);
index = 0;
try
    for g = 1:numel(graphsList)
        dependencyGraph = findDependencies(graphsList{g});
        for i = 1:length(dependencyGraph)
            block_i = blocksList{g}(i);
            independentBlocks = find(dependencyGraph(i, :) == 0);
            for j = independentBlocks
                if dependencyGraph(j, i) == 0
                    block_j = blocksList{g}(j);
                    if block_i < block_j
                        if independencyGraph(block_i, block_j) == 0 % not entered before
                            index = index + 1;
                            independencyGraph(block_i, block_j) = index;
                        end
                    elseif block_j < block_i
                        if independencyGraph(block_j, block_i) == 0 % not entered before (same independency may be examined from i to j earlier)
                            index = index + 1;
                            independencyGraph(block_j, block_i) = index;
                        end
                    end
                end
            end
        end
    end
catch
    error('findIndependentPairs failed!');
end


end

