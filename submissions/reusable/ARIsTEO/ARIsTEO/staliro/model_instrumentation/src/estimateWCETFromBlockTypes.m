% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function wcet = estimateWCETFromBlockTypes(blockType)
%estimateWCETForMergedBlocks Estimate WCET for merged blocks.

try
    switch blockType
        case {'Inport', 'Outport', 'Constant'}
            wcet = 1;
        case {'ActionPort'}
            wcet = 10;
        case {'DataStoreRead', 'DataStoreWrite'}
            wcet = 50;
        case {'Lookup_n-D'}
            wcet = 1000;
        case {'Subsystem'}
            wcet = 1000;
        otherwise
            wcet = 100;
    end
catch
    error('ERROR: estimateWCETFromBlockTypes failed!');
end


end

