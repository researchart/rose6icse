% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ dataSize, lookUpTableOut ] = getSizeOfDataType( dataType, lookUpTable )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
lookUpTableOut = lookUpTable;
% Determine size of data type
try
    dataSize = sizeof(dataType);
catch
    dataSize = -1;
    
    lookUpTableIndex = length(lookUpTable(:,1));
    for i = 1:lookUpTableIndex
        if strcmp(lookUpTable{i, 1}, dataType)
            dataSize = lookUpTable{i, 2};
        end
    end
    if strcmp(dataType, 'Boolean') || strcmp(dataType, 'boolean') || strcmp(dataType, 'Action') || strcmp(dataType, 'action')
        dataSize = 8;
    end
    
    while (dataSize < 0)
        prompt = sprintf('What is the size of %s in bytes? ', dataType);
        try
            dataSize = input(prompt);
            lookUpTableIndex = lookUpTableIndex + 1;
            lookUpTableOut{lookUpTableIndex, 1} = dataType;
            lookUpTableOut{lookUpTableIndex, 2} = dataSize;
        catch
            dataSize = -1;
        end
    end
end
end

