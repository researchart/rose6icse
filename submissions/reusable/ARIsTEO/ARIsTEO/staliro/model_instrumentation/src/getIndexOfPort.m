% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ index, alreadyExisting, ports ] = getIndexOfPort( portsIn, block, type, portNo )
%getIndexOfPort Searches for a port with given 'block', 'type' and 'portNo'
%fields in 'portsIn' structure array and returns index of the found entry and
%alreadyExisting output is set to 1.
%If no such port is found it is added to 'ports' and alreadyExisting output
%is set to 0.

try
    ports = portsIn;
    alreadyExisting = 0;
    index = 0;
    
    for i = 1:numel(ports)
        if ports(i).block == block && ports(i).type == type && ports(i).portNo == portNo
            index = i;
            alreadyExisting = 1;
            break;
        end
    end
    if ~alreadyExisting
        index = numel(ports) + 1;
        ports(index).block = block;
        ports(index).type = type;
        ports(index).portNo = portNo;
    end
catch
    error('ERROR: getIndexOfPort failed!');
end
end

