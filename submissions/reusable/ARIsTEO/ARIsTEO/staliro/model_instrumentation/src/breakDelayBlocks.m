% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = breakDelayBlocks(infoIn)
%breakDelayBlocks Break connection from delay blocks to their successors 
% (among main blocks).

try
    info = infoIn;
    
    for i = 1:info.numOfMainBlocks
        if numel(info.mainBlockIndices{i}) == 1
            if ~isempty(find(strcmpi(info.blockTypeList{info.mainBlockIndices{i}},...
                    {'UnitDelay', 'Delay', 'ZeroOrderHold', 'Memory'}), 1))
                dsts = find(info.mainBlocksGraph(i, :));
                for j = dsts
%                     info.mainBlocksGraph(i, j) = 0;
                    info.sameCoreBlocks(i, j) = 1;
                end
                srcs = find(info.mainBlocksGraph(:, i));
                for j = srcs
                    info.mainBlocksGraph(j, i) = 0;
                end
            end
        end
    end
catch
    error('ERROR: breakDelayBlocks failed!');
end

end

