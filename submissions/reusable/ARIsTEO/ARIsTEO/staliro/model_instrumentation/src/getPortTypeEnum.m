% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ portTypeEnum ] = getPortTypeEnum( portType )
%getPortTypeEnum Returns port type enumerated value for representing in
%ports graph. DO NOT USE FOR OUTPUT PORTS

try
    switch portType
        case 'enable'
            portTypeEnum = 2;
        case 'trigger'
            portTypeEnum = 2;
        case 'state'
            portTypeEnum = 3;
        case 'ifaction'
            portTypeEnum = 2;
        otherwise
            if str2double(portType) > 0
                portTypeEnum = 1;
            else
                portTypeEnum = 3;
            end
    end
catch
    portTypeEnum = -1;
    fprintf('Error in getting port type\n');
    fprintf('%s\n', portType);
end
end

