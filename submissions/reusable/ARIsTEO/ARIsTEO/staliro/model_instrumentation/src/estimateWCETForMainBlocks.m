% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function info = estimateWCETForMainBlocks(infoIn)
%estimateWCETForMainBlocks Estimate WCET for main blocks.

try
    info = infoIn;
    
    info.mainBlockWCETs = zeros(info.numOfMainBlocks, 1);
    for i = 1:info.numOfMainBlocks
        for j = info.mainBlockIndices{i}.'
            switch info.blockTypeList{j}
                case {'Inport', 'Outport', 'ActionPort', 'Constant'}
                    info.mainBlockWCETs(i) = info.mainBlockWCETs(i) + 1;
                case {'DataStoreRead', 'DataStoreWrite'}
                    info.mainBlockWCETs(i) = info.mainBlockWCETs(i) + 2;
                case {'Subsystem'}
                    for k = 1:info.numOfBlocks
                        if ~isempty(find(info.ancestorsList{k} == j, 1)) % block k has our block in its ancestors list
                            switch info.blockTypeList{k}
                                case {'Inport', 'Outport', 'ActionPort', 'Constant'}
                                    info.mainBlockWCETs(i) = info.mainBlockWCETs(i) + 1;
                                case {'DataStoreRead', 'DataStoreWrite'}
                                    info.mainBlockWCETs(i) = info.mainBlockWCETs(i) + 2;
                                case {'Subsystem'}
                                    % Do not add. Blocks under this will be added
                                otherwise
                                    info.mainBlockWCETs(i) = info.mainBlockWCETs(i) + 10;
                            end
                        end
                    end
                otherwise
                    info.mainBlockWCETs(i) = info.mainBlockWCETs(i) + 10;
            end
        end
    end
catch
    error('ERROR: estimateWCETForMainBlocks failed!');
end


end

