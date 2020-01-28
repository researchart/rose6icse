% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ index, alreadyExisting, ports ] = addPortData( portsIn, block, type, portNo, edgeCost, dataType, dataSize, width, dimensions, position )
%addPortData Searches for a port with given 'block', 'type' and 'portNo'
%using getIndexOfPort.
%Then adds other supplied fields.

try
    [ index, alreadyExisting, ports ] = getIndexOfPort( portsIn, block, type, portNo);
    if nargin > 4
        ports(index).edgeCost = edgeCost;
    end
    if nargin > 5
        ports(index).dataType = dataType;
    end
    if nargin > 6
         ports(index).dataSize = dataSize;
    end
    if nargin > 7
        ports(index).width = width;
    end
    if nargin > 8
        ports(index).dimensions = dimensions;
    end
    if nargin > 9
        ports(index).position = position;
    end
    
    ports(index).mapping = 0; % no mapping set
catch
    error('ERROR: addPortData failed!');
end
end

