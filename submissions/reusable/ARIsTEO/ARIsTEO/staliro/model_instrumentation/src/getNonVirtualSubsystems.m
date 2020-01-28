% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = getNonVirtualSubsystems( infoIn )
%getNonVirtualSubsystems List of strings of block types of each block

try
    info = infoIn;
    nonVirtualSubsystems = [];
    nonVirtualSubsystemsBelowDesiredDepth = [];
    for i = 1:info.numOfBlocks
        try
            if strcmpi(info.blockTypeList{i}, 'Subsystem')
                isVirtual = get_param(info.blockList{i}, 'IsSubsystemVirtual');
                if strcmpi(isVirtual, 'off')
                    nonVirtualSubsystems = [nonVirtualSubsystems, i];
                    if info.blockDepths(i) > info.desiredDepth
                        nonVirtualSubsystemsBelowDesiredDepth = [nonVirtualSubsystemsBelowDesiredDepth, i];
                    end
                end
                %                 isAtomic = get_param(blockList{i}, 'TreatAsAtomicUnit');
                %                 if strcmpi(isAtomic, 'on')
                %                     fprintf('%d - %s is ATOMIC\n', i, blockList{i});
                %                 end
            end
        catch
            fprintf('Could not read IsSubsystemVirtual parameter of block %d: ', i);
        end
    end
    info.nonVirtualSubsystems = nonVirtualSubsystems;
    info.nonVirtualSubsystemsBelowDesiredDepth = nonVirtualSubsystemsBelowDesiredDepth;
catch
    error('ERROR: getNonVirtualSubsystems failed!');
end
end

