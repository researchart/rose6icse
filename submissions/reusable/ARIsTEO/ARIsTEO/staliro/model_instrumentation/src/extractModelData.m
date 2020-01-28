% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info, errStatus ] = extractModelData( infoIn )
%extractModelData Reads all connection data and creates related graphs

errStatus = 1;
try
    info = infoIn;
    
    errStatus = compileModel(info.modelName, info.modelInitFile);
    if errStatus == 0
        info.sampleTimeList = readCompiledSampleTimes(info.blockList);
        [ info ] = readImmediateConnections( info );
        terminateCompilation(info.modelName);
    else
        error('ERROR: extractModelData: model can not be compiled!');
    end
catch
    if errStatus == 0 % Model was compiled succesfully
        terminateCompilation(info.modelName);
    end
    error('ERROR: extractModelData failed!');
end

end

