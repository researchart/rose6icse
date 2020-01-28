% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function setMappingOfBlock( block, mappedCore )
%setMappingOfBlock Sets userData and color per mapping

try
    userData = get_param(block, 'UserData');
    userData.mapping = mappedCore;
    set_param(block, 'UserData', userData);
    %for saving User Data into model file
    set_param(block, 'UserDataPersistent', 'on');
    [~, colorStr] = getMappingColor(userData.mapping);
    set_param(block, 'ForegroundColor', colorStr);
catch
    if isnumeric(block)
        fprintf('ERROR : Could not set the mapping of block %f\n', block);
    else
        fprintf('ERROR : Could not set the mapping of block %s\n', block);
    end
end
end

