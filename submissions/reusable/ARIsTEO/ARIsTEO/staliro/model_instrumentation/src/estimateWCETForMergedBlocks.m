% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function info = estimateWCETForMergedBlocks(infoIn)
%estimateWCETForMergedBlocks Estimate WCET for merged blocks.

try
    info = infoIn;
    
    info.mergedBlockWCETs = zeros(info.numOfMergedBlocks, 1);
    for i = 1:info.numOfMergedBlocks
        for j = info.mergedBlockIndices{i}
            switch info.blockTypeList{j}
                case {'Inport', 'Outport', 'ActionPort', 'Constant'}
                    info.mergedBlockWCETs(i) = info.mergedBlockWCETs(i) + 1;
                case {'DataStoreRead', 'DataStoreWrite'}
                    info.mergedBlockWCETs(i) = info.mergedBlockWCETs(i) + 2;
                case {'Subsystem'}
                    for k = 1:info.numOfBlocks
                        if ~isempty(find(info.ancestorsList{k} == j, 1)) % block k has our block in its ancestors list
                            switch info.blockTypeList{k}
                                case {'Inport', 'Outport', 'ActionPort', 'Constant'}
                                    info.mergedBlockWCETs(i) = info.mergedBlockWCETs(i) + 1;
                                case {'DataStoreRead', 'DataStoreWrite'}
                                    info.mergedBlockWCETs(i) = info.mergedBlockWCETs(i) + 2;
                                case {'Subsystem'}
                                    info.mergedBlockWCETs(i) = info.mergedBlockWCETs(i) + 100;
                                otherwise
                                    info.mergedBlockWCETs(i) = info.mergedBlockWCETs(i) + 10;
                            end
                        end
                    end
                otherwise
                    info.mergedBlockWCETs(i) = info.mergedBlockWCETs(i) + 10;
            end
        end
    end
catch
    error('ERROR: estimateWCETForMergedBlocks failed!');
end


end

